import logging
import os
import time


class Logger(logging.Logger):
    __slots__ = ["_stream_handler", "_formatter", "_file_handler"]

    def __init__(self, name, log_save_path="./log",
                 log_save_name=f"{time.strftime('%Y%m%d', time.localtime(time.time()))}.log",
                 level=logging.INFO):
        super(Logger, self).__init__(name, level)
        self._stream_handler = logging.StreamHandler()
        if not os.path.exists(log_save_path):
            os.mkdir(log_save_path)
        log_save_path = f"{log_save_path}/{log_save_name}"
        self._file_handler = logging.FileHandler(filename=log_save_path, encoding="utf-8")

        self._formatter = logging.Formatter(
            "%(asctime)s %(levelname)s Process:%(process)d-Thread:%(thread)d-%(name)s-%(filename)s-%(funcName)s-%(lineno)d: %(message)s")
        self._stream_handler.setFormatter(self._formatter)
        self._file_handler.setFormatter(self._formatter)
        self.addHandler(self._stream_handler)
        self.addHandler(self._file_handler)


if __name__ == '__main__':
    log = Logger(__name__)
    log.debug("12313")
    log.info({"12313"})
    log.warning(["12313"])
    log.error(("12313",))
