from django.http import HttpResponse, JsonResponse
from pymongo import MongoClient

client = MongoClient(host="mongo")
db = client.likelion  # db 생성


def create_blog(request) -> bool:
    blog = {
        "title": "My first blog",
        "content": "This is my first blog",
        "author": "lion",
    }
    try:
        db.blogs.insert_one(blog)
        # return JsonResponse({"status": True})
        return HttpResponse("Success")
    except Exception as e:
        print(e)
        # return JsonResponse({"status": False})
        return HttpResponse("Failed")

def update_blog(request):
    pass

def delete_blog(request):
    pass

def read_blog(request):
    pass