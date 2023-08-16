import os

from .base import *


SECRET_KEY = os.getenv("DJANGO_SECRET_KEY")

DEBUG = False

ALLOWED_HOSTS = [
    os.getenv("NCP_LB_DOMAIN"),
]

CSRF_TRUSTED_ORIGINS = [
    f"http://{os.getenv('NCP_LB_DOMAIN')}",
]
