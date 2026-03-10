import logging
from celery import shared_task

logger = logging.getLogger(__name__)


@shared_task(bind=True, max_retries=3, default_retry_delay=10)
def task_dispatch_emergency_comms(self, event_id):
    """Notify emergency contacts and police dashboard when SOS is triggered."""
    from apps.emergency.models import EmergencyEvent, EmergencyLog
    from apps.accounts.models import EmergencyContact
    from services.sms import send_sms

    try:
        event = EmergencyEvent.objects.select_related("user").get(pk=event_id)
    except EmergencyEvent.DoesNotExist:
        logger.error(f"Emergency event {event_id} not found")
        return

    user = event.user
    lat = event.start_location.y
    lng = event.start_location.x

    # Build tracking link (placeholder — replace with real URL in production)
    tracking_url = f"https://suraksha.app/track/{event.id}"

    message = (
        f"🚨 EMERGENCY ALERT from {user.phone_number}!\n"
        f"Type: {event.get_trigger_type_display()}\n"
        f"Location: {lat:.6f}, {lng:.6f}\n"
        f"Maps: https://maps.google.com/?q={lat},{lng}\n"
        f"Track live: {tracking_url}"
    )

    contacts = EmergencyContact.objects.filter(user=user, is_active=True, notify_on_sos=True)
    notified = []

    for contact in contacts:
        try:
            send_sms(contact.phone_number, message)
            notified.append(contact.phone_number)
        except Exception as e:
            logger.error(f"Failed to notify {contact.phone_number}: {e}")

    # Update event status
    event.status = EmergencyEvent.Status.DISPATCHED
    event.save(update_fields=["status"])

    EmergencyLog.objects.create(
        event=event,
        action="comms_dispatched",
        details={"notified_contacts": notified, "total": len(notified)},
    )

    logger.info(f"✅ Emergency comms dispatched for event {event_id} to {len(notified)} contacts")
    return {"event_id": event_id, "contacts_notified": len(notified)}
