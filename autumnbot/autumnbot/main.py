import cv2
import typing
import pykka

from services.camera_saver.camera_saver import CameraSaver
from services.service import Service
from services.service_manager import ServiceManager

SERVICES: set[typing.Type[Service]] = {CameraSaver}


def main() -> None:
    service_manager = ServiceManager(SERVICES)
    service_manager.start_all_service()

    try:
        camera = service_manager.get_started_service(CameraSaver)
        if camera is not None:
            camera = typing.cast(pykka.ActorRef[typing.Any], camera)
            img = typing.cast(typing.Optional[cv2.Mat], camera.ask({}))
            if img is not None:
                cv2.imshow("test", img)
                cv2.waitKey(0)
    finally:
        service_manager.stop_all_service()
