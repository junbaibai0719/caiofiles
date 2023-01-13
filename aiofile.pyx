# cython: language_level=3
# distutils: language = c++
import asyncio
import concurrent.futures
import io
import time
from asyncio import ProactorEventLoop
import _overlapped

from fileapi cimport ReadFileEx, CreateFileA, GetFileSizeEx, ReadFile, CancelIo
from ioapi cimport CreateIoCompletionPort, GetQueuedCompletionStatus
from errhandlingapi cimport GetLastError
from synchapi cimport WaitForSingleObjectEx
from futuremap cimport FutureMap

from libc.stdlib cimport malloc, free
from libc.stdio cimport printf

cdef FutureMap * locked_map = new FutureMap()

cpdef get_last_error():
    return GetLastError()

cpdef get_error_msg(DWORD error):
    """
    :param error: int
    :return: str
    """
    if error > 128 or error < 0:
        raise Exception("不符合范围的error")
    cdef LPVOID lpMsgBuf
    cdef int size = FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM,
                                  NULL,
                                  error,
                                  SUBLANG_NEUTRAL,
                                  <LPTSTR> &lpMsgBuf,
                                  1024 * 4, NULL)
    cdef char * msg = <char *> lpMsgBuf
    cdef bytes b = msg
    return b.decode(encoding="gbk")

cdef void __stdcall CompletedReadRoutine(DWORD dwErr, DWORD cbBytesRead,
                                         LPOVERLAPPED lpOverLap) except +:
    cdef LPOVBUFFER lpPipeInst = <LPOVBUFFER> lpOverLap
    cdef bytes res
    file: AsyncFile = <object> lpPipeInst.file
    file._cursor += cbBytesRead
    res = lpPipeInst.read[0:cbBytesRead]
    fut: concurrent.futures.Future = <object> lpPipeInst.fut
    fut.set_result(res)
    free(lpPipeInst.read)
    free(lpPipeInst)

cdef void __stdcall CompletedWriteRoutine(DWORD dwErr, DWORD cbBytesRead,
                                          LPOVERLAPPED lpOverLap):
    cdef LPOVBUFFER lpPipeInst = <LPOVBUFFER> lpOverLap
    fut: concurrent.futures.Future = <object> locked_map.get(<int> lpPipeInst.oOverlap.hEvent)
    fut.set_result(True)

cpdef open(str fn, str mode="r"):
    cdef HANDLE handle
    cdef PLARGE_INTEGER  lpFileSize
    if mode == "r":
        handle = CreateFileA(fn.encode(),
                             GENERIC_READ,
                             FILE_SHARE_READ | FILE_SHARE_WRITE,
                             NULL,
                             OPEN_EXISTING,
                             FILE_FLAG_OVERLAPPED,
                             NULL)
        lpFileSize = <PLARGE_INTEGER> GlobalAlloc(
            GPTR, sizeof(PLARGE_INTEGER))
        GetFileSizeEx(handle, lpFileSize)
        fp = AsyncFile()
        fp._handle = handle
        fp._lpFileSize = lpFileSize
        return fp

cdef class Overlapped:
    cdef LPOVERLAPPED _ov
    cdef char * _buffer
    cdef LPDWORD _size

    def __cinit__(self):
        _ov = <LPOVERLAPPED> GlobalAlloc(GPTR, sizeof(LPOVERLAPPED))

    def getresult(self):
        return self._buffer

cdef class AsyncFile:
    cdef HANDLE _handle
    cdef PLARGE_INTEGER _lpFileSize
    cdef long long _cursor

    def fileno(self) -> int:
        return <long> self._handle

    def read_async(self, long long size = -1):
        # print(loop._proactor._iocp)
        # CreateIoCompletionPort(self._handle, <HANDLE> loop._proactor._iocp, 0, 0)
        # print(get_error_msg(GetLastError()))
        # _overlapped.CreateIoCompletionPort(<int> self._handle, loop._proactor._iocp, 0, 0)
        # print(get_error_msg(GetLastError()))
        import threading
        print(threading.current_thread().ident)
        cdef HANDLE handle =  CreateFileA(b"C:\\Users\\lin\\Downloads\\python-3.11.1-amd64.exe",
                             GENERIC_READ,
                             FILE_SHARE_READ | FILE_SHARE_WRITE,
                             NULL,
                             OPEN_EXISTING,
                             FILE_FLAG_OVERLAPPED,
                             NULL)
        cdef LPOVERLAPPED lpov = <LPOVERLAPPED> GlobalAlloc(
            GPTR, sizeof(OVERLAPPED))
        cdef LPDWORD p_size = <LPDWORD> malloc(sizeof(DWORD))
        cdef char *read = <char *> malloc(size * sizeof(char))
        CancelIo(self._handle)
        print(get_error_msg(GetLastError()))
        # cdef int r = ReadFile(<HANDLE> handle, read, size, p_size, <LPOVERLAPPED> lpov)
        # print("r,", r)
        # print(GetLastError())
        ov = _overlapped.Overlapped(0)
        print(GetLastError())
        print(ov.ReadFile(<int>self.fileno(), <int>1024))
        print(GetLastError())

        cdef DWORD NumberOfBytes = 0
        cdef ULONG_PTR CompletionKey = 0
        cdef OVERLAPPED *pov = NULL
        cdef DWORD err
        cdef BOOL ret

        loop: ProactorEventLoop = asyncio.get_event_loop()
        print(loop._proactor._iocp)
        ret = GetQueuedCompletionStatus(<HANDLE> loop._proactor._iocp, &NumberOfBytes,
                                        &CompletionKey, &pov, 10)
        print(get_error_msg(GetLastError()))
        print(ret, NumberOfBytes, CompletionKey)

    def read(self, long long size=-1):
        cdef long long file_size = self._lpFileSize.QuadPart
        cdef long long need_size = size if size != -1 else file_size
        need_size = min(file_size, need_size)

        fut: asyncio.futures.Future = asyncio.futures.Future()
        cdef LPOVBUFFER lpPipeInst = <LPOVBUFFER> GlobalAlloc(
            GPTR, sizeof(OVBUFFER))
        cdef HANDLE handle = self._handle
        cdef DWORD wait
        lpPipeInst.read = <char *> malloc(need_size * sizeof(char))
        lpPipeInst.oOverlap.hEvent = handle
        lpPipeInst.oOverlap.Offset = self._cursor
        lpPipeInst.file = <void *> self
        lpPipeInst.fut = <void *> fut
        ReadFileEx(handle, <LPVOID> lpPipeInst.read, need_size * sizeof(char),
                   <LPOVERLAPPED> lpPipeInst,
                   <LPOVERLAPPED_COMPLETION_ROUTINE> CompletedReadRoutine)
        wait = WaitForSingleObjectEx(handle, 1000, True)
        return fut

cpdef read_file(long handle, long long size):
    cdef LPOVBUFFER lpPipeInst = <LPOVBUFFER> GlobalAlloc(
        GPTR, sizeof(OVBUFFER))
    cdef LPDWORD p_size
    lpPipeInst.read = <char *> malloc(size * sizeof(char))
    cdef int r = ReadFile(<HANDLE> handle, lpPipeInst.read, size * sizeof(char), p_size, <LPOVERLAPPED> lpPipeInst)
    print("r,", r)
    print(GetLastError())

# cpdef read_file(LPCSTR file_path):
#     fut: concurrent.futures.Future = concurrent.futures.Future()
#     cdef int read_size = 1024 * 1024
#     cdef DWORD num_read
#     cdef LPOVBUFFER lpPipeInst = <LPOVBUFFER> GlobalAlloc(
#         GPTR, sizeof(OVBUFFER))
#     lpPipeInst.read = <char *> malloc(read_size * sizeof(char))
#
#     printf("%u %u %u \n", GENERIC_READ,
#            OPEN_EXISTING,
#            FILE_FLAG_OVERLAPPED
#            )
#
#     cdef HANDLE handle = CreateFileA(file_path,
#                                      GENERIC_READ,
#                                      FILE_SHARE_READ | FILE_SHARE_WRITE,
#                                      NULL,
#                                      OPEN_EXISTING,
#                                      FILE_FLAG_OVERLAPPED,
#                                      NULL)
#     lpPipeInst.oOverlap.hEvent = handle
#
#     locked_map.set(<int> handle, <void *> fut)
#
#     cdef int error = GetLastError()
#
#     ReadFileEx(handle, lpPipeInst.read, read_size * sizeof(char), <LPOVERLAPPED> lpPipeInst,
#                <LPOVERLAPPED_COMPLETION_ROUTINE> CompletedReadRoutine)
#     cdef DWORD wait = WaitForSingleObjectEx(handle, 0, True)
#     return asyncio.wrap_future(fut)
#
#
