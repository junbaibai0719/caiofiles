# cython: language_level=3
# distutils: language = c++
import asyncio
import concurrent.futures
import io
import time
from asyncio import ProactorEventLoop, IocpProactor
from typing import Callable

import _overlapped
from libc.string cimport memset

from fileapi cimport ReadFileEx, CreateFileA, GetFileSizeEx, ReadFile, CancelIo
from ioapi cimport CreateIoCompletionPort, GetQueuedCompletionStatus, GetOverlappedResult
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
        fp.register()
        return fp

cdef class Overlapped:
    cdef LPOVERLAPPED _lpov
    cdef char * _buffer

    _pending: bool

    def __cinit__(self):
        _ov = <LPOVERLAPPED> GlobalAlloc(GPTR, sizeof(LPOVERLAPPED))

    def __init__(self):
        self._pending = False

    @property
    def pending(self):
        return <DWORD> (self._lpov.Internal) == STATUS_PENDING

    @property
    def address(self):
        return <unsigned long long> self._lpov

    def getresult(self):
        cdef HANDLE handle = self._lpov.hEvent
        cdef DWORD transferred = 0;
        cdef BOOL ret;
        ret = GetOverlappedResult(handle, self._lpov, &transferred, 1)
        return self._buffer[0:self._lpov.InternalHigh]

def finish_recv(trans, key, ov):
    try:
        return ov.getresult()
    except OSError as exc:
        if exc.winerror in (_overlapped.ERROR_NETNAME_DELETED,
                            _overlapped.ERROR_OPERATION_ABORTED):
            raise ConnectionResetError(*exc.args)
        else:
            raise


class WrapperAsyncFile:
    _fp: AsyncFile

    def __init__(self, fp):
        self._fp = fp

    def fileno(self):
        return self._fp.fileno()


cdef class AsyncFile:
    cdef HANDLE _handle
    cdef PLARGE_INTEGER _lpFileSize
    cdef long long _cursor

    _register: Callable

    def register(self):
        loop: ProactorEventLoop = asyncio.get_event_loop()
        proactor: IocpProactor = loop._proactor
        proactor._register_with_iocp(WrapperAsyncFile(self))
        self._register = proactor._register

    def fileno(self) -> int:
        return <long> self._handle

    def read_async(self, long long size = -1):
        cdef long long file_size = self._lpFileSize.QuadPart
        if size == -1:
            size = file_size - self._cursor

        cdef LPOVERLAPPED lpov = <LPOVERLAPPED> GlobalAlloc(
            GPTR, sizeof(OVERLAPPED))
        lpov.Offset = self._cursor
        self._cursor += size
        cdef char *read = <char *> malloc(size * sizeof(char))
        ov = Overlapped()
        ov._lpov = lpov
        ov._buffer = read
        cdef int r = ReadFile(self._handle, read, size * sizeof(char), NULL, lpov)
        f = self._register(ov, <long> self._handle, finish_recv)
        return f

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
    cdef LPOVERLAPPED lpov = <LPOVERLAPPED> GlobalAlloc(
        GPTR, sizeof(OVERLAPPED))
    cdef char *read = <char *> malloc(size * sizeof(char))
    ov = Overlapped()
    ov._lpov = lpov
    ov._buffer = read
    cdef int r = ReadFile(<HANDLE> handle, read, size * sizeof(char), NULL, lpov)
    return ov

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
