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
    flagged_url = serializers.URLField(required=False)
    # Backward compatibility for clients that still send {"url": "..."}.
    url = serializers.URLField(required=False, write_only=True)
    platform_name = serializers.CharField(max_length=100, required=False, default="")
    breach_type = serializers.CharField(max_length=50, required=False, default="data_exposure")

    def validate(self, attrs):
        flagged = attrs.get("flagged_url") or attrs.get("url")
        if not flagged:
            raise serializers.ValidationError({"flagged_url": "This field is required."})
        attrs["flagged_url"] = flagged
        attrs.pop("url", None)
        return attrs


class PrivacyNoticeSerializer(serializers.ModelSerializer):
    class Meta:
        model = PrivacyNotice
        fields = [
            "id", "flagged_url", "platform_name", "breach_type",
            "notice_text", "notice_pdf_url", "is_sent", "created_at",
        ]
