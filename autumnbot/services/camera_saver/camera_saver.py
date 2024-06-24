# pyright: reportReturnType=false

import typing
import cv2
from .. import service


class CameraSaver(service.Service):
    class_name = "CameraSaver"
    camera0: cv2.VideoCapture = cv2.VideoCapture(0)

    def __init__(self) -> None:
        self.info("initialize")
        super().__init__("CameraSaver")

    def on_start(self) -> None:
        self.info("start")
        return super().on_start()

    def on_receive(self, message: typing.Any) -> typing.Optional[cv2.Mat]:
        self.info("Request to obtain the current camera picture")
        ret, frame = self.camera0.read()

        if ret:
            self.info("Get camera image")
            return frame
        else:
            self.error("Unable to get camera image")
            return None

    def on_stop(self) -> None:
        self.info("stop")
        self.camera0.release()
        return super().on_stop()
