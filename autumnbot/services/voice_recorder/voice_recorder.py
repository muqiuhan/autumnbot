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

import pyaudio
import threading
import audioop
import wave
import time


class VoiceRecorderThread(threading.Thread):

    __stream: pyaudio.PyAudio.Stream
    __frames: list[bytes]
    __running: bool = True
    __voice_list: list[str]
    __sample_width: int

    def __init__(
        self,
        stream: pyaudio.PyAudio.Stream,
        voice_list: list[str],
        sample_width: int,
    ) -> None:
        self.__stream = stream
        self.__voice_list = voice_list
        self.__sample_width = sample_width
        self.__frames = list()
        threading.Thread.__init__(self)

    def run(self) -> None:
        low_audio_flag = 0
        detect_count = 0

        while self.__running:
            detect_count += 1
            data = self.__stream.read(1024)
            rms = audioop.rms(data, 2)
            low_audio_flag = 0 if rms > 5000 else low_audio_flag + 1

            if low_audio_flag > 100:
                if len(self.__frames) <= (int(44100 / 1024 * 2) + 50):
                    low_audio_flag = 0
                    continue
                path = "{}.wav".format(int(time.time()))
                wav_file = wave.open(path, "wb")
                wav_file.setnchannels(1)
                wav_file.setsampwidth(self.__sample_width)
                wav_file.setframerate(44100)
                wav_file.writeframes(b"".join(self.__frames))
                wav_file.close()
                self.__frames.clear()
                low_audio_flag = 0
                self.__voice_list.append(path)
                continue

            self.__frames.append(data)

    def stop(self) -> None:
        self.__running = False


class VoiceRecorder(service.Service):
    class_name: str = "VoiceRecorder"

    __pyaudio_instance: pyaudio.PyAudio
    __stream: pyaudio.PyAudio.Stream
    __voice_list: list[str]
    __recorder_thread: VoiceRecorderThread

    def __init__(self) -> None:
        self.info("initialize")
        super().__init__()
        self.__pyaudio_instance = pyaudio.PyAudio()
        self.__stream = self.__pyaudio_instance.open(
            format=pyaudio.paInt16,
            channels=1,
            rate=44100,
            input=True,
            frames_per_buffer=1024,
        )
        self.__voice_list = list()

    def on_start(self) -> None:
        self.info("start")
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
