import asyncio
import os
import pytest
import pytest_asyncio
import caiofiles

# -------- Fixtures --------
@pytest_asyncio.fixture
async def test_file_path(request):
    """创建测试文件路径，并在测试后清理"""
    path = f"test_{request.function.__name__}.txt"
    await asyncio.sleep(0)
    yield path
    if os.path.exists(path):
        try:
            os.remove(path)
        except PermissionError:
            await asyncio.sleep(0.1)
            os.remove(path)

# -------- 基本读取测试 --------
@pytest.mark.asyncio
async def test_read_basic(test_file_path):
    """测试基本的读取功能"""
    test_data = b"Hello\nWorld\n"
    with open(test_file_path, "wb") as f:
        f.write(test_data)
    
    async with caiofiles.open(test_file_path, "rb") as f:
        content = await f.read()
        assert content == test_data

@pytest.mark.asyncio
async def test_read_partial(test_file_path):
    """测试部分读取功能"""
    test_data = b"Hello World!"
    with open(test_file_path, "wb") as f:
        f.write(test_data)
    
    async with caiofiles.open(test_file_path, "rb") as f:
        assert await f.read(5) == b"Hello"
        assert await f.read(6) == b" World"
        assert await f.read(1) == b"!"

# -------- 行读取测试 --------
@pytest.mark.asyncio
async def test_readline(test_file_path):
    """测试逐行读取功能"""
    test_data = b"Line 1\nLine 2\nLine 3"
    with open(test_file_path, "wb") as f:
        f.write(test_data)
    
    async with caiofiles.open(test_file_path, "rb") as f:
        assert await f.readline() == b"Line 1\n"
        assert await f.readline() == b"Line 2\n"
        assert await f.readline() == b"Line 3"

@pytest.mark.asyncio
async def test_async_iteration(test_file_path):
    """测试异步迭代功能"""
    test_lines = [b"Line 1\n", b"Line 2\n", b"Line 3\n", b"Line 4"]
    with open(test_file_path, "wb") as f:
        f.writelines(test_lines)
    
    async with caiofiles.open(test_file_path, "rb") as f:
        lines = [line async for line in f]
        assert lines == test_lines

# -------- 基本写入测试 --------
@pytest.mark.asyncio
async def test_write_basic(test_file_path):
    """测试基本的写入功能"""
    test_data = b"Hello World!"
    
    async with caiofiles.open(test_file_path, "wb") as f:
        await f.write(test_data)
    
    with open(test_file_path, "rb") as f:
        assert f.read() == test_data

@pytest.mark.asyncio
async def test_write_empty(test_file_path):
    """测试写入空数据"""
    async with caiofiles.open(test_file_path, "wb") as f:
        await f.write(b"")
    
    with open(test_file_path, "rb") as f:
        assert f.read() == b""

# -------- 大文件测试 --------
@pytest.mark.asyncio
async def test_write_large_data(test_file_path):
    """测试一次性写入大文件"""
    size = 2 * 1024 * 1024  # 2MB
    test_data = b"x" * size
    
    async with caiofiles.open(test_file_path, "wb") as f:
        await f.write(test_data)
    
    with open(test_file_path, "rb") as f:
        content = f.read()
        assert len(content) == size
        assert content == test_data

@pytest.mark.asyncio
async def test_write_chunked(test_file_path):
    """测试分块写入大文件"""
    chunk_size = 1024  # 1KB
    num_chunks = 64    # 64KB 总大小
    chunk = b"x" * chunk_size
    
    async with caiofiles.open(test_file_path, "wb") as f:
        for _ in range(num_chunks):
            await f.write(chunk)
    
    with open(test_file_path, "rb") as f:
        content = f.read()
        assert len(content) == chunk_size * num_chunks
        assert content == b"x" * chunk_size * num_chunks

@pytest.mark.asyncio
async def test_read_large_data(test_file_path):
    """测试一次性读取大文件"""
    size = 2 * 1024 * 1024  # 2MB
    test_data = b"x" * size
    
    # 使用原生文件写入测试数据
    with open(test_file_path, "wb") as f:
        f.write(test_data)
    
    # 一次性读取
    async with caiofiles.open(test_file_path, "rb") as f:
        content = await f.read()
        assert len(content) == size
        assert content == test_data

@pytest.mark.asyncio
async def test_read_large_data_chunks(test_file_path):
    """测试分块读取大文件"""
    chunk_size = 1024  # 1KB
    num_chunks = 64    # 64KB 总大小
    test_data = b"x" * chunk_size * num_chunks
    
    # 写入测试数据
    with open(test_file_path, "wb") as f:
        f.write(test_data)
    
    # 分块读取
    async with caiofiles.open(test_file_path, "rb") as f:
        chunks = []
        while True:
            chunk = await f.read(chunk_size)
            if not chunk:
                break
            chunks.append(chunk)
        
        # 验证数据
        content = b"".join(chunks)
        assert len(chunks) == num_chunks
        assert len(content) == chunk_size * num_chunks
        assert content == test_data

@pytest.mark.asyncio
async def test_read_large_data_partial(test_file_path):
    """测试大文件的部分读取"""
    size = 1024 * 1024  # 1MB
    test_data = b"x" * size
    
    with open(test_file_path, "wb") as f:
        f.write(test_data)
    
    async with caiofiles.open(test_file_path, "rb") as f:
        # 读取开头的数据
        start = await f.read(1024)
        assert start == b"x" * 1024
        
        # 读取中间的数据
        await f.read(size // 2)  # 跳过一半
        middle = await f.read(1024)
        assert middle == b"x" * 1024
        
        # 读取末尾的数据
        await f.read(size - size//2 - 1024 * 3)  # 跳到最后1KB
        end = await f.read(1024)
        assert end == b"x" * 1024

@pytest.mark.asyncio
async def test_read_large_data_lines(test_file_path):
    """测试大文件的行读取"""
    # 创建包含多行的大文件
    line = b"x" * 1000 + b"\n"  # 1KB的行
    num_lines = 1024  # 总共约1MB
    test_data = line * num_lines
    
    with open(test_file_path, "wb") as f:
        f.write(test_data)
    
    async with caiofiles.open(test_file_path, "rb") as f:
        # 读取所有行
        lines = []
        async for line in f:
            lines.append(line)
        
        # 验证数据
        assert len(lines) == num_lines
        assert all(len(l) == 1001 for l in lines[:-1])  # 1000 bytes + \n
        assert all(l.endswith(b"\n") for l in lines[:-1])
        assert b"".join(lines) == test_data

# -------- 特殊场景测试 --------
@pytest.mark.asyncio
async def test_write_after_close(test_file_path):
    """测试文件关闭后写入"""
    f = caiofiles.open(test_file_path, "wb")
    await f.close()
    
    with pytest.raises(ValueError, match="File is closed"):
        await f.write(b"test")

@pytest.mark.asyncio
async def test_context_manager(test_file_path):
    """测试上下文管理器"""
    test_data = b"Hello World!"
    
    async with caiofiles.open(test_file_path, "wb") as f:
        await f.write(test_data)
    
    with open(test_file_path, "rb") as f:
        assert f.read() == test_data 