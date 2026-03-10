from django.urls import path
from . import views

urlpatterns = [
    path("emergencies/", views.ActiveEmergenciesView.as_view(), name="dashboard-emergencies"),
    path("emergencies/<uuid:pk>/", views.EmergencyDetailView.as_view(), name="dashboard-emergency-detail"),
    path("emergencies/<uuid:pk>/resolve/", views.ResolveEmergencyView.as_view(), name="dashboard-resolve"),
    path("hazards/pending/", views.PendingHazardsView.as_view(), name="dashboard-pending-hazards"),
    path("hazards/<uuid:pk>/verify/", views.VerifyHazardView.as_view(), name="dashboard-verify-hazard"),
    path("analytics/", views.DashboardAnalyticsView.as_view(), name="dashboard-analytics"),
]
