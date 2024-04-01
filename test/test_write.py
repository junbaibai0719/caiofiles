import asyncio

import pathlib
import sys
sys.path.append(pathlib.Path(__file__).parent.parent.absolute().as_posix( ) )

from utils import timer


@timer.timer
def test_python_write_file():
    with open("write.txt", "wb") as fp:
        for i in range(10 ** 6):
            s = f"{i}" * 100
            fp.write(f"中{i}:{s}\n".encode("gbk"))


@timer.atimer
async def test_write_file():
    import aiofile
    async with aiofile.open("write1.txt", "wb") as fp:
        write_tasks = []
        for i in range(10 ** 6):
            s = f"{i}" * 100

            # @timer.atimer
            # async def _write(fp, data):
            #     await fp.write(data)
            #
            # await _write(fp, f"中{i}:{s}\n")
            await fp.write(f"中{i}:{s}\n".encode("gbk"))
            # write_tasks.append(task)
        # await asyncio.gather(*write_tasks)


@timer.atimer
async def test_aiofiles_write_file():
    import aiofiles
    async with aiofiles.open("write2.txt", "wb") as fp:
        write_tasks = []
        for i in range(10 ** 6):
            s = f"{i}" * 100
            task = fp.write(f"中{i}:{s}\n".encode("gbk"))
            await task
            # write_tasks.append(task)
        # await asyncio.gather(*write_tasks)


@timer.atimer
async def test_caio_write_file():
    from caio import AsyncioContext
    ctx = AsyncioContext(max_requests=128)
    with open("write3.txt", "w") as fp:
        write_tasks = []
        fd = fp.fileno()
        offset = 0
        for i in range(10 ** 6):
            s = f"{i}" * 100
            task = ctx.write(s.encode(), fd, offset=offset)
            offset += len(s)
            write_tasks.append(task)
        await asyncio.gather(*write_tasks)


@timer.timer
def valid():
    with open("write.txt", "rb") as fp0, open("write1.txt", "rb") as fp1, open("write2.txt", "rb") as fp2:
        fp0_read = fp0.read()
        fp1_read = fp1.read()
        try:
            fp2_read = fp2.read()
        except:
            fp2_read = ""
        # idx = 0
        # for i, j in zip(fp0_read, fp1_read):
        #     if i != j:
        #         print(i, j, idx)
        #         print(fp0_read[idx-1000:idx + 100])
        #         print(fp1_read[idx-1000:idx + 100])
        #         raise
        #     idx+=1
        print(fp0_read == fp1_read, fp0_read == fp2_read, len(fp0_read), len(fp1_read), len(fp2_read))
        # print(fp0_read[:1024])
        # print(fp1_read[:1024])


@timer.atimer
async def test_write_correct():
    import aiofile
    write_lines = []
    async with aiofile.open("write1.txt", "wb") as fp:
        for i in range(10):
            s = f"{i}" * 100
            line = f"中{i}:{s}\n".encode("gbk")
            await fp.write(line)
            write_lines.append(line)
    with open("write1.txt", "rb") as fp:
        assert fp.read() == b''.join(write_lines)


async def test_write_correct_repeat():
    for i in range(10 ** 5):
        await test_write_correct()


@timer.atimer
async def test_write_lines():
    import aiofile
    async with aiofile.open("write1.txt", "wb") as fp:
        lines = []
        for i in range(10 ** 6):
            s = f"{i}" * 100
            line = f"中{i}:{s}\n".encode("gbk")
            lines.append(line)
            # @timer.atimer
            # async def _write(fp, data):
            #     await fp.write(data)
            #
            # await _write(fp, f"中{i}:{s}\n")
        await fp.write_lines(lines)


@timer.timer
def test_python_write_lines():
    with open("write.txt", "wb") as fp:
        lines = []
        for i in range(10 ** 6):
            s = f"{i}" * 100
            line = f"中{i}:{s}\n".encode("gbk")
            lines.append(line)
        fp.writelines(lines)


if __name__ == '__main__':
    # asyncio.run(test_write_correct_repeat())
    asyncio.run(test_write_file())
    asyncio.run(test_aiofiles_write_file())
    # asyncio.run(test_caio_write_file())
    test_python_write_file()
    # asyncio.run(test_write_lines())
    # test_python_write_lines()
    valid()
