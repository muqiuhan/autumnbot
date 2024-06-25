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

from preimport import *
from .. import service
from .voice_recorder_thread import VoiceRecorderThread
from . import voice_recorder_config as config

import pyaudio


# Smartly record audio and store it as wav file for use by other services.
class VoiceRecorder(service.Service):
    CLASS_NAME: str = "VoiceRecorder"

    __pyaudio_instance: pyaudio.PyAudio
    __stream: pyaudio.PyAudio.Stream

    # Store valid audio paths
    __voice_list: list[str]

    __recorder_thread: VoiceRecorderThread

    def __init__(self) -> None:
        self.info("initialize")
        super().__init__()
        self.__pyaudio_instance = pyaudio.PyAudio()
        self.__voice_list = list()

    def on_start(self) -> None:
        self.info("start")

        # Turn on the microphone using configuration parameters.
        self.__stream = self.__pyaudio_instance.open(
            format=config.FORMAT,
            channels=config.CHANNELS,
            rate=config.RATE,
            input=True,
            frames_per_buffer=config.FRAMES_PER_BUFFER,
        )

        # Put the recording operation into a new thread to execute.
        self.__recorder_thread = VoiceRecorderThread(
            self.__stream,
            self.__voice_list,
            self.__pyaudio_instance.get_sample_size(pyaudio.paInt16),
        )
        self.__recorder_thread.start()
        return super().on_start()

    def on_failure(
        self,
        exception_type: Optional[type[BaseException]],
        exception_value: Optional[BaseException],
        traceback: Optional[Any],
    ) -> None:
        self.error("{}".format(exception_type))
        return super().on_failure(exception_type, exception_value, traceback)

    # Get the latest valid audio path. If there is no valid audio, it will block until the acquisition is successful.
    def on_receive(self, message: Any) -> str:
        while True:
            if self.__voice_list:
                return self.__voice_list.pop()

    def __clean_voices(self) -> None:
        import os

        for voice in self.__voice_list:
            os.remove(voice)

    def on_stop(self) -> None:
        self.info("stop")
        self.__recorder_thread.stop()
        self.__recorder_thread.join()
        self.__stream.stop_stream()
        self.__stream.close()
        self.__pyaudio_instance.terminate()
        self.__clean_voices()
        return super().on_stop()
