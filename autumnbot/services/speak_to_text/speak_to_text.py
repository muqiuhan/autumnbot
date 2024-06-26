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

from .. import service
from preimport import *
import json
import wave
import vosk
import os
import alive_progress


# Chinese speech to text is currently implemented using Vosk and uses a relatively small embedded vosk model.
# Download the model from here and modify __model to customize the model: https://alphacephei.com/vosk/models
class SpeakToText(service.Service):

    CLASS_NAME: str = "SpeakToText"
    TIMEOUT = 2000

    __model: vosk.Model
    __vosk_model_path: str

    def __init__(self, vosk_model_path="vosk-model-small-cn-0.22") -> None:
        self.info("initialize")
        super().__init__()
        self.__vosk_model_path = vosk_model_path
        vosk.SetLogLevel(level=-1)

    def on_start(self) -> None:
        self.info("start")
        try:
            # Load vosk model.
            self.__model = vosk.Model(
                model_path=os.path.join(
                    os.path.dirname(__file__), self.__vosk_model_path
                ),
                lang="zh-cn",
            )
        except Exception:
            return
        finally:
            return super().on_start()

    # Convert the voice file path in message to text and return.
    # NOTE: 1. The current message itself is the voice file path.
    #       2. Currently only supports mono channel, PCM encoded wav format audio.
    def on_receive(self, message: str) -> Optional[str]:
        self.info("request speak to text")

        with alive_progress.alive_bar(3) as bar:
            wav_file = self.__open_wav_file(message)
            bar()

            if wav_file is not None:
                self.__check_wavfile(wav_file)
            bar()

            if wav_file is not None:
                voice_text = self.__recognizer(wav_file)
                bar()
                return voice_text

    def __open_wav_file(self, path: str) -> Optional[wave.Wave_read]:
        try:
            return wave.open(path, "rb")
        except Exception:
            self.error("unable to open the wav file: {}".format(path))

    def __check_wavfile(self, wav_file: wave.Wave_read) -> Optional[wave.Wave_read]:
        # Check if the audio format can be parsed.
        if (
            wav_file.getnchannels() != 1
            or wav_file.getsampwidth() != 2
            or wav_file.getcomptype() != "NONE"
        ):
            self.error("audio file must be WAV format mono PCM.")
            return None

        else:
            return wav_file

    def __recognizer(self, wav_file: wave.Wave_read) -> Optional[str]:
        rec = vosk.KaldiRecognizer(self.__model, wav_file.getframerate())
        rec.SetWords(True)
        rec.SetPartialWords(True)

        self.info("trying to parse the voice file...")

        # If more than two thousand reads do not stop parsing, stop parsing and return timeout.
        timeout = 0

        while True:
            timeout = timeout + 1
            if timeout == SpeakToText.TIMEOUT:
                return "timeout"
            try:
                if rec.AcceptWaveform(wav_file.readframes(4000)):
                    text = json.loads(rec.Result())["text"].replace(" ", "")
                    return text
            except Exception as e:
                self.error("unable to parse the voice file: {}".format(e))
                return None

    def on_stop(self) -> None:
        self.info("stop")
