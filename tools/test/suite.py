#!/usr/bin/env python
# coding=UTF-8
#
# Script to run a set of test files in a single suite. Tests to run are
# passed on command line.

import os
import sys
import unittest

# Run unit tests.
# - tests: list of test files to run.
# - verbosity: verbosity as an integer (defaults to 2).
def run(tests, verbosity=2):
    # add tests in test suite
    suite = unittest.TestSuite()
    for test in tests:
        try:
            test_dir = os.path.dirname(test)
            sys.path.insert(0, test_dir)
            module = os.path.splitext(os.path.basename(test))[0]
            suite.addTest(unittest.defaultTestLoader.loadTestsFromName(module))
        finally:
            sys.path.remove(test_dir)
    # run test suite with verbosity
    runner = unittest.TextTestRunner(verbosity=verbosity)
    result = runner.run(suite)
    if not result.wasSuccessful():
        sys.exit(-1)
    else:
        sys.exit(0)

# run if started on command line
if __name__ == '__main__':
    run(sys.argv[1:])
