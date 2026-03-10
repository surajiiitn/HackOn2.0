import uuid
from django.contrib.gis.db import models
from apps.accounts.models import User


class RouteRequest(models.Model):
    """Saved route calculations."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="routes")
    start_location = models.PointField(srid=4326)
    end_location = models.PointField(srid=4326)
    danger_score = models.FloatField(default=0.0, help_text="0-100 danger score")
    hazard_count = models.IntegerField(default=0)
    route_data = models.JSONField(default=dict, blank=True, help_text="Polyline/waypoints from map provider")
    map_provider = models.CharField(max_length=30, default="stub")
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "route_requests"
        ordering = ["-created_at"]

    def __str__(self):
        return f"Route {self.id} (danger: {self.danger_score})"
