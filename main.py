# This is a sample Python script.

# Press Shift+F10 to execute it or replace it with your code.
# Press Double Shift to search everywhere for classes, files, tool windows, actions, and settings.
from __future__ import annotations

import io
from _winapi import CreateFile, GENERIC_READ, FILE_GENERIC_READ, FILE_GENERIC_WRITE, GENERIC_WRITE, \
    FILE_FLAG_OVERLAPPED, NULL, CloseHandle, INVALID_HANDLE_VALUE, ReadFile, Overlapped, GetLastError, \
    ERROR_IO_PENDING, WaitForSingleObject, INFINITE, WriteFile

import asyncio
from asyncio import IocpProactor
from asyncio.proactor_events import BaseProactorEventLoop
from typing import Tuple

import _overlapped

from utils.timer import timer, repeat
from utils.logger import Logger

logger = Logger(__name__)

CREATE_NEW = 1
CREATE_ALWAYS = 2
OPEN_ALWAYS = 4
TRUNCATE_EXISTING = 5


@repeat(10 ** 5)
def py_open():
    with open("1.py", "wb") as fp:
        pass


@timer
def win_read(fn):
    file_handler = CreateFile(fn, GENERIC_READ, 0, NULL, OPEN_ALWAYS,
                              FILE_FLAG_OVERLAPPED, NULL)
    if file_handler is INVALID_HANDLE_VALUE:
        return -1
    ov = _overlapped.Overlapped(NULL)
    r: Tuple[Overlapped, int] = ReadFile(file_handler, 2 ** 10, True)
    ov, error = r
    if error == ERROR_IO_PENDING:
        res = ov.GetOverlappedResult(False)
        logger.info(res)
        logger.info(len(ov.getbuffer()))
    CloseHandle(file_handler)
    return ov.getbuffer()


@timer
def win_write(fn, data):
    file_handler = CreateFile(fn, GENERIC_WRITE, 0, NULL, OPEN_ALWAYS,
                              FILE_FLAG_OVERLAPPED, NULL)
    if file_handler is INVALID_HANDLE_VALUE:
        return -1
    ov = _overlapped.Overlapped(NULL)
    r: Tuple[Overlapped, int] = WriteFile(file_handler, data, True)
    ov, error = r
    if error == ERROR_IO_PENDING:
        res = ov.GetOverlappedResult(False)
        logger.info(res)
        logger.info(ov.getbuffer())
    CloseHandle(file_handler)
    return ov.getbuffer()


def open(fn):
    file_handler = CreateFile(fn, GENERIC_READ, 0, NULL, OPEN_ALWAYS,
                              FILE_FLAG_OVERLAPPED, NULL)
    if file_handler is INVALID_HANDLE_VALUE:
        return -1
    return File(file_handler)


class File(io.BufferedIOBase):

    def __init__(self, handle):
        self.handle = handle

    async def read(self, __size: int | None = ...) -> bytes:

        ov = _overlapped.Overlapped(NULL)
        r: Tuple[Overlapped, int] = ReadFile(self.handle, 2 ** 10, True)

        loop = asyncio.get_event_loop()
        if isinstance(loop, BaseProactorEventLoop):
            iocp: IocpProactor = loop._proactor
            if await iocp.wait_for_handle(self.handle):
                res = ov.GetOverlappedResult(False)
                logger.info(res)
                logger.info(len(ov.getbuffer()))
                return res


async def test():
    f = open("1.exe")
    res = await f.read(1)
    print(res)


# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    # py_open()
    # data = win_read(r"D:\Downloads\android-studio-2021.2.1.15-windows.exe")
    # win_write(r"1.exe", data)
    asyncio.run(test())
    # import aiofile
    # for i in range(1):
    #     aiofile.read_file(b"D:/Downloads/android-studio-2021.2.1.15-windows.exe")
# See PyCharm help at https://www.jetbrains.com/help/pycharm/
