#!/usr/bin/env python3
"""
Simple HTTP server to serve the Flutter web app on port 5000
"""
import http.server
import socketserver
import os

# Change to the build/web directory
os.chdir('build/web')

PORT = 5000
Handler = http.server.SimpleHTTPRequestHandler

# Override to disable caching
class NoCacheHTTPRequestHandler(Handler):
    def end_headers(self):
        self.send_header('Cache-Control', 'no-store, no-cache, must-revalidate')
        self.send_header('Expires', '0')
        super().end_headers()

class ReuseAddrTCPServer(socketserver.TCPServer):
    allow_reuse_address = True

with ReuseAddrTCPServer(("0.0.0.0", PORT), NoCacheHTTPRequestHandler) as httpd:
    print(f"Serving Flutter app at http://0.0.0.0:{PORT}")
    httpd.serve_forever()
