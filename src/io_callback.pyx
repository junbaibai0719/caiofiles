# cython: language_level=3
# distutils: language = c++

from overlapped cimport Overlapped
from winbase cimport uchar

import re

def read_callback(trans, key, Overlapped ov):
    return ov.getresult_char()[0:ov._lpov.InternalHigh]

def readlines_callback(trans, key, Overlapped ov):
    cdef uchar* res = ov.getresult_char()
    cdef list lines = []
    cdef unsigned long long length = ov._lpov.InternalHigh
    cdef unsigned long long last = 0
    cdef unsigned long long i = 0
    cdef uchar ch
    for i in range(length):
        ch = res[i]
        if ch == b'\n' or i == length - 1:
            lines.append(res[last:i + 1])
            last = i + 1
    return lines

def write_callback(trans, key, Overlapped ov):
    return True