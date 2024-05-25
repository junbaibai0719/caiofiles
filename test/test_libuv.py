import sys

# sys.path.append("/home/pi/Programs/libuv/lib/")
from py_libuv import pyuv
import uvloop

loop = uvloop.new_event_loop()
print(loop.uvloop)
pyuv.test()