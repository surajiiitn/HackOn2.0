"""Standalone core API views."""
import json
import logging
from typing import Iterable

import requests
from django.conf import settings
from django.http import JsonResponse

logger = logging.getLogger(__name__)

FAST2SMS_URL = "https://www.fast2sms.com/dev/bulkV2"
FAST2SMS_API_KEY = getattr(settings, "FAST2SMS_API_KEY", "[PASTE YOUR API KEY HERE]")
EMERGENCY_CONTACTS = getattr(
    settings,
    "FAST2SMS_EMERGENCY_CONTACTS",
    ["9XXXXXXXXX", "9XXXXXXXXX", "9XXXXXXXXX"],
)


def _normalize_number(number: str) -> str:
    digits = "".join(ch for ch in str(number) if ch.isdigit())
    if len(digits) > 10 and digits.startswith("91"):
        digits = digits[-10:]
    if len(digits) != 10:
        return ""
    return digits


def _resolve_contacts(raw_contacts: object) -> list[str]:
    if raw_contacts is None:
        raw_contacts = EMERGENCY_CONTACTS

    if isinstance(raw_contacts, str):
        parts: Iterable[str] = raw_contacts.split(",")
    elif isinstance(raw_contacts, (list, tuple, set)):
        parts = [str(item) for item in raw_contacts]
    else:
        parts = []

    cleaned: list[str] = []
    for item in parts:
        mobile = _normalize_number(item)
        if mobile and mobile not in cleaned:
            cleaned.append(mobile)
    return cleaned


def _resolve_name(request, payload: dict) -> str:
    if payload.get("user_name"):
        return str(payload["user_name"])

    user = getattr(request, "user", None)
    if user is not None and getattr(user, "is_authenticated", False):
        return (
            getattr(user, "get_full_name", lambda: "")().strip()
            or getattr(user, "username", "")
            or getattr(user, "phone_number", "")
            or "User"
        )
    return "User"


def _resolve_location(payload: dict) -> str:
    if payload.get("location"):
        return str(payload["location"])

    lat = payload.get("latitude", payload.get("lat"))
    lng = payload.get("longitude", payload.get("lng"))
    if lat is not None and lng is not None:
        return f"{lat}, {lng}"
    return "Location unavailable"


def send_sos_alert(request=None, trigger: str | None = None):
    """
    Send SOS alert SMS to emergency contacts using Fast2SMS.

    Can be called directly in Python: send_sos_alert(trigger="manual_sos")
    Or as an HTTP endpoint via POST /api/sos/
    """
    if request is not None and request.method not in {"POST", "GET"}:
        return JsonResponse(
            {
                "success": False,
                "message": "Only GET or POST is allowed",
                "fast2sms_response": {},
            },
            status=405,
        )

    payload: dict = {}
    if request is not None:
        if request.method == "POST" and request.body:
            try:
                payload = json.loads(request.body.decode("utf-8"))
            except json.JSONDecodeError:
                payload = {}
        elif request.method == "GET":
            payload = request.GET.dict()

    trigger = trigger or str(payload.get("trigger", "manual_sos"))
    user_name = _resolve_name(request, payload)
    location = _resolve_location(payload)
    message_text = (
        f"🚨 SOS ALERT: {user_name} needs immediate help! "
        f"Location: {location}. This is an automated safety alert."
    )

    contacts = _resolve_contacts(payload.get("emergency_contacts"))
    if not contacts:
        return JsonResponse(
            {
                "success": False,
                "message": "No valid 10-digit emergency contacts configured",
                "fast2sms_response": {},
            },
            status=400,
        )

    api_key = str(payload.get("fast2sms_api_key") or FAST2SMS_API_KEY).strip()
    if not api_key or api_key == "[PASTE YOUR API KEY HERE]":
        return JsonResponse(
            {
                "success": False,
                "message": "Fast2SMS API key is not configured",
                "fast2sms_response": {},
            },
            status=400,
        )

    headers = {"authorization": api_key}
    params = {
        "authorization": api_key,
        "variables_values": message_text,
        "message": message_text,
        "language": "english",
        "route": "q",
        "numbers": ",".join(contacts),
    }

    try:
        response = requests.get(
            FAST2SMS_URL,
            headers=headers,
            params=params,
            timeout=15,
        )
        try:
            raw_response = response.json()
        except ValueError:
            raw_response = {"status_code": response.status_code, "text": response.text}

        # Required debug print to terminal
        print(json.dumps(raw_response, ensure_ascii=False, indent=2))

        logger.info(
            "Fast2SMS SOS trigger=%s contacts=%d status=%s",
            trigger,
            len(contacts),
            response.status_code,
        )

        sent_ok = bool(raw_response.get("return") is True)
        return JsonResponse(
            {
                "success": sent_ok,
                "message": "SOS alerts sent" if sent_ok else "Fast2SMS request failed",
                "fast2sms_response": raw_response,
            },
            status=200 if sent_ok else 502,
        )
    except Exception as exc:
        logger.exception("Fast2SMS SOS API call failed")
        return JsonResponse(
            {
                "success": False,
                "message": str(exc),
                "fast2sms_response": {},
            },
            status=500,
        )
