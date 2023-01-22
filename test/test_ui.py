import sys
import time

from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

import Controller

import qasync

if __name__ == '__main__':
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    loop = qasync.QEventLoop(app)

    engine.load(QUrl.fromLocalFile("main.qml"))

    root_objects = engine.rootObjects()
    if not root_objects:
        sys.exit(-1)
    window = root_objects[0]

    with loop:
        loop.run_forever()