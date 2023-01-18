# cython: language_level=3
# distutils: language = c++

from winbase cimport *

cdef class Overlapped:
    cdef LPOVERLAPPED _lpov
    cdef char * _buffer

    cpdef bytes getresult(self)