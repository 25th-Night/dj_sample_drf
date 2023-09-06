from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import AllowAny

from django.http import JsonResponse


class HealthCheckView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        return Response(status=status.HTTP_200_OK, data={"message": "정상"})


def healthcheck(request):
    return JsonResponse({"status": "okay"})
