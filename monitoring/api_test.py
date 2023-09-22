from abc import ABC, abstractmethod
import time
from random import *

import requests

from faker import Faker


class APIHandler(ABC):
    def __init__(self, host: str = "http://127.0.0.1:8000"):
        self.root_url = "forum/topic"
        self.host = host
        self.access, self.refresh = self._login()
        self.headers = {
            "Authorization": f"Bearer {self.access}",  # 'Bearer' 은 simple-jwt 설정에서 변경 가능
        }

    def _get_url(self, detail=False, pk: int = None) -> str:
        if detail:
            return f"{self.host}/{self.root_url}/{pk}/"

        return f"{self.host}/{self.root_url}/"

    @abstractmethod
    def _generate_data(self, fk: int = None) -> dict:
        """
        generate data for POST, PUT
        """
        ...

    def _login(self) -> tuple:
        url = f"{self.host}/api/token/"
        data = {"username": "admin", "password": "1234"}
        res = requests.post(url, data=data)
        data = res.json()
        return data.get("access"), data.get("refresh")

    def _api_call(self, method: str, url: str, data: dict = None):
        request = {"url": url, "data": data, "headers": self.headers}
        try:
            res = getattr(requests, method)(**request)
            res.raise_for_status()  # 에러 상태 코드인 경우 예외 발생
            return res
        except requests.exceptions.RequestException as e:
            # HTTP 요청 중에 예외가 발생한 경우 처리
            print(f"An error occurred: {e}")
            return None  # 에러 발생 시 None을 반환하거나 다른 적절한 처리 수행

    def _get_pk(self, model: str = None) -> int:
        lst = self.list(model)

        return lst[0].get("id")

    @abstractmethod
    def create(self):
        ...

    @abstractmethod
    def list(self, model: str = None):
        ...

    @abstractmethod
    def update(self):
        ...

    def destroy(self):
        pk = self._get_pk()
        self._api_call(method="delete", url=self._get_url(detail=True, pk=pk))

    def detail(self):
        pk = self._get_pk()
        res = self._api_call(method="get", url=self._get_url(detail=True, pk=pk))

        return res


class TopicAPIHandler(APIHandler):
    def __init__(self, host: str = "http://127.0.0.1:8000"):
        super().__init__(host)
        self.root_url = "forum/topic"

    def _generate_data(self, fk: int = None) -> dict:
        fake = Faker()
        data = {
            "name": fake.word(),
            "is_private": False,
        }

        return data

    def create(self):
        res = self._api_call(
            method="post", url=self._get_url(), data=self._generate_data()
        )
        print(res.status_code)

    def list(self, model: str = None):
        res = self._api_call(method="get", url=self._get_url())

        data = res.json()

        return data

    def update(self):
        pk = self._get_pk()
        res = self._api_call(
            method="put",
            url=self._get_url(detail=True, pk=pk),
            data=self._generate_data(),
        )

        data = res.json()

        return data


class PostAPIHandler(APIHandler):
    def __init__(self, host: str = "http://127.0.0.1:8000"):
        super().__init__(host)
        self.root_url = "forum/post"

    def _generate_data(self, fk: int = None) -> dict:
        fake = Faker()
        data = {
            "topic": fk,
            "title": fake.text(max_nb_chars=20),
            "content": fake.text(max_nb_chars=100),
        }
        return data

    def _get_pk(self, model: str = None) -> int:
        res = self._api_call("get", f"{self.host}/forum/topic/")
        if model is None:
            res = self._api_call(
                "get", f"{self.host}/forum/topic/{self._get_pk('topic')}/posts"
            )

        data = res.json()

        return data[0].get("id")

    def create(self):
        fk = self._get_pk("topic")
        res = self._api_call(
            method="post", url=self._get_url(), data=self._generate_data(fk)
        )
        print(res.status_code)

    def list(self, model: str = None):
        res = self._api_call(
            method="get",
            url=f"{self.host}/forum/topic/{self._get_pk('topic')}/posts",
        )

        data = res.json()

        return data

    def update(self):
        pk = self._get_pk()
        fk = self._get_pk("topic")
        res = self._api_call(
            method="put",
            url=self._get_url(detail=True, pk=pk),
            data=self._generate_data(fk),
        )

        data = res.json()

        return data


if __name__ == "__main__":
    topic_handler = TopicAPIHandler()
    post_handler = PostAPIHandler()

    cnt = 0

    while cnt != 100:
        instance = [topic_handler, post_handler]
        method = ["create", "list", "update", "detail", "destroy"]
        for i in instance:
            for m in method:
                getattr(i, m)()
                print(f"{m} : done")
                period = uniform(0, 3)
                time.sleep(period)
                print(f"{period} seconds delayed")
                cnt += 1
                print(f"{cnt} times executed")
