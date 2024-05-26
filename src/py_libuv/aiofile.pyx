

from uvloop cimport loop as uvloop

cdef class AsyncFile:

    def __cinit__(self, uvloop.Loop loop, int fd):
        self._uv_loop = loop.uvloop
        self.fd = fd