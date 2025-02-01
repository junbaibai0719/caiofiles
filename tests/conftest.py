import pytest
from test_performance import collect_test_results, generate_performance_charts
import sys

@pytest.hookimpl
def pytest_sessionfinish(session):
    """测试会话结束时的钩子函数"""
    if session.testsfailed == 0:  # 所有测试都通过
        results = collect_test_results()
        if results["write"]["small"]:
            print("\n生成性能测试图表...", file=sys.stderr)
            generate_performance_charts(results)
            print("\n性能测试图表已生成在 performance_charts 目录", file=sys.stderr) 