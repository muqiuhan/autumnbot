#pragma once

#include "log.cpp"
#include "client.cpp"
#include <mirai.h>

namespace AutumnBot::Client::QQ {
    class Handler {
      public:
        inline static auto friendMessageHandler(const Cyan::FriendMessage & message) noexcept -> void {
            if (message.MessageChain.GetPlainText() == "Hi") {
                
            }
        }
    };
} // namespace AutumnBot::Client::QQ