#!/bin/bash

# Load Environment Variables
echo "Load Environment Variables"
chmod +x .env
source ./.env

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
sudo docker run -d \
-p 8000:8000 \
-v /home/lion/.aws:/root/.aws:ro \
--env-file .env \
--name $DJANGO_CONTAINER_NAME \
$NCR_HOST/$DJANGO_IMAGE_TAG