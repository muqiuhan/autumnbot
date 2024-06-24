# Copyright (c) 2024 Muqiu Han
# 
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
# 
#     * Redistributions of source code must retain the above copyright notice,
#       this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright notice,
#       this list of conditions and the following disclaimer in the documentation
#       and/or other materials provided with the distribution.
#     * Neither the name of AutumnBot nor the names of its contributors
#       may be used to endorse or promote products derived from this software
#       without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import cv2
import typing
import pykka

from services.camera_saver.camera_saver import CameraSaver
from services.service import Service
from services.service_manager import ServiceManager

# These are all services of AutumnBot
SERVICES: set[typing.Type[Service]] = {CameraSaver}


# An example of managing and using all services through ServiceManager
def example() -> None:
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


def main() -> None:
    example()