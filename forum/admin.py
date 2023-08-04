from django.contrib import admin

from forum.models import Post, Topic


admin.register(Topic)
admin.register(Post)