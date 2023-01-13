# cython: language_level=3

from winbase cimport *

ctypedef struct OVBUFFER:
    OVERLAPPED oOverlap
    char * read
    void * fut
    void * file

ctypedef OVBUFFER *LPOVBUFFER

cdef enum :
    BUFFER_SIZE = 1024 * 1024


cdef extern from "Python.h":
    str PyUnicode_FromWideChar(wchar_t *w, int size)


