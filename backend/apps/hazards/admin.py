from django.contrib import admin
from .models import HazardPin


@admin.register(HazardPin)
class HazardPinAdmin(admin.ModelAdmin):
    list_display = ["hazard_type", "verification_status", "upvotes", "is_active", "created_at"]
    list_filter = ["hazard_type", "verification_status", "is_active"]
    search_fields = ["description"]
