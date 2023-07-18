### Container Images

By default, pre-built images by Oracle are used.

#### Pre-built images

* [Fluentd Container Image](https://container-registry.oracle.com/ords/f?p=113:4:13515970073310:::4:P4_REPOSITORY,AI_REPOSITORY,AI_REPOSITORY_NAME,P4_REPOSITORY_NAME,P4_EULA_ID,P4_BUSINESS_AREA_ID:1843,1843,OCI%20Logging%20Analytics%20Fluentd%20based%20Collector,OCI%20Logging%20Analytics%20Fluentd%20based%20Collector,1,0&cs=3UtJ-CmXRZ5iKQ-QrQfja1Mxp3EIiFQ7TwBty97eqA8LmTyZtsiaFZgLmGu-qD28SwH3RIUZVXxYevRBNBR5yng)
* [Management Agent Container Image](https://container-registry.oracle.com/ords/f?p=113:4:13515970073310:::4:P4_REPOSITORY,AI_REPOSITORY,AI_REPOSITORY_NAME,P4_REPOSITORY_NAME,P4_EULA_ID,P4_BUSINESS_AREA_ID:2004,2004,OCI%20Management%20Agent%20Container%20Image,OCI%20Management%20Agent%20Container%20Image,1,0&cs=35eEP-Hh_4zhB7KLZ1uShwA7SEd5xmbYo-gwkV-TJaxhVB25CIxgQN7EfUbBlUcZQHiX-peQRtm7MAGxO-hEjTA)

#### Building images

##### Fluentd Container Image

- Download all the files from the below mentioned dir into a local machine having access to internet and docker installed.
  - [OL8-Slim](logan/docker-images/v1.0/oraclelinux/8-slim/)
- Run the following command to build the image.
    - `docker build -t oci-la-fluentd-collector-custom -f Dockerfile .`
- The docker image built from the above step, can either be pushed to Docker Hub or OCI Container Registry (OCIR) or to a Local Docker Registry depending on the requirements.
    - [How to push the image to Docker Hub](https://docs.docker.com/docker-hub/repos/#pushing-a-docker-container-image-to-docker-hub)
    - [How to push the image to OCIR](https://www.oracle.com/webfolder/technetwork/tutorials/obe/oci/registry/index.html).
    - [How to push the image to Local Registry](https://docs.docker.com/registry/deploying/).

##### Management Agent Container Image
Instructions to build the container image for Management Agent are available in the Oracle's Docker Images repository on [Github](https://github.com/oracle/docker-images/tree/main/OracleManagementAgent)

