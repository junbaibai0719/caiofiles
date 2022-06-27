# cython: language_level=3
from libc.stdlib cimport malloc
from libc.string cimport memset
from libc.stdio cimport printf

cdef void __stdcall func(DWORD dwErrorCode,
                         DWORD dwNumberOfBytesTransfered,
                         LPOVERLAPPED lpOverlapped):
    cdef int r = 0
    printf("call:%d", r)

cpdef read_file(LPCSTR file_path):
    cdef DWORD read_size = 1024

    # cdef char *lp_buf = [0]*1024
    cdef char lp_buf[1024]
    # lp_buf = <char*>malloc(sizeof(char *))
    printf("%s \n", lp_buf)

    cdef DWORD num_read
    cdef LPOVERLAPPED lpOverlapped
    cdef LPOVERLAPPED_COMPLETION_ROUTINE callback = func

    handle = CreateFileA(file_path,
                         GENERIC_READ,
                         0,
                         NULL,
                         OPEN_EXISTING,
                         FILE_ATTRIBUTE_NORMAL,
                         NULL)
    error = GetLastError()
    printf("error:%d\n", error)
    memset(&lpOverlapped, 0, sizeof(lpOverlapped))
    printf("%s\n", file_path)
    printf("handle:%d\n", handle)
    cdef int r = ReadFile(handle, lp_buf, read_size, &num_read, NULL)
    printf("%d %d\n", r, num_read)
