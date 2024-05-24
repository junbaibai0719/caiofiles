import asyncio
import threading
import pathlib
import sys
sys.path.append(pathlib.Path(__file__).parent.parent.absolute().as_posix( ) )
# ov = _overlapped.Overlapped(NULL)
# try:
#     ov.ReadFile(0, 1024)
# except BrokenPipeError:
#     traceback.print_exc()
from utils.timer import atimer, timer



@atimer
async def test_read_file():
    import caiofiles
    async with caiofiles.open("write.txt", "rb") as fp:
        data = []
        while chunk := await fp.read(1024):
            data.append(chunk)
        data = b"".join(data)
    with open("write.txt", "rb") as f:
        data1 = f.read()
        print("valid:", data1 == data, len(data), len(data1))


@atimer
async def test_aiofiles():
    import aiofiles
    # lock = threading.Lock()
    data = []
    async with aiofiles.open("write.txt", "rb") as afp:
        while chunk := await afp.read(1024):
        # with lock:
            data.append(chunk)

    data = b"".join(data)
    with open("write.txt", "rb") as f:
        data1 = f.read()
        print(data1 == data, len(data), len(data1))
    # for index, (i, j) in enumerate(zip(data, data1)):
    #     print(index, i, j)
    #     if i != j:
    #         break


@timer
def test_python_read_file():
    data = []
    with open("write.txt", "rb") as fp:
        while chunk := fp.read(1024):
            data.append(chunk)
            ...
        # with open("tmp.exe", "wb") as wp:
        #     while data := fp.read(1024):
        #         wp.write(data)
    # print(fp.read(1024))
    data = b''.join(data)
    with open("write.txt", "rb") as f:
        data1 = f.read()
        print(data1 == data, len(data), len(data1))


@atimer
async def test_readline():
    import caiofiles
    lines = []
    count = 0
    read_tasks = []
    async with caiofiles.open("write.txt", "rb") as fp:
        async for line in fp:
            lines.append(line)
            count += 1

    with open("write.txt", "rb") as fp:
        print(fp.readlines() == lines)
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
    import caiofiles
    fp = caiofiles.open("write.txt", "rb")
    lines = await fp.readlines()
    # with open("write.txt", "rb") as fp:
    #     print(fp.readlines() == lines)
    #     fp.readlines()


@timer
def test_python_readlines():
    with open("write.txt", "rb") as fp:
        fp.readlines()


if __name__ == '__main__':
    asyncio.run(test_read_file())
    asyncio.run(test_aiofiles())
    test_python_read_file()
    # asyncio.run(test_readline())
    # asyncio.run(test_aiofiles_readline())
    # test_python_readline()
    # asyncio.run(test_readlines())
    # test_python_readlines()
