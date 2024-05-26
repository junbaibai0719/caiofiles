

from .uv cimport *

cdef class AsyncFile:
    cdef uv_loop_t* _uv_loop 
    cdef int fd


