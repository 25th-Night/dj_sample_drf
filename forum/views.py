import uuid

from django.shortcuts import get_object_or_404
from drf_spectacular.utils import extend_schema, OpenApiParameter
from django.conf import settings
from django.core.files.base import File

from rest_framework import viewsets, status
from rest_framework.response import Response
from rest_framework.request import Request
from rest_framework.decorators import action

import boto3

from .models import Post, Topic, TopicGroupUser
from .serializers import PostSerializer, PostUploadSerializer, TopicSerializer


@extend_schema(tags=["Topic"])
class TopicViewSet(viewsets.ModelViewSet):
    queryset = Topic.objects.all()
    serializer_class = TopicSerializer

    @extend_schema(
        parameters=[
            OpenApiParameter(
                name="name", description="Filter by name", required=False, type=str
            )
        ]
    )
    def list(self, request: Request, *args, **kwargs):
        queryset = Topic.objects.all()
        name = request.query_params.get("name")

        if name is not None:
            queryset = queryset.filter(name__icontains=name)

        serialized_topic_data = self.serializer_class(queryset, many=True).data
        return Response(status=status.HTTP_200_OK, data=serialized_topic_data)

    @extend_schema(summary="새 토픽 생성")
    def create(self, request: Request, *args, **kwargs):
        return super().create(request, *args, **kwargs)

    @action(detail=True, methods=["get"], url_name="posts")
    def posts(self, request: Request, *args, **kwargs):
        topic: Topic = self.get_object()
        user = request.user

        if not topic.can_be_access_by(user):
            return Response(
                status=status.HTTP_401_UNAUTHORIZED,
                data="This user is not allowed to write a post on this topic",
            )

        posts = topic.posts
        serializer = PostSerializer(posts, many=True)

        return Response(data=serializer.data)


@extend_schema(tags=["Post"])
class PostViewSet(viewsets.ModelViewSet):
    queryset = Post.objects.all()
    serializer_class = PostSerializer

    def get_serializer_class(self):
        if self.action == "create":
            return PostUploadSerializer
        return super().get_serializer_class()

    @extend_schema(deprecated=True)
    def list(self, request, *args, **kwargs):
        return Response(status=status.HTTP_400_BAD_REQUEST, data="Deprecated API")

    def create(self, request, *args, **kwargs):
        user = request.user
        data = request.data
        topic_id = data.get("topic")
        topic = get_object_or_404(Topic, id=topic_id)

        if not topic.can_be_access_by(user):
            return Response(
                status=status.HTTP_401_UNAUTHORIZED,
                data="This user is not allowed to write a post on this topic",
            )

        # If image exists
        if image := request.data.get("image"):
            print(type(image))
            image: File
            endpoint_url = "https://kr.object.ncloudstorage.com"
            access_key = settings.NCP_ACCESS_KEY
            secret_key = settings.NCP_SECRET_KEY
            bucket_name = settings.S3_BUCKET_NAME

            s3 = boto3.client(
                service_name="s3",
                endpoint_url=endpoint_url,
                aws_access_key_id=access_key,
                aws_secret_access_key=secret_key,
            )

            # upload it to Object Storage(S3)
            ext = image.name.split(".")[-1]
            image_id = str(uuid.uuid4())
            image_filename = f"{image_id}.{ext}"
            s3.upload_fileobj(image.file, bucket_name, image_filename)

            # and get its url
            image_url = f"{endpoint_url}/{bucket_name}/{image_filename}"

            # file access permission change
            response = s3.put_object_acl(
                Bucket=bucket_name, Key=image_filename, ACL="public-read"
            )

        serializer: PostSerializer = self.serializer_class(data=request.data)
        if serializer.is_valid():
            data = serializer.validated_data
            data["owner"] = user
            data["image_url"] = image_url if image else None
            res: Post = serializer.create(data)
            return Response(
                status=status.HTTP_201_CREATED, data=PostSerializer(res).data
            )
        else:
            return Response(status=status.HTTP_400_BAD_REQUEST, data=serializer.errors)

    def retrieve(self, request: Request, *args, **kwargs):
        post: Post = self.get_object()
        user = request.user
        topic = post.topic

        if not topic.can_be_access_by(user):
            return Response(
                status=status.HTTP_401_UNAUTHORIZED,
                data="This user is not allowed to write a post on this topic",
            )

        return super().retrieve(request, *args, **kwargs)

    def destroy(self, request: Request, *args, **kwargs):
        # Authorization check
        # Topic owner, admin user can delete any post in the topic
        # common user can delete only their posts

        post: Post = self.get_object()
        user = request.user

        if not post.can_be_access_by(user):
            return Response(
                status=status.HTTP_401_UNAUTHORIZED,
                data="This user is not allowed to delete a post on this topic",
            )

        return super().destroy(request, *args, **kwargs)
