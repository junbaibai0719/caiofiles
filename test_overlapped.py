import asyncio
import threading
import traceback
from asyncio import ProactorEventLoop

import _overlapped
from _overlapped import NULL, INFINITE

# ov = _overlapped.Overlapped(NULL)
# try:
#     ov.ReadFile(0, 1024)
# except BrokenPipeError:
#     traceback.print_exc()
import aiofile
from utils.timer import atimer, timer


@atimer
async def test_read_file():
    import aiofile
    fp = aiofile.open("C:\\Users\\lin\\Downloads\\python-3.11.1-amd64.exe")
    data = []

    async def coro(fp):
        nonlocal data
        data.append(await fp.read_async(1024))

    await asyncio.gather(*[coro(fp) for i in range(30000)])
    data = b"".join(data)
    with open("C:\\Users\\lin\\Downloads\\python-3.11.1-amd64.exe", "rb") as f:
        print(f.read() == data, len(data))
    # fp = aiofile.open("C:\\Users\\lin\\Downloads\\MHXY-JD-3.0.393.exe")
    # with open("tmp1.exe", "wb") as wp:
    #     while data := await fp.read_async(1024):
    #         wp.write(data)


@atimer
async def test_aiofiles():
    import aiofiles
    lock = threading.Lock()
    data = []
    async with aiofiles.open("C:\\Users\\lin\\Downloads\\python-3.11.1-amd64.exe", "rb") as afp:
        async def coro(fp):
            nonlocal data
            d = await fp.read(1024)
            with lock:
                data.append(d)

        await asyncio.gather(*[coro(afp) for i in range(30000)])

    data = b"".join(data)
    with open("C:\\Users\\lin\\Downloads\\python-3.11.1-amd64.exe", "rb") as f:
        data1 = f.read()
        print(data1 == data, len(data), len(data1))


@timer
def sync_test_read_file():
    with open("C:\\Users\\lin\\Downloads\\MHXY-JD-3.0.393.exe", "rb") as fp:
        with open("tmp.exe", "wb") as wp:
            while data := fp.read(1024 * 1024 * 20):
                wp.write(data)
    # print(fp.read(1024))


if __name__ == '__main__':
    asyncio.run(test_read_file())
    asyncio.run(test_aiofiles())
    # sync_test_read_file()
