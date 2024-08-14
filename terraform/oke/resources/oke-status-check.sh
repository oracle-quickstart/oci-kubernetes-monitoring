#!/bin/bash

############################################################
##
##   Check the lifecycle-state of OKE cluster [$OKE_OCID]
##   every $CHECK_INTERVAL seconds
##   untill
##       - lifecycle state is "ACTIVE" 
##         or 
##       - time limit $WAIT_TIME is breached
##   
##   exit with status 0, iff lifecycle-state is "ACTIVE",
##   otherwise exit with status 1
##
############################################################

# Exit on error
set -e

# Inputs from ENV is preferred over CLI
if [ -z "${WAIT_TIME}" ]; then WAIT_TIME=$1; fi
if [ -z "${CHECK_INTERVAL}" ]; then CHECK_INTERVAL=$2; fi
if [ -z "${OKE_OCID}" ]; then OKE_OCID=$3; fi

# timer=0

# while true; 
# do
#     oke_status=$(oci ce cluster get --cluster-id "$OKE_OCID" --query 'data."lifecycle-state"' --raw-output)
#     echo -e "OKE status: $oke_status"

#     if [ "$oke_status" == "ACTIVE" ]; then
#         echo -e "OKE status is ACTIVE. Returning with success."
#         break; 
#     fi

#     echo -e "Next check scheduled after seconds: $CHECK_INTERVAL"
#     sleep "$CHECK_INTERVAL"

#     (( timer = timer + CHECK_INTERVAL ))
#     if [ $timer -ge "$WAIT_TIME" ]; then
#          echo -e "Timeout limit breached: $WAIT_TIME"
#          echo -e "ERROR: OKE status is not ACTIVE."
#          exit 1
#     fi
# done

# echo -e "Total wait time: $timer"

# Temp static sleep for 15 minutes
echo -e "Sleeping for seconds: 900"
sleep 900

exit 0