#!/bin/bash

source "./.env"

# Create Image Tags for Image Push to NCR"
if [ -n $(docker images | grep -q "$LOCAL_DJANGO_IMAGE_NAME" | grep -q "$LOCAL_DJANGO_IMAGE_TAG") ]
then
	if [ -n $(docker images | grep -q "$NCR_ADDRESS/$NCR_DJANGO_IMAGE_NAME" | grep -q "$NCR_DJANGO_IMAGE_TAG") ]
	then 
		echo "Remove eaxisting Django Image Tag for NCR"
		docker tag $LOCAL_DJANGO_IMAGE_NAME:$LOCAL_DJANGO_IMAGE_TAG $NCR_ADDRESS/$NCR_DJANGO_IMAGE_NAME:$NCR_DJANGO_IMAGE_TAG
	fi
	echo "Create Django Image Tag for NCR"
	docker tag $LOCAL_DJANGO_IMAGE_NAME:$LOCAL_DJANGO_IMAGE_TAG $NCR_ADDRESS/$NCR_DJANGO_IMAGE_NAME:$NCR_DJANGO_IMAGE_TAG
fi

if [ -n $(docker images | grep -q "$LOCAL_NGINX_IMAGE_NAME" | grep -q "$LOCAL_NGINX_IMAGE_TAG") ]
then
	if [ -n $(docker images | grep -q "$NCR_ADDRESS/$NCR_NGINX_IMAGE_NAME" | grep -q "$NCR_NGINX_IMAGE_TAG") ]
	then 
		echo "Remove eaxisting Nginx Image Tag for NCR"
		docker tag $LOCAL_NGINX_IMAGE_NAME:$LOCAL_NGINX_IMAGE_TAG $NCR_ADDRESS/$NCR_NGINX_IMAGE_NAME:$NCR_NGINX_IMAGE_TAG
	fi
	echo "Create NGINX Image Tag for NCR"
	docker tag $LOCAL_NGINX_IMAGE_NAME:$LOCAL_NGINX_IMAGE_TAG $NCR_ADDRESS/$NCR_NGINX_IMAGE_NAME:$NCR_NGINX_IMAGE_TAG
fi

# Push Image to NCR"
echo "Push Django Image to Naver Container Registry"
docker push $NCR_ADDRESS/$NCR_DJANGO_IMAGE_NAME:$NCR_DJANGO_IMAGE_TAG

echo "Push Nginx Image to Naver Container Registry"
docker push $NCR_ADDRESS/$NCR_NGINX_IMAGE_NAME:$NCR_NGINX_IMAGE_TAG
