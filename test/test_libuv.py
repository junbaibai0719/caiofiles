
import os
os.add_dll_directory(r"E:\Lib\libuv_install\bin")
from py_libuv import pyuv
# import uvloop

# loop = uvloop.new_event_loop()
# print(loop.uvloop)
pyuv.test()