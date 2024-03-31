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
from libc.stdio cimport printf
from libc.string cimport memcpy

from fileapi cimport CreateFileA, GetFileSizeEx, ReadFile, WriteFile
from ioapi cimport CancelIo, CloseHandle
from errhandlingapi cimport GetLastError

from overlapped cimport Overlapped

from io_callback import read_callback, readlines_callback, write_callback

import time

cdef double write_cost_sum = 0
cdef double register_cost_sum = 0

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



cdef class AsyncFile:
    cdef HANDLE _handle
    cdef PLARGE_INTEGER _lpFileSize
    cdef LONGLONG _cursor
    cdef uchar[:] write_buffer
    cdef LONGLONG _write_cursor
    cdef uchar[:] read_buffer

    cdef object __weakref__

    _register_callback: Callable

    def __cinit__(self):
        self._cursor = 0
        self._write_cursor = 0
        self.write_buffer = bytearray(BUFFER_SIZE)

    async def __aenter__(self):
        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        await self.close()

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
        proactor._register_with_iocp(self)
        self._register_callback = proactor._register

    def fileno(self) -> int:
        return <ulonglong> self._handle

    async def close(self):
        cdef Overlapped ov = self._flush_write_buffer()
        if ov: 
            f = self._register_callback(ov, <ulonglong> self._handle, write_callback)
            await f
        CancelIo(self._handle)
        CloseHandle(self._handle)

    cdef Overlapped _read(self, long long size = -1):
        if size >= 0xffffffff:
            raise Exception("size too large")
        cdef LONGLONG file_size = self._lpFileSize.QuadPart
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
        cdef int r = ReadFile(self._handle, read, size, NULL, lpov)
        return ov

    cpdef read(self, long long size = -1):
        """

        :param size: int
        :return: bytes
        """
        ov = self._read(size)
        f = self._register_callback(ov, <ulonglong> self._handle, read_callback)
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
        f = self._register_callback(ov, <ulonglong> self._handle, readlines_callback)
        return f

    cdef Overlapped _flush_write_buffer(self):
        if not self._write_cursor:
            return
        cdef uchar[:] buffer = <uchar[:self._write_cursor]>GlobalAlloc(
                GPTR, self._write_cursor)

        memcpy(&buffer[0], &self.write_buffer[0], self._write_cursor)
        self._write_cursor = 0
        return self._do_write(buffer)

    cdef Overlapped _do_write(self, const uchar[:] buffer):
        cdef longlong size = buffer.shape[0]
        cdef LPOVERLAPPED lpov = <LPOVERLAPPED> GlobalAlloc(
                GPTR, sizeof(OVERLAPPED))
        lpov.Offset = self._cursor
        self._cursor += size
        cdef Overlapped ov = Overlapped()
        ov._lpov = lpov
        ov._write_buffer = &buffer[0]
        cdef int r = WriteFile(self._handle, ov._write_buffer, size, NULL, lpov)
        return ov

    @cython.boundscheck(False)
    cdef Overlapped _write(self, const uchar[:] buffer):
        cdef longlong size = buffer.shape[0]
        cdef Overlapped ov = None
        if self._write_cursor + size > BUFFER_SIZE:
            ov = self._flush_write_buffer()
        if size > BUFFER_SIZE:
            return self._do_write(buffer)
        self.write_buffer[self._write_cursor:self._write_cursor + size] = buffer[:]
        # memcpy(&self.write_buffer[self._write_cursor], &buffer[0], size)
        self._write_cursor += size
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
        if not ov:
            f = asyncio.futures.Future()
            f.set_result(True)
            return f
        f = self._register_callback(ov, <ulonglong> self._handle, write_callback)
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
        f = self._register_callback(ov, <ulonglong> self._handle, write_callback)
        return f