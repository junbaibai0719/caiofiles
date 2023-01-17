import asyncio
import threading

# ov = _overlapped.Overlapped(NULL)
# try:
#     ov.ReadFile(0, 1024)
# except BrokenPipeError:
#     traceback.print_exc()
from utils.timer import atimer, timer


@atimer
async def test_read_file():
    import aiofile
    fp = aiofile.open("C:\\Users\\lin\\Downloads\\python-3.11.1-amd64.exe")
    data = []

    async def coro(fp):
        nonlocal data
        data.append(await fp.read(1024))

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
    # for index, (i, j) in enumerate(zip(data, data1)):
    #     print(index, i, j)
    #     if i != j:
    #         break


@timer
def sync_test_read_file():
    data = []
    with open("C:\\Users\\lin\\Downloads\\python-3.11.1-amd64.exe", "rb") as fp:
        while chunk := fp.read(1024):
            data.append(chunk)
            ...
        # with open("tmp.exe", "wb") as wp:
        #     while data := fp.read(1024):
        #         wp.write(data)
    # print(fp.read(1024))
    data = b''.join(data)
    with open("C:\\Users\\lin\\Downloads\\python-3.11.1-amd64.exe", "rb") as f:
        data1 = f.read()
        print(data1 == data, len(data), len(data1))


@atimer
async def test_readline():
    import aiofile
    fp = aiofile.open("write.txt")
    count = 0
    while await fp.readline():
        count += 1
    print(count)

@atimer
async def test_aiofiles_readline():
    import aiofiles
    async with aiofiles.open("write.txt", "rb") as afp:
        async for line in afp:
            ...


@timer
def test_python_readline():
    with open("write.txt", "rb") as fp:
        # print(fp.readlines())
        # for line in fp:
        #     ...
        count = 0
        while fp.readline():
            count += 1
        print(count)
@atimer
async def test_readlines():
    import aiofile
    fp = aiofile.open("write.txt")
    lines = await fp.readlines()
    with open("write.txt", "rb") as fp:
        print(fp.readlines() == lines)
        fp.readlines()

if __name__ == '__main__':
    # asyncio.run(test_read_file())
    # asyncio.run(test_aiofiles())
    # sync_test_read_file()
    asyncio.run(test_readline())
    asyncio.run(test_aiofiles_readline())
    test_python_readline()