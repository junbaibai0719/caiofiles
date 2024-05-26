# cython: language_level=3

cimport cython
from cpython.ref cimport PyObject
from libc.stdlib cimport free, malloc
from libc.stdio cimport printf
from uvloop cimport loop as uvloop

cdef uv_loop_t *loop = NULL
cdef uv_buf_t iov
cdef uv_fs_t* open_req = NULL

cdef void on_read(uv_fs_t* req) noexcept with gil:
    printf("1234\n")
    printf("iov :%ld\n", iov.len)
    printf("onread req:%ld\n", req.result)
    printf("read res: %s\n", iov.base)
    cdef uv_fs_t close_req
    if (req.result < 0):
        printf("Read error: %s\n", uv_strerror(req.result))
    
    elif (req.result == 0):
    
        # synchronous
        uv_fs_close(loop, &close_req, open_req.result, NULL)
    
    elif (req.result > 0):
    
        printf("111111111\n")
        # iov.len = req.result
        printf("req : %ld\n", req.result)
        # uv_fs_write(uv_default_loop(), &write_req, 1, &iov, 1, -1, on_write)
    


cdef void open_cb(uv_fs_t* req) noexcept with gil:
    # cdef uvloop.aio_Future fut = req.future
    cdef char *buffer = <char*>malloc(10 * sizeof(char))
    printf("%ld\n", req.result)
    
    cdef uv_fs_t read_req 
    # = <uv_fs_t*>malloc(sizeof(uv_fs_t))
    cdef int r
    global iov
    if (req.result >= 0):
        iov = uv_buf_init(buffer, 10)
        printf("iov: %s, buf: %ld\n", iov.base, iov.len)
        r = uv_fs_read(loop, &read_req, req.result,
                   &iov, 1, 0, on_read)
        printf("uv fs read\n")
        printf("readr %d %s\n", r, iov.base)
    else:
        printf("error opening file: %s\n", uv_strerror(<int>(req.result)))

include "aiofile.pyx"

import asyncio

async def main():
    cdef uvloop.Loop loop = asyncio.get_event_loop()
    printf("%d\n",loop.uvloop)
    await asyncio.sleep(1)

cdef void on_open(uv_fs_t* req) noexcept with gil:
    cdef:
        uv_fs_t_plus* req_plus
        object fut
        char* buffer
        AsyncFile file
        uvloop.Loop loop
        bytes error_str
    # printf("on open %d\n", req)
    # printf("result: %d\n", req.result)
    req_plus = <uv_fs_t_plus*> req 
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
    # print(fut)

cdef struct uv_fs_t_plus:
    uv_fs_t req
    PyObject* fut
    PyObject* loop

def open(str fn, str mode):
    cdef:
        uvloop.Loop loop
        uv_loop_t* uv_loop
        object fut
        uv_fs_t_plus* req
        int flags = O_ASYNC | O_RDONLY
        int uv_mode = S_IRWXU
        int open_r = -1
    loop = asyncio.get_event_loop()
    uv_loop = loop.uvloop
    # printf("%d\n",loop.uvloop)
    fut = loop._new_future()
    req = <uv_fs_t_plus*>malloc(sizeof(uv_fs_t_plus))

    req.fut = <PyObject*>fut
    req.loop = <PyObject*>loop

    # printf("req addr %d fut:%d req:%d\n", req, &(req.fut), &(req.req))
    if mode == "rb":
        open_r = uv_fs_open(uv_loop, <uv_fs_t*>req, fn.encode(), flags, uv_mode, on_open)

    if open_r != 0:
        raise Exception(uv_strerror(open_r))
        # printf("open r: %d %s\n", open_r, uv_strerror(open_r))
    return fut


def test():
    cdef uvloop.Loop lp = uvloop.Loop()
    printf("%d\n",lp.uvloop)
    cdef int flags = O_ASYNC | O_RDONLY
    cdef int mode = S_IRWXU
    cdef const char* path = "./main.py"
    global loop
    loop = <uv_loop_t*> lp.uvloop
    
    # uv_loop_init(loop)
    cdef uv_fs_t *req = <uv_fs_t*>malloc(sizeof(uv_fs_t))
    global open_req
    open_req = req
    
    printf("flags: %d, mode:%d\n", flags, mode)
    cdef int r = uv_fs_open(loop, req, path, flags, mode, open_cb)
    printf("error opening file: %s\n", uv_strerror(<int>(req.result)))
    printf("uv_fs_open %d\n", r)

    # uv_run(loop, UV_RUN_DEFAULT)

    # uv_loop_close(loop)
    # free(loop)
    lp.run_until_complete(main())
    printf("end?\n")
