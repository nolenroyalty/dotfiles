from __future__ import print_function
import os
import sys
import itertools
import functools
import collections
import datetime
import re
import random
try:
    import MySQLdb
except ImportError:
    pass
import subprocess
import operator
import time

def timer(fn, *args):
    "Time the application of fn to args. Return (result, seconds)."
    start = time.time()
    return fn(*args), time.time() - start

def mult(sequence):
    "Multiply together all values in sequence"
    return functools.reduce(operator.mul, sequence)

def iter_print(iterable):
    "Print each value in iterator on its own line."
    for item in iterable:
        print(item)
