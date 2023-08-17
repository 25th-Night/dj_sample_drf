from django.shortcuts import get_object_or_404
from drf_spectacular.utils import extend_schema, OpenApiParameter

from rest_framework import viewsets, status
from rest_framework.response import Response

from .models import Post, Topic, TopicGroupUser
from .serializers import PostSerializer, TopicSerializer


@extend_schema(tags=["Topic"])
class TopicViewSet(viewsets.ModelViewSet):
    queryset = Topic.objects.all()
    serializer_class = TopicSerializer

    @extend_schema(
        parameters=[
            OpenApiParameter(name="name", description="Filter by name", required=False, type=str)
        ]
    )
    def list(self, request, *args, **kwargs):
        queryset = Topic.objects.all()
        name = request.query_params.get("name")

        if name is not None:
            queryset = queryset.filter(name__icontains=name)

        serialized_topic_data = self.serializer_class(queryset, many=True).data
        return Response(status=status.HTTP_200_OK, data=serialized_topic_data)

    @extend_schema(summary="새 토픽 생성")
    def create(self, request, *args, **kwargs):
        return super().create(request, *args, **kwargs)


@extend_schema(tags=["Post"])
class PostViewSet(viewsets.ModelViewSet):
    queryset = Post.objects.all()
    serializer_class = PostSerializer

    # def list(self, request, *args, **kwargs):
    #     queryset = Post.objects.all()
    #     topic_id = request.query_params.get("topic_id")

    #     if topic_id is not None:
    #         queryset = queryset.filter(topic_id=topic_id)

    #     serialized_post_data = self.serializer_class(queryset, many=True).data
    #     return Response(status=status.HTTP_200_OK, data=serialized_post_data)

    def create(self, request, *args, **kwargs):
        user = request.user
        data = request.data
        topic_id = data.get("topic")
        topic = get_object_or_404(Topic, id=topic_id)
        if topic.is_private:
            qs = TopicGroupUser.objects.filter(
                group__lte=TopicGroupUser.groupChoices.common, topic=topic, user=user
            )
            # SELECT * FROM TopicGroupUser WHERE topic=topic, user=user, (group=0 OR group=1)
            if not qs.exists():
                return Response(
                    status=status.HTTP_401_UNAUTHORIZED,
                    data="This user is not allowed to write a post on this topic",
                )

        # Topic - private
        # User1 - Unauthorized
        # User2 - Authorized

        # User1 tried to write a post on Topic => fail. 401
        # User2 tried to write a post on Topic => success. 201

        return super().create(request, *args, **kwargs)
