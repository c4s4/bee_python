#!/usr/bin/env python
# coding=utf-8

# Script to compile a Python source file passed on command line. Called
# by python.compile task.

import sys
import py_compile

source = sys.argv[1]
try:
    py_compile.compile(source, doraise=True)
    sys.exit(0)
except py_compile.PyCompileError:
    py_compile.compile(source)
    sys.exit(1)
