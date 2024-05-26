

from uvloop cimport loop as uvloop

from libc.stdlib cimport free, malloc
from libc.stdio cimport printf

import asyncio
from .exceptions import LibUVError, LibUVReadError, LibUVOpenError

cdef void on_open(uv_fs_t* req) noexcept with gil:
    cdef:
        on_open_ctx* ctx
        object fut
        char* buffer
        AsyncFile file
        uvloop.Loop loop
        bytes error_str
    printf("on open %d\n", req)
    printf("result: %d\n", req.result)
    ctx = <on_open_ctx*> req.data 
    
    fut = <object>ctx.fut
    loop = <uvloop.Loop>ctx.loop

    fut: asyncio.Future
    printf("1111111111111111\n")
    if req.result >= 0:
        file = AsyncFile(loop, req.result)
        fut.set_result(file)
    else:
        error_str = uv_strerror(req.result)
        fut.set_exception(LibUVOpenError(f"cannot open the file : {error_str.decode()}"))
    free(ctx)    
    free(req)
    # print(fut)


cdef void on_read(uv_fs_t* req) noexcept with gil:
    cdef:
        on_read_ctx* ctx
        object fut
        char* buffer
        AsyncFile file
        uvloop.Loop loop
    # printf("on read \n")
    ctx = <on_read_ctx*> req.data
    
    fut = <object>ctx.fut
    # printf("iov :%ld\n", ctx.iov.len)
    # printf("onread req:%ld\n", req.result)
    # printf("read res: %s\n", ctx.iov.base)

    fut: asyncio.Future
    if req.result < 0:
        fut.set_exception(LibUVReadError(uv_strerror(req.result).decode()))
    elif req.result == 0:
        printf("file end?\n")
        ...
        fut.set_result(b"")
    else:
        fut.set_result(ctx.iov.base[:req.result])
    free(ctx.iov.base)
    free(ctx)    
    free(req)

cdef class AsyncFile:

    def __cinit__(self, uvloop.Loop loop, int fd):
        self._uv_loop = loop.uvloop
        self._loop = loop
        self.fd = fd

    def read(self, int i=-1):
        cdef:
            int size = max(i, 0)
            char *buffer = <char*>malloc(size * sizeof(char))
            uv_fs_t* req = <uv_fs_t*>malloc(sizeof(uv_fs_t))
            on_read_ctx* ctx = <on_read_ctx*>malloc(sizeof(on_read_ctx))
            object fut = self._loop._new_future()
            int read_r
        fut: asyncio.Future
        if size == 0:
            fut.set_result(b"")
            return fut

        ctx.fut = <PyObject*>fut
        ctx.iov = uv_buf_init(buffer, size)
        # printf("iov :%ld\n", ctx.iov.len)
        req.data = ctx
        read_r = uv_fs_read(self._uv_loop, req, self.fd, &(ctx.iov), 1, 0, on_read)

        # printf("read r%d\n", read_r)
        return fut

