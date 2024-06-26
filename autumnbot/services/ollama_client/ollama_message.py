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

from typing import Sequence
from preimport import *
import utils.logging

import ollama


# api request for generating ollama
class OllamaMessage(utils.logging.Logging):

    MODULE_NAME: str = "service"
    CLASS_NAME: str = "OllamaMessage"

    # Request type (chat or generate)
    typ: Optional[str]
    content: str

    # model called
    model: str

    def __init__(self, content: str, typ: str = "chat", model: str = "qwen") -> None:
        super().__init__(self.MODULE_NAME, self.CLASS_NAME)
        self.info("initialize")

        self.typ = OllamaMessage.__check_typ(typ)
        self.content = content
        self.model = model

    @staticmethod
    # Check if request type is valid
    def __check_typ(typ: str) -> Optional[str]:
        match typ:
            case "chat":
                return typ

    def __to_request_message(self) -> ollama.Message:
        return {"role": "user", "content": self.content}

    # Return the corresponding request function according to self.__typ
    def to_request(
        self,
    ) -> Optional[
        Callable[[Any], Union[Mapping[str, Any], Iterator[Mapping[str, Any]]]]
    ]:
        if self.typ is None:
            return None

        typ = cast(str, self.typ)

        match typ:
            case "chat":
                return self.__to_chat_request()

    def __to_chat_request(
        self,
    ) -> Callable[
        [list[ollama.Message]],
        Union[Mapping[str, Any], Iterator[Mapping[str, Any]]],
    ]:
        return lambda history: ollama.chat(
            model=self.model, messages=[self.__to_request_message()]
        )
