#!/bin/bash

source "./.env"

# Create Django Image Tag in Local
if [ -n $(docker images | grep -q "$LOCAL_DJANGO_IMAGE_NAME" | grep -q "$LOCAL_DJANGO_IMAGE_TAG") ]
then
    echo "Remove eaxisting Django Image in Local"
    docker rmi -f $LOCAL_DJANGO_IMAGE_NAME:$LOCAL_DJANGO_IMAGE_TAG
fi
echo "Create Django Image Tag in Local"
docker build -t $LOCAL_DJANGO_IMAGE_NAME:$LOCAL_DJANGO_IMAGE_TAG -f Dockerfile_django .

# Create Django Image Tag for NCR
echo "Create Django Image Tag for NCR"
docker tag $LOCAL_DJANGO_IMAGE_NAME:$LOCAL_DJANGO_IMAGE_TAG $NCR_ADDRESS/$NCR_DJANGO_IMAGE_NAME:$NCR_DJANGO_IMAGE_TAG


# Create NGINX Image Tag in Local
if [ -n $(docker images | grep -q "$LOCAL_NGINX_IMAGE_NAME" | grep -q "$LOCAL_NGINX_IMAGE_TAG") ]
then
    echo "Remove eaxisting Nginx Image in Local"
    docker rmi -f $LOCAL_NGINX_IMAGE_NAME:$LOCAL_NGINX_IMAGE_TAG
fi
echo "Create Nginx Image Tag in Local"
docker build -t $LOCAL_NGINX_IMAGE_NAME:$LOCAL_NGINX_IMAGE_TAG -f Dockerfile_nginx .

# Create NGINX Image Tag for NCR
echo "Create NGINX Image Tag for NCR"
docker tag $LOCAL_NGINX_IMAGE_NAME:$LOCAL_NGINX_IMAGE_TAG $NCR_ADDRESS/$NCR_NGINX_IMAGE_NAME:$NCR_NGINX_IMAGE_TAG

# Push Image to NCR"
echo "Push Django Image to Naver Container Registry"
docker push $NCR_ADDRESS/$NCR_DJANGO_IMAGE_NAME:$NCR_DJANGO_IMAGE_TAG

echo "Push Nginx Image to Naver Container Registry"
docker push $NCR_ADDRESS/$NCR_NGINX_IMAGE_NAME:$NCR_NGINX_IMAGE_TAG
