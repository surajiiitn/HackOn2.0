from django.contrib import admin
from .models import User, EmergencyContact, OTP


@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = ["phone_number", "role", "is_verified", "created_at"]
    list_filter = ["role", "is_verified"]
    search_fields = ["phone_number", "username"]


@admin.register(EmergencyContact)
class EmergencyContactAdmin(admin.ModelAdmin):
    list_display = ["name", "phone_number", "user", "is_active"]
    list_filter = ["is_active"]


@admin.register(OTP)
class OTPAdmin(admin.ModelAdmin):
    list_display = ["phone_number", "code", "is_used", "created_at", "expires_at"]
    list_filter = ["is_used"]
