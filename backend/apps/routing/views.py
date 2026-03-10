import logging
from django.conf import settings
from django.contrib.gis.geos import Point
from django.contrib.gis.measure import D
from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import RouteRequest
from .serializers import SafePathRequestSerializer, SafePathResponseSerializer
from apps.hazards.models import HazardPin
from services.map_provider import get_map_provider

logger = logging.getLogger(__name__)

# Hazard proximity radius for danger score calculation (meters)
HAZARD_RADIUS = 500


class SafePathView(APIView):
    """
    Calculate the safest route between two points.
    Analyzes nearby hazards and computes a danger score.
    """

    def post(self, request):
        serializer = SafePathRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        start = Point(
            serializer.validated_data["start_lng"],
            serializer.validated_data["start_lat"],
            srid=4326,
        )
        end = Point(
            serializer.validated_data["end_lng"],
            serializer.validated_data["end_lat"],
            srid=4326,
        )

        # Get route from map provider (stub returns direct path)
        provider = get_map_provider()
        route_data = provider.get_route(start, end)

        # Analyze hazards along the route corridor
        midpoint = Point((start.x + end.x) / 2, (start.y + end.y) / 2, srid=4326)
        corridor_radius = start.distance(end) * 111000 / 2 + HAZARD_RADIUS  # approx meters

        nearby_hazards = HazardPin.objects.filter(
            is_active=True,
            location__distance_lte=(midpoint, D(m=max(corridor_radius, HAZARD_RADIUS))),
        )

        hazard_count = nearby_hazards.count()

        # Compute danger score (0-100)
        danger_score = min(100.0, hazard_count * 15.0)

        # Boost score for verified or highly-upvoted hazards
        for hazard in nearby_hazards[:20]:
            if hazard.verification_status == "verified":
                danger_score = min(100.0, danger_score + 5.0)
            if hazard.upvotes >= 5:
                danger_score = min(100.0, danger_score + 3.0)

        route = RouteRequest.objects.create(
            user=request.user,
            start_location=start,
            end_location=end,
            danger_score=round(danger_score, 1),
            hazard_count=hazard_count,
            route_data=route_data,
            map_provider=settings.MAP_PROVIDER,
        )

        return Response(SafePathResponseSerializer(route).data, status=status.HTTP_200_OK)
