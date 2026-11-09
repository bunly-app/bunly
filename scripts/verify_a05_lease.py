"""Read-only lease guard shared by local verification runners."""
from datetime import datetime, timezone
import json
from pathlib import Path


def require_environment_lease():
    state = Path(__file__).resolve().parents[1] / 'documents/development/autonomous-run'
    if json.loads((state / 'waiting-user.json').read_text(encoding='utf-8-sig'))['status'] == 'waiting':
        raise RuntimeError('Waiting for user; local commands are blocked')
    lease = json.loads((state / 'workspace-lease.json').read_text(encoding='utf-8-sig'))
    if lease['owner_thread_id'] != '01a1bf45-c4e6-75e2-bf1a-ad9c410e2612' or datetime.fromisoformat(lease['expires_at']) <= datetime.now(timezone.utc):
        raise RuntimeError('Active exclusive environment lease required')
