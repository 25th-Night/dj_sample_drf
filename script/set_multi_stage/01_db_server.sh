#!/bin/bash

INIT_ENV_FILENAME=.db_env
INIT_POSTGRES_VOLUME=lion_db_vol
INIT_POSTGRES_DBNAME=lion_db
INIT_POSTGRES_USERNAME=browneyed
INIT_POSTGRES_PASSWORD=25thnight!

ENV_FILENAME=""
POSTGRES_VOLUME=""
POSTGRES_DBNAME=""
POSTGRES_USERNAME=""
POSTGRES_PASSWORD=""
MANUAL="Usage: $0 [-f env_filename -v volumename -n dbname -u username -p password]"

while getopts "f:v:n:u:p:" option
do
	case $option in
        f)
			ENV_FILENAME=$OPTARG
            ;;
        v)
			VOLUME_NAME=$OPTARG
            ;;
		n)
			POSTGRES_DB=$OPTARG
            ;;
		u)
			POSTGRES_USER=$OPTARG
			;;
		p)
			POSTGRES_PASSWORD=$OPTARG
			;;
		*)
			echo $MANUAL
			exit 1
			;;
	esac
done


if [ -z "$ENV_FILENAME" ]
then
	echo "ENV_FILENAME is automatically set to "$INIT_ENV_FILENAME"."
	ENV_FILENAME=$INIT_ENV_FILENAME
else
    echo "ENV_FILENAME is set to "$ENV_FILENAME"."
fi

if [ -z "$VOLUME_NAME" ]
then
	echo "POSTGRES_VOLUME is automatically set to "$INIT_POSTGRES_VOLUME"."
	POSTGRES_VOLUME=$INIT_POSTGRES_VOLUME
else
    echo "POSTGRES_VOLUME is set to "$POSTGRES_VOLUME"."
fi

if [ -z "$POSTGRES_DBNAME" ]
then
	echo "POSTGRES_DBNAME is automatically set to "$INIT_POSTGRES_DBNAME"."
	POSTGRES_DBNAME=$INIT_POSTGRES_DBNAME
else
    echo "POSTGRES_DBNAME is set to "$POSTGRES_DBNAME"."
fi

if [ -z "$POSTGRES_USERNAME" ]
then
	echo "POSTGRES_USERNAME is automatically set to "$INIT_POSTGRES_USERNAME"."
	POSTGRES_USERNAME=$INIT_POSTGRES_USERNAME
else
    echo "POSTGRES_USERNAME is set to "$POSTGRES_USERNAME"."
fi

if [ -z "$POSTGRES_PASSWORD" ]
then
	echo "POSTGRES_PASSWORD is automatically set to "$INIT_POSTGRES_PASSWORD"."
	POSTGRES_PASSWORD=$INIT_POSTGRES_PASSWORD
else
    echo "POSTGRES_PASSWORD is set to "$POSTGRES_PASSWORD"."
fi


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

# pull Postgres Image
echo "Pull Postgres Image"
sudo docker pull postgres:13

# create docker volume
echo "Create docker Volume"
sudo docker volume create $VOLUME_NAME

# create env file"
echo "Create env file"
cat > $ENV_FILENAME <<EOF
POSTGRES_DB=$POSTGRES_DBNAME
POSTGRES_USER=$POSTGRES_USERNAME
POSTGRES_PASSWORD=$POSTGRES_PASSWORD
POSTGRES_PORT=5432
EOF

# run docker container
echo "Run docker container"
sudo docker run --env-file $ENV_FILENAME --name $POSTGRES_DBNAME \
-v $POSTGRES_VOLUME:/var/lib/postgresql/data -p 5432:5432 -d postgres:13