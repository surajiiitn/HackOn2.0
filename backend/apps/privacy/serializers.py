from rest_framework import serializers
from .models import DigitalFootprintScan, PrivacyNotice


class StartScanSerializer(serializers.Serializer):
    """Trigger a new digital footprint scan."""
    pass  # No input needed; scan is per-user


class ScanStatusSerializer(serializers.ModelSerializer):
    class Meta:
        model = DigitalFootprintScan
        fields = [
            "id", "status", "identity_score", "deepfake_score",
            "flagged_urls", "breaches_found", "scan_summary",
            "started_at", "completed_at", "created_at",
        ]


class GenerateNoticeSerializer(serializers.Serializer):
    flagged_url = serializers.URLField()
    platform_name = serializers.CharField(max_length=100, required=False, default="")
    breach_type = serializers.CharField(max_length=50, required=False, default="data_exposure")


class PrivacyNoticeSerializer(serializers.ModelSerializer):
    class Meta:
        model = PrivacyNotice
        fields = [
            "id", "flagged_url", "platform_name", "breach_type",
            "notice_text", "notice_pdf_url", "is_sent", "created_at",
        ]
