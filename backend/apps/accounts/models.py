import uuid
from django.contrib.auth.models import AbstractUser
from django.contrib.gis.db import models
from django.contrib.postgres.fields import ArrayField
from django.core.validators import RegexValidator


class User(AbstractUser):
    """Custom user with phone-based auth and safety features."""

    class Role(models.TextChoices):
        CITIZEN = "citizen", "Citizen"
        POLICE = "police", "Police"
        ADMIN = "admin", "Admin"

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    phone_number = models.CharField(
        max_length=15,
        unique=True,
        validators=[RegexValidator(r"^\+?\d{10,15}$", "Enter a valid phone number.")],
    )
    role = models.CharField(max_length=10, choices=Role.choices, default=Role.CITIZEN)
    preferred_language = models.CharField(max_length=10, default="en")
    duress_pin = models.CharField(max_length=128, blank=True, help_text="Hashed duress PIN")
    device_id = models.CharField(max_length=255, blank=True)
    device_platform = models.CharField(max_length=20, blank=True)
    fcm_token = models.CharField(max_length=255, blank=True, help_text="Firebase Cloud Messaging token")
    is_verified = models.BooleanField(default=False)
    last_known_location = models.PointField(null=True, blank=True, srid=4326)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    # Make phone_number the login field
    USERNAME_FIELD = "phone_number"
    REQUIRED_FIELDS = ["username"]

    class Meta:
        db_table = "users"
        ordering = ["-created_at"]

    def __str__(self):
        return f"{self.phone_number} ({self.role})"


class EmergencyContact(models.Model):
    """Emergency contacts linked to a user."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="emergency_contacts")
    name = models.CharField(max_length=100)
    phone_number = models.CharField(
        max_length=15,
        validators=[RegexValidator(r"^\+?\d{10,15}$", "Enter a valid phone number.")],
    )
    relationship = models.CharField(max_length=50, blank=True)
    is_active = models.BooleanField(default=True)
    notify_on_sos = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "emergency_contacts"
        ordering = ["-created_at"]
        unique_together = ["user", "phone_number"]

    def __str__(self):
        return f"{self.name} ({self.phone_number})"


class OTP(models.Model):
    """One-time passwords for phone verification."""

    phone_number = models.CharField(max_length=15)
    code = models.CharField(max_length=6)
    is_used = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField()

    class Meta:
        db_table = "otps"
        ordering = ["-created_at"]

    def __str__(self):
        return f"OTP for {self.phone_number}"
