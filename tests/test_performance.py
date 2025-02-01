import asyncio
import os
import time
import pytest
import caiofiles
import aiofiles
import sys
from pathlib import Path
import matplotlib.pyplot as plt
import numpy as np

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

async def aiofiles_write_file(file_path, data):
    """使用 aiofiles 写入文件"""
    async with aiofiles.open(file_path, "wb") as f:
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

# 添加全局变量来存储测试结果
_test_results = {
    'write': {
        'small': {},
        'continuous': {},
        'large': {}
    },
    'read': {
        'small': {},
        'continuous': {},
        'large': {}
    }
}

def store_test_result(category, subcategory, size, caio_time, aio_time, sync_time):
    """存储测试结果"""
    size_key = f"{size}{'MB' if size >= 1 else 'KB'}"
    _test_results[category][subcategory][size_key] = {
        'caio': caio_time,
        'aio': aio_time,
        'sync': sync_time
    }

@pytest.mark.parametrize("size_mb", [1, 10, 50, 100])
def test_write_performance(test_dir, size_mb):
    """测试写入性能"""
    data = generate_test_data(size_mb)
    caio_file = test_dir / f"caio_write_{size_mb}mb.bin"
    aio_file = test_dir / f"aio_write_{size_mb}mb.bin"
    sync_file = test_dir / f"sync_write_{size_mb}mb.bin"
    
    # 测试 caiofiles 写入
    start_time = time.perf_counter()
    asyncio.run(async_write_file(str(caio_file), data))
    caio_time = time.perf_counter() - start_time
    
    # 测试 aiofiles 写入
    start_time = time.perf_counter()
    asyncio.run(aiofiles_write_file(str(aio_file), data))
    aio_time = time.perf_counter() - start_time
    
    # 测试同步写入
    start_time = time.perf_counter()
    sync_write_file(sync_file, data)
    sync_time = time.perf_counter() - start_time
    
    # 验证文件大小
    assert caio_file.stat().st_size == len(data)
    assert aio_file.stat().st_size == len(data)
    assert sync_file.stat().st_size == len(data)
    
    # 存储结果
    store_test_result('write', 'large', size_mb, caio_time, aio_time, sync_time)
    
    print(f"\n写入 {size_mb}MB 数据性能对比:")
    print(f"caiofiles: {caio_time:.3f}秒", file=sys.stderr)
    print(f"aiofiles: {aio_time:.3f}秒", file=sys.stderr)
    print(f"原生Python: {sync_time:.3f}秒", file=sys.stderr)
    print(f"caiofiles vs aiofiles: {aio_time/caio_time:.2f}x", file=sys.stderr)
    print(f"caiofiles vs Python: {sync_time/caio_time:.2f}x", file=sys.stderr)

# -------- 读取性能测试 --------
async def async_read_file(file_path):
    """使用 caiofiles 读取文件"""
    async with caiofiles.open(file_path, "rb") as f:
        return await f.read()

async def aiofiles_read_file(file_path):
    """使用 aiofiles 读取文件"""
    async with aiofiles.open(file_path, "rb") as f:
        return await f.read()

def sync_read_file(file_path):
    """使用原生 Python 读取文件"""
    with open(file_path, "rb") as f:
        return f.read()

@pytest.mark.parametrize("size_mb", [1, 10, 50, 100])
def test_read_performance(test_dir, size_mb):
    """测试读取性能"""
    test_file = test_dir / f"test_{size_mb}mb.bin"
    data = generate_test_data(size_mb)
    with open(test_file, "wb") as f:
        f.write(data)
    
    # 测试 caiofiles 读取
    start_time = time.perf_counter()
    content = asyncio.run(async_read_file(str(test_file)))
    caio_time = time.perf_counter() - start_time
    assert len(content) == len(data)
    
    # 测试 aiofiles 读取
    start_time = time.perf_counter()
    content = asyncio.run(aiofiles_read_file(str(test_file)))
    aio_time = time.perf_counter() - start_time
    assert len(content) == len(data)
    
    # 测试同步读取
    start_time = time.perf_counter()
    content = sync_read_file(test_file)
    sync_time = time.perf_counter() - start_time
    assert len(content) == len(data)
    
    # 存储结果
    store_test_result('read', 'large', size_mb, caio_time, aio_time, sync_time)
    
    print(f"\n读取 {size_mb}MB 数据性能对比:")
    print(f"caiofiles: {caio_time:.3f}秒", file=sys.stderr)
    print(f"aiofiles: {aio_time:.3f}秒", file=sys.stderr)
    print(f"原生Python: {sync_time:.3f}秒", file=sys.stderr)
    print(f"caiofiles vs aiofiles: {aio_time/caio_time:.2f}x", file=sys.stderr)
    print(f"caiofiles vs Python: {sync_time/caio_time:.2f}x", file=sys.stderr)

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

# -------- 小块读写测试 --------
@pytest.mark.parametrize("size_kb", [1, 2, 4, 8])
def test_small_write_performance(test_dir, size_kb):
    """测试小块写入性能"""
    data = b"x" * (size_kb * 1024)
    caio_file = test_dir / f"caio_write_{size_kb}kb.bin"
    aio_file = test_dir / f"aio_write_{size_kb}kb.bin"
    sync_file = test_dir / f"sync_write_{size_kb}kb.bin"
    
    # 测试 caiofiles 写入
    start_time = time.perf_counter()
    asyncio.run(async_write_file(str(caio_file), data))
    caio_time = time.perf_counter() - start_time
    
    # 测试 aiofiles 写入
    start_time = time.perf_counter()
    asyncio.run(aiofiles_write_file(str(aio_file), data))
    aio_time = time.perf_counter() - start_time
    
    # 测试同步写入
    start_time = time.perf_counter()
    sync_write_file(sync_file, data)
    sync_time = time.perf_counter() - start_time
    
    # 存储结果
    store_test_result('write', 'small', size_kb, caio_time, aio_time, sync_time)
    
    print(f"\n写入 {size_kb}KB 数据性能对比:")
    print(f"caiofiles: {caio_time:.3f}秒", file=sys.stderr)
    print(f"aiofiles: {aio_time:.3f}秒", file=sys.stderr)
    print(f"原生Python: {sync_time:.3f}秒", file=sys.stderr)
    print(f"caiofiles vs aiofiles: {aio_time/caio_time:.2f}x", file=sys.stderr)
    print(f"caiofiles vs Python: {sync_time/caio_time:.2f}x", file=sys.stderr)

@pytest.mark.parametrize("size_kb", [1, 2, 4, 8])
def test_small_read_performance(test_dir, size_kb):
    """测试小块读取性能"""
    # 准备测试文件
    test_file = test_dir / f"test_{size_kb}kb.bin"
    data = b"x" * (size_kb * 1024)
    with open(test_file, "wb") as f:
        f.write(data)
    
    # 测试 caiofiles 读取
    start_time = time.perf_counter()
    content = asyncio.run(async_read_file(str(test_file)))
    caio_time = time.perf_counter() - start_time
    assert len(content) == len(data)
    
    # 测试 aiofiles 读取
    start_time = time.perf_counter()
    content = asyncio.run(aiofiles_read_file(str(test_file)))
    aio_time = time.perf_counter() - start_time
    assert len(content) == len(data)
    
    # 测试同步读取
    start_time = time.perf_counter()
    content = sync_read_file(test_file)
    sync_time = time.perf_counter() - start_time
    assert len(content) == len(data)
    
    # 存储结果
    store_test_result('read', 'small', size_kb, caio_time, aio_time, sync_time)
    
    print(f"\n读取 {size_kb}KB 数据性能对比:")
    print(f"caiofiles: {caio_time:.3f}秒", file=sys.stderr)
    print(f"aiofiles: {aio_time:.3f}秒", file=sys.stderr)
    print(f"原生Python: {sync_time:.3f}秒", file=sys.stderr)
    print(f"caiofiles vs aiofiles: {aio_time/caio_time:.2f}x", file=sys.stderr)
    print(f"caiofiles vs Python: {sync_time/caio_time:.2f}x", file=sys.stderr)

# -------- 连续小块读写测试 --------
@pytest.mark.parametrize("size_kb", [1, 2, 4, 8])
def test_continuous_small_write(test_dir, size_kb):
    """测试连续小块写入性能"""
    chunk = b"x" * (size_kb * 1024)
    num_chunks = 1000
    
    async def caio_write_chunks():
        async with caiofiles.open(str(caio_file), "wb") as f:
            for _ in range(num_chunks):
                await f.write(chunk)
                
    async def aio_write_chunks():
        async with aiofiles.open(str(aio_file), "wb") as f:
            for _ in range(num_chunks):
                await f.write(chunk)
    
    def sync_write_chunks():
        with open(sync_file, "wb") as f:
            for _ in range(num_chunks):
                f.write(chunk)
    
    caio_file = test_dir / f"caio_continuous_{size_kb}kb.bin"
    aio_file = test_dir / f"aio_continuous_{size_kb}kb.bin"
    sync_file = test_dir / f"sync_continuous_{size_kb}kb.bin"
    
    # 测试 caiofiles 连续写入
    start_time = time.perf_counter()
    asyncio.run(caio_write_chunks())
    caio_time = time.perf_counter() - start_time
    
    # 测试 aiofiles 连续写入
    start_time = time.perf_counter()
    asyncio.run(aio_write_chunks())
    aio_time = time.perf_counter() - start_time
    
    # 测试同步连续写入
    start_time = time.perf_counter()
    sync_write_chunks()
    sync_time = time.perf_counter() - start_time
    
    # 存储结果
    store_test_result('write', 'continuous', size_kb, caio_time, aio_time, sync_time)
    
    print(f"\n连续写入 {num_chunks}次 {size_kb}KB 数据性能对比:")
    print(f"caiofiles: {caio_time:.3f}秒", file=sys.stderr)
    print(f"aiofiles: {aio_time:.3f}秒", file=sys.stderr)
    print(f"原生Python: {sync_time:.3f}秒", file=sys.stderr)
    print(f"caiofiles vs aiofiles: {aio_time/caio_time:.2f}x", file=sys.stderr)
    print(f"caiofiles vs Python: {sync_time/caio_time:.2f}x", file=sys.stderr)

@pytest.mark.parametrize("size_kb", [1, 2, 4, 8])
def test_continuous_small_read(test_dir, size_kb):
    """测试连续小块读取性能"""
    chunk_size = size_kb * 1024
    num_chunks = 1000
    test_data = b"x" * (chunk_size * num_chunks)
    
    # 准备测试文件
    test_file = test_dir / f"test_continuous_{size_kb}kb.bin"
    with open(test_file, "wb") as f:
        f.write(test_data)
    
    async def caio_read_chunks():
        chunks = []
        async with caiofiles.open(str(test_file), "rb") as f:
            for _ in range(num_chunks):
                chunk = await f.read(chunk_size)
                chunks.append(chunk)
        return b''.join(chunks)
    
    async def aio_read_chunks():
        chunks = []
        async with aiofiles.open(str(test_file), "rb") as f:
            for _ in range(num_chunks):
                chunk = await f.read(chunk_size)
                chunks.append(chunk)
        return b''.join(chunks)
    
    def sync_read_chunks():
        chunks = []
        with open(test_file, "rb") as f:
            for _ in range(num_chunks):
                chunk = f.read(chunk_size)
                chunks.append(chunk)
        return b''.join(chunks)
    
    # 测试 caiofiles 连续读取
    start_time = time.perf_counter()
    content = asyncio.run(caio_read_chunks())
    caio_time = time.perf_counter() - start_time
    assert len(content) == len(test_data)
    
    # 测试 aiofiles 连续读取
    start_time = time.perf_counter()
    content = asyncio.run(aio_read_chunks())
    aio_time = time.perf_counter() - start_time
    assert len(content) == len(test_data)
    
    # 测试同步连续读取
    start_time = time.perf_counter()
    content = sync_read_chunks()
    sync_time = time.perf_counter() - start_time
    assert len(content) == len(test_data)
    
    # 存储结果
    store_test_result('read', 'continuous', size_kb, caio_time, aio_time, sync_time)
    
    print(f"\n连续读取 {num_chunks}次 {size_kb}KB 数据性能对比:")
    print(f"caiofiles: {caio_time:.3f}秒", file=sys.stderr)
    print(f"aiofiles: {aio_time:.3f}秒", file=sys.stderr)
    print(f"原生Python: {sync_time:.3f}秒", file=sys.stderr)
    print(f"caiofiles vs aiofiles: {aio_time/caio_time:.2f}x", file=sys.stderr)
    print(f"caiofiles vs Python: {sync_time/caio_time:.2f}x", file=sys.stderr)

def plot_performance_results(results, title, save_path):
    """生成性能对比图表
    
    :param results: 包含测试结果的字典
    :param title: 图表标题
    :param save_path: 保存路径
    """
    # 设置中文字体
    plt.rcParams['font.sans-serif'] = ['SimHei']  # 用来正常显示中文标签
    plt.rcParams['axes.unicode_minus'] = False  # 用来正常显示负号
    
    categories = list(results.keys())
    caio_times = [r['caio'] for r in results.values()]
    aio_times = [r['aio'] for r in results.values()]
    sync_times = [r['sync'] for r in results.values()]
    
    x = np.arange(len(categories))
    width = 0.25
    
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 10))
    
    # 执行时间对比
    rects1 = ax1.bar(x - width, caio_times, width, label='caiofiles')
    rects2 = ax1.bar(x, aio_times, width, label='aiofiles')
    rects3 = ax1.bar(x + width, sync_times, width, label='Python')
    
    ax1.set_ylabel('执行时间 (秒)')
    ax1.set_title(f'{title} - 执行时间对比')
    ax1.set_xticks(x)
    ax1.set_xticklabels(categories)
    ax1.legend()
    
    # 添加数值标签
    def autolabel(rects):
        for rect in rects:
            height = rect.get_height()
            ax1.annotate(f'{height:.3f}s',
                        xy=(rect.get_x() + rect.get_width() / 2, height),
                        xytext=(0, 3),
                        textcoords="offset points",
                        ha='center', va='bottom')
    
    autolabel(rects1)
    autolabel(rects2)
    autolabel(rects3)
    
    # 性能比例对比
    caio_vs_aio = [aio/caio for aio, caio in zip(aio_times, caio_times)]
    caio_vs_sync = [sync/caio for sync, caio in zip(sync_times, caio_times)]
    
    ax2.plot(categories, caio_vs_aio, 'o-', label='caiofiles vs aiofiles')
    ax2.plot(categories, caio_vs_sync, 's-', label='caiofiles vs Python')
    ax2.axhline(y=1.0, color='r', linestyle='--', alpha=0.3)
    
    ax2.set_ylabel('性能比')
    ax2.set_title('性能比例对比 (>1 表示 caiofiles 更快)')
    ax2.legend()
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig(save_path, dpi=300, bbox_inches='tight')  # 增加分辨率
    plt.close()

def collect_test_results():
    """获取测试结果"""
    return _test_results

def generate_performance_charts(results):
    """生成所有性能图表"""
    charts_dir = Path("performance_charts")
    charts_dir.mkdir(exist_ok=True)
    
    # 生成小块操作图表
    plot_performance_results(
        results['write']['small'],
        '小块写入性能',
        charts_dir / 'small_write_performance.png'
    )
    plot_performance_results(
        results['read']['small'],
        '小块读取性能',
        charts_dir / 'small_read_performance.png'
    )
    
    # 生成连续操作图表
    plot_performance_results(
        results['write']['continuous'],
        '连续小块写入性能',
        charts_dir / 'continuous_write_performance.png'
    )
    plot_performance_results(
        results['read']['continuous'],
        '连续小块读取性能',
        charts_dir / 'continuous_read_performance.png'
    )
    
    # 生成大文件操作图表
    plot_performance_results(
        results['write']['large'],
        '大文件写入性能',
        charts_dir / 'large_write_performance.png'
    )
    plot_performance_results(
        results['read']['large'],
        '大文件读取性能',
        charts_dir / 'large_read_performance.png'
    )
