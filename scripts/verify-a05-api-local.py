"""Pass local status in memory to Node tests; never print/store server credentials."""
import json
from pathlib import Path
import subprocess
import sys
from urllib.parse import urlparse

sys.dont_write_bytecode = True
from verify_a05_lease import require_environment_lease


require_environment_lease()
root = Path(__file__).resolve().parents[1]
status = subprocess.run(['npm.cmd', 'run', 'supabase', '--', 'status', '-o', 'json'],
    cwd=root, capture_output=True, text=True, check=True)
raw = status.stdout
config, _ = json.JSONDecoder().raw_decode(raw[raw.index('{'):])
url = urlparse(config['API_URL'])
if url.scheme != 'http' or url.hostname not in ('localhost', '127.0.0.1') or url.port != 54321:
    raise RuntimeError('Only local Supabase port 54321 is allowed')
result = subprocess.run(['node', 'supabase/functions/tests/analysis-api.integration.mjs'],
    cwd=root, input=json.dumps(config), text=True)
sys.exit(result.returncode)
