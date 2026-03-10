"""User management URL routes."""
from django.urls import path
from . import views

urlpatterns = [
    path("profile/", views.UserProfileView.as_view(), name="user-profile"),
    path("contacts/", views.EmergencyContactListCreateView.as_view(), name="contacts-list"),
    path("contacts/<uuid:pk>/", views.EmergencyContactDetailView.as_view(), name="contacts-detail"),
    path("duress-pin/", views.SetDuressPinView.as_view(), name="set-duress-pin"),
    path("location/", views.UpdateLocationView.as_view(), name="update-location"),
]
