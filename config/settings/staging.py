import os

from .base import *


SECRET_KEY = os.getenv("DJANGO_SECRET_KEY")


DEBUG = True

ALLOWED_HOSTS = [
    # staging 환경의 Django 서버의 LB 도메인
    "lion-staging-lb-18974486-d2dd79860392.kr.lb.naverncp.com",
]

CSRF_TRUSTED_ORIGINS = [
    "http://lion-staging-lb-18974486-d2dd79860392.kr.lb.naverncp.com",
]
