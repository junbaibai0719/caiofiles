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

from cpython cimport array
from cython.view cimport array as cvarray

cdef double write_cost_sum = 0
cdef double register_cost_sum = 0

cpdef get_last_error():
    return GetLastError()

cpdef get_error_msg(DWORD error):
    """获取Windows错误信息
    
    :param error: 错误码
    :return: 错误信息字符串
    """
    if error > 128 or error < 0:
        raise ValueError("错误码超出范围")
        
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
    return (<bytes>msg).decode(encoding="gbk")

cpdef open(str fn, str mode):
    """打开文件
    
    :param fn: 文件名
    :param mode: 打开模式 ('rb' 或 'wb')
    :return: AsyncFile 对象
    """
    cdef HANDLE handle
    cdef PLARGE_INTEGER lpFileSize
    cdef DWORD share_mode = FILE_SHARE_READ
    cdef int retry_count = 0
    cdef int max_retries = 3
    
    if mode == "rb":
        handle = CreateFileA(
            fn.encode(),
            GENERIC_READ,
            FILE_SHARE_READ | FILE_SHARE_WRITE,  # 允许其他进程读写
            NULL,
            OPEN_EXISTING,
            FILE_FLAG_OVERLAPPED,
            NULL
        )
    elif mode == "wb":
        handle = CreateFileA(
            fn.encode(),
            GENERIC_WRITE,
            FILE_SHARE_READ,  # 允许其他进程读取
            NULL,
            CREATE_ALWAYS,
            FILE_FLAG_OVERLAPPED,
            NULL
        )
    else:
        raise ValueError(f"不支持的打开模式: {mode}")
    
    if <ulonglong>handle == INVALID_HANDLE_VALUE:
        error = get_last_error()
        raise OSError(f"打开文件失败: {get_error_msg(error)}")
    
    lpFileSize = <PLARGE_INTEGER>GlobalAlloc(GPTR, sizeof(PLARGE_INTEGER))
    GetFileSizeEx(handle, lpFileSize)
    
    fp = AsyncFile()
    fp._handle = handle
    fp._lpFileSize = lpFileSize
    fp.register()
    return fp

cdef array.array uc_array_template = array.array('B', [])

cdef class Buffer:
    """高性能缓冲区实现"""
    cdef unsigned char[:] _buffer  # 使用 memoryview
    cdef size_t _pos        # 当前读/写位置
    cdef size_t _size      # 缓冲区总大小
    cdef size_t _filled    # 已填充数据的大小
    
    def __cinit__(self, size_t size):
        # 4KB 对齐
        self._size = (size + 4095) & ~4095
        self._buffer = array.clone(uc_array_template, self._size, zero=False)
        self._pos = 0
        self._filled = 0
    
    @cython.boundscheck(False)
    @cython.initializedcheck(False)
    cdef const unsigned char[:] read(self, size_t size):
        """从缓冲区读取数据"""
        if size > self.remaining():
            size = self.remaining()
        if size <= 0:
            return array.clone(uc_array_template, 0, zero=False)
        
        cdef const unsigned char[:] result = self._buffer[self._pos:self._pos + size]
        self._pos += size
        return result
    
    @cython.boundscheck(False)
    @cython.initializedcheck(False)
    cdef void write(self, const unsigned char[:] data, size_t size):
        """写入数据到缓冲区"""
        # 检查是否有足够空间
        if size > self.available():
            raise ValueError("数据大小超过缓冲区可用空间")
        
        # 写入数据
        self._buffer[self._filled:self._filled + size] = data[0:size]
        self._filled += size
    
    cdef size_t remaining(self):
        """返回剩余可读数据量"""
        return self._filled - self._pos
    
    cdef size_t available(self):
        """返回剩余可写空间"""
        return self._size - self._filled
    
    cdef bint is_empty(self):
        """检查缓冲区是否为空"""
        return self._pos >= self._filled
    
    cdef bint is_full(self):
        """检查缓冲区是否已满"""
        return self._filled >= self._size
    
    cdef void reset(self):
        """重置缓冲区"""
        self._pos = 0
        self._filled = 0
    
    @cython.boundscheck(False)
    @cython.initializedcheck(False)
    cdef void compact(self):
        """压缩缓冲区，移除已读取的数据"""
        cdef size_t remaining = 0
        if self._pos > 0:
            if not self.is_empty():
                # 移动未读数据到开头
                remaining = self.remaining()
                self._buffer[0:remaining] = self._buffer[self._pos:self._filled]
                self._filled = remaining
            else:
                self._filled = 0
            self._pos = 0
    
    @property
    def size(self):
        """返回缓冲区总大小"""
        return self._size

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
                await self._flush_write_buffer()
            
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
            self._read_buffer.compact()
            self._read_buffer.write(ov.getresult_char()[:], trans)
            return ov.getresult_char()[0:trans]

        return self._register_callback(ov, <ulonglong> self._handle, read_callback)

    async def _fill_read_buffer_async(self):
        async with self._fill_read_buffer_lock:
            f = self._fill_read_buffer()
            if f:
                await f
            else:
                await asyncio.sleep(0)
                
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
    async def read(self, cython.Py_ssize_t size = -1):
        """优化小块读取性能"""
        if size == -1:
            size = self._lpFileSize.QuadPart - self._cursor
        elif size <= 0:
            return b''
            
        # 小块读取优化
        if size <= BUFFER_SIZE:  # 8KB以下
            if self._read_buffer.remaining() <= size:
                if self._read_buffer.is_empty():
                    await self._fill_read_buffer_async()
                else:
                    # 不为空就需要移动
                    self._read_buffer.compact()
                    await self._fill_read_buffer_async()
            return bytes(self._read_buffer.read(size))
            
        # 大块直接读取
        return await self._raw_read(size)

    async def _raw_read(self, long long size):
        """底层读取方法"""
        cdef LONGLONG file_size = self._lpFileSize.QuadPart
        
        # 确保不会读取超过文件末尾
        size = min(size, file_size - self._cursor)
        if size <= 0:
            return b''
        
        # 对于大于缓冲区的读取，直接分配新的缓冲区
        cdef Overlapped ov = self._do_read(size)
        f = self._register_callback(ov, <ulonglong>self._handle, read_callback)
        return await f

    # @timer.atimer
    @cython.boundscheck(False)
    @cython.wraparound(False)
    async def readline(self) -> bytes:
        """使用内存视图优化的行读取实现"""

        cdef:
            list data_list = []
            const unsigned char[:] chunk
            Py_ssize_t index = -1
            Py_ssize_t i
            size_t chunk_size = BUFFER_SIZE
            const unsigned char[:] remaining
            cdef const unsigned char[:] line
        
        # 首先检查缓冲区中是否有数据
        if self._read_buffer.is_empty():
            await self._fill_read_buffer_async()
        
        chunk = self._read_buffer.read(self._read_buffer.remaining())
        while chunk.shape[0] > 0:
            # 使用内存视图处理数据
            
            # 手动查找换行符
            for i in range(chunk.shape[0]):
                if chunk[i] == LF[0]:
                    index = i
                    break
            else:
                index = -1
            if index != -1:
                # 找到换行符
                line = chunk[:index + 1].copy()
                # 保存剩余数据到缓冲区
                remaining = chunk[index + 1:]
                if remaining.shape[0] > 0:
                    self._read_buffer.reset()
                    self._read_buffer.write(remaining, remaining.shape[0])
                if data_list:
                    data_list.append(line)
                    return b''.join(data_list)
                return bytes(line)
            else:
                data_list.append(chunk)
                await self._fill_read_buffer_async()
                chunk = self._read_buffer.read(chunk_size)
        
        # 如果没有找到换行符，返回所有数据
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

    cdef object _do_write(self, const uchar[:] buffer):
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
        f = self._register_callback(ov, <ulonglong> self._handle, write_callback)
        return f

    @cython.boundscheck(False)
    cdef object _write(self, const uchar[:] buffer):
        cdef longlong size = buffer.shape[0]
                    
        # 如果缓冲区剩余空间不足，先刷新缓冲区
        if self._write_buffer.remaining() + size > BUFFER_SIZE:
            f = self._flush_write_buffer()
            f.add_done_callback(lambda _: self._do_write(buffer))
            return f
                
        # 写入数据到缓冲区
        self._write_buffer.write(buffer, size)
            
        return asyncio.ensure_future(asyncio.sleep(0))

    cdef object _flush_write_buffer(self):
        if self._write_buffer.is_empty():
            return asyncio.ensure_future(asyncio.sleep(0))
            
        cdef size_t size = self._write_buffer.remaining()
        cdef uchar[:] buffer = <uchar[:size]>GlobalAlloc(GPTR, size)
        
        memcpy(&buffer[0], &self._write_buffer._buffer[0], size)
        self._write_buffer.reset()
        
        return self._do_write(buffer)

    async def write(self, const uchar[:] s):
        """优化小块写入性能"""
        if self._handle == NULL:
            raise ValueError("File is closed")
            
        if s is None or len(s) == 0:
            return None
            
        cdef size_t size = s.shape[0]
        
        # 小块写入优化
        if size <= BUFFER_SIZE:  # 8KB以下使用缓冲
            async with self._write_lock:
                if self._write_buffer.available() < size:
                    await self._flush_write_buffer()
                self._write_buffer.write(s, size)
                # 立即返回，不等待刷新
                return None
                
        # 大块直接写入
        return await self._do_write(s)

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
