from __future__ import print_function
import os
import sys
import itertools
import functools
import collections
import datetime
import re
import random
import subprocess
import operator
import time
import importlib

third_party = ['MySQLdb', 'pathlib']

for module in third_party:
    try: m = importlib.import_module(module)
    except ImportError: pass
    else: globals()[module] = m

def timer(fn, *args, **kwargs):
    "Time the application of fn to args. Return (result, seconds)."
    start = time.time()
    return fn(*args, **kwargs), time.time() - start

def mult(sequence):
    "Multiply together all values in sequence"
    return functools.reduce(operator.mul, sequence)

def iter_print(iterable):
    "Print each value in iterator on its own line."
    for item in iterable:
        print(item)

def human_bytes(num):
    num = float(num)
    if num < 0:
        return "0 bytes"

    for x in ['bytes','KB','MB','GB']:
        if num < 1024.0:
            return "%3.1f %s" % (num, x)
        num /= 1024.0
    return "%3.1f %s" % (num, 'TB')
