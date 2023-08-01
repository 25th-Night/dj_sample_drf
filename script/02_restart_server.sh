#!/bin/bash

PROJECT_DIRECTORY_NAME="dj_sample_drf"
REMOTE_DIRECTORY="/home/lion/"

# nginx 재시작
echo "restart nginx"
sudo systemctl restart nginx

# gunicorn 실행
echo "run gunicorn"
cd "$REMOTE_DIRECTORY""$PROJECT_DIRECTORY_NAME"
source ./venv/bin/activate
gunicorn config.wsgi:application -c config/gunicorn_config.py