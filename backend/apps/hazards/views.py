import logging
from django.contrib.gis.geos import Point
from django.contrib.gis.db.models.functions import Distance
from django.contrib.gis.measure import D
from rest_framework import status, generics, permissions
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import HazardPin
from .serializers import HazardPinSerializer, HazardListSerializer

logger = logging.getLogger(__name__)


class DropPinView(generics.CreateAPIView):
    """Report a new hazard."""
    serializer_class = HazardPinSerializer

    def perform_create(self, serializer):
        logger.info(f"Hazard pin dropped by {self.request.user.phone_number}")
        serializer.save()


class HazardListView(generics.ListAPIView):
    """List hazards, optionally filtered by proximity."""
    serializer_class = HazardListSerializer

    def get_queryset(self):
        qs = HazardPin.objects.filter(is_active=True)

        lat = self.request.query_params.get("lat")
        lng = self.request.query_params.get("lng")
        radius = self.request.query_params.get("radius", 5000)  # meters

        if lat and lng:
            point = Point(float(lng), float(lat), srid=4326)
            qs = qs.filter(location__distance_lte=(point, D(m=int(radius))))
            qs = qs.annotate(distance=Distance("location", point)).order_by("distance")

        hazard_type = self.request.query_params.get("type")
        if hazard_type:
            qs = qs.filter(hazard_type=hazard_type)

        return qs


class UpvoteHazardView(APIView):
    """Upvote a hazard pin."""

    def post(self, request, pk):
        try:
            hazard = HazardPin.objects.get(pk=pk, is_active=True)
        except HazardPin.DoesNotExist:
            return Response({"error": "Hazard not found"}, status=status.HTTP_404_NOT_FOUND)

        if hazard.upvoted_by.filter(pk=request.user.pk).exists():
            return Response({"error": "Already upvoted"}, status=status.HTTP_400_BAD_REQUEST)

        hazard.upvoted_by.add(request.user)
        hazard.upvotes += 1
        hazard.save(update_fields=["upvotes"])

        return Response({"upvotes": hazard.upvotes})
