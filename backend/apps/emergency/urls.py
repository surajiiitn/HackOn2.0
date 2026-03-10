from django.urls import path
from . import views

urlpatterns = [
    path("trigger/", views.SOSTriggerView.as_view(), name="sos-trigger"),
    path("<uuid:pk>/cancel/", views.SOSCancelView.as_view(), name="sos-cancel"),
    path("<uuid:pk>/location/", views.SOSUpdateLocationView.as_view(), name="sos-update-location"),
    path("history/", views.MyEmergenciesView.as_view(), name="sos-history"),
]
