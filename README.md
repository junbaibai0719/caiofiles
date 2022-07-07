# caiofiles
## 尝试不使用多线程而是调用Windows的 `fileapi`实现在事件循环内的文件异步IO。
## Try to use Windows' `fileapi` to  achieve asynchronous file IO in event loop, instead of using multithreading.


## 不需要封装`fileapi.h`，只需要实现一个`io.BufferedIOBase`的类，然后使用事件循环的sock_recv方法就能实现异步读取。但是无法实现文件指针和偏移量，事件循环内封装的overlapped对象不支持偏移量属性。
