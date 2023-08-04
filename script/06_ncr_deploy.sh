#!/bin/bash

source "./.env"

SERVER_IP=
MANUAL="사용법: $0 [-i 서버주소]"

# -i 인자로 server_ip가 들어오면, 해당 ip 사용.
# 그렇지 않으면, curl ifconfig.me 이용해서 ip 자동입력

while getopts "i:" option
do
	case $option in
		i)
			SERVER_IP=$OPTARG
			;;
		*)
			echo $MANUAL
			exit 1
			;;
	esac
done

if [ -z "$SERVER_IP" ]
then
	SERVER_IP=$(curl -s ifconfig.me)
fi

# Install Docker & Docker-compose
echo "Installing Docker"
sudo apt-get update && sudo apt-get install -y docker.io docker-compose 
sudo service docker start

# NCR 로그인
echo "Login to NCR"
echo "$NCP_SECRET_KEY" | docker login browneyed.kr.ncr.ntruss.com -u "$NCP_ACCESS_KEY_ID" --password-stdin

# NCR에서 이미지 pull
echo "Pull Django Image from Naver Container Registry"
docker pull $NCR_ADDRESS/$NCR_DJANGO_IMAGE_NAME:$NCR_DJANGO_IMAGE_TAG

echo "Pull Nginx Image from Naver Container Registry"
docker pull $NCR_ADDRESS/$NCR_NGINX_IMAGE_NAME:$NCR_NGINX_IMAGE_TAG=

# Docker Compose up
echo "Docker Compose up"
docker-compose -f docker-compose_ncr.yml up -d

# Create Nginx Setting file
echo "Create Nginx Setting file"
cat > django <<EOF 
server {
        listen 80;
        server_name $SERVER_IP;

        location / {
                proxy_pass http://127.0.0.1:8000;
                proxy_set_header Host \$host;
                proxy_set_header X-Real-IP \$remote_addr;
        }
}
EOF

# Overwrite Nginx setting file in Docker Container
echo "Overwrite Nginx setting file in Docker Container"
docker cp django lion-nginx-dc:$REMOTE_NGINX_CONF_FILE