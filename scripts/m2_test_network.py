"""Loopback-only controller for a 35-second outage of the CI local API gateway."""
from http.server import BaseHTTPRequestHandler, HTTPServer
import json
from pathlib import Path
import secrets
import subprocess
import threading

config = json.loads(Path('config/m2-test.local.json').read_text())
token = config['TEST_CONTROL_TOKEN']


def connectivity(value):
    command = ['docker', 'stop', '--time', '1', 'supabase_kong_bunly'] if value == 'disable' else ['docker', 'start', 'supabase_kong_bunly']
    subprocess.run(command, check=True, capture_output=True, timeout=30)


class Handler(BaseHTTPRequestHandler):
    def log_message(self, *_args):
        pass

    def do_POST(self):
        if self.path != '/offline' or not secrets.compare_digest(self.headers.get('X-M2-Test', ''), token):
            self.send_error(403)
            return
        try:
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b'Network interruption scheduled')
            self.wfile.flush()
        except (BrokenPipeError, ConnectionResetError):
            pass
        connectivity('disable')
        timer = threading.Timer(35, connectivity, args=('enable',))
        timer.daemon = True
        timer.start()


HTTPServer(('127.0.0.1', 54325), Handler).serve_forever()
