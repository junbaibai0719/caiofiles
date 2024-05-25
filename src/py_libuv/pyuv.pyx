# cython: language_level=3

cimport cython
from libc.stdlib cimport free, malloc
from libc.stdio cimport printf

cdef uv_loop_t *loop = NULL
cdef uv_buf_t iov
cdef uv_fs_t* open_req = NULL

cdef void on_read(uv_fs_t* req) noexcept nogil:
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
    


cdef void open_cb(uv_fs_t* req) noexcept nogil:
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
        printf("readr %d\n", r)
    else:
        printf("error opening file: %s\n", uv_strerror(<int>(req.result)))


def test():
    global loop
    loop = <uv_loop_t*>PyMem_RawMalloc(sizeof(uv_loop_t))
    cdef const char* path = "./main.py"
    
    uv_loop_init(loop)
    cdef uv_fs_t *req = <uv_fs_t*>malloc(sizeof(uv_fs_t))
    global open_req
    open_req = req
    cdef int flags = O_ASYNC | O_RDONLY
    cdef int mode = S_IRWXU
    printf("flags: %d, mode:%d\n", flags, mode)
    cdef int r = uv_fs_open(loop, req, path, flags, mode, open_cb)
    printf("uv_fs_open %d\n", r)

    uv_run(loop, UV_RUN_DEFAULT)
    printf("end?\n")

    uv_loop_close(loop)
    free(loop)
