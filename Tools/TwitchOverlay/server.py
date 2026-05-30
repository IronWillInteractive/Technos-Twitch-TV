from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import webbrowser

PORT = 8080
ROOT = Path(__file__).resolve().parent

class Handler(SimpleHTTPRequestHandler):
    extensions_map = {**SimpleHTTPRequestHandler.extensions_map, '.html': 'text/html; charset=utf-8', '.js': 'application/javascript; charset=utf-8', '.json': 'application/json; charset=utf-8', '.svg': 'image/svg+xml'}

if __name__ == '__main__':
    import os
    os.chdir(ROOT)
    server = ThreadingHTTPServer(('127.0.0.1', PORT), Handler)
    print(f'Twitch Overlay Suite running at http://localhost:{PORT}')
    try:
        webbrowser.open(f'http://localhost:{PORT}')
    except Exception:
        pass
    server.serve_forever()
