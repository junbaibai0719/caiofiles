# cython: language_level=3, c_string_type=unicode, c_string_encoding=utf8
# distutils: language = c++

from .ioapi cimport GetOverlappedResult, CancelIo, CloseHandle
# from .errhandlingapi cimport GetLastError
from libc.stdlib cimport free
cimport cython
from cpython cimport array

cdef array.array uc_array_template = array.array('B', [])

cdef class Overlapped:
    def __cinit__(self):
        pass

    def __dealloc__(self):
        free(<void *> self._lpov)

    @property
    def pending(self):
        return (<DWORD> self._lpov.Internal) == STATUS_PENDING

    @property
    def address(self):
        return <unsigned long long> self._lpov

    @cython.boundscheck(False)
    @cython.initializedcheck(False)
    cdef uchar[:] getresult_char(self):
        cdef HANDLE handle = self._lpov.hEvent
        cdef DWORD transferred = 0
        GetOverlappedResult(handle, self._lpov, &transferred, 1)
        return self._read_buffer[0:transferred]

    cpdef bytes getresult(self):
        cdef HANDLE handle = self._lpov.hEvent
        cdef DWORD transferred = 0
        GetOverlappedResult(handle, self._lpov, &transferred, 1)
        return self._read_buffer[0:self._lpov.InternalHigh]

    def cancel(self):
        """取消重叠操作"""
        if self._lpov:
            CancelIo(self._lpov.hEvent)  # 取消IO操作
            
    @staticmethod
    cdef Overlapped New(LPOVERLAPPED ov, cython.Py_ssize_t size):
        cdef Overlapped self = Overlapped()
        self._lpov = ov
        self._read_buffer = array.clone(uc_array_template, size, zero=False)
        return self

cpdef bytes read_callback(trans, key, Overlapped ov):
    return bytes(ov.getresult_char()[0:ov._lpov.InternalHigh])

cpdef list readlines_callback(trans, key, Overlapped ov):
    cdef uchar[:] res = ov.getresult_char()
    cdef list lines = []
    cdef unsigned long long length = ov._lpov.InternalHigh
    cdef unsigned long long last = 0
    cdef unsigned long long i = 0
    cdef uchar ch
    for i in range(length):
        ch = res[i]
        if ch == b'\n' or i == length - 1:
            lines.append(bytes(res[last:i + 1]))
            last = i + 1
    return lines

cpdef cython.bint write_callback(trans, key, Overlapped ov):
    return True
