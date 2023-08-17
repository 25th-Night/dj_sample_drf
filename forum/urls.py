from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import TopicViewSet, PostViewSet

router = DefaultRouter()

router.register("topics", TopicViewSet, basename="topic")
router.register("posts", PostViewSet, basename="post")
