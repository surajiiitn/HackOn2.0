from rest_framework import serializers
from .models import EmergencyEvent, EmergencyLog


class SOSTriggerSerializer(serializers.Serializer):
    trigger_type = serializers.ChoiceField(choices=EmergencyEvent.TriggerType.choices)
    latitude = serializers.FloatField(min_value=-90, max_value=90)
    longitude = serializers.FloatField(min_value=-180, max_value=180)
    notes = serializers.CharField(required=False, allow_blank=True, default="")


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
