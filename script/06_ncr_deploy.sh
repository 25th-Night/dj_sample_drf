#!/bin/bash


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

# SET NCP_SERVER_IP in .env
echo "Set NCP_SERVER_IP=$SERVER_IP in .env"
sed -i "s/^NCP_SERVER_IP=.*/NCP_SERVER_IP=$SERVER_IP/" .env || echo "NCP_SERVER_IP=$SERVER_IP" >> .env
source ./.env

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
docker pull $NCR_ADDRESS/$NCR_NGINX_IMAGE_NAME:$NCR_NGINX_IMAGE_TAG


# Docker Compose up
echo "Docker Compose up"
docker-compose up -d --build

# Modify Server name at Nginx setting file in Docker Container
echo "Modify Server name at Nginx setting file in Docker Container"
docker exec lion-nginx-dc sed -i "s/server_name.*$/server_name $SERVER_IP;/" /etc/nginx/sites-available/django

# Restart All Container
echo "Restart All Container"
docker-compose restart