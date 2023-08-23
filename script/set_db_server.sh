#!/bin/bash

env_file=/home/lion/.env

# 1. Fetch Environment variables
echo "Fetch Environment Variables"
sed -i 's/\r$//g' $env_file
source $env_file

# 2. Run DB image
echo "Run postgres container"
sudo docker run -d \
-p 5432:5432 \
--name $DB_CONTAINER_NAME \
--env-file $env_file \
-v $POSTGRES_VOLUME:/var/lib/postgresql/data \
postgres:13