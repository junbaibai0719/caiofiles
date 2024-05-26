

from .uv cimport *
from cpython.ref cimport PyObject
from uvloop cimport loop as uvloop

cdef class AsyncFile:
    cdef uv_loop_t* _uv_loop 
    cdef uvloop.Loop _loop
    cdef int fd

cdef void on_open(uv_fs_t* req) noexcept with gil
cdef void on_read(uv_fs_t* req) noexcept with gil


cdef struct on_open_ctx:
    PyObject* fut
    PyObject* loop

cdef struct on_read_ctx:
    uv_buf_t iov
    PyObject* fut
