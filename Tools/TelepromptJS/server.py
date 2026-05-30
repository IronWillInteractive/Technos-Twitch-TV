from http.server import ThreadingHTTPServer, SimpleHTTPRequestHandler
from pathlib import Path
import webbrowser
import socket

ROOT = Path(__file__).resolve().parent
PORT = 8080

class Handler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(ROOT), **kwargs)
    def end_headers(self):
        self.send_header('Cache-Control', 'no-store')
        super().end_headers()

def find_port(start=PORT):
    for port in range(start, start + 40):
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
            try:
                sock.bind(('127.0.0.1', port))
                return port
            except OSError:
                continue
    return start

if __name__ == '__main__':
    port = find_port()
    url = f'http://127.0.0.1:{port}/index.html'
    print('\nPRO-CRAWL OS local server')
    print(f'Root: {ROOT}')
    print(f'Open: {url}\n')
    webbrowser.open(url)
    ThreadingHTTPServer(('127.0.0.1', port), Handler).serve_forever()
