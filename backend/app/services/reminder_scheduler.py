import threading
import time

from ..core.config import settings
from ..database import SessionLocal
from .reminder_service import ReminderService
from ..models import Organization


def _run_reminder_loop() -> None:
    while True:
        try:
            db = SessionLocal()
            try:
                service = ReminderService(db)
                organizations = db.query(Organization).filter(Organization.is_active.is_(True)).all()
                for organization in organizations:
                    try:
                        service.generate_reminders_for_organization(str(organization.id))
                    except Exception:
                        continue
            finally:
                db.close()
        except Exception as err:
            print(f"[ReminderScheduler] Database unavailable or offline: {err}")

        time.sleep(settings.reminder_scheduler_interval_minutes * 60)


def start_reminder_scheduler() -> None:
    thread = threading.Thread(target=_run_reminder_loop, daemon=True)
    thread.start()
