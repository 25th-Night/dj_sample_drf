"""
URL configuration for config project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/4.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static

from drf_spectacular.views import (
    SpectacularAPIView,
    SpectacularRedocView,
    SpectacularSwaggerView,
)

from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)

from blog.urls import router as blog_router
from forum.urls import router as forum_router
from common.views import (
    HealthCheckView,
    Me,
    healthcheck,
    get_version,
    get_my_id,
    TokenObtainPairView_,
    TokenRefreshView_,
)

urlpatterns = [
    path("admin/", admin.site.urls),
    path("blog/", include(blog_router.urls)),
    path("forum/", include(forum_router.urls)),
    path("api/token/", TokenObtainPairView_.as_view(), name="token_obtain_pair"),
    path("api/token/refresh/", TokenRefreshView_.as_view(), name="token_refresh"),
    path("api-auth/", include("rest_framework.urls")),
    # drf-spectacular
    path("api/schema/", SpectacularAPIView.as_view(), name="api-schema"),
    path(
        "api/docs/",
        SpectacularSwaggerView.as_view(url_name="api-schema"),
        name="api-swagger-ui",
    ),
    path(
        "api/redoc/",
        SpectacularRedocView.as_view(url_name="api-schema"),
        name="api-redoc",
    ),
    # path("health", HealthCheckView.as_view(), name="health_check"),
    # path("health/", healthcheck, name="healthcheck"),
    path("version/", get_version, name="get_version"),
    path("users/me/", Me.as_view(), name="me"),
    path("", include("django_prometheus.urls")),
] + static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
