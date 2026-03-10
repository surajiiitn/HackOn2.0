"""SMS service abstraction layer."""
import logging
from django.conf import settings

logger = logging.getLogger(__name__)


def send_sms(phone_number: str, message: str) -> bool:
    provider = getattr(settings, "SMS_PROVIDER", "console")

    if provider == "console":
        return _send_console(phone_number, message)
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
