# cython: language_level=3
# distutils: language = c++

from .winbase cimport *
from cpython cimport array
cimport cython

cdef array.array uc_array_template = array.array('B', [])

cdef class Overlapped:
    cdef LPOVERLAPPED _lpov
    cdef uchar[:] _read_buffer
    cdef const uchar[:] _write_buffer
    
    @staticmethod
    cdef Overlapped New(LPOVERLAPPED ov, cython.Py_ssize_t size)

    cdef uchar[:] getresult_char(self)
    cpdef bytes getresult(self)

cpdef bytes read_callback(trans, key, Overlapped ov)

cpdef list readlines_callback(trans, key, Overlapped ov)

cpdef bint write_callback(trans, key, Overlapped ov)
