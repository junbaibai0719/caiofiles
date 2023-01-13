from __future__ import annotations

import asyncio
import io
import sys
from asyncio.proactor_events import BaseProactorEventLoop
from typing import Tuple

if sys.platform != 'win32':
    raise RuntimeError("暂时不支持在非Windows平台工作")

from _winapi import CreateFile, GENERIC_READ, FILE_GENERIC_READ, FILE_GENERIC_WRITE, GENERIC_WRITE, \
    FILE_FLAG_OVERLAPPED, NULL, CloseHandle, INVALID_HANDLE_VALUE, ReadFile, Overlapped, GetLastError, \
    ERROR_IO_PENDING, WaitForSingleObject, INFINITE, WriteFile

OPEN_ALWAYS = 4

mode_access_map = {
    "r": GENERIC_READ,
    "w": GENERIC_WRITE
}


def open(
        file,
        mode="r",
        buffering=-1,
        encoding=None,
        errors=None,
        newline=None,
        closefd=True,
        opener=None,
        *,
        loop=None,
        executor=None
):
    ov = Overlapped()
    file_handler = CreateFile(file, GENERIC_READ, 0, NULL, OPEN_ALWAYS,
                              FILE_FLAG_OVERLAPPED, NULL)
    if file_handler is INVALID_HANDLE_VALUE:
        return -1
    return File(file_handler)


class File(io.BufferedIOBase):

    def __init__(self, handle):
        self.handle = handle

    def fileno(self) -> int:
        return self.handle

    async def read(self, __size: int | None = ...) -> bytes:

        r: Tuple[Overlapped, int] = ReadFile(self.handle, 2 ** 10, True)

        loop = asyncio.get_event_loop()
        if isinstance(loop, BaseProactorEventLoop):
            res = await loop.sock_recv(self, 1024)
            return res

    async def write(self, __buffer) -> int:
        loop = asyncio.get_event_loop()
        if isinstance(loop, BaseProactorEventLoop):
            res = await loop.sock_sendall(self, __buffer)


