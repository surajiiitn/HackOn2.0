from rest_framework import serializers
from django.utils import timezone
from .models import User, EmergencyContact, OTP


class OTPRequestSerializer(serializers.Serializer):
    phone_number = serializers.CharField(max_length=15)


class OTPVerifySerializer(serializers.Serializer):
    phone_number = serializers.CharField(max_length=15)
    code = serializers.CharField(max_length=6)


class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = [
            "id", "phone_number", "username", "role",
            "preferred_language", "device_id", "device_platform",
            "is_verified", "created_at",
        ]
        read_only_fields = ["id", "phone_number", "is_verified", "created_at"]


class UserUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = [
            "username", "preferred_language",
            "device_id", "device_platform", "fcm_token",
        ]


class EmergencyContactSerializer(serializers.ModelSerializer):
    class Meta:
        model = EmergencyContact
        fields = [
            "id", "name", "phone_number", "relationship",
            "is_active", "notify_on_sos", "created_at",
        ]
        read_only_fields = ["id", "created_at"]

    def create(self, validated_data):
        validated_data["user"] = self.context["request"].user
        return super().create(validated_data)


class DuressSetupSerializer(serializers.Serializer):
    duress_pin = serializers.CharField(min_length=4, max_length=6)


class LocationUpdateSerializer(serializers.Serializer):
    latitude = serializers.FloatField(min_value=-90, max_value=90)
    longitude = serializers.FloatField(min_value=-180, max_value=180)
