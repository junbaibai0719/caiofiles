# cython: language_level=3
# distutils: language = c++

from overlapped cimport Overlapped

import re

def read_callback(int trans, int key, Overlapped ov):
    return ov.getresult()

def readlines_callback(int trans, int key, Overlapped ov):
    cdef bytes res = ov.getresult()
    cdef list lines = []
    cdef unsigned long long length = len(res)
    cdef unsigned long long last = 0
    cdef unsigned long long i = 0
    cdef char ch
    for i in range(length):
        ch = res[i]
        if ch == b'\n' or i == length - 1:
            lines.append(res[last:i + 1])
            last = i + 1
    return lines
