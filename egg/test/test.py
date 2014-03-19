#!/usr/bin/env python
# encoding=UTF-8

"""Sample Python unit test."""

import unittest

def say_hello(who):
    """Method under test."""
    return "Hello %s!" % who

class Test(unittest.TestCase):
    """Test class."""

    def setUp(self):
        """Setup test. Runs before each test."""
        pass

    def test_say_hello(self):
        """Test say_hello() function."""
        actual = say_hello("World")
        expected = "Hello World!"
        self.assertEquals(expected, actual)

# Run unit tests when started on command line
if __name__ == '__main__':
    unittest.main()

