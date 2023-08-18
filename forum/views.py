from django.shortcuts import get_object_or_404
from drf_spectacular.utils import extend_schema, OpenApiParameter

from rest_framework import viewsets, status
from rest_framework.response import Response
from rest_framework.request import Request
from rest_framework.decorators import action


from .models import Post, Topic, TopicGroupUser
from .serializers import PostSerializer, TopicSerializer


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

        serializer: PostSerializer = self.serializer_class(data=request.data)
        if serializer.is_valid():
            data = serializer.validated_data
            data["owner"] = user
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
