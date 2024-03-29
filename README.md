# caiofiles: 异步文件支持 file support for asyncio

尝试不使用多线程而是调用Windows的 `fileapi`实现在事件循环内的文件异步IO。
Try to use Windows' `fileapi` to  achieve asynchronous file IO in event loop, instead of using multithreading.
重新封装支持偏移量的ReadFile和Overlapped结构体，借用IocpProactor注册文件句柄实现异步文件读取。

## 支持的平台 platform
windows

## 安装 install
    python setup.py install

## 用法 Usage
    import asyncio
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
    
    async def test_readline():
        import aiofile
        fp = aiofile.open("write.txt")
        count = 0
        while await fp.readline():
            count += 1
        print(count)

    async def test_readlines():
        import aiofile
        fp = aiofile.open("write.txt")
        lines = await fp.readlines()
        with open("write.txt", "rb") as fp:
            print(fp.readlines() == lines)

    if __name__ == '__main__':
        asyncio.run(test_read_file())
        asyncio.run(test_readline())
        asyncio.run(test_readlines())