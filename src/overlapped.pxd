# cython: language_level=3
# distutils: language = c++

from winbase cimport *

cdef class Overlapped:
    cdef LPOVERLAPPED _lpov
    cdef uchar * _read_buffer
    cdef const uchar * _write_buffer

    cdef uchar * getresult_char(self)
    cpdef bytes getresult(self)