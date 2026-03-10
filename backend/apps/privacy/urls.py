from django.urls import path
from . import views

urlpatterns = [
    path("scan/start/", views.StartScanView.as_view(), name="start-scan"),
    path("scan/status/", views.ScanStatusView.as_view(), name="scan-status"),
    path("generate-notice/", views.GenerateNoticeView.as_view(), name="generate-notice"),
    path("notices/", views.NoticeListView.as_view(), name="notice-list"),
]
