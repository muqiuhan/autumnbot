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
from .ollama_message import OllamaMessage
from .. import service

import ollama
import alive_progress

class OllamaClient(service.Service):

    CLASS_NAME: str = "Ollama"

    # Request Ollama's message context. In chat mode, some models can optimize output content through context.
    __context: list[ollama.Message]

    def __init__(self) -> None:
        super().__init__()
        self.info("initialize")
        self.__context = list()

    def on_start(self) -> None:
        super().on_start()
        self.info("start")

    def on_stop(self) -> None:
        super().on_stop()
        self.info("stop")

    def on_receive(self, message: OllamaMessage) -> Optional[dict[str, Any]]:
        self.info("request message")

        with alive_progress.alive_bar(3) as bar:
            request = message.to_request()
            bar()

            if request is not None:
                response = cast(Callable, request)(self.__context)
                bar()
                if response is not None:
                    response_message = response["message"]
                    self.__context.append(response_message)
                    bar()
                    return response_message
