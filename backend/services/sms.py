"""SMS service abstraction layer."""
import logging
from django.conf import settings

logger = logging.getLogger(__name__)


def send_sms(phone_number: str, message: str) -> bool:
    """
    Send an SMS using the configured provider.

    Providers:
    - 'console': Logs to console (development)
    - 'twilio': Uses Twilio API (production)
    - 'msg91': Uses MSG91 API (India-focused)

    Configure via SMS_PROVIDER in settings.
    """
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
    """Log SMS to console (development mode)."""
    logger.info(f"📱 SMS to {phone_number}: {message}")
    return True


def _send_twilio(phone_number: str, message: str) -> bool:
    """Send SMS via Twilio. TODO: Implement with twilio package."""
    # from twilio.rest import Client
    # client = Client(settings.TWILIO_SID, settings.TWILIO_TOKEN)
    # client.messages.create(body=message, from_=settings.TWILIO_FROM, to=phone_number)
    logger.info(f"[Twilio stub] SMS to {phone_number}")
    return True


def _send_msg91(phone_number: str, message: str) -> bool:
    """Send SMS via MSG91. TODO: Implement with requests."""
    # import requests
    # requests.post("https://api.msg91.com/api/v5/flow/", ...)
    logger.info(f"[MSG91 stub] SMS to {phone_number}")
    return True
