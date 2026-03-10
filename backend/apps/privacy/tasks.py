import logging
from celery import shared_task

logger = logging.getLogger(__name__)


@shared_task(bind=True, max_retries=2, default_retry_delay=30)
def task_run_osint_scraper(self, scan_id):
    """
    Run OSINT digital footprint scan.
    Checks public breach databases and social media for exposed data.
    """
    from django.utils import timezone
    from apps.privacy.models import DigitalFootprintScan
    from services.osint import run_osint_scan

    try:
        scan = DigitalFootprintScan.objects.get(pk=scan_id)
    except DigitalFootprintScan.DoesNotExist:
        logger.error(f"Scan {scan_id} not found")
        return

    scan.status = DigitalFootprintScan.ScanStatus.RUNNING
    scan.started_at = timezone.now()
    scan.save(update_fields=["status", "started_at"])

    try:
        result = run_osint_scan(scan.user)

        scan.identity_score = result.get("identity_score", 0)
        scan.flagged_urls = result.get("flagged_urls", [])
        scan.breaches_found = result.get("breaches_found", [])
        scan.scan_summary = result.get("summary", "")
        scan.status = DigitalFootprintScan.ScanStatus.COMPLETED
        scan.completed_at = timezone.now()
        scan.save()

        logger.info(f"✅ OSINT scan {scan_id} completed. Score: {scan.identity_score}")

    except Exception as e:
        scan.status = DigitalFootprintScan.ScanStatus.FAILED
        scan.scan_summary = str(e)
        scan.save(update_fields=["status", "scan_summary"])
        logger.error(f"❌ OSINT scan {scan_id} failed: {e}")
        raise self.retry(exc=e)

    return {"scan_id": scan_id, "score": scan.identity_score}


@shared_task(bind=True, max_retries=2)
def task_analyze_deepfake(self, scan_id, image_url=None):
    """
    Placeholder task for deepfake detection.
    Will call an ML model service when integrated.
    """
    from apps.privacy.models import DigitalFootprintScan
    from services.deepfake import analyze_deepfake

    try:
        scan = DigitalFootprintScan.objects.get(pk=scan_id)
    except DigitalFootprintScan.DoesNotExist:
        return

    try:
        result = analyze_deepfake(image_url)
        scan.deepfake_score = result.get("probability", 0.0)
        scan.save(update_fields=["deepfake_score"])
        logger.info(f"Deepfake analysis for scan {scan_id}: score={scan.deepfake_score}")
    except Exception as e:
        logger.error(f"Deepfake analysis failed for scan {scan_id}: {e}")
        raise self.retry(exc=e)

    return {"scan_id": scan_id, "deepfake_score": scan.deepfake_score}
