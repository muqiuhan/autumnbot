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

import threading
import audioop
import wave
import time
import pyaudio

from . import voice_recorder_config as config
import utils.logging


# This thread will record audio intelligently.
# The current strategy is:
#   if the volume is lower than AUDIO_MIN_RMS within a certain period of time (specified by MAX_LOW_AUDIO_FLAG),
#   it is considered as no sound, and the audio saving method is started.
class VoiceRecorderThread(threading.Thread, utils.logging.Logging):
    MODULE_NAME = "service"
    CLASS_NAME = "VoiceRecorderThread"
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
        # Minimum volume duration
        low_audio_flag = 0

        while self.__running:
            data = self.__stream.read(config.FRAMES_PER_BUFFER)
            rms = audioop.rms(data, 2)
            low_audio_flag = 0 if rms > config.AUDIO_MIN_RMS else low_audio_flag + 1

            if low_audio_flag > config.MAX_LOW_AUDIO_FLAG:
                if len(self.__frames) <= (
                    int(config.RATE / config.FRAMES_PER_BUFFER * 2) + 50
                ):
                    low_audio_flag = 0
                    continue
                path = "{}.wav".format(int(time.time()))
                self.__save(path)
                self.__frames.clear()
                self.__voice_list.append(path)

                low_audio_flag = 0
                continue

            self.__frames.append(data)

    def __save(self, path: str) -> None:
        self.info("save voice audio {}".format(path))
        wav_file = wave.open(path, "wb")
        wav_file.setnchannels(1)
        wav_file.setsampwidth(self.__sample_width)
        wav_file.setframerate(config.RATE)
        wav_file.writeframes(b"".join(self.__frames))
        wav_file.close()

    def stop(self) -> None:
        self.__running = False
