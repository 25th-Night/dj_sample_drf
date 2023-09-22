import json
import tempfile
from unittest.mock import patch, MagicMock

from django.contrib.auth.models import User
from django.db.models.query import QuerySet
from django.http import HttpResponse
from django.urls import reverse
from rest_framework.test import APITestCase, APIClient
from rest_framework import status

from unittest.mock import patch

from .models import Topic, Post, TopicGroupUser


class PostTest(APITestCase):
    # Set up
    @classmethod
    def setUpTestData(cls):
        cls.superuser = User.objects.create_superuser("superuser")
        cls.private_topic = Topic.objects.create(
            name="private_topic", is_private=True, owner=cls.superuser
        )
        cls.public_topic = Topic.objects.create(
            name="public_topic", is_private=False, owner=cls.superuser
        )

        for i in range(5):
            Post.objects.create(
                topic=cls.private_topic,
                title=f"{i+1}",
                content=f"{i+1}",
                owner=cls.superuser,
            )

        for i in range(5):
            Post.objects.create(
                topic=cls.public_topic,
                title=f"{i+1}",
                content=f"{i+1}",
                owner=cls.superuser,
            )

        cls.authorized_user = User.objects.create_user("authorized")
        cls.unauthorized_user = User.objects.create_user("unauthorized")
        cls.admin_user = User.objects.create_user("admin")

        TopicGroupUser.objects.create(
            topic=cls.private_topic,
            group=TopicGroupUser.GroupChoices.common,
            user=cls.authorized_user,
        )

        TopicGroupUser.objects.create(
            topic=cls.private_topic,
            group=TopicGroupUser.GroupChoices.admin,
            user=cls.admin_user,
        )

    # Test
    def test_write_permission_on_private_topic(self):
        api_client = APIClient()
        data = {
            "title": "test",
            "content": "test",
            "topic": self.private_topic.pk,
        }
        # when unauthorized user tried to write a post on Topic => fail. 401
        api_client.force_authenticate(self.unauthorized_user)
        res = api_client.post(reverse("post-list"), data=data)
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

        # when authorized tried to write a post on Topic => success. 201
        api_client.force_authenticate(self.authorized_user)
        res: HttpResponse = api_client.post(reverse("post-list"), data=data)
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        res_data = json.loads(res.content)
        Post.objects.get(pk=res_data["id"])

        # Admin
        api_client.force_authenticate(self.admin_user)
        res: HttpResponse = api_client.post(reverse("post-list"), data=data)
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        res_data = json.loads(res.content)
        Post.objects.get(pk=res_data["id"])

        # Owner
        api_client.force_authenticate(self.superuser)
        res: HttpResponse = api_client.post(reverse("post-list"), data=data)
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        res_data = json.loads(res.content)
        Post.objects.get(pk=res_data["id"])

    def test_read_permission_on_topics(self):
        api_client = APIClient()
        # read public topic
        # unauthorized user requests => 200. public topic's post
        api_client.force_authenticate(self.unauthorized_user)
        res: HttpResponse = api_client.get(
            reverse("topic-posts", args=[self.public_topic.pk])
        )
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        data = json.loads(res.content)
        posts_n = Post.objects.filter(topic=self.public_topic).count()
        self.assertEqual(len(data), posts_n)

        # read private topic
        # unauthorized user requests => 401.
        api_client.force_authenticate(self.unauthorized_user)
        res: HttpResponse = api_client.get(
            reverse("topic-posts", args=[self.private_topic.pk])
        )
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)
        # authorized user requests => 200. public topic's post
        api_client.force_authenticate(self.authorized_user)
        res: HttpResponse = api_client.get(
            reverse("topic-posts", args=[self.private_topic.pk])
        )
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        data = json.loads(res.content)
        posts_n = Post.objects.filter(topic=self.private_topic).count()
        self.assertEqual(len(data), posts_n)

    def test_read_permission_on_posts(self):
        api_client = APIClient()
        # read public topic's post:
        # unauthorized user requests => 200, post of public topic
        api_client.force_authenticate(self.unauthorized_user)
        public_post = Post.objects.filter(topic=self.public_topic).first()
        res: HttpResponse = api_client.get(
            reverse("post-detail", args=[public_post.pk])
        )
        self.assertEqual(res.status_code, status.HTTP_200_OK)

        # read private topic's post
        # unauthorized user requests => 401
        api_client.force_authenticate(self.unauthorized_user)
        private_post = Post.objects.filter(topic=self.private_topic).first()
        res: HttpResponse = api_client.get(
            reverse("post-detail", args=[private_post.pk])
        )
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

        # authorized user requests => 200. post of private topic
        api_client.force_authenticate(self.authorized_user)
        private_post = Post.objects.filter(topic=self.private_topic).first()
        res: HttpResponse = api_client.get(
            reverse("post-detail", args=[private_post.pk])
        )
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    @patch("forum.views.boto3.client")
    def test_post_with_or_without_image(self, client: MagicMock):
        api_client = APIClient()
        # mock s3
        s3 = MagicMock()
        client.return_value = s3
        s3.upload_fileobj.return_value = None
        s3.put_object_acl.return_value = None
        # without image => success.
        data = {
            "title": "test",
            "content": "test",
            "topic": self.public_topic.pk,
        }
        api_client.force_authenticate(self.authorized_user)
        res = api_client.post(reverse("post-list"), data=data)
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)

        # with image => success.
        with tempfile.NamedTemporaryFile(suffix=".jpg") as tmpfile:
            data["image"] = tmpfile
            res = api_client.post(reverse("post-list"), data=data)
            self.assertEqual(res.status_code, status.HTTP_201_CREATED)
            res_data = json.loads(res.content)
            # self.assertContains(res, res_data["image_url"])
            print(res_data["image_url"])
            self.assertTrue(res_data["image_url"].startswith("https://"))

        s3.upload_fileobj.assert_called_once()
        s3.put_object_acl.assert_called_once()

    def test_delete_permission(self):
        api_client = APIClient()
        # setup
        common_user = User.objects.create_user("common1")
        another_common_user = User.objects.create_user("another")
        admin_user = User.objects.create_user("admin1")
        post1 = Post.objects.create(
            topic=self.private_topic,
            title="private",
            content="private",
            owner=common_user,
        )
        post2 = Post.objects.create(
            topic=self.private_topic,
            title="post2",
            content="private",
            owner=common_user,
        )
        post3 = Post.objects.create(
            topic=self.private_topic,
            title="post3",
            content="private",
            owner=common_user,
        )
        another_post = Post.objects.create(
            topic=self.private_topic,
            title="another",
            content="another",
            owner=another_common_user,
        )

        TopicGroupUser.objects.create(
            topic=self.private_topic,
            group=TopicGroupUser.GroupChoices.common,
            user=common_user,
        )
        TopicGroupUser.objects.create(
            topic=self.private_topic,
            group=TopicGroupUser.GroupChoices.admin,
            user=admin_user,
        )
        # topic owner can delete any post
        topic_owner = self.superuser
        api_client.force_authenticate(topic_owner)
        res: HttpResponse = api_client.delete(reverse("post-detail", args=[post1.pk]))
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)

        # admin user can delete any post
        api_client.force_authenticate(admin_user)
        res: HttpResponse = api_client.delete(reverse("post-detail", args=[post2.pk]))
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)

        # common user can delete only their posts

        # - post created by common user : success
        api_client.force_authenticate(common_user)
        res: HttpResponse = api_client.delete(reverse("post-detail", args=[post3.pk]))
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)

        # - another post created by another common user : fail
        api_client.force_authenticate(common_user)
        res: HttpResponse = api_client.delete(
            reverse("post-detail", args=[another_post.pk])
        )
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

        # unauthorized user can't delete any post
        api_client.force_authenticate(self.unauthorized_user)
        res: HttpResponse = api_client.delete(
            reverse("post-detail", args=[another_post.pk])
        )
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)
