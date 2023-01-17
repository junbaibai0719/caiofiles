import asyncio

import aiofiles

from utils import timer


# with open("write.txt", "w") as fp:
#     for i in range(10 ** 6):
#         s = f"{i}" * 100
#         fp.write(f"{i}:{s}\n")

@timer.atimer
async def test_aiofiles():
    alines = []
    async with aiofiles.open("write.txt", "rb") as afp:
        async for line in afp:
            alines.append(line)

    lines = []
    with open("write.txt", "rb") as fp:
        for line in fp:
            lines.append(line)
    print(lines == alines)


if __name__ == '__main__':
    asyncio.run(test_aiofiles())

# @timer.timer
# def test_read():
#     with open("write.txt", "rb") as fp:
#         for line in fp:
#             ...
#
#
# # test_read()
#
#
# @timer.timer
# def test_read():
#     with open("write.txt", "rb") as fp:
#         while res := fp.read(1024):
#             ...
#
#
# with open("write.txt", "rb") as fp:
#     print(fp.readline())
#     print(fp.read(104))
#     print(fp.read(104))
#     print(fp.read(104))
