#!/usr/bin/env python3

# Input: 
#   Resource list of LB, subnet and OKE Cluster
# Output:
#   Check if logs are already enabled for input resources
#   If already enabled:
#   - Check if they are enabled by previous/current oke monitoring solution (using free form tags)
#
#   Returns data in JSON format; to be consumed by terraform

# Built-in libraries
import os
import re
import json
import logging
from pprint import pprint # TODO Remove later

# Third-party libraries

# TODO: Dependency on python packages installed cloud-shell
# Does cloud shell provide support for these modules as part of it's images ?
# Cloud shell will always install OCI python SDK, can we use a subset of packages already installed by OCI SDK
import requests
from requests.adapters import HTTPAdapter
from urllib3.util import Retry

from optparse import OptionParser, SUPPRESS_HELP

from oci.config import from_file
from oci.signer import Signer
from oci.auth.signers import InstancePrincipalsDelegationTokenSigner
from oci import regions

FILTER_LOG_URL_TEMPLATE = 'https://logging.{region}.oci.{second_level_domain}/20200531/actions/filterLogs?compartmentId={compartment_id}&sourceService={source_service}&sourceResource={ocid}'
SEARCH_LOG_URL_TEMPLATE = 'https://logging-cp.{region}.oci.{second_level_domain}/20200531/searchLogs?compartmentId={compartment_id}&sourceService={source_service}&sourceResource={ocid}'

RETRY_STRATEGY = Retry(
    total=2,  # maximum number of retries
    backoff_factor=2,  # exponential backoff factor
    status_forcelist=[404, 429, 500, 502, 503, 504],  # the HTTP status codes to retry on
)

# create an HTTP adapter with the retry strategy and mount it to the session
adapter = HTTPAdapter(max_retries=RETRY_STRATEGY)

# create a new session object
session = requests.Session()
session.mount("http://", adapter)
session.mount("https://", adapter)

def parse_command_line_arguments():
    parser = OptionParser()
    parser.add_option('-r', dest = 'oci_region', type = 'string', help = 'OCI region')
    parser.add_option('-d', dest = 'oci_domain', type = 'string', default='None', help = 'OCI domain')
    # when passed, config based authentication is used | only meant for dev testing
    # In production we always use InstancePrincipal based authentication
    # 'OCI configuration file for Config based authentication'
    parser.add_option('-c', dest = 'oci_config', type = 'string', default='None', help = SUPPRESS_HELP)
    # 'OCI configuration profile for Config based authentication' 
    parser.add_option('-p', dest = 'oci_profile', type = 'string', default='DEFAULT', help = SUPPRESS_HELP)
    parser.add_option('-s', dest = 'subnet_list', type = 'string', help = 'List of subnets')
    parser.add_option('-l', dest = 'load_balancer_list', type = 'string', help = 'List of load balancers')
    parser.add_option('-k', dest = 'cluster_details', type = 'string', help = 'List of K8 clusters')
    parser.add_option('-t', dest = 'source_tag', type = 'string', help = 'Name of stack invoking this script')
    
    (options, args) = parser.parse_args()

    if not options.oci_region:
        parser.error("The -r option is required.")
    if not options.subnet_list:
        parser.error("The -s option is required.")
    if not options.load_balancer_list:
        parser.error("The -l option is required.")
    if not options.cluster_details:
        parser.error("The -c option is required.")
    if not options.source_tag:
        parser.error("The -t option is required.")

    return (options, args)

# Falls back to "oraclecloud.com" in case region is not defined in SDK
# User is expected to provide domain when SDK support is not expected (In case of new regions/realms)
def set_second_level_domain(region, domain):
    global SECOND_LEVEL_DOMAIN
    if domain != "None":
        match = re.search(r'\.oci\.([\S]+)$', domain)
        SECOND_LEVEL_DOMAIN = match.group(1)
    else:
        realm = regions.get_realm_from_region(region)
        SECOND_LEVEL_DOMAIN = regions.REALMS[realm]

def prepare_signer(oci_region, oci_config = None, oci_profile = None):
    # 'InstancePrincipal' for OCI RMS Stack
    if oci_config == None or oci_config == 'None':
        try:
            obo_token = os.environ.get('OCI_obo_token')
            federation_url = "https://auth.{region}.oci.{second_level_domain}/v1/x509".format(
                region = oci_region, second_level_domain = SECOND_LEVEL_DOMAIN)
            instance_principal_signer = InstancePrincipalsDelegationTokenSigner(
                delegation_token=obo_token, federation_endpoint = federation_url)
        except Exception as e:
            logging.exception("Unable to prepare signer using OBO token. Exception: %s.", str(e))
            exit(1)
        return instance_principal_signer
    else:
        # Config based authentication is only used during development
        # Production always uses InstancePrincipal authentication via OBO token
        # as this script is expected to run on cloud-shell VMs of RMS service
        try:
            config = from_file(file_location = oci_config, profile_name = oci_profile)
            config_auth_signer = Signer(
                tenancy=config['tenancy'],
                user=config['user'],
                fingerprint=config['fingerprint'],
                private_key_file_location=config['key_file'],
                pass_phrase=config['pass_phrase']
            )
        except Exception as e:
            logging.exception("Unable to prepare signer using config file. Exception: %s.", str(e))
            exit(1)
        return config_auth_signer


def client_request(endpoint_url, method_type, signer):
    if method_type == 'POST':
        response = session.post(endpoint_url, auth=signer)
    elif method_type == 'GET':
        response = session.get(endpoint_url, auth=signer)
    else:
        print('Unsupported method type')

    response.raise_for_status()
    return json.loads(response.text)


# TODO
# may be we can add a time created filter from resource 
# 'timeCreated': '2025-01-02T06:59:28.974Z' 
# in order to avoid adding entires from previous stack apply jobs

def prepare_entry(resource, service, log_type, is_log_enabled, managed_by_stack, enabled_log_details = None):
    log_entry = {
        'name': resource['name'],
        'ocid': resource['ocid'],
        'service': service,
        'compartment_id': resource['compartment_id'],
        'log_type': log_type,
        'is_log_enabled': is_log_enabled,
        'managed_by_stack': managed_by_stack
    }
    if enabled_log_details != None:
        log_entry['log_group_id'] = enabled_log_details['log_group_id']
        log_entry['id'] = enabled_log_details['id']
    return log_entry

# Checks if free form tag (source_tag) is present
def contains_tag(source_tag, freeform_tags):
    tag_key = "managedBy"

    if tag_key not in freeform_tags:
        return False

    if source_tag.strip() == freeform_tags[tag_key].strip():
        return True

    return False

def search_log_category(category, response):
    if response is None:
        return False
    
    for item in response:
        if item['configuration']['source']['category'] == category:
            return item
    
    return False

def prepare_logging_log_entries(resource, service, categories_list, current_logs_data, source_tag):
    logging_log_data = []
    for category in categories_list:
        is_log_enabled = False
        managed_by_stack = True
        log_details = None
        log_metadata = search_log_category(category, current_logs_data)
        if log_metadata:
            freeform_tags = log_metadata['freeformTags']
            managed_by_stack = contains_tag(source_tag, freeform_tags)
            is_log_enabled = log_metadata['isEnabled']
            if is_log_enabled:
                log_details = {
                    'log_group_id': log_metadata['logGroupId'],
                    'id': log_metadata['id']
                }
        entry = prepare_entry(resource = resource,
                              service = service,
                              log_type = category,
                              is_log_enabled = is_log_enabled, 
                              managed_by_stack = managed_by_stack,
                              enabled_log_details = log_details
                              )
        logging_log_data.append(entry)
    return logging_log_data

def main():
    logging.info('Initiating service log detail collection for passed resources.')

    (options, args) = parse_command_line_arguments()

    logging.debug('Command line arguments parsed.')

    set_second_level_domain(options.oci_region, options.oci_domain)

    signer = prepare_signer(options.oci_region, options.oci_config, options.oci_profile)
    logging.debug('OCI signer prepared.')

    output = []

    processed_subnets = []
    processed_load_balancers = []
    processed_clusters = []

    # A unique tag which is present on all resources (logging_log) created by the stack triggering this python job
    source_tag = options.source_tag

    # Parse the list of resources received from command line argument
    try:
        subnet_list = json.loads(options.subnet_list.replace("\\", ""))
        load_balancer_list = json.loads(options.load_balancer_list.replace("\\", ""))
        cluster_details = json.loads(options.cluster_details.replace("\\", ""))
    except Exception as e:
        logging.exception("Unable to parse resource list provided via argument (JSON expected). Exception: %s.", str(e))
        exit(1)

    # Process subnet list
    for subnet in subnet_list:
        endpoint_url = FILTER_LOG_URL_TEMPLATE.format(region = options.oci_region, 
                                                      second_level_domain = SECOND_LEVEL_DOMAIN, 
                                                      compartment_id = subnet['compartment_id'], 
                                                      source_service = 'flowlogs', 
                                                      ocid = subnet['ocid'])
        try:
            logging.debug("'Filter Log' API request to fetch log details for subnet '%s'", subnet['ocid'])
            parsed_response = client_request(endpoint_url, 'POST', signer)
        except Exception as e:
            logging.exception("'Filter Log' API request failed while fetching subnet log details. Exception: %s.", str(e))
            exit(1)

        subnet_logs_expected_to_be_enabled = ['all']

        entires = prepare_logging_log_entries(subnet,
                                              "flowlogs",
                                              subnet_logs_expected_to_be_enabled,
                                              parsed_response,
                                              source_tag)
        
        output += entires

    # Process load balancer list
    for load_balancer in load_balancer_list:
        endpoint_url = SEARCH_LOG_URL_TEMPLATE.format(region = options.oci_region,
                                                    second_level_domain = SECOND_LEVEL_DOMAIN,
                                                    compartment_id = load_balancer['compartment_id'], 
                                                    source_service = "loadbalancer",
                                                    ocid = load_balancer['ocid']
                                                    )
        try:
            logging.debug("'Search Log' API request to fetch log details for loadbalancer '%s'", load_balancer['ocid'])
            parsed_response = client_request(endpoint_url, 'GET', signer)
            # pprint(parsed_response)
        except Exception as e:
            logging.exception("'Search Log' API request failed while fetching load balancer log details. Exception: %s.", str(e))
            exit(1)

        lb_logs_expected_to_be_enabled = ['access', 'error']

        entires = prepare_logging_log_entries(load_balancer,
                                              "loadbalancer",
                                              lb_logs_expected_to_be_enabled,
                                              parsed_response,
                                              source_tag)
        
        output += entires

    # Process cluster details
    for cluster_detail in cluster_details:
        endpoint_url = FILTER_LOG_URL_TEMPLATE.format(region = options.oci_region,
                                                      second_level_domain = SECOND_LEVEL_DOMAIN,
                                                      compartment_id = cluster_detail['compartment_id'],
                                                      source_service = 'oke-k8s-cp-prod',
                                                      ocid = cluster_detail['ocid']
                                                      )
        try:
            logging.debug("'Filter Log' API request to fetch log details for cluster '%s'", cluster_detail['ocid'])
            parsed_response = client_request(endpoint_url, 'POST', signer)
        except Exception as e:
            logging.exception("'Filter Log' API request failed while fetching cluster log details. Exception: %s.", str(e))
            exit(1)

        cluster_logs_expected_to_be_enabled = ['kube-apiserver', 'cloud-controller-manager', 'kube-controller-manager', 'kube-scheduler']

        entires = prepare_logging_log_entries(cluster_detail,
                                              "oke-k8s-cp-prod",
                                              cluster_logs_expected_to_be_enabled,
                                              parsed_response,
                                              source_tag)
        
        output += entires

    # Prepare collected data and store it in file
    collected_data = {'logs': output }

    data = {}
    try:
        data["collected_data"] = json.dumps(collected_data)
        print(json.dumps({'value': data["collected_data"]}))

        # Comment for local dev test #TODO
        # pprint(collected_data)
    except Exception as e:
        logging.exception("Unable to prepare JSON dump. Exception: %s.", str(e))
        exit(1)

    logging.info('Log details collected for passed resources.')


if __name__ == '__main__':
    try:
        # logging.basicConfig(filename="filter-logs.log", level=logging.DEBUG)
        main()
    except Exception as e:
        logging.exception("Exception occurred: %s.", str(e))
        exit(1)

    exit(0)
