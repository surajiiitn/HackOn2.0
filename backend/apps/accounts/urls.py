"""Auth URL routes."""
from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from . import views

urlpatterns = [
    path("login/", views.RequestOTPView.as_view(), name="request-otp"),
    path("verify/", views.VerifyOTPView.as_view(), name="verify-otp"),
    path("refresh/", TokenRefreshView.as_view(), name="token-refresh"),
]
