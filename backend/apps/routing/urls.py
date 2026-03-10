from django.urls import path
from . import views

urlpatterns = [
    path("safe-path/", views.SafePathView.as_view(), name="safe-path"),
]
