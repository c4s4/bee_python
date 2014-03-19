#!/usr/bin/env python
# encoding=UTF-8

"""Sample Python unit test."""

import os
import sys
import inspect
test_dir = os.path.dirname(inspect.currentframe().f_code.co_filename)
src_dir = os.path.join(test_dir, '..', 'src')
sys.path.insert(0, src_dir)
import <%= name %>
import unittest

class Test(unittest.TestCase):
    """Test class."""

    def setUp(self):
        """Setup test. Runs before each test."""
        pass

    def test_say_hello(self):
        """Test say_hello() function."""
        actual = <%= name %>.say_hello("World")
        expected = "Hello World!"
        self.assertEquals(expected, actual)

# Run unit tests when started on command line
if __name__ == '__main__':
    unittest.main()

