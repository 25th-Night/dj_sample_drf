import os

from .base import *


SECRET_KEY = os.getenv("DJANGO_SECRET_KEY")

DEBUG = False

ALLOWED_HOSTS = [
    # production 환경의 Django 서버의 LB 도메인
    "lion-lb-18904314-4889fba25a98.kr.lb.naverncp.com",
]

CSRF_TRUSTED_ORIGINS = [
    "http://lion-lb-18904314-4889fba25a98.kr.lb.naverncp.com",
]
