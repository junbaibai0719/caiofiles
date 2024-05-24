# cython: language_level=3

from .winbase cimport *

cdef extern from "errhandlingapi.h":
    cdef DWORD GetLastError();