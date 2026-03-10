import logging
from rest_framework import status, generics
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import DigitalFootprintScan, PrivacyNotice
from .serializers import (
    ScanStatusSerializer,
    GenerateNoticeSerializer,
    PrivacyNoticeSerializer,
)
from .tasks import task_run_osint_scraper

logger = logging.getLogger(__name__)


class StartScanView(APIView):
    """Start a new OSINT digital footprint scan."""

    def post(self, request):
        # Check for in-progress scans
        active_scan = DigitalFootprintScan.objects.filter(
            user=request.user, status__in=["pending", "running"]
        ).first()

        if active_scan:
            return Response(
                {"message": "Scan already in progress", "scan": ScanStatusSerializer(active_scan).data},
                status=status.HTTP_409_CONFLICT,
            )

        scan = DigitalFootprintScan.objects.create(user=request.user)
        task_run_osint_scraper.delay(str(scan.id))

        logger.info(f"OSINT scan started for {request.user.phone_number}")

        return Response(
            ScanStatusSerializer(scan).data,
            status=status.HTTP_201_CREATED,
        )


class ScanStatusView(APIView):
    """Get status of the latest or specific scan."""

    def get(self, request):
        scan_id = request.query_params.get("scan_id")

        if scan_id:
            try:
                scan = DigitalFootprintScan.objects.get(pk=scan_id, user=request.user)
            except DigitalFootprintScan.DoesNotExist:
                return Response({"error": "Scan not found"}, status=status.HTTP_404_NOT_FOUND)
        else:
            scan = DigitalFootprintScan.objects.filter(user=request.user).first()
            if not scan:
                return Response({"error": "No scans found"}, status=status.HTTP_404_NOT_FOUND)

        return Response(ScanStatusSerializer(scan).data)


class GenerateNoticeView(APIView):
    """Generate a DPDP Act takedown notice."""

    def post(self, request):
        serializer = GenerateNoticeSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        notice_text = _generate_dpdp_notice(
            user=request.user,
            url=serializer.validated_data["flagged_url"],
            platform=serializer.validated_data.get("platform_name", ""),
            breach_type=serializer.validated_data.get("breach_type", "data_exposure"),
        )

        notice = PrivacyNotice.objects.create(
            user=request.user,
            flagged_url=serializer.validated_data["flagged_url"],
            platform_name=serializer.validated_data.get("platform_name", ""),
            breach_type=serializer.validated_data.get("breach_type", ""),
            notice_text=notice_text,
        )

        return Response(PrivacyNoticeSerializer(notice).data, status=status.HTTP_201_CREATED)


class NoticeListView(generics.ListAPIView):
    """List user's generated takedown notices."""
    serializer_class = PrivacyNoticeSerializer

    def get_queryset(self):
        return PrivacyNotice.objects.filter(user=self.request.user)


def _generate_dpdp_notice(user, url, platform, breach_type):
    """Generate a legal notice template under DPDP Act 2023."""
    return (
        f"LEGAL NOTICE UNDER THE DIGITAL PERSONAL DATA PROTECTION ACT, 2023\n\n"
        f"To: The Data Fiduciary / Platform Operator\n"
        f"Platform: {platform or 'Unknown'}\n"
        f"URL: {url}\n\n"
        f"Subject: Request for Erasure of Personal Data\n\n"
        f"Dear Sir/Madam,\n\n"
        f"I, the undersigned Data Principal (contact: {user.phone_number}), hereby invoke my rights "
        f"under Section 12 of the Digital Personal Data Protection Act, 2023 (India) to request "
        f"the immediate erasure of my personal data hosted at the above URL.\n\n"
        f"Breach Type: {breach_type}\n\n"
        f"Under Section 12(1), a Data Principal has the right to erasure of personal data "
        f"that is no longer necessary for the purpose for which it was processed, or where "
        f"consent has been withdrawn.\n\n"
        f"I request that the data be removed within 72 hours of receipt of this notice. "
        f"Failure to comply may result in a complaint to the Data Protection Board of India "
        f"under Section 27 of the Act.\n\n"
        f"Regards,\n"
        f"Data Principal (Suraksha AI User)\n"
        f"Contact: {user.phone_number}\n"
    )
