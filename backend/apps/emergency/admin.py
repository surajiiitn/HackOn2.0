from django.contrib import admin
from .models import EmergencyEvent, EmergencyLog


@admin.register(EmergencyEvent)
class EmergencyEventAdmin(admin.ModelAdmin):
    list_display = ["user", "trigger_type", "status", "started_at", "resolved_at"]
    list_filter = ["status", "trigger_type"]
    readonly_fields = ["started_at"]


@admin.register(EmergencyLog)
class EmergencyLogAdmin(admin.ModelAdmin):
    list_display = ["event", "action", "created_at"]
    list_filter = ["action"]
