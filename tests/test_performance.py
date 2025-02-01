import asyncio
import os
import time
import pytest
import caiofiles
from pathlib import Path

# -------- 测试数据准备 --------
@pytest.fixture
def test_dir():
    """创建测试目录"""
    dir_path = Path("test_files")
    dir_path.mkdir(exist_ok=True)
    yield dir_path
    # 清理测试文件
    for file in dir_path.glob("*"):
        try:
            file.unlink()
        except PermissionError:
            time.sleep(0.1)
            file.unlink()
    dir_path.rmdir()

def generate_test_data(size_mb):
    """生成测试数据"""
    return b"x" * (size_mb * 1024 * 1024)

# -------- 写入性能测试 --------
async def async_write_file(file_path, data):
    """使用 caiofiles 写入文件"""
    async with caiofiles.open(file_path, "wb") as f:
        await f.write(data)

def sync_write_file(file_path, data):
    """使用原生 Python 写入文件"""
    with open(file_path, "wb") as f:
        f.write(data)

def print_results(title, async_time, sync_time):
    """打印性能测试结果"""
    import sys
    # 强制刷新输出
    print(f"\n{title}:", file=sys.stderr)
    print(f"caiofiles: {async_time:.3f}秒", file=sys.stderr)
    print(f"原生Python: {sync_time:.3f}秒", file=sys.stderr)
    print(f"性能比: {sync_time/async_time:.2f}x", file=sys.stderr)

@pytest.mark.parametrize("size_mb", [1, 10, 50, 100])
def test_write_performance(test_dir, size_mb):
    """测试写入性能"""
    data = generate_test_data(size_mb)
    async_file = test_dir / f"async_write_{size_mb}mb.bin"
    sync_file = test_dir / f"sync_write_{size_mb}mb.bin"
    
    # 测试异步写入
    start_time = time.perf_counter()
    asyncio.run(async_write_file(str(async_file), data))
    async_time = time.perf_counter() - start_time
    
    # 测试同步写入
    start_time = time.perf_counter()
    sync_write_file(sync_file, data)
    sync_time = time.perf_counter() - start_time
    
    # 验证文件大小
    assert async_file.stat().st_size == len(data)
    assert sync_file.stat().st_size == len(data)
    
    print_results(f"写入 {size_mb}MB 数据性能对比", async_time, sync_time)

# -------- 读取性能测试 --------
async def async_read_file(file_path):
    """使用 caiofiles 读取文件"""
    async with caiofiles.open(file_path, "rb") as f:
        return await f.read()

def sync_read_file(file_path):
    """使用原生 Python 读取文件"""
    with open(file_path, "rb") as f:
        return f.read()

@pytest.mark.parametrize("size_mb", [1, 10, 50, 100])
def test_read_performance(test_dir, size_mb):
    """测试读取性能"""
    # 准备测试文件
    test_file = test_dir / f"test_{size_mb}mb.bin"
    data = generate_test_data(size_mb)
    with open(test_file, "wb") as f:
        f.write(data)
    
    # 测试异步读取
    start_time = time.perf_counter()
    content = asyncio.run(async_read_file(str(test_file)))
    async_time = time.perf_counter() - start_time
    assert len(content) == len(data)
    
    # 测试同步读取
    start_time = time.perf_counter()
    content = sync_read_file(test_file)
    sync_time = time.perf_counter() - start_time
    assert len(content) == len(data)
    
    print_results(f"读取 {size_mb}MB 数据性能对比", async_time, sync_time)

# -------- 分块操作性能测试 --------
async def async_chunked_write(file_path, total_size_mb, chunk_size=1024*1024):
    """使用 caiofiles 分块写入"""
    chunk = b"x" * chunk_size
    total_chunks = (total_size_mb * 1024 * 1024) // chunk_size
    
    async with caiofiles.open(file_path, "wb") as f:
        for _ in range(total_chunks):
            await f.write(chunk)

def sync_chunked_write(file_path, total_size_mb, chunk_size=1024*1024):
    """使用原生 Python 分块写入"""
    chunk = b"x" * chunk_size
    total_chunks = (total_size_mb * 1024 * 1024) // chunk_size
    
    with open(file_path, "wb") as f:
        for _ in range(total_chunks):
            f.write(chunk)

@pytest.mark.parametrize("size_mb", [10, 50, 100])
def test_chunked_write_performance(test_dir, size_mb):
    """测试分块写入性能"""
    async_file = test_dir / f"async_chunked_{size_mb}mb.bin"
    sync_file = test_dir / f"sync_chunked_{size_mb}mb.bin"
    
    # 测试异步分块写入
    start_time = time.perf_counter()
    asyncio.run(async_chunked_write(str(async_file), size_mb))
    async_time = time.perf_counter() - start_time
    
    # 测试同步分块写入
    start_time = time.perf_counter()
    sync_chunked_write(sync_file, size_mb)
    sync_time = time.perf_counter() - start_time
    
    # 验证文件大小
    expected_size = size_mb * 1024 * 1024
    assert async_file.stat().st_size == expected_size
    assert sync_file.stat().st_size == expected_size
    
    print_results(f"分块写入 {size_mb}MB 数据性能对比", async_time, sync_time)

def pytest_sessionfinish(session, exitstatus):
    """测试会话结束时的钩子函数"""
    if exitstatus == 0:
        print("\n性能测试汇总报告:", file=sys.stderr)
        print("-" * 50, file=sys.stderr)
        print("所有测试完成！", file=sys.stderr)
        print("注意：实际性能可能因系统负载和硬件条件而异", file=sys.stderr) 