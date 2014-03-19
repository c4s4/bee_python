#!/usr/bin/env python
# coding=utf-8

"""Sample XML-RPC server."""

import DocXMLRPCServer

HOST_NAME   = "localhost"
PORT_NUMBER = 8000

def hello(who):
    """Say hello to somebody.
    - who: the person to say hello to."""
    return "Hello %s!" % who

if __name__ == '__main__':
    SERVER = DocXMLRPCServer.DocXMLRPCServer((HOST_NAME, PORT_NUMBER))
    SERVER.register_function(hello, 'test.hello')
    try:
        print "Server started on port %s" % PORT_NUMBER
        SERVER.serve_forever()
    except KeyboardInterrupt:
        SERVER.server_close()
        print "Server stopped"
