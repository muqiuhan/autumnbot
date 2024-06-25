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


# Chinese speech to text is currently implemented using Vosk and uses a relatively small embedded vosk model.
# Download the model from here and modify __model to customize the model: https://alphacephei.com/vosk/models
class SpeakToText(service.Service):
    __model: vosk.Model
    class_name: str = "SpeakToText"

    def __init__(self) -> None:
        self.info("initialize")
        super().__init__()
        vosk.SetLogLevel(level=-1)

    def on_start(self) -> None:
        self.info("start")
        try:
            self.__model = vosk.Model(
                model_path=os.path.join(
                    os.path.dirname(__file__), "vosk-model-small-cn-0.22"
                )
            )
        except Exception:
            return
        finally:
            return super().on_start()

    # Returns a frame of the camera, or None if an error occurs
    # The message is the path of voice
    def on_receive(self, message: str) -> Optional[str]:
        self.info("Request speak to text")

        wav_file: wave.Wave_read = wave.open(message, "rb")
        if (
            wav_file.getnchannels() != 1
            or wav_file.getsampwidth() != 2
            or wav_file.getcomptype() != "NONE"
        ):
            self.error("Audio file must be WAV format mono PCM.")
            return None

        rec = vosk.KaldiRecognizer(self.__model, wav_file.getframerate())
        rec.SetWords(True)
        rec.SetPartialWords(True)

        self.info("trying to parse the voice file...")
        while True:
            try:
                if rec.AcceptWaveform(wav_file.readframes(4000)):
                    text = json.loads(rec.Result())["text"]
                    self.info("speak to text: {}".format(text))
                    return text
            except Exception as e:
                self.error("unable to parse the voice file: {}".format(e))
                return None

    def on_stop(self) -> None:
        self.info("stop")
