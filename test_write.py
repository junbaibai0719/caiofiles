import asyncio

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
    async with aiofiles.open("write2.txt", "w") as fp:
        write_tasks = []
        for i in range(10 ** 6):
            s = f"{i}" * 100
            task = fp.write(f"中{i}:{s}\n")
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
        print(fp0_read == fp1_read, fp0_read == fp2_read, len(fp0_read), len(fp1_read))
        print(fp0_read[:1024])
        print(fp1_read[:1024])


if __name__ == '__main__':
    asyncio.run(test_write_file())
    # asyncio.run(test_aiofiles_write_file())
    test_python_write_file()
    valid()
