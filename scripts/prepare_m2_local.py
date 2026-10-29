"""Create disposable confirmed users on local Supabase without printing secrets."""
import json
import os
from pathlib import Path
import secrets
import subprocess
from urllib.parse import urlparse
from urllib.request import Request, urlopen
import uuid


def main():
    npm = 'npm.cmd' if os.name == 'nt' else 'npm'
    process = subprocess.run(
        [npm, 'run', 'supabase', '--', 'status', '-o', 'json'],
        capture_output=True, text=True, check=True,
    )
    raw = process.stdout
    status, _ = json.JSONDecoder().raw_decode(raw[raw.index('{'):])
    url = status['API_URL']
    uri = urlparse(url)
    if uri.scheme != 'http' or uri.hostname not in ('localhost', '127.0.0.1') or uri.port != 54321:
        raise RuntimeError('Only local Supabase port 54321 is allowed')
    password = 'M2-' + secrets.token_hex(20) + '!a9'
    emails = []
    for label in ('a', 'b'):
        email = f'm2-{label}-{uuid.uuid4().hex}@example.test'
        data = json.dumps({'email': email, 'password': password, 'email_confirm': True}).encode()
        request = Request(url + '/auth/v1/admin/users', data=data, method='POST', headers={
            'Content-Type': 'application/json', 'apikey': status['SERVICE_ROLE_KEY'],
            'Authorization': 'Bearer ' + status['SERVICE_ROLE_KEY'],
        })
        with urlopen(request, timeout=30) as response:
            if response.status not in (200, 201):
                raise RuntimeError('Local test user creation failed')
        emails.append(email)
    config = {'APP_MODE': 'connected', 'SUPABASE_URL': url,
              'SUPABASE_ANON_KEY': status['ANON_KEY'],
              'TEST_EMAIL_A': emails[0], 'TEST_EMAIL_B': emails[1], 'TEST_PASSWORD': password}
    Path('config/m2-test.local.json').write_text(json.dumps(config, indent=2), encoding='utf-8')
    print('Prepared two confirmed disposable local test users. No admin key written to config.')


if __name__ == '__main__':
    try:
        main()
    except Exception as error:
        # urllib/subprocess errors may contain command or response details: keep them local.
        print(f'Local test setup failed ({type(error).__name__}). Check local stack readiness.')
        raise SystemExit(1) from None
