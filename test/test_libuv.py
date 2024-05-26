
import pytest
import os

# os.add_dll_directory(r"E:\Lib\libuv_install\bin")
import sys
import pathlib
sys.path.append(pathlib.Path(__file__).absolute().parent.parent.as_posix())

from utils import timer
print(sys.path)

def test_open_file_read():
    from py_libuv import pyuv
    import uvloop
    loop = uvloop.new_event_loop()

    async def main():
        fp = await pyuv.open("./main.py", "rb")
        assert isinstance(fp, pyuv.AsyncFile)

    loop.run_until_complete(main())


def test_open_file_read_mode_not_exist():
    from py_libuv import pyuv, exceptions
    import uvloop
    loop = uvloop.new_event_loop()

    async def main():
        fp = await pyuv.open("./main1.py", "rb")

    try:
        loop.run_until_complete(main())
    except exceptions.LibUVError:
        pass
    else:
        raise Exception("")


def test_open_file_read_bytes():
    from py_libuv import pyuv
    import uvloop
    loop = uvloop.new_event_loop()

    async def main():
        with open("./main.py", "rb") as fp:
            data = fp.read(10)
        fp = await pyuv.open("./main.py", "rb")
        assert isinstance(fp, pyuv.AsyncFile)
        data1 = await fp.read(10)
        assert data == data1

    loop.run_until_complete(main())


def test_file_read_cost_8192():
    import sys
    print(sys.flags.dev_mode)
    from py_libuv import pyuv
    import asyncio
    import uvloop
    loop = uvloop.new_event_loop()
    import time
    with open("./test_read.txt", "w", encoding="utf-8") as fp:
        for i in range(100000):
            fp.write(f"{time.time_ns()}\n")
    @timer.atimer
    async def main():
        print(1111111)
        while True:
            fp = await pyuv.open("./test_read.txt", "rb")
            print(fp)
        print(fp)
        assert isinstance(fp, pyuv.AsyncFile)
        while data:= await fp.read(8192):
            print(len(data))
            continue


    loop.run_until_complete(main())
    @timer.timer
    def native_py():
        with open("./test_read.txt", "rb") as fp:
            while data:= fp.read(8192):
                continue
    native_py()
    import os
    os.remove("./test_read.txt")


test_file_read_cost_8192()