import uuid
from django.contrib.gis.db import models
from apps.accounts.models import User


class HazardPin(models.Model):
    """User-reported hazard locations with spatial data."""

    class HazardType(models.TextChoices):
        BROKEN_STREETLIGHT = "broken_streetlight", "Broken Streetlight"
        HARASSMENT = "harassment", "Harassment Hotspot"
        SUSPICIOUS_ACTIVITY = "suspicious_activity", "Suspicious Activity"
        UNSAFE_ROAD = "unsafe_road", "Unsafe Road"
        CONSTRUCTION = "construction", "Construction Zone"
        FLOODING = "flooding", "Flooding"
        OTHER = "other", "Other"

    class VerificationStatus(models.TextChoices):
        PENDING = "pending", "Pending"
        VERIFIED = "verified", "Verified"
        REJECTED = "rejected", "Rejected"

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="hazard_pins")
    location = models.PointField(srid=4326)
    hazard_type = models.CharField(max_length=30, choices=HazardType.choices)
    description = models.TextField(blank=True)
    verification_status = models.CharField(
        max_length=10, choices=VerificationStatus.choices, default=VerificationStatus.PENDING
    )
    upvotes = models.PositiveIntegerField(default=0)
    upvoted_by = models.ManyToManyField(User, blank=True, related_name="upvoted_hazards")
    verified_by = models.ForeignKey(
        User, null=True, blank=True, on_delete=models.SET_NULL, related_name="verified_hazards"
    )
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    expires_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = "hazard_pins"
        ordering = ["-created_at"]
        indexes = [
            models.Index(fields=["hazard_type", "is_active"]),
        ]

    def __str__(self):
        return f"{self.hazard_type} at ({self.location.x}, {self.location.y})"
