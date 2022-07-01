# cython: language_level=3
import time

from libc.stdlib cimport malloc
from libc.string cimport memset
from libc.stdio cimport printf



cdef void __stdcall func(DWORD dwErrorCode,
                         DWORD dwNumberOfBytesTransfered,
                         LPOVERLAPPED lpOverlapped):
    cdef int r = 112223330
    printf("call:%d", r)

cdef int called = 1


cdef void __stdcall CompletedReadRoutine(DWORD dwErr, DWORD cbBytesRead,
                                         LPOVERLAPPED lpOverLap):
    called = 0
    cdef int r = 0
    cdef HANDLE h = <void *> r
    lpOverLap = NULL
    printf("-----------call:%d,%d,%d\n", r,dwErr,cbBytesRead)

cpdef read_file(LPCSTR file_path):
    cdef DWORD read_size = 1024*1024

    # cdef char *lp_buf = [0]*1024
    cdef char lp_buf[1024*1024]
    # lp_buf = <char*>malloc(sizeof(char *))
    printf("lp_buf:%s \n", lp_buf)

    cdef DWORD num_read
    cdef OVERLAPPED overlapped
    # cdef LPOVERLAPPED_COMPLETION_ROUTINE callback = func

    printf("%u %u %u \n", GENERIC_READ,
           OPEN_EXISTING,
           FILE_FLAG_OVERLAPPED
           )
    memset(&overlapped, 0, sizeof(overlapped))
    cdef HANDLE handle = CreateFileA(file_path,
                                     GENERIC_READ,
                                     0,
                                     NULL,
                                     OPEN_EXISTING,
                                     FILE_FLAG_OVERLAPPED,
                                     NULL)
    cdef int error = GetLastError()
    printf("error:%d\n", error)
    printf("%s\n", file_path)
    printf("handle:%d\n", handle)
    # lpOverlapped.hEvent = handle
    cdef LPOVERLAPPED lpOverlapped = &overlapped
    cdef int r
    # CompletedReadRoutine(read_size,read_size,lpOverlapped)
    # r = ReadFile(handle, lp_buf, read_size, &num_read, lpOverlapped)
    # error = GetLastError()
    # if error == ERROR_IO_PENDING:
    #     pass
    # printf("error:%d\n", error)
    # printf("%d %d\n", r, num_read)
    # printf("%d \n",callback)
    r = ReadFileEx(handle, lp_buf, read_size, lpOverlapped, <LPOVERLAPPED_COMPLETION_ROUTINE> CompletedReadRoutine)
    cdef DWORD wait = WaitForSingleObjectEx(handle,0 , True)
    while True:
        if wait == WAIT_IO_COMPLETION:
            printf("WAIT_IO_COMPLETION:%d\n",wait)
        if wait == WAIT_ABANDONED:
            printf("WAIT_ABANDONED:%d\n",wait)
        error = GetLastError()
        printf("error:%d\n", error)
        printf("r:%d, wait:%d, called:%d\n", r, wait, called)
        time.sleep(0.5)
        printf("lpOverlapped:%d\n", lpOverlapped.hEvent)
        wait = WaitForSingleObjectEx(handle, 0, True)
