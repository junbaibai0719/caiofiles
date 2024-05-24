import asyncio
import functools
import pathlib

import caiofiles
import qasync
from PySide6.QtCore import QObject, Slot
from PySide6.QtQml import QmlElement

QML_IMPORT_NAME = "Controllers"
QML_IMPORT_MAJOR_VERSION = 1


@QmlElement
class Controller(QObject):
    def __init__(self, parent=None):
        super(Controller, self).__init__(parent)

        self._async_reading = False

        with open("test.txt", "w") as fp:
            for i in range(10 ** 6):
                fp.write(f"{str(i) * 100}\n")

    @qasync.asyncSlot()
    async def async_read(self):
        if not self._async_reading:
            self._async_reading = True
            lines = []
            async with caiofiles.open("test.txt") as fp:
                async for line in fp:
                    lines.append(line)
            print(len(lines))
            self._async_reading = False

    @Slot()
    def sync_read(self):
        lines = []
        with open("test.txt", "rb") as fp:
            for line in fp:
                lines.append(line)
        print(len(lines))
