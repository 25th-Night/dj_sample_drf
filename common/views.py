from django.http import HttpResponse, JsonResponse, HttpResponseServerError
from django.conf import settings


from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import AllowAny
from rest_framework.views import APIView
from rest_framework.request import Request

from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)


from drf_spectacular.utils import extend_schema


class HealthCheckView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        return Response(status=status.HTTP_200_OK, data={"message": "정상"})


def healthcheck(request):
    return JsonResponse({"status": "okay"})


def get_version(request):
    if settings.VERSION == "0.3.0":
        return HttpResponse(status=500)
    return JsonResponse({"version": settings.VERSION})


def get_my_id(request):
    print(request.user)
    print(request.user.id)
    return JsonResponse({"my_id": request.user.id})


@extend_schema(tags=["User"])
class Me(APIView):
    def get(self, request: Request):
        return Response({"pk": request.user.id})


@extend_schema(tags=["Auth"])
class TokenObtainPairView_(TokenObtainPairView):
    pass


@extend_schema(tags=["Auth"])
class TokenRefreshView_(TokenRefreshView):
    pass
