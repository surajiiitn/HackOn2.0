import random
import logging
from datetime import timedelta

from django.contrib.gis.geos import Point
from django.contrib.auth.hashers import make_password, check_password
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


class RequestOTPView(APIView):
    """Send OTP to a phone number."""
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = OTPRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        phone = serializer.validated_data["phone_number"]

        code = f"{random.randint(100000, 999999)}"
        OTP.objects.create(
            phone_number=phone,
            code=code,
            expires_at=timezone.now() + timedelta(minutes=5),
        )

        send_sms(phone, f"Your Suraksha AI verification code is: {code}")
        logger.info(f"OTP sent to {phone}")

        return Response(
            {"message": "OTP sent successfully", "expires_in": 300},
            status=status.HTTP_200_OK,
        )


class VerifyOTPView(APIView):
    """Verify OTP and return JWT tokens."""
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = OTPVerifySerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        phone = serializer.validated_data["phone_number"]
        code = serializer.validated_data["code"]

        otp = (
            OTP.objects.filter(
                phone_number=phone,
                code=code,
                is_used=False,
                expires_at__gt=timezone.now(),
            )
            .order_by("-created_at")
            .first()
        )

        if not otp:
            return Response(
                {"error": "Invalid or expired OTP"},
                status=status.HTTP_400_BAD_REQUEST,
            )

        otp.is_used = True
        otp.save()

        user, created = User.objects.get_or_create(
            phone_number=phone,
            defaults={"username": phone, "is_verified": True},
        )
        if not user.is_verified:
            user.is_verified = True
            user.save()

        refresh = RefreshToken.for_user(user)

        return Response({
            "access": str(refresh.access_token),
            "refresh": str(refresh),
            "is_new_user": created,
            "user": UserProfileSerializer(user).data,
        })


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
