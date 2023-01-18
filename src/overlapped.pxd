# cython: language_level=3
# distutils: language = c++

from winbase cimport *

cdef class Overlapped:
    cdef LPOVERLAPPED _lpov
    cdef char * _buffer

    cdef char * getresult_char(self)
    cpdef bytes getresult(self)