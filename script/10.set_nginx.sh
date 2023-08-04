#!/bin/bash

REMOTE_NGINX_CONF_FILE="/etc/nginx/sites-available/django"
REMOTE_NGINX_SYMLINK_FILE="/etc/nginx/sites-enabled/django"

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


# nginx 설치
echo "install nginx"
sudo apt install -y nginx

# /etc/nginx/sites-available/ 폴더에 nginx 설정 파일 생성
echo "create nginx.conf"
if [ -f "$REMOTE_NGINX_CONF_FILE" ]
then
        echo "remove $REMOTE_NGINX_CONF_FILE file and regenerate"
        sudo rm $REMOTE_NGINX_CONF_FILE
fi

sudo sh -c "cat > $REMOTE_NGINX_CONF_FILE <<EOF 
server {
        listen 80;
        server_name $SERVER_IP;

        location / {
                proxy_pass http://127.0.0.1:8000;
                proxy_set_header Host \\\$host;
                proxy_set_header X-Real-IP \\\$remote_addr;
        }
}
EOF"

# /etc/nginx/sites-enabled/ 폴더에 symlink 생성
echo "create symlink"
if [ -f "$REMOTE_NGINX_SYMLINK_FILE" ]
then
        echo "remove $REMOTE_NGINX_SYMLINK_FILE file and regenerate"
        sudo rm $REMOTE_NGINX_SYMLINK_FILE
fi
sudo ln -s $REMOTE_NGINX_CONF_FILE $REMOTE_NGINX_SYMLINK_FILE

# nginx 재시작
echo "restart nginx"
sudo systemctl restart nginx
