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

import typing
import cv2
from .. import service


# Capture a frame from the camera
class CameraSaver(service.Service):
    class_name = "CameraSaver"
    camera0: cv2.VideoCapture = cv2.VideoCapture(0)

    def __init__(self) -> None:
        self.info("initialize")
        super().__init__()

    def on_start(self) -> None:
        self.info("start")
        return super().on_start()

    # Returns a frame of the camera, or None if an error occurs
    def on_receive(self, message: typing.Any) -> typing.Optional[cv2.typing.MatLike]:
        self.info("request to obtain the current camera picture")
        ret, frame = self.camera0.read()

        if ret:
            self.info("Get camera image")
            return frame
        else:
            self.error("unable to get camera image")
            return None

    def on_stop(self) -> None:
        self.info("stop")
        self.camera0.release()
        return super().on_stop()
