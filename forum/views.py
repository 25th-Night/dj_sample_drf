from drf_spectacular.utils import extend_schema, OpenApiParameter

from rest_framework import viewsets, status
from rest_framework.response import Response

from .models import Post, Topic
from .serializers import PostSerializer, TopicSerializer


@extend_schema(tags=["Topic"])
class TopicViewSet(viewsets.ModelViewSet):
    queryset = Topic.objects.all()
    serializer_class = TopicSerializer
    
    @extend_schema(parameters=[OpenApiParameter(name='name', description='Filter by name', required=False, type=str)])
    def list(self, request, *args, **kwargs):
        queryset = Topic.objects.all()
        name = request.query_params.get('name')

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

    def get_queryset(self):
        queryset = Post.objects.all()
        topic_id = self.kwargs.get('topic_id')

        if topic_id:
            queryset = queryset.filter(topic_id=topic_id)

        return queryset