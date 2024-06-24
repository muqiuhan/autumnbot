import cv2
import typing
from services.camera_saver.camera_saver import CameraSaver


def main() -> None:
    camera = CameraSaver.start()
    img = typing.cast(typing.Optional[cv2.Mat], camera.ask({}))
    
    if img is not None:
        cv2.imshow("test", img)
        cv2.waitKey(0)
        camera.stop()
