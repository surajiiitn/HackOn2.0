from rest_framework import serializers
from .models import EmergencyEvent, EmergencyLog


class SOSTriggerSerializer(serializers.Serializer):
    # Accept aliases from older/mobile clients and normalize to enum values.
    trigger_type = serializers.CharField()
    latitude = serializers.FloatField(min_value=-90, max_value=90)
    longitude = serializers.FloatField(min_value=-180, max_value=180)
    notes = serializers.CharField(required=False, allow_blank=True, default="")

    _TRIGGER_ALIASES = {
        "manual": EmergencyEvent.TriggerType.MANUAL_SOS,
        "audio_keyword": EmergencyEvent.TriggerType.SCREAM_DETECTION,
        "audio": EmergencyEvent.TriggerType.SCREAM_DETECTION,
    }

    def validate_trigger_type(self, value):
        normalized = value.strip().lower()
        normalized = self._TRIGGER_ALIASES.get(normalized, normalized)
        allowed = {choice for choice, _ in EmergencyEvent.TriggerType.choices}
        if normalized not in allowed:
            raise serializers.ValidationError(
                "Invalid trigger_type. Use one of: "
                + ", ".join(sorted(allowed))
            )
        return normalized


class EmergencyEventSerializer(serializers.ModelSerializer):
    user_phone = serializers.CharField(source="user.phone_number", read_only=True)
    start_lat = serializers.SerializerMethodField()
    start_lng = serializers.SerializerMethodField()

    class Meta:
        model = EmergencyEvent
        fields = [
            "id", "user_phone", "trigger_type", "status",
            "start_lat", "start_lng", "notes",
            "started_at", "resolved_at",
        ]

    def get_start_lat(self, obj):
        return obj.start_location.y if obj.start_location else None

    def get_start_lng(self, obj):
        return obj.start_location.x if obj.start_location else None


class EmergencyLogSerializer(serializers.ModelSerializer):
    class Meta:
        model = EmergencyLog
        fields = ["action", "details", "created_at"]


class ResolveEmergencySerializer(serializers.Serializer):
    resolution_notes = serializers.CharField(required=False, allow_blank=True, default="")
    status = serializers.ChoiceField(
        choices=[EmergencyEvent.Status.RESOLVED, EmergencyEvent.Status.FALSE_ALARM],
        default=EmergencyEvent.Status.RESOLVED,
    )
