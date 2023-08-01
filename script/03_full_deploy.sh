#!/bin/bash

USERNAME="lion2"
PASSWORD="1212"

PROJECT_DIRECTORY_NAME="dj_sample_drf"
GIT_REPOSITORY="https://github.com/25th-Night/$PROJECT_DIRECTORY_NAME.git"
REMOTE_DIRECTORY="/home/lion/"
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

# Add user
echo "Add user"
useradd -s /bin/bash -d $REMOTE_DIRECTORY -m $USERNAME

# Set password
echo "Set password"
echo "$USERNAME:$PASSWORD" | chpasswd

# Set sudo
echo "Set sudo"
usermod -aG sudo $USERNAME
echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/$USERNAME

echo "Set user done"

# Clone git
echo "start to clone"
cd "$REMOTE_DIRECTORY"
git clone "$GIT_REPOSITORY" "$PROJECT_DIRECTORY_NAME"
cd "$PROJECT_DIRECTORY_NAME"

# Install venv
echo "start to install venv"
sudo apt-get update && sudo apt install -y python3.8-venv

# Create venv
echo "start to create venv"
python3 -m venv venv

# Activate venv
echo "start to activate venv"
source venv/bin/activate

# Install pip
echo "start to install requirements"
pip install -r requirements.txt

# Create & Set secret.json
echo "start to crate secret.json"
mkdir -p .secrets && touch .secrets/secret.json
cat <<EOF > .secrets/secret.json 
{
    "DJANGO_SECRET_KEY": "django-insecure-2q-0(0c(%$v^+7_337#v*r&0ca$vb=%ml#y=5)j!4q!=qxh&+d",
    "NCLOUD_SERVER_IP": "$SERVER_IP"
}
EOF

# Install Nginx
echo "Install Nginx"
sudo apt install -y nginx

# Set Nginx
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

# Create symlink
echo "create symlink"
if [ -f "$REMOTE_NGINX_SYMLINK_FILE" ]
then
        echo "remove $REMOTE_NGINX_SYMLINK_FILE file and regenerate"
        sudo rm $REMOTE_NGINX_SYMLINK_FILE
fi
sudo ln -s $REMOTE_NGINX_CONF_FILE $REMOTE_NGINX_SYMLINK_FILE

# Restart Nginx
echo "restart nginx"
sudo systemctl restart nginx

# Run gunicorn
echo "run gunicorn"
cd "$REMOTE_DIRECTORY""$PROJECT_DIRECTORY_NAME"
gunicorn config.wsgi:application -c config/gunicorn_config.py