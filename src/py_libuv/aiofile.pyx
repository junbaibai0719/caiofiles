

from uvloop cimport loop as uvloop

from libc.stdlib cimport free

import asyncio


cdef void on_open(uv_fs_t* req) noexcept with gil:
    cdef:
        uv_fs_t_wrap* req_plus
        object fut
        char* buffer
        AsyncFile file
        uvloop.Loop loop
        bytes error_str
    # printf("on open %d\n", req)
    # printf("result: %d\n", req.result)
    req_plus = <uv_fs_t_wrap*> req 
    # printf("on open req plus %d fut %d req: %d %d\n", req_plus, &(req_plus.fut), &(req_plus.req), req)
    
    fut = <object>req_plus.fut
    loop = <uvloop.Loop>req_plus.loop

    fut: asyncio.Future
    if req.result >= 0:
        file = AsyncFile(loop, req.result)
        fut.set_result(file)
    else:
        error_str = uv_strerror(req.result)
        fut.set_exception(Exception(f"cannot open the file : {error_str.decode()}"))
    free(req_plus)    
    # print(fut)



cdef class AsyncFile:

    def __cinit__(self, uvloop.Loop loop, int fd):
        self._uv_loop = loop.uvloop
        self.fd = fd