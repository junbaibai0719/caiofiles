import time
import functools

from utils.logger import Logger

log = Logger(__name__)

def timer(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        start = time.time_ns()
        res = func(*args,**kwargs)
        end = time.time_ns()
        log.info(f"异步函数【{func.__name__}】 运行耗时 {(end - start)/10**6} ms")
        return res
    return wrapper

def atimer(func):
    @functools.wraps(func)
    async def wrapper(*args, **kwargs):
        start = time.time_ns()
        res = await func(*args,**kwargs)
        end = time.time_ns()
        log.info(f"异步函数【{func.__name__}】 运行耗时 {(end - start)/10**6} ms")
        return res
    return wrapper

def repeat(num = 1):
    def decorator(func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            res = []
            start = time.time()
            for i in range(num):
                res.append(func(*args, **kwargs))
            end = time.time()
            cost = end - start
            log.info(f"函数【{func.__name__}】运行{num}次耗时{cost}秒，平均每次耗时{cost/num*(10**3)}毫秒")
            return res
        return wrapper
    return decorator

@repeat(10**5)
def test():
    pass

if __name__ == '__main__':
    test()
    log.info(test.__name__)