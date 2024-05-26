
import os
# os.add_dll_directory(r"E:\Lib\libuv_install\bin")
from py_libuv import pyuv
import uvloop
loop = uvloop.new_event_loop()
import asyncio
# loop = asyncio.get_event_loop()
# print(loop.uvloop)
async def main():
    fp = await pyuv.open("./main.py", "rb")
    print("test open fp", fp)

loop.run_until_complete(main())
print("loop end")

# pyuv.test()