#!/usr/bin/env python
# coding=UTF-8

"""Sample Hello World Python script."""

import sys
import getopt

# Command line help
HELP = """Usage: %s [-h] [-w who]
Say hello:
-h    Print this help page.
-w    Who to say hello to.""" % sys.argv[0]

def say_hello(person):
    """Say hello.
    - person: who to say hello to."""
    return "Hello %s!" % person

# parse command line
if __name__ == '__main__':
    who = "World"
    try:
        OPTS, ARGS = getopt.getopt(sys.argv[1:],
                                   "hw:",
                                   ["help", "who"])
    except getopt.GetoptError, error:
        print "ERROR: %s" % str(error)
        print HELP
        sys.exit(1)
    for OPT, ARG in OPTS:
        if OPT == "-h":
            print HELP
            sys.exit(0)
        elif OPT == "-w":
            who = ARG
        else:
            print "Unhandled option: %s" % OPT
            print HELP
            sys.exit(1)
    print say_hello(who)

