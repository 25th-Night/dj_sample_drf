#!/bin/bash

DIRECTORY_NAME=dj_sample_drf
REMOTE_REPOSITORY=https://github.com/25th-Night/$DIRECTORY_NAME.git

NCP_HOST=$(curl -s ifconfig.me)

POSTGRES_DB=lion_db
POSTGRES_USER=browneyed


NCR_HOST=browneyed.kr.ncr.ntruss.com
DJANGO_IMAGE_TAG=lion-app:latest

DJANGO_SECRET_KEY=
DB_SERVER_HOST=
POSTGRES_PASSWORD=
LOAD_BALANCER_DOMAIN=
NCP_ACCESS_KEY_ID=
NCP_SECRET_ACCESS_KEY=
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=

MANUAL="Usage: $0 [-j django_secret_key -s db_server_host -p postgres_pw \
-l load_balancer_domain -n ncp_access_key -s ncp_secret_key \
-a aws_access_key -k aws_secret_key]"

while getopts "j:d:p:l:n:s:a:k:" option
do
	case $option in
        j)
			DJANGO_SECRET_KEY=$OPTARG
            ;;
        d)
			DB_SERVER_HOST=$OPTARG
            ;;
        p)
			POSTGRES_PASSWORD=$OPTARG
            ;;
        l)
			LOAD_BALANCER_DOMAIN=$OPTARG
            ;;
        n)
			NCP_ACCESS_KEY_ID=$OPTARG
            ;;
        s)
			NCP_SECRET_ACCESS_KEY=$OPTARG
            ;;
        a)
			AWS_ACCESS_KEY_ID=$OPTARG
            ;;
        k)
			AWS_SECRET_ACCESS_KEY=$OPTARG
            ;;
		*)
			echo $MANUAL
			exit 1
			;;
	esac
done

if [ -z "$DJANGO_SECRET_KEY" ] || [ -z "$DB_SERVER_HOST" ]  || [ -z "$POSTGRES_PASSWORD" ]  \
|| [ -z "$LOAD_BALANCER_DOMAIN" ] || [ -z "$NCP_ACCESS_KEY_ID" ] || [ -z "$NCP_SECRET_ACCESS_KEY" ] \
|| [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]
then
	echo "DJANGO_SECRET_KEY and DB_SERVER_HOST and POSTGRES_PW and LOAD_BALANCER_DOMAIN \
    and NCP_ACCESS_KEY and NCP_SECRET_KEY  and AWS_ACCESS_KEY and AWS_SECRET_KEY are required"
	echo $MANUAL
	exit 1
fi


# clone git repository
echo "Clone git repository"
git clone $REMOTE_REPOSITORY

# change to Project directory
echo "Change to Project directory"
cd $DIRECTORY_NAME

# create env files
echo "Create Env files"
mkdir .envs/prod && \
cat > .envs/prod/db <<EOF
POSTGRES_DB=$POSTGRES_DB
POSTGRES_USER=$POSTGRES_USER
POSTGRES_PASSWORD=$POSTGRES_PASSWORD
POSTGRES_PORT=5432
EOF
cat > .envs/prod/django <<EOF
DB_HOST=$DB_SERVER_HOST
EOF
cat > .envs/prod/server <<EOF
LOCAL_IP=$(curl -s ifconfig.me)
LOAD_BALANCER_DOMAIN=$LOAD_BALANCER_DOMAIN
EOF

# create secret.json
echo "Create secret.json"
mkdir .secrets && cat > .secrets/secret.json <<EOF
{
  "DJANGO_SECRET_KEY": "$DJANGO_SECRET_KEY",
  "NCLOUD_SERVER_IP": "$NCP_HOST"
}
EOF

# install aws cli & configure aws credential
echo "Install aws cli and Configure aws credential"
sudo apt install -y awscli
mkdir ~/.aws
cat > ~/.aws/config <<EOF
[default]
region = ap-northeast-2
output = JSON
EOF
cat > ~/.aws/credentials <<EOF
[default]
aws_access_key_id = $AWS_ACCESS_KEY_ID
aws_secret_access_key = $AWS_SECRET_ACCESS_KEY
EOF

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

# login to NCloud Container Registry
echo "Login to NCloud Container Registry"
sudo docker login $NCR_HOST -u $NCP_ACCESS_KEY_ID -p $NCP_SECRET_ACCESS_KEY

# pull Image from NCR
echo "Pull Django Image from NCloud Container Registry"
sudo docker pull $NCR_HOST/$DJANGO_IMAGE_TAG

# run django container
echo "Run Django Container"
sudo docker run -p 8000:8000 -d \
-v /home/lion/.aws:/root/.aws:ro -v /home/lion/$DIRECTORY_NAME/.secrets/secret.json:/app/.secrets/secret.json:ro \
--env-file .envs/prod/django --env-file .envs/prod/db --env-file .envs/prod/server \
--name lion-app-dc $NCR_HOST/$DJANGO_IMAGE_TAG /start