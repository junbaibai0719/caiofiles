import pytest
import asyncio

# @pytest.fixture(scope="function")
# def event_loop():
#     """创建一个新的事件循环"""
#     loop = asyncio.new_event_loop()
#     yield loop
#     # 确保所有挂起的任务都完成
#     pending = asyncio.all_tasks(loop)
#     for task in pending:
#         task.cancel()
#     loop.run_until_complete(asyncio.gather(*pending, return_exceptions=True))
#     loop.close()