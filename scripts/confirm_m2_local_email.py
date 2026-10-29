"""Activate only the disposable local signup email, without logging its token.

Mailpit raw endpoint: https://mailpit.axllent.org/docs/api-v1/
This does not access an external mailbox or change confirmation requirements.
"""
from email import policy
from email.parser import BytesParser
import html
import json
from pathlib import Path
import re
import time
from urllib.error import HTTPError, URLError
from urllib.parse import urlsplit, parse_qs
from urllib.request import HTTPRedirectHandler, build_opener, urlopen


class NoRedirect(HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None


def main():
    config = json.loads(Path('config/m2-test.local.json').read_text())
    expected = config['TEST_EMAIL_A'].lower()
    for _ in range(150):
        try:
            with urlopen('http://127.0.0.1:54324/api/v1/message/latest/raw', timeout=5) as response:
                message = BytesParser(policy=policy.default).parsebytes(response.read())
            recipients = [address.addr_spec.lower() for address in message['To'].addresses]
            if expected not in recipients:
                time.sleep(2)
                continue
            for part in message.walk():
                if part.get_content_type() not in ('text/plain', 'text/html'):
                    continue
                text = html.unescape(part.get_content())
                for link in re.findall(r'https?://[^\s<>"\']+', text):
                    uri = urlsplit(link)
                    if uri.path != '/auth/v1/verify':
                        continue
                    if uri.hostname not in ('localhost', '127.0.0.1') or uri.port != 54321 or uri.scheme != 'http':
                        raise ValueError('Confirmation must target local Auth only')
                    try:
                        with build_opener(NoRedirect()).open(link, timeout=10) as response:
                            ok = response.status == 200
                    except HTTPError as error:
                        location = error.headers.get('Location', '')
                        ok = error.code in (302, 303) and 'error' not in parse_qs(urlsplit(location).query)
                    if not ok:
                        raise RuntimeError('Local email confirmation failed')
                    Path('build/m2-evidence/email-confirmed.txt').write_text('Local signup email link verified.\n')
                    print('Local signup email link verified; token omitted.')
                    return
        except (HTTPError, URLError):
            pass
        time.sleep(2)
    raise TimeoutError('Disposable signup email did not arrive')


if __name__ == '__main__':
    try:
        main()
    except Exception as error:
        print(f'Local email verification failed ({type(error).__name__}); token omitted.')
        raise SystemExit(1) from None
