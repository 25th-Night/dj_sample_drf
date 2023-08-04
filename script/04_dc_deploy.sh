#!/bin/bash

PROJECT_DIRECTORY_NAME="dj_sample_drf"
GIT_REPOSITORY="https://github.com/25th-Night/$PROJECT_DIRECTORY_NAME.git"
REMOTE_DIRECTORY="/home/lion/"

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

# Clone git
echo "start to clone"
cd "$REMOTE_DIRECTORY"
git clone "$GIT_REPOSITORY" "$PROJECT_DIRECTORY_NAME"
cd "$PROJECT_DIRECTORY_NAME"

# Make secret.json
echo "Make .secrets && secret.json"
mkdir -p .secrets && touch .secrets/secret.json
cat <<EOF > .secrets/secret.json 
{
    "DJANGO_SECRET_KEY": "django-insecure-2q-0(0c(%$v^+7_337#v*r&0ca$vb=%ml#y=5)j!4q!=qxh&+d",
    "NCLOUD_SERVER_IP": "$SERVER_IP"
}
EOF

# Docker Compose up
docker-compose up -d --build