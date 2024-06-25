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

from services.speak_to_text.speak_to_text import SpeakToText
from services.camera_saver.camera_saver import CameraSaver
from services.voice_recorder.voice_recorder import VoiceRecorder
from services.service import Service
from services.service_manager import ServiceManager
from preimport import *

# These are all services of AutumnBot
SERVICES: set[Type[Service]] = {
    # CameraSaver,
    # SpeakToText,
    VoiceRecorder
}


async def camera_saver_example(service_manager: ServiceManager) -> None:
    import cv2

    camera_saver = service_manager.get_started_service(CameraSaver)
    if camera_saver is not None:
        camera_saver = cast(ActorRef[Any], camera_saver)
        img = cast(Optional[cv2.typing.MatLike], camera_saver.ask({}))

        if img is not None:
            cv2.imshow("test.png", img)
            cv2.waitKey()


async def speak_to_text_example(service_manager: ServiceManager) -> None:
    import os

    speak_to_text = service_manager.get_started_service(SpeakToText)
    if speak_to_text is not None:
        speak_to_text = cast(ActorRef[Any], speak_to_text)
        speak_to_text.ask(os.path.join(os.path.dirname(__file__), "test.wav"))


async def voice_recorder_example(service_manager: ServiceManager) -> None:
    voice_recorder = service_manager.get_started_service(VoiceRecorder)

    if voice_recorder is not None:
        while True:
            frames = voice_recorder.ask({})
            if frames is not []: print(frames)


# An example of managing and using all services through ServiceManager
async def example() -> None:
    service_manager = ServiceManager(SERVICES)
    service_manager.start_all_services()

    try:
        # await camera_saver_example(service_manager)
        # await speak_to_text_example(service_manager)
        await voice_recorder_example(service_manager)
    finally:
        service_manager.stop_all_services()


def main() -> None:
    import asyncio

    asyncio.run(example())
