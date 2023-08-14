from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import TopicViewSet, PostViewSet

router = DefaultRouter()


# router.register(r'topics', TopicViewSet)
# router.register(
#     r'topics/(?P<topic_id>\d+)/posts',
#     PostViewSet,
#     basename='topic-posts'
# )

router.register('topics', TopicViewSet)
router.register(
    'topics/<int:topic_id>/posts',
    PostViewSet,
    basename='topic-posts'
)