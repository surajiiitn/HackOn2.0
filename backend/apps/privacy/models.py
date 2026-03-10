import uuid
from django.db import models
from apps.accounts.models import User


class DigitalFootprintScan(models.Model):
    """OSINT scan of user's digital footprint."""

    class ScanStatus(models.TextChoices):
        PENDING = "pending", "Pending"
        RUNNING = "running", "Running"
        COMPLETED = "completed", "Completed"
        FAILED = "failed", "Failed"

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="scans")
    status = models.CharField(max_length=10, choices=ScanStatus.choices, default=ScanStatus.PENDING)
    identity_score = models.IntegerField(default=0, help_text="0-100 integrity score")
    deepfake_score = models.FloatField(default=0.0, help_text="ML deepfake probability (0-1)")
    flagged_urls = models.JSONField(default=list, blank=True)
    breaches_found = models.JSONField(default=list, blank=True)
    scan_summary = models.TextField(blank=True)
    started_at = models.DateTimeField(null=True, blank=True)
    completed_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "digital_footprint_scans"
        ordering = ["-created_at"]

    def __str__(self):
        return f"Scan {self.id} for {self.user} ({self.status})"


class PrivacyNotice(models.Model):
    """Auto-generated legal takedown notices under DPDP Act."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="notices")
    scan = models.ForeignKey(
        DigitalFootprintScan, null=True, blank=True,
        on_delete=models.SET_NULL, related_name="notices"
    )
    flagged_url = models.URLField()
    platform_name = models.CharField(max_length=100, blank=True)
    breach_type = models.CharField(max_length=50, blank=True)
    notice_text = models.TextField(blank=True)
    notice_pdf_url = models.URLField(blank=True)
    is_sent = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "privacy_notices"
        ordering = ["-created_at"]

    def __str__(self):
        return f"Notice for {self.flagged_url}"
