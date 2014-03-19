#!/usr/bin/env python
# coding=utf-8

"""Multi-threaded HTTP server based on BaseHttpServer."""

import SocketServer
import BaseHTTPServer

HOST_NAME   = "localhost"
PORT_NUMBER = 8000

class Handler(BaseHTTPServer.BaseHTTPRequestHandler):
    """Handler class for the HTTP server."""
    
    def do_GET(self):
        """Respond to a GET request."""
        self.send_response(200)
        self.send_header("Content-type", "text/html")
        self.end_headers()
        self.wfile.write("<html><body><p>Hello World!</p></body></html>")

class ThreadedHTTPServer(SocketServer.ThreadingMixIn,
                         BaseHTTPServer.HTTPServer):
    """Handle requests in a separate thread."""

def start_for_test(port):
    import time
    import thread
    server = ThreadedHTTPServer((HOST_NAME, port), Handler)
    thread.start_new_thread(server.handle_request, ())
    time.sleep(1)

if __name__ == '__main__':
    SERVER = ThreadedHTTPServer((HOST_NAME, PORT_NUMBER), Handler)
    try:
        print "Server started on port %s" % PORT_NUMBER
        SERVER.serve_forever()
    except KeyboardInterrupt:
        SERVER.server_close()
        print "Server stopped"

