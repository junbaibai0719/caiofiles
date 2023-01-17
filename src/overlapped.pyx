# cython: language_level=3
# distutils: language = c++

from ioapi cimport GetOverlappedResult

cdef class Overlapped:

    def __cinit__(self):
        _ov = <LPOVERLAPPED> GlobalAlloc(GPTR, sizeof(LPOVERLAPPED))

    @property
    def pending(self):
        return (<DWORD> self._lpov.Internal) == STATUS_PENDING

    @property
    def address(self):
        return <unsigned long long> self._lpov

    # def getresult(self):
    cpdef bytes getresult(self):
        cdef HANDLE handle = self._lpov.hEvent
        cdef DWORD transferred = 0;
        cdef BOOL ret;
        ret = GetOverlappedResult(handle, self._lpov, &transferred, 1)
        return self._buffer[0:self._lpov.InternalHigh]