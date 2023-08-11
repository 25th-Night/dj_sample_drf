from drf_spectacular.utils import extend_schema

from rest_framework import viewsets

from .models import Post, Topic
from .serializers import PostSerializer, TopicSerializer


@extend_schema(tags=["Topic"])
class TopicViewSet(viewsets.ModelViewSet):
    queryset = Topic.objects.all()
    serializer_class = TopicSerializer

    def get_queryset(self):
        queryset = Topic.objects.all()
        name = self.request.query_params.get('name')

        if name is not None:
            queryset = queryset.filter(name__icontains=name)
        
        return queryset


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