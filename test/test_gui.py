from typing import List
import asyncio
import functools
import sys


# from PyQt5.QtWidgets import (
from PySide6.QtWidgets import (
    QWidget,
    QLabel,
    QLineEdit,
    QTextEdit,
    QPushButton,
    QVBoxLayout,
)

import qasync
from qasync import asyncSlot, asyncClose, QApplication


class MainWindow(QWidget):
    """Main window."""

    _DEF_URL = "https://jsonplaceholder.typicode.com/todos/1"
    """str: Default URL."""

    _SESSION_TIMEOUT = 10
    """float: Session timeout."""

    def __init__(self):
        super().__init__()

        self.setLayout(QVBoxLayout())

        self.lblStatus = QLabel("Idle", self)
        self.layout().addWidget(self.lblStatus)

        self.editUrl = QLineEdit(self._DEF_URL, self)
        self.layout().addWidget(self.editUrl)

        self.editResponse = QTextEdit("", self)
        self.layout().addWidget(self.editResponse)

        self.btnFetch = QPushButton("Fetch", self)
        self.btnFetch.clicked.connect(self.on_btnFetch_clicked)
        self.layout().addWidget(self.btnFetch)


        self._queue = asyncio.Queue(100)
        self._running = True
        self.tasks:List[asyncio.Task] = []

    @asyncClose
    async def closeEvent(self, event):
        self._running = False
        for t in self.tasks:
            t.cancel()
        print(111111)
        await asyncio.gather(*self.tasks, return_exceptions=True)
        print(111111)

    @asyncSlot()
    async def on_btnFetch_clicked(self):
        self.btnFetch.setEnabled(False)
        self.lblStatus.setText("Fetching...")

        tasks = self.tasks
        for _ in range(3000):
            tasks.append(asyncio.create_task(self.get_task()))
            tasks.append(asyncio.create_task(self.put_task()))

    
    async def get_task(self):
        import caiofiles
        while self._running:
            await self._queue.get()
            try:
                data = []
                async with caiofiles.open("write.txt", "rb") as fp:
                    while chunk := await fp.read(1024):
                        data.append(chunk)
                
                # with open("write.txt", "rb") as fp:
                #     print(fp.read() == b''.join(data))
            except:
                ...
            await asyncio.sleep(0)
                
    
    async def put_task(self):
        while self._running:
            await self._queue.put(None)


async def main():
    def close_future(future, loop):
        loop.call_later(10, future.cancel)
        future.cancel()

    loop = asyncio.get_event_loop()
    future = asyncio.Future()

    app = QApplication.instance()
    if hasattr(app, "aboutToQuit"):
        getattr(app, "aboutToQuit").connect(
            functools.partial(close_future, future, loop)
        )

    mainWindow = MainWindow()
    mainWindow.show()

    await future
    return True


if __name__ == "__main__":
    try:
        qasync.run(main())
    except asyncio.exceptions.CancelledError:
        sys.exit(0)