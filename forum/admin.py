from django.contrib import admin

from forum.models import Post, Topic, TopicGroupUser


admin.site.register(Topic)
admin.site.register(Post)


@admin.register(TopicGroupUser)
class TopicGroupUSerAdmin(admin.ModelAdmin):
    list_display = ["topic", "group", "user"]

    @admin.display(description="group")
    def get_group_at(self, obj):
        return obj.get_group_display()
