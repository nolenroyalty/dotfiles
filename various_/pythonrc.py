import os
import sys
import itertools
import functools
import collections
import datetime
import re
import random
import MySQLdb
import subprocess
import operator

def timer(fn, *args):
    "Time the application of fn to args. Return (result, seconds)."
    import time
    start = time.clock()
    return fn(*args), time.clock() - start

def mult(vals):
    return functools.reduce(operator.mul, vals)
