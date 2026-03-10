import logging
from django.utils import timezone
from django.db.models import Count, Q
from rest_framework import status, generics, permissions
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.emergency.models import EmergencyEvent, EmergencyLog
from apps.emergency.serializers import EmergencyEventSerializer, ResolveEmergencySerializer
from apps.hazards.models import HazardPin
from apps.hazards.serializers import HazardListSerializer

logger = logging.getLogger(__name__)


class IsPoliceOrAdmin(permissions.BasePermission):
    """Only police or admin users can access dashboard endpoints."""

    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role in ("police", "admin")


class ActiveEmergenciesView(generics.ListAPIView):
    """List all active emergency events for the dashboard."""
    serializer_class = EmergencyEventSerializer
    permission_classes = [IsPoliceOrAdmin]

    def get_queryset(self):
        return EmergencyEvent.objects.filter(
            status__in=["active", "dispatched", "responding"]
        ).select_related("user").order_by("-started_at")


class EmergencyDetailView(generics.RetrieveAPIView):
    """Get detailed info about a specific emergency event."""
    serializer_class = EmergencyEventSerializer
    permission_classes = [IsPoliceOrAdmin]
    queryset = EmergencyEvent.objects.all()


class ResolveEmergencyView(APIView):
    """Resolve an emergency event (police/admin only)."""
    permission_classes = [IsPoliceOrAdmin]

    def post(self, request, pk):
        try:
            event = EmergencyEvent.objects.get(pk=pk)
        except EmergencyEvent.DoesNotExist:
            return Response({"error": "Event not found"}, status=status.HTTP_404_NOT_FOUND)

        serializer = ResolveEmergencySerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        event.status = serializer.validated_data["status"]
        event.resolved_by = request.user
        event.resolution_notes = serializer.validated_data.get("resolution_notes", "")
        event.resolved_at = timezone.now()
        event.save()

        EmergencyLog.objects.create(
            event=event,
            action=f"resolved_{event.status}",
            actor=request.user,
            details={"resolution_notes": event.resolution_notes},
        )

        logger.info(f"Emergency {pk} resolved by {request.user.phone_number}")
        return Response(EmergencyEventSerializer(event).data)


class VerifyHazardView(APIView):
    """Verify or reject a hazard pin (police/admin only)."""
    permission_classes = [IsPoliceOrAdmin]

    def post(self, request, pk):
        try:
            hazard = HazardPin.objects.get(pk=pk)
        except HazardPin.DoesNotExist:
            return Response({"error": "Hazard not found"}, status=status.HTTP_404_NOT_FOUND)

        action = request.data.get("action")  # "verify" or "reject"
        if action == "verify":
            hazard.verification_status = HazardPin.VerificationStatus.VERIFIED
            hazard.verified_by = request.user
        elif action == "reject":
            hazard.verification_status = HazardPin.VerificationStatus.REJECTED
            hazard.is_active = False
        else:
            return Response({"error": "action must be 'verify' or 'reject'"}, status=status.HTTP_400_BAD_REQUEST)

        hazard.save()
        return Response(HazardListSerializer(hazard).data)


class PendingHazardsView(generics.ListAPIView):
    """List hazard pins pending verification."""
    serializer_class = HazardListSerializer
    permission_classes = [IsPoliceOrAdmin]

    def get_queryset(self):
        return HazardPin.objects.filter(
            verification_status=HazardPin.VerificationStatus.PENDING, is_active=True
        )


class DashboardAnalyticsView(APIView):
    """Aggregate analytics for the admin dashboard."""
    permission_classes = [IsPoliceOrAdmin]

    def get(self, request):
        now = timezone.now()
        last_24h = now - timezone.timedelta(hours=24)
        last_7d = now - timezone.timedelta(days=7)

        return Response({
            "active_emergencies": EmergencyEvent.objects.filter(
                status__in=["active", "dispatched", "responding"]
            ).count(),
            "emergencies_24h": EmergencyEvent.objects.filter(started_at__gte=last_24h).count(),
            "emergencies_7d": EmergencyEvent.objects.filter(started_at__gte=last_7d).count(),
            "total_hazards": HazardPin.objects.filter(is_active=True).count(),
            "pending_hazards": HazardPin.objects.filter(
                verification_status="pending", is_active=True
            ).count(),
            "verified_hazards": HazardPin.objects.filter(verification_status="verified").count(),
            "trigger_breakdown": dict(
                EmergencyEvent.objects.filter(started_at__gte=last_7d)
                .values_list("trigger_type")
                .annotate(count=Count("id"))
                .values_list("trigger_type", "count")
            ),
        })
