from django.contrib import admin

from forum.models import Post, Topic, TopicGroupUser


admin.site.register(Topic)
admin.site.register(Post)
admin.site.register(TopicGroupUser)
