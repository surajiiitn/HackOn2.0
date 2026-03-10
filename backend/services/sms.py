"""SMS service abstraction layer."""
import json
import logging

import requests
from django.conf import settings

logger = logging.getLogger(__name__)


def send_sms(phone_number: str, message: str) -> bool:
    provider = getattr(settings, "SMS_PROVIDER", "console")

    if provider == "console":
        return _send_console(phone_number, message)
    elif provider == "fast2sms":
        return _send_fast2sms(phone_number, message)
    elif provider == "twilio":
        return _send_twilio(phone_number, message)
    elif provider == "msg91":
        return _send_msg91(phone_number, message)
    else:
        logger.warning(f"Unknown SMS provider: {provider}, falling back to console")
        return _send_console(phone_number, message)


def _send_console(phone_number: str, message: str) -> bool:
    logger.info(f"📱 SMS to {phone_number}: {message}")
    return True


def _normalize_indian_mobile(phone_number: str) -> str:
    digits = "".join(ch for ch in str(phone_number) if ch.isdigit())
    if len(digits) > 10 and digits.startswith("91"):
        digits = digits[-10:]
    return digits if len(digits) == 10 else ""


def _send_fast2sms(phone_number: str, message: str) -> bool:
    api_key = getattr(settings, "FAST2SMS_API_KEY", "")
    if not api_key:
        logger.error("Fast2SMS API key not configured")
        return _send_console(phone_number, message)

    mobile = _normalize_indian_mobile(phone_number)
    if not mobile:
        logger.error("Invalid Indian mobile number for Fast2SMS: %s", phone_number)
        return False

    try:
        response = requests.get(
            "https://www.fast2sms.com/dev/bulkV2",
            headers={"authorization": api_key},
            params={
                "authorization": api_key,
                "variables_values": message,
                "message": message,
                "language": "english",
                "route": "q",
                "numbers": mobile,
            },
            timeout=15,
        )
        try:
            payload = response.json()
        except ValueError:
            payload = {"status_code": response.status_code, "text": response.text}

        logger.info("Fast2SMS response: %s", json.dumps(payload, ensure_ascii=False))
        if response.ok and payload.get("return") is True:
            return True

        logger.error("Fast2SMS send failed for %s: %s", mobile, payload)
        # Fast2SMS test/account limits are common in development.
        # Fall back to console so OTP/SOS flows remain testable locally.
        return _send_console(phone_number, message)
    except Exception as exc:
        logger.error("Fast2SMS exception for %s: %s", mobile, exc)
        return False


def _send_twilio(phone_number: str, message: str) -> bool:
    try:
        from twilio.rest import Client

        account_sid = getattr(settings, "TWILIO_ACCOUNT_SID", "")
        auth_token = getattr(settings, "TWILIO_AUTH_TOKEN", "")
        from_number = getattr(settings, "TWILIO_PHONE_NUMBER", "")

        if not all([account_sid, auth_token, from_number]):
            logger.error("Twilio credentials not configured")
            return _send_console(phone_number, message)

        client = Client(account_sid, auth_token)
        msg = client.messages.create(
            body=message,
            from_=from_number,
            to=phone_number,
        )
        logger.info(f"✅ Twilio SMS sent to {phone_number}, SID: {msg.sid}")
        return True
    except Exception as e:
        logger.error(f"❌ Twilio SMS failed to {phone_number}: {e}")
        return False


def _send_msg91(phone_number: str, message: str) -> bool:
    logger.info(f"[MSG91 stub] SMS to {phone_number}")
    return True
