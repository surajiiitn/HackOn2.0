import uuid
from django.contrib.gis.db import models
from apps.accounts.models import User


class EmergencyEvent(models.Model):
    """Active SOS emergency events."""

    class TriggerType(models.TextChoices):
        MANUAL_SOS = "manual_sos", "Manual SOS"
        SCREAM_DETECTION = "scream_detection", "Scream Detection"
        DURESS_PIN = "duress_pin", "Duress PIN"
        OFFLINE_FALLBACK = "offline_fallback", "Offline Fallback"
        SHAKE_GESTURE = "shake_gesture", "Shake Gesture"

    class Status(models.TextChoices):
        ACTIVE = "active", "Active"
        DISPATCHED = "dispatched", "Dispatched"
        RESPONDING = "responding", "Responding"
        RESOLVED = "resolved", "Resolved"
        CANCELLED = "cancelled", "Cancelled"
        FALSE_ALARM = "false_alarm", "False Alarm"

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="emergencies")
    trigger_type = models.CharField(max_length=20, choices=TriggerType.choices)
    status = models.CharField(max_length=15, choices=Status.choices, default=Status.ACTIVE)
    start_location = models.PointField(srid=4326)
    current_location = models.PointField(null=True, blank=True, srid=4326)
    notes = models.TextField(blank=True)
    resolved_by = models.ForeignKey(
        User, null=True, blank=True, on_delete=models.SET_NULL, related_name="resolved_emergencies"
    )
    resolution_notes = models.TextField(blank=True)
    started_at = models.DateTimeField(auto_now_add=True)
    resolved_at = models.DateTimeField(null=True, blank=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "emergency_events"
        ordering = ["-started_at"]
        indexes = [
            models.Index(fields=["status", "-started_at"]),
        ]

    def __str__(self):
        return f"SOS {self.trigger_type} by {self.user} ({self.status})"


class EmergencyLog(models.Model):
    """Audit trail for emergency event state changes."""

    event = models.ForeignKey(EmergencyEvent, on_delete=models.CASCADE, related_name="logs")
    action = models.CharField(max_length=50)
    actor = models.ForeignKey(User, null=True, blank=True, on_delete=models.SET_NULL)
    details = models.JSONField(default=dict)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "emergency_logs"
        ordering = ["-created_at"]
