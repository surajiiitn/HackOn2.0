from django.urls import path
from . import views

urlpatterns = [
    path("drop-pin/", views.DropPinView.as_view(), name="drop-pin"),
    path("list/", views.HazardListView.as_view(), name="hazard-list"),
    path("<uuid:pk>/upvote/", views.UpvoteHazardView.as_view(), name="hazard-upvote"),
]
