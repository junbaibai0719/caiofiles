# cython: language_level=3

from winbase cimport *

ctypedef struct OVBUFFER:
    OVERLAPPED oOverlap
    char * read
    void * fut
    void * file

ctypedef OVBUFFER *LPOVBUFFER

ctypedef unsigned long long ulonglong
ctypedef long long longlong

cdef enum:
    BUFFER_SIZE = 8192


cdef extern from "Python.h":
    str PyUnicode_FromWideChar(wchar_t *w, int size)
