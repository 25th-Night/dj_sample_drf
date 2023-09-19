from django.http import HttpResponse, JsonResponse, HttpResponseServerError
from django.conf import settings


from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import AllowAny


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
