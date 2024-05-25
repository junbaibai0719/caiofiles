# cython: language_level=3

from .winbase cimport *

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
    cdef int PyBUF_WRITE
    cdef int PyBUF_READ
    str PyUnicode_FromWideChar(wchar_t *w, int size)
    object PyMemoryView_FromMemory(char *memory, ssize_t size, int flags)
