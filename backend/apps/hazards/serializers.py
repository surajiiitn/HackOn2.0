from rest_framework import serializers
from rest_framework_gis.serializers import GeoFeatureModelSerializer
from .models import HazardPin


class HazardPinSerializer(serializers.ModelSerializer):
    latitude = serializers.FloatField(write_only=True)
    longitude = serializers.FloatField(write_only=True)
    lat = serializers.SerializerMethodField()
    lng = serializers.SerializerMethodField()
    reporter = serializers.StringRelatedField(source="user", read_only=True)

    class Meta:
        model = HazardPin
        fields = [
            "id", "latitude", "longitude", "lat", "lng",
            "hazard_type", "description", "verification_status",
            "upvotes", "is_active", "reporter", "created_at",
        ]
        read_only_fields = ["id", "verification_status", "upvotes", "is_active", "created_at"]

    def get_lat(self, obj):
        return obj.location.y if obj.location else None

    def get_lng(self, obj):
        return obj.location.x if obj.location else None

    def create(self, validated_data):
        from django.contrib.gis.geos import Point
        lat = validated_data.pop("latitude")
        lng = validated_data.pop("longitude")
        validated_data["location"] = Point(lng, lat, srid=4326)
        validated_data["user"] = self.context["request"].user
        return super().create(validated_data)


class HazardListSerializer(serializers.ModelSerializer):
    lat = serializers.SerializerMethodField()
    lng = serializers.SerializerMethodField()

    class Meta:
        model = HazardPin
        fields = [
            "id", "lat", "lng", "hazard_type", "description",
            "verification_status", "upvotes", "is_active", "created_at",
        ]

    def get_lat(self, obj):
        return obj.location.y if obj.location else None

    def get_lng(self, obj):
        return obj.location.x if obj.location else None
