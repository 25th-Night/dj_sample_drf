#!/bin/bash

POSTGRES_VOLUME=lion_db_vol
MANUAL="Usage: $0 [-v volumename]"

while getopts "v:" option
do
	case $option in
        v)
			VOLUME_NAME=$OPTARG
            ;;
		*)
			echo $MANUAL
			exit 1
			;;
	esac
done

if [ -z "$VOLUME_NAME" ]
then
	echo "POSTGRES_VOLUME is automatically set to "$POSTGRES_VOLUME"."
fi


# Load Environment Variables
echo "Load Environment Variables"
chmod +x .env
source ./.env

# update apt & install docker
echo "Update apt and Install docker"
sudo apt-get update
sudo apt install -y docker.io

# start docker
echo " Start docker"
sudo service docker start

# add user to 'docker' group
echo "Add user to 'docker' group"
sudo usermod -aG docker lion

# create docker volume
echo "Create docker Volume"
sudo docker volume create $VOLUME_NAME

# run docker container
echo "Run docker container"
sudo docker run -d \
-p 5432:5432 \
--name $DB_CONTAINER_NAME \
--env-file .env \
-v $POSTGRES_VOLUME:/var/lib/postgresql/data \
postgres:13