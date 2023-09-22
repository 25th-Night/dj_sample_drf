from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import TopicViewSet, PostViewSet

router = DefaultRouter()

router.register("topic", TopicViewSet, basename="topic")
router.register("post", PostViewSet, basename="post")
