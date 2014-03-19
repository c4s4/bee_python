#!/usr/bin/env python
# coding=utf-8

"""This server uses SOAPpy library that can be downloaded (in version 0.11.1
preferably) at: http://sourceforge.net/projects/pywebsvcs/files/SOAP.py/.
You must also have installed library FPconst that can be downloaded at
http://pypi.python.org/pypi/fpconst/0.7.2."""

import SOAPpy

HOST_NAME   = "localhost"
PORT_NUMBER = 8000

def hello(who):
    """Say hello."""
    return "Hello %s!" % who

def start():
    """Start server and serve forever."""
    server = SOAPpy.SOAPServer((HOST_NAME, PORT_NUMBER))
    server.registerFunction(hello)
    try:
        print "Server started on port %s" % PORT_NUMBER
        server.serve_forever()
    except KeyboardInterrupt:
        print "Server stopped"

if __name__ == '__main__':
    start()

