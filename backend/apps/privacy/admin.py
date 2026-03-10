from django.contrib import admin
from .models import DigitalFootprintScan, PrivacyNotice


@admin.register(DigitalFootprintScan)
class ScanAdmin(admin.ModelAdmin):
    list_display = ["user", "status", "identity_score", "created_at"]
    list_filter = ["status"]


@admin.register(PrivacyNotice)
class NoticeAdmin(admin.ModelAdmin):
    list_display = ["user", "flagged_url", "is_sent", "created_at"]
    list_filter = ["is_sent"]
