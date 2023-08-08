from pymongo import MongoClient

client = MongoClient()
db = client.likelion  # db 생성


def create_blog() -> bool:
    blog = {
        "title": "My first blog",
        "content": "This is my first blog",
        "author": "lion",
    }
    try:
        db.blogs.insert_one(blog)  # blogs 라는 collection에 데이터 추가
        return True
    except Exception as e:
        print(e)
        return False

def update_blog():
    pass

def delete():
    pass

def read_blog():
    pass