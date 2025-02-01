# cython: language_level=3
# distutils: language = c++

# import py
import asyncio
from _winapi import CloseHandle
from asyncio import ProactorEventLoop, IocpProactor
from typing import Callable

# import cython
cimport cython
from libc.stdlib cimport malloc, free
from libc.stdio cimport printf
from libc.string cimport memcpy

from .fileapi cimport CreateFileA, GetFileSizeEx, ReadFile, WriteFile
from .ioapi cimport CancelIo, CloseHandle
from .errhandlingapi cimport GetLastError

# from .overlapped cimport Overlapped, read_callback, readlines_callback, write_callback
include "overlapped.pyx"

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
    cdef int size = FormatMessage(
        FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM,
        NULL,
        error,
        SUBLANG_NEUTRAL,
        <LPTSTR> &lpMsgBuf,
        1024 * 4, NULL
    )
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

cdef class Buffer:
    """缓冲区类，管理读取缓冲区的数据和位置"""
    
    cdef uchar[:] _buffer
    cdef size_t _pos      # 当前读取位置
    cdef size_t _filled   # 已填充数据的结束位置
    
    def __cinit__(self, size_t size):
        self._buffer = bytearray(size)
        self._pos = 0
        self._filled = 0
    
    cdef bytes read(self, size_t size):
        """从缓冲区读取指定大小的数据"""
        if size > self.remaining():
            size = self.remaining()
        if size <= 0:
            return b''
            
        result = bytes(self._buffer[self._pos:self._pos + size])
        self._pos += size
        return result
    
    cdef size_t remaining(self):
        """返回缓冲区中剩余可读数据量"""
        return self._filled - self._pos
    
    cdef void reset(self):
        """重置缓冲区"""
        self._pos = 0
        self._filled = 0
    
    cdef bint is_empty(self):
        """检查缓冲区是否为空"""
        return self._pos >= self._filled
    
    cdef void write(self, const uchar[:] data, size_t size):
        """写入数据到缓冲区"""
        if size > len(self._buffer):
            raise ValueError("Data too large for buffer")
        memcpy(&self._buffer[0], &data[0], size)
        self._pos = 0
        self._filled = size

cdef class AsyncFile:
    cdef HANDLE _handle
    cdef PLARGE_INTEGER _lpFileSize
    cdef LONGLONG _cursor
    cdef Buffer _read_buffer
    cdef Buffer _write_buffer
    
    cdef object __weakref__

    _register_callback: Callable
    _fill_read_buffer_lock: asyncio.Lock
    _write_lock: asyncio.Lock

    def __cinit__(self):
        self._cursor = 0
        self._read_buffer = Buffer(BUFFER_SIZE)
        self._write_buffer = Buffer(BUFFER_SIZE)

    # def __dealloc__(self):
    #     free(<void*> &self._write_buffer[0])
    #     free(<void*> &self._read_buffer[0])

    def __init__(self) -> None:
        self._fill_read_buffer_lock = asyncio.Lock()
        self._write_lock = asyncio.Lock()

    async def __aenter__(self):
        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        await self.close()

    def __aiter__(self):
        return self

    async def __anext__(self):
        """异步迭代器的下一个元素
        
        返回文件的下一行，如果到达文件末尾则抛出 StopAsyncIteration
        """
        cdef bytes line = await self.readline()
        print(line)
        if not line:  # 到达文件末尾
            raise StopAsyncIteration
        return line

    def register(self):
        loop: ProactorEventLoop = asyncio.get_event_loop()
        proactor: IocpProactor = loop._proactor
        proactor._register_with_iocp(self)
        self._register_callback = proactor._register

    def fileno(self) -> int:
        return <ulonglong> self._handle

    async def close(self):
        """关闭文件并清理资源"""
        try:
            # 刷新写缓冲区
            if not self._write_buffer.is_empty():
                ov = self._flush_write_buffer()
                if ov:
                    f = self._register_callback(ov, <ulonglong> self._handle, write_callback)
                    await f
            
            # 取消所有挂起的IO操作
            CancelIo(self._handle)
            
            # 关闭文件句柄
            CloseHandle(self._handle)
            
            # 清空缓冲区
            self._read_buffer.reset()
            self._write_buffer.reset()
            
            # 标记文件已关闭
            self._handle = NULL
            
        except Exception as e:
            # 确保即使出错也关闭文件句柄
            if self._handle:
                CloseHandle(self._handle)
                self._handle = NULL
            raise

    cdef object _fill_read_buffer(self):
        cdef longlong read_size = 0
        if self._read_buffer.is_empty():
            read_size = BUFFER_SIZE
        cdef LONGLONG file_size = self._lpFileSize.QuadPart
        read_size = min(read_size, file_size - self._cursor)
        if read_size <= 0:
            return None
        cdef Overlapped ov = self._do_read(read_size)

        @cython.boundscheck(False)
        def read_callback(int trans, key, Overlapped ov):
            self._read_buffer.write(ov.getresult_char()[:], trans)
            return ov.getresult_char()[0:trans]

        f = self._register_callback(ov, <ulonglong> self._handle, read_callback)
        return f

    async def _fill_read_buffer_async(self):
        async with self._fill_read_buffer_lock:
            f = self._fill_read_buffer()
            if f:
                await f
                
    cdef Overlapped _do_read(self, long long size):
        cdef LPOVERLAPPED lpov = <LPOVERLAPPED> GlobalAlloc(
            GPTR, sizeof(OVERLAPPED))
        cdef uchar *read = <uchar *> malloc(size * sizeof(uchar))
        lpov.Offset = self._cursor
        self._cursor += size
        cdef Overlapped ov = Overlapped()
        ov._lpov = lpov
        ov._read_buffer = read
        cdef int r = ReadFile(self._handle, read, size, NULL, lpov)
        return ov

    @cython.boundscheck(False)
    async def read(self, long long size = -1):
        """读取指定大小的数据
        
        :param size: 要读取的字节数，-1表示读取到文件末尾
        :return: 读取的数据
        """
        cdef LONGLONG file_size = self._lpFileSize.QuadPart
        cdef bytes chunk
        
        # 处理无效的size参数
        if size < -1:
            raise ValueError("size cannot be negative")
        
        # 处理读取到文件末尾的情况
        if size == -1:
            # 如果缓冲区有数据，先返回缓冲区数据
            if not self._read_buffer.is_empty():
                chunk = self._read_buffer.read(self._read_buffer.remaining())
                if chunk:
                    return chunk
            
            # 读取剩余所有数据
            chunks = []
            while True:
                chunk = await self._raw_read(BUFFER_SIZE)
                if not chunk:
                    break
                chunks.append(chunk)
            return b''.join(chunks)
        
        # 处理指定大小的读取
        if size == 0:
            return b''
        
        # 检查是否超过最大值
        if size >= 0xffffffff:
            raise ValueError("size too large")
        
        # 首先尝试从缓冲区读取
        if not self._read_buffer.is_empty():
            if self._read_buffer.remaining() >= size:
                # 缓冲区有足够数据
                return self._read_buffer.read(size)
            
            # 缓冲区数据不足，先读取缓冲区中的所有数据
            chunks = []
            if self._read_buffer.remaining() > 0:
                chunks.append(self._read_buffer.read(self._read_buffer.remaining()))
                size -= len(chunks[0])
            
            # 读取剩余所需数据
            chunk = await self._raw_read(size)
            if chunk:
                chunks.append(chunk)
            
            return b''.join(chunks)
        
        # 缓冲区为空，直接读取
        return await self._raw_read(size)

    async def _raw_read(self, long long size):
        """底层读取方法
        
        :param size: 要读取的字节数
        :return: 读取的数据
        """
        cdef LONGLONG file_size = self._lpFileSize.QuadPart
        
        # 确保不会读取超过文件末尾
        size = min(size, file_size - self._cursor)
        if size <= 0:
            return b''
        
        # 执行实际的读取操作
        cdef Overlapped ov = self._do_read(size)
        f = self._register_callback(ov, <ulonglong> self._handle, read_callback)
        return await f

    # @timer.atimer
    async def readline(self):
        """读取一行数据
        
        :return: bytes line
        """
        cdef list data_list = []
        cdef bytes chunk
        cdef cython.Py_ssize_t index
        
        # 首先检查缓冲区中是否有数据
        if not self._read_buffer.is_empty():
            chunk = self._read_buffer.read(self._read_buffer.remaining())
        else:
            chunk = await self.read(BUFFER_SIZE)

        while chunk:
            index = chunk.find(b'\n')
            if index != -1:
                # 找到换行符，只返回到换行符为止的数据
                line = chunk[:index + 1]
                # 保存剩余数据到缓冲区
                remaining = chunk[index + 1:]
                if remaining:
                    self._read_buffer.write(remaining, len(remaining))
                if data_list:  # 如果之前有积累的数据，需要合并
                    data_list.append(line)
                    return b''.join(data_list)
                return line
            else:
                data_list.append(chunk)
                chunk = await self.read(BUFFER_SIZE)

        # 如果没有找到换行符，返回所有读取的数据（可能是文件的最后一行，没有换行符）
        if data_list:
            return b''.join(data_list)
        return b''

    def readlines(self):
        """

        :return: bytes
        """
        ov = self._read()
        f = self._register_callback(ov, <ulonglong> self._handle, readlines_callback)
        return f

    cdef Overlapped _do_write(self, const uchar[:] buffer):
        cdef longlong size = buffer.shape[0]
        cdef LPOVERLAPPED lpov = <LPOVERLAPPED> GlobalAlloc(
                GPTR, sizeof(OVERLAPPED))
        lpov.Offset = self._cursor
        self._cursor += size
        cdef Overlapped ov = Overlapped()
        ov._lpov = lpov
        cdef uchar* write_buffer = <uchar*>malloc(size)
        if write_buffer == NULL:
            raise MemoryError("Failed to allocate memory for write buffer")
        memcpy(write_buffer, &buffer[0], size)
        ov._write_buffer = write_buffer
        cdef int r = WriteFile(self._handle, write_buffer, size, NULL, lpov)
        return ov

    @cython.boundscheck(False)
    cdef Overlapped _write(self, const uchar[:] buffer):
        cdef longlong size = buffer.shape[0]
        cdef Overlapped ov = None
        
        # 如果数据大于缓冲区大小，直接写入
        if size > BUFFER_SIZE:
            return self._do_write(buffer)
            
        # 如果缓冲区剩余空间不足，先刷新缓冲区
        if self._write_buffer.remaining() + size > BUFFER_SIZE:
            ov = self._flush_write_buffer()
            if ov:
                # 等待刷新完成后再写入新数据
                return ov
                
        # 写入数据到缓冲区
        self._write_buffer.write(buffer, size)
        
        # 如果是最后一块数据，需要刷新
        if size < BUFFER_SIZE:
            return self._flush_write_buffer()
            
        return ov

    cdef Overlapped _flush_write_buffer(self):
        if self._write_buffer.is_empty():
            return None
            
        cdef size_t size = self._write_buffer.remaining()
        cdef uchar[:] buffer = <uchar[:size]>GlobalAlloc(GPTR, size)
        
        memcpy(&buffer[0], &self._write_buffer._buffer[0], size)
        self._write_buffer.reset()
        
        return self._do_write(buffer)

    async def write(self, const uchar[:] s):
        """写入数据到文件"""
        if self._handle == NULL:
            raise ValueError("File is closed")
            
        if s is None or len(s) == 0:
            f = asyncio.futures.Future()
            f.set_result(True)
            return f
            
        async with self._write_lock:
            ov = self._write(s)
            if not ov:
                # 如果没有立即写入，需要刷新缓冲区
                ov = self._flush_write_buffer()
                if not ov:
                    f = asyncio.futures.Future()
                    f.set_result(True)
                    return f
                
        return self._register_callback(ov, <ulonglong> self._handle, write_callback)

    cpdef write_lines(self, list lines):
        """写入多行数据
        
        :param lines: List[bytes] 要写入的行列表
        :return: Future对象
        """
        if not lines:
            f = asyncio.futures.Future()
            f.set_result(True)
            return f
            
        data = b''.join(lines)
        return self.write(data)
