#!/bin/bash

env_file=/home/lion/.env

# 1. Fetch Environment Variables
echo "Fetch Environment Variables"
sed -i 's/\r$//g' $env_file
source $env_file


# NCR login
echo "Login to NCR"
docker login ${NCR_HOST} -u ${NCP_ACCESS_KEY} -p ${NCP_SECRET_KEY}


# Pull Django Image from NCR
echo "Pull Django Image from NCR"
docker pull ${NCR_HOST}/${NCR_IMAGE}


# 2. Run Django Image
echo "Run Django Image"
sudo docker run -d \
-p 8000:8000 \
--name ${DJANGO_CONTAINER_NAME} \
--env-file $env_file \
${NCR_HOST}/${NCR_IMAGE}