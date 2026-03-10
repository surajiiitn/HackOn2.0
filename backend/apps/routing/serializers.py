from rest_framework import serializers
from .models import RouteRequest


class SafePathRequestSerializer(serializers.Serializer):
    start_lat = serializers.FloatField(min_value=-90, max_value=90)
    start_lng = serializers.FloatField(min_value=-180, max_value=180)
    end_lat = serializers.FloatField(min_value=-90, max_value=90)
    end_lng = serializers.FloatField(min_value=-180, max_value=180)


class SafePathResponseSerializer(serializers.ModelSerializer):
    start_lat = serializers.SerializerMethodField()
    start_lng = serializers.SerializerMethodField()
    end_lat = serializers.SerializerMethodField()
    end_lng = serializers.SerializerMethodField()

    class Meta:
        model = RouteRequest
        fields = [
            "id", "start_lat", "start_lng", "end_lat", "end_lng",
            "danger_score", "hazard_count", "route_data",
            "map_provider", "created_at",
        ]

    def get_start_lat(self, obj):
        return obj.start_location.y

    def get_start_lng(self, obj):
        return obj.start_location.x

    def get_end_lat(self, obj):
        return obj.end_location.y

    def get_end_lng(self, obj):
        return obj.end_location.x
