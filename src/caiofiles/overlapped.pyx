# cython: language_level=3, c_string_type=unicode, c_string_encoding=utf8
# distutils: language = c++

from .ioapi cimport GetOverlappedResult
from .errhandlingapi cimport GetLastError
from libc.stdlib cimport free


cdef class Overlapped:
    def __cinit__(self):
        pass

    def __dealloc__(self):
        free(<void *> self._read_buffer)
        free(<void *> self._write_buffer)
        free(<void *> self._lpov)


    @property
    def pending(self):
        return (<DWORD> self._lpov.Internal) == STATUS_PENDING

    @property
    def address(self):
        return <unsigned long long> self._lpov

    cdef uchar * getresult_char(self):
        cdef HANDLE handle = self._lpov.hEvent
        cdef DWORD transferred = 0;
        cdef BOOL ret;
        ret = GetOverlappedResult(handle, self._lpov, &transferred, 1)
        return self._read_buffer


    cpdef bytes getresult(self):
        cdef HANDLE handle = self._lpov.hEvent
        cdef DWORD transferred = 0;
        cdef BOOL ret;
        ret = GetOverlappedResult(handle, self._lpov, &transferred, 1)
        return self._read_buffer[0:self._lpov.InternalHigh]
