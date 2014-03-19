#!/usr/bin/env python
# coding=utf-8

"""Sample XML-RPC client."""

import xmlrpclib

HOST_NAME   = "localhost"
PORT_NUMBER = 8000

def run():
    client = xmlrpclib.ServerProxy("http://%s:%s/" % (HOST_NAME, PORT_NUMBER))
    try:
        response = client.test.hello("World")
        print response
    except xmlrpclib.Fault, err:
        print "A fault occurred: code='%s', string='%s'" % \
              (err.faultCode, err.faultString)

if __name__ == '__main__':
    run()

