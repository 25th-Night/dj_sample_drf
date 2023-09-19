from django.http import JsonResponse
from django.conf import settings


class HealthCheckMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        if settings.VERSION == "0.3.0":
            return JsonResponse({"status": "unhealthy"}, status=500)
        if request.path == "/health/":
            return JsonResponse({"status": "ok"})

        return self.get_response(request)  # 그다음 미들웨어로 보냄


# class VersionCheckMiddleware:
#     def __init__(self, get_response):
#         self.get_response = get_response

#     def __call__(self, request):
#         if request.path == "/version/":
#             return JsonResponse({"version": settings.VERSION})

#         return self.get_response(request)  # 그다음 미들웨어로 보냄
