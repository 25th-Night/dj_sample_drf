from django.urls import path, re_path
from . import views

app_name = 'blog'

urlpatterns = [
    path('create/', views.create_blog, name='blog_create'),
    path('update/', views.update_blog, name='blog_update'),
    path('delete/', views.delete_blog, name='blog_delete'),
    path('read/', views.read_blog, name='blog_read'),
]