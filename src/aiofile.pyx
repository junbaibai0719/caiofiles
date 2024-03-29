# cython: language_level=3
# distutils: language = c++

# import py
import asyncio
import concurrent.futures
from _winapi import CloseHandle
from asyncio import ProactorEventLoop, IocpProactor
from typing import Callable, Union

# import cython
cimport cython
from libc.stdlib cimport malloc, free

from fileapi cimport CreateFileA, GetFileSizeEx, ReadFile, WriteFile
from ioapi cimport CancelIo, CloseHandle
from errhandlingapi cimport GetLastError

from overlapped cimport Overlapped

from io_callback import read_callback, readlines_callback, write_callback

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

cpdef open(str fn, str mode):
    """
    :param fn: str
    :param mode: str
    :return: 
    """
    cdef HANDLE handle
    cdef PLARGE_INTEGER  lpFileSize
    if mode == "rb":
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
    if mode == "wb":
        handle = CreateFileA(fn.encode(),
                             GENERIC_WRITE,
                             FILE_SHARE_READ | FILE_SHARE_WRITE,
                             NULL,
                             CREATE_ALWAYS,
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


class WrapperAsyncFile:
    _fp: AsyncFile

    def __init__(self, fp):
        self._fp = fp

    def fileno(self):
        return self._fp.fileno()


cdef class AsyncFile:
    cdef HANDLE _handle
    cdef PLARGE_INTEGER _lpFileSize
    cdef unsigned long long _cursor

    _register_callback: Callable

    async def __aenter__(self):
        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        self.close()

    def __aiter__(self):
        return self

    async def __anext__(self):
        cdef bytes line = await self.readline()
        if line:
            return line
        else:
            raise StopAsyncIteration

    def register(self):
        loop: ProactorEventLoop = asyncio.get_event_loop()
        proactor: IocpProactor = loop._proactor
        proactor._register_with_iocp(WrapperAsyncFile(self))
        self._register_callback = proactor._register

    def fileno(self) -> int:
        return <long> self._handle

    cpdef close(self):
        CancelIo(self._handle)
        CloseHandle(self._handle)

    cdef Overlapped _read(self, long long size = -1):
        cdef long long file_size = self._lpFileSize.QuadPart
        if size == -1:
            size = file_size - self._cursor

        cdef LPOVERLAPPED lpov = <LPOVERLAPPED> GlobalAlloc(
            GPTR, sizeof(OVERLAPPED))
        lpov.Offset = self._cursor
        self._cursor += size
        cdef uchar *read = <uchar *> malloc(size * sizeof(uchar))
        cdef Overlapped ov = Overlapped()
        ov._lpov = lpov
        ov._read_buffer = read
        cdef int r = ReadFile(self._handle, read, size * sizeof(uchar), NULL, lpov)
        return ov

    cpdef read(self, long long size = -1):
        """

        :param size: int
        :return: bytes
        """
        ov = self._read(size)
        f = self._register_callback(ov, <long> self._handle, read_callback)
        return f

    # @timer.atimer
    async def readline(self):
        """

        :return: bytes line
        """
        cdef list data_list = []
        cdef bytes chunk
        cdef unsigned long long index
        cdef unsigned long long res_length = 0
        chunk = await self.read(BUFFER_SIZE)

        while chunk:
            index = chunk.find(b'\n')
            if index != -1:
                self._cursor = self._cursor - BUFFER_SIZE + index + 1
                # chunk = chunk[0:index + 1]
                res_length += index + 1
                data_list.append(chunk)
                break
            else:
                data_list.append(chunk)
                res_length += BUFFER_SIZE
            chunk = await self.read(BUFFER_SIZE)

        return b''.join(data_list)[0:res_length]

    def readlines(self):
        """

        :return: bytes
        """
        ov = self._read()
        f = self._register_callback(ov, <long> self._handle, readlines_callback)
        return f

    @cython.boundscheck(False)
    cdef Overlapped _write(self, const uchar[:] buffer):
        cdef unsigned long long size = buffer.shape[0]

        cdef LPOVERLAPPED lpov = <LPOVERLAPPED> GlobalAlloc(
            GPTR, sizeof(OVERLAPPED))
        lpov.Offset = self._cursor
        self._cursor += size
        cdef Overlapped ov = Overlapped()
        ov._lpov = lpov
        ov._write_buffer = &buffer[0]
        cdef int r = WriteFile(self._handle, ov._write_buffer, size * sizeof(uchar), NULL, lpov)
        return ov

    cpdef write(self, const uchar[:] s):
        """
        :param s: str or bytes
        :return: bool
        """
        # cdef bytes buffer_bytes
        # if isinstance(s, str):
        #     buffer_bytes = s.encode("gbk")
        # elif isinstance(s, bytes):
        #     buffer_bytes = s
        # else:
        #     raise
        ov = self._write(s)
        f = self._register_callback(ov, <long> self._handle, write_callback)
        return f

    cpdef write_lines(self, list lines):
        """
        
        :param lines: List[bytes] 
        :return: 
        """
        # cdef bytes buffer_bytes
        # if isinstance(s, str):
        #     buffer_bytes = s.encode("gbk")
        # elif isinstance(s, bytes):
        #     buffer_bytes = s
        # else:
        #     raise
        ov = self._write(b''.join(lines))
        f = self._register_callback(ov, <long> self._handle, write_callback)
        return f


    # def read_ex(self, long long size=-1):
    #     cdef long long file_size = self._lpFileSize.QuadPart
    #     cdef long long need_size = size if size != -1 else file_size
    #     need_size = min(file_size, need_size)
    #
    #     fut: asyncio.futures.Future = asyncio.futures.Future()
    #     cdef LPOVBUFFER lpPipeInst = <LPOVBUFFER> GlobalAlloc(
    #         GPTR, sizeof(OVBUFFER))
    #     cdef HANDLE handle = self._handle
    #     cdef DWORD wait
    #     lpPipeInst.read = <char *> malloc(need_size * sizeof(char))
    #     lpPipeInst.oOverlap.hEvent = handle
    #     lpPipeInst.oOverlap.Offset = self._cursor
    #     lpPipeInst.file = <void *> self
    #     lpPipeInst.fut = <void *> fut
    #     ReadFileEx(handle, <LPVOID> lpPipeInst.read, need_size * sizeof(char),
    #                <LPOVERLAPPED> lpPipeInst,
    #                <LPOVERLAPPED_COMPLETION_ROUTINE> CompletedReadRoutine)
    #     wait = WaitForSingleObjectEx(handle, 1000, True)
    #     return fut
