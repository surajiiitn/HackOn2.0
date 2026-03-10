import logging
from django.contrib.gis.geos import Point
from django.utils import timezone
from rest_framework import status, generics, permissions
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import EmergencyEvent, EmergencyLog
from .serializers import SOSTriggerSerializer, EmergencyEventSerializer
from .tasks import task_dispatch_emergency_comms

logger = logging.getLogger(__name__)


class SOSTriggerView(APIView):
    """Trigger an SOS emergency event."""

    def post(self, request):
        serializer = SOSTriggerSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        lat = serializer.validated_data["latitude"]
        lng = serializer.validated_data["longitude"]
        location = Point(lng, lat, srid=4326)

        event = EmergencyEvent.objects.create(
            user=request.user,
            trigger_type=serializer.validated_data["trigger_type"],
            start_location=location,
            current_location=location,
            notes=serializer.validated_data.get("notes", ""),
        )

        # Update user's last known location
        request.user.last_known_location = location
        request.user.save(update_fields=["last_known_location"])

        EmergencyLog.objects.create(
            event=event,
            action="sos_triggered",
            actor=request.user,
            details={"trigger_type": event.trigger_type, "lat": lat, "lng": lng},
        )

        # Dispatch notifications asynchronously
        task_dispatch_emergency_comms.delay(str(event.id))

        logger.warning(f"🚨 SOS triggered by {request.user.phone_number} ({event.trigger_type})")

        return Response(
            EmergencyEventSerializer(event).data,
            status=status.HTTP_201_CREATED,
        )


class SOSCancelView(APIView):
    """Cancel an active SOS event."""

    def post(self, request, pk):
        try:
            event = EmergencyEvent.objects.get(pk=pk, user=request.user)
        except EmergencyEvent.DoesNotExist:
            return Response({"error": "Event not found"}, status=status.HTTP_404_NOT_FOUND)

        if event.status not in (EmergencyEvent.Status.ACTIVE, EmergencyEvent.Status.DISPATCHED):
            return Response({"error": "Event cannot be cancelled"}, status=status.HTTP_400_BAD_REQUEST)

        event.status = EmergencyEvent.Status.CANCELLED
        event.resolved_at = timezone.now()
        event.save(update_fields=["status", "resolved_at"])

        EmergencyLog.objects.create(
            event=event, action="cancelled_by_user", actor=request.user,
        )

        return Response({"message": "SOS cancelled"})


class SOSUpdateLocationView(APIView):
    """Update live location during active emergency."""

    def post(self, request, pk):
        try:
            event = EmergencyEvent.objects.get(
                pk=pk, user=request.user, status__in=["active", "dispatched", "responding"]
            )
        except EmergencyEvent.DoesNotExist:
            return Response({"error": "Active event not found"}, status=status.HTTP_404_NOT_FOUND)

        lat = request.data.get("latitude")
        lng = request.data.get("longitude")
        if lat and lng:
            location = Point(float(lng), float(lat), srid=4326)
            event.current_location = location
            event.save(update_fields=["current_location"])
            request.user.last_known_location = location
            request.user.save(update_fields=["last_known_location"])

        return Response({"message": "Location updated"})


class MyEmergenciesView(generics.ListAPIView):
    """List current user's emergency events."""
    serializer_class = EmergencyEventSerializer

    def get_queryset(self):
        return EmergencyEvent.objects.filter(user=self.request.user)
