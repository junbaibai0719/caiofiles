import asyncio
import traceback
from asyncio import ProactorEventLoop

import _overlapped
from _overlapped import NULL, INFINITE

# ov = _overlapped.Overlapped(NULL)
# try:
#     ov.ReadFile(0, 1024)
# except BrokenPipeError:
#     traceback.print_exc()
from utils.timer import atimer


@atimer
async def test_read_file():
    import aiofile
    import threading
    print(threading.current_thread().ident)
    # fp = aiofile.open("C:\\Users\\lin\\Downloads\\MHXY-JD-3.0.393.exe")
    loop: ProactorEventLoop = asyncio.get_event_loop()

    fp = aiofile.open("C:\\Users\\lin\\Downloads\\python-3.11.1-amd64.exe")
    # fut = aiofile.read_file(b"aiofile.pxd")
    p = _overlapped.CreateIoCompletionPort(fp.fileno(), loop._proactor._iocp, 0, 0)
    print(aiofile.get_error_msg(aiofile.get_last_error()), p, loop._proactor._iocp)
    ov = _overlapped.Overlapped(NULL)
    try:
        # error = ov.ReadFile(fp.fileno(), 1024)
        # print(_overlapped.FormatMessage(error), error)
        fp.read_async(1024)
        # aiofile.read_file(fp.fileno(),1024)
        # print(await fp.read(1024))
    except BrokenPipeError:
        traceback.print_exc()
    res = _overlapped.GetQueuedCompletionStatus(loop._proactor._iocp, 10)
    print(res)
    # print(ov.getresult())

if __name__ == '__main__':
    asyncio.run(test_read_file())
