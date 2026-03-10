"""URL configuration for Suraksha AI backend."""
from django.contrib import admin
from django.urls import path, include
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView

urlpatterns = [
    path("admin/", admin.site.urls),

    # API v1
    path("api/v1/auth/", include("apps.accounts.urls")),
    path("api/v1/users/", include("apps.accounts.urls_users")),
    path("api/v1/hazards/", include("apps.hazards.urls")),
    path("api/v1/sos/", include("apps.emergency.urls")),
    path("api/v1/routes/", include("apps.routing.urls")),
    path("api/v1/privacy/", include("apps.privacy.urls")),
    path("api/v1/dashboard/", include("apps.dashboard.urls")),

    # API docs
    path("api/schema/", SpectacularAPIView.as_view(), name="schema"),
    path("api/docs/", SpectacularSwaggerView.as_view(url_name="schema"), name="swagger"),
]
