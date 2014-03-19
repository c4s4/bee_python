#!/usr/bin/env python
# coding=utf-8

"""Sample SOAP client."""

import SOAPpy

HOST_NAME   = "localhost"
PORT_NUMBER = 8000

def main():
    """Call server."""
    client = SOAPpy.SOAPProxy("http://%s:%s/" % (HOST_NAME, PORT_NUMBER))
    print client.hello("World")

if __name__ == '__main__':
    main()

