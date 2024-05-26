

from .uv cimport *
from cpython.ref cimport PyObject

cdef class AsyncFile:
    cdef uv_loop_t* _uv_loop 
    cdef int fd

cdef void on_open(uv_fs_t* req) noexcept with gil


cdef struct uv_fs_t_wrap:
    uv_fs_t req
    PyObject* fut
    PyObject* loop
