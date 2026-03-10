import random
import logging
from datetime import timedelta

from django.contrib.gis.geos import Point
from django.contrib.auth.hashers import make_password, check_password
from django.conf import settings
from django.utils import timezone
from rest_framework import status, generics, permissions
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken

from .models import User, EmergencyContact, OTP
from .serializers import (
    OTPRequestSerializer,
    OTPVerifySerializer,
    UserProfileSerializer,
    UserUpdateSerializer,
    EmergencyContactSerializer,
    DuressSetupSerializer,
    LocationUpdateSerializer,
)
from services.sms import send_sms

logger = logging.getLogger(__name__)


def _normalize_phone_number(phone: str) -> str:
    raw = str(phone).strip()
    digits = "".join(ch for ch in raw if ch.isdigit())

    if len(digits) == 10:
        return f"+91{digits}"
    if len(digits) == 11 and digits.startswith("0"):
        return f"+91{digits[1:]}"
    if len(digits) == 12 and digits.startswith("91"):
        return f"+{digits}"
    if raw.startswith("+") and len(digits) >= 10:
        return f"+{digits}"
    return raw


def _issue_auth_response(phone: str) -> Response:
    user, created = User.objects.get_or_create(
        phone_number=phone,
        defaults={"username": phone, "is_verified": True},
    )
    if not user.is_verified:
        user.is_verified = True
        user.save(update_fields=["is_verified"])

    refresh = RefreshToken.for_user(user)
    return Response({
        "access": str(refresh.access_token),
        "refresh": str(refresh),
        "is_new_user": created,
        "user": UserProfileSerializer(user).data,
    })


class RequestOTPView(APIView):
    """Send OTP to a phone number."""
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = OTPRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        phone = _normalize_phone_number(serializer.validated_data["phone_number"])

        code = f"{random.randint(100000, 999999)}"
        # Keep only one active OTP per phone to avoid user confusion.
        OTP.objects.filter(phone_number=phone, is_used=False).update(is_used=True)
        otp = OTP.objects.create(
            phone_number=phone,
            code=code,
            expires_at=timezone.now() + timedelta(minutes=5),
        )

        sent = send_sms(phone, f"Your Suraksha AI verification code is: {code}")
        if not sent:
            # Avoid keeping OTPs that were never delivered.
            otp.delete()
            logger.error(f"OTP delivery failed for {phone}")
            return Response(
                {"error": "Failed to send OTP. Please retry."},
                status=status.HTTP_502_BAD_GATEWAY,
            )

        logger.info(f"OTP sent to {phone}")

        return Response(
            {"message": "OTP sent successfully", "expires_in": 300},
            status=status.HTTP_200_OK,
        )


class VerifyOTPView(APIView):
    """Verify OTP and return JWT tokens."""
    permission_classes = [permissions.AllowAny]

    def _verify(self, phone_input: str, code_input: str):
        phone = _normalize_phone_number(phone_input)
        code = str(code_input).strip()
        now = timezone.now()

        dummy_enabled = bool(getattr(settings, "DUMMY_AUTH_ENABLED", False))
        dummy_phone = _normalize_phone_number(getattr(settings, "DUMMY_AUTH_PHONE", ""))
        if dummy_enabled:
            # Hackathon/dev bypass: always allow verification when dummy auth is enabled.
            # This guarantees login flow works even if OTP entry/network/cache is flaky.
            target_phone = phone or dummy_phone or "+917877139375"
            logger.warning("Dummy auth bypass active for %s", target_phone)
            return _issue_auth_response(target_phone)

        otp = (
            OTP.objects.filter(phone_number=phone, code=code)
            .order_by("-created_at")
            .first()
        )

        if otp is None:
            return Response(
                {"error": "Invalid or expired OTP"},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if otp.expires_at <= now:
            return Response(
                {"error": "OTP expired. Please request a new OTP."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if otp.is_used and not settings.DEBUG:
            return Response(
                {"error": "OTP already used. Please request a new OTP."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # In DEBUG we allow retry with same still-valid OTP to avoid false negatives
        # from duplicate verification attempts during local testing.
        if not otp.is_used:
            otp.is_used = True
            otp.save(update_fields=["is_used"])

        return _issue_auth_response(phone)

    def post(self, request):
        serializer = OTPVerifySerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        return self._verify(
            serializer.validated_data["phone_number"],
            serializer.validated_data["code"],
        )

    def get(self, request):
        phone = request.query_params.get("phone_number", "")
        code = request.query_params.get("code", "")
        if not phone or not code:
            return Response(
                {
                    "detail": (
                        "Provide phone_number and code query params, or use "
                        "POST with JSON body."
                    )
                },
                status=status.HTTP_400_BAD_REQUEST,
            )
        return self._verify(phone, code)


class UserProfileView(generics.RetrieveUpdateAPIView):
    """Get or update user profile."""
    serializer_class = UserProfileSerializer

    def get_object(self):
        return self.request.user

    def get_serializer_class(self):
        if self.request.method in ("PUT", "PATCH"):
            return UserUpdateSerializer
        return UserProfileSerializer


class EmergencyContactListCreateView(generics.ListCreateAPIView):
    """List and create emergency contacts."""
    serializer_class = EmergencyContactSerializer

    def get_queryset(self):
        return EmergencyContact.objects.filter(user=self.request.user)


class EmergencyContactDetailView(generics.RetrieveUpdateDestroyAPIView):
    """Manage a specific emergency contact."""
    serializer_class = EmergencyContactSerializer

    def get_queryset(self):
        return EmergencyContact.objects.filter(user=self.request.user)


class SetDuressPinView(APIView):
    """Set a duress PIN for silent emergency trigger."""

    def post(self, request):
        serializer = DuressSetupSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        request.user.duress_pin = make_password(serializer.validated_data["duress_pin"])
        request.user.save(update_fields=["duress_pin"])
        return Response({"message": "Duress PIN set successfully"})


class UpdateLocationView(APIView):
    """Update user's last known location."""

    def post(self, request):
        serializer = LocationUpdateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        lat = serializer.validated_data["latitude"]
        lng = serializer.validated_data["longitude"]
        request.user.last_known_location = Point(lng, lat, srid=4326)
        request.user.save(update_fields=["last_known_location"])
        return Response({"message": "Location updated"})
