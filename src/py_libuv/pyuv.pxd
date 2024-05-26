# cython: language_level=3

cimport cython

from .uv cimport *

cdef extern from "winix.h":
    cdef int O_ASYNC
    cdef int O_RDONLY
    cdef int S_IRWXU

cdef extern from "Python.h":
    int PY_VERSION_HEX

    unicode PyUnicode_FromString(const char *)

    void* PyMem_RawMalloc(size_t n) nogil
    void* PyMem_RawRealloc(void *p, size_t n) nogil
    void* PyMem_RawCalloc(size_t nelem, size_t elsize) nogil
    void PyMem_RawFree(void *p) nogil

    object PyUnicode_EncodeFSDefault(object)
    void PyErr_SetInterrupt() nogil

    void _Py_RestoreSignals()

    object PyMemoryView_FromMemory(char *mem, ssize_t size, int flags)
    object PyMemoryView_FromObject(object obj)
    int PyMemoryView_Check(object obj)

    cdef enum:
        PyBUF_WRITE

include "aiofile.pxd"

# cdef extern from "uv.h" nogil:
#     ctypedef cython.ulonglong uint64_t
#     ctypedef cython.longlong int64_t
#     ctypedef cython.int uv_file
#     ctypedef struct uv_loop_t:
#         void* data
#         # ... 
#     ctypedef struct uv_timespec_t:
#         long tv_sec
#         long tv_nsec
#     ctypedef struct uv_stat_t:
#         uint64_t st_dev
#         uint64_t st_mode
#         uint64_t st_nlink
#         uint64_t st_uid
#         uint64_t st_gid
#         uint64_t st_rdev
#         uint64_t st_ino
#         uint64_t st_size
#         uint64_t st_blksize
#         uint64_t st_blocks
#         uint64_t st_flags
#         uint64_t st_gen
#         uv_timespec_t st_atim
#         uv_timespec_t st_mtim
#         uv_timespec_t st_ctim
#         uv_timespec_t st_birthtim
#     ctypedef struct uv_fs_t:
#         pass
#     ctypedef void (*uv_fs_cb)(void* req)
#     ctypedef struct uv_fs_s:
#         # UV_REQ_FIELDS
#         # uv_fs_type fs_type
#         uv_loop_t* loop
#         uv_fs_cb cb
#         ssize_t result
#         void* ptr
#         const char* path
#         uv_stat_t statbuf 
#         # UV_FS_PRIVATE_FIELDS
#         # ...

#     ctypedef uv_fs_s uv_fs_t
#     ctypedef void (*uv_fs_cb)(uv_fs_t* req)

#     ctypedef struct uv_buf_t:
#         char* base
#         size_t len
#     ctypedef enum uv_run_mode:
#         UV_RUN_DEFAULT = 0,
#         UV_RUN_ONCE,
#         UV_RUN_NOWAIT
#     uv_loop_t* uv_default_loop()
#     int uv_loop_init(uv_loop_t* loop)
#     int uv_loop_close(uv_loop_t* loop)
#     int uv_loop_alive(uv_loop_t* loop)
#     int uv_loop_fork(uv_loop_t* loop)
#     int uv_run(uv_loop_t*, uv_run_mode mode) nogil
#     uv_buf_t uv_buf_init(char* base, unsigned int len)
#     int uv_fs_open(uv_loop_t* loop, uv_fs_t* req, const char* path, int flags, int mode, uv_fs_cb cb)
#     int uv_fs_close(uv_loop_t* loop,
#                           uv_fs_t* req,
#                           uv_file file,
#                           uv_fs_cb cb)    
#     int uv_fs_read(uv_loop_t* loop,
#                          uv_fs_t* req,
#                          uv_file file,
#                          const uv_buf_t bufs[],
#                          unsigned int nbufs,
#                          int64_t offset,
#                          uv_fs_cb cb)
#     const char* uv_strerror(int err)
