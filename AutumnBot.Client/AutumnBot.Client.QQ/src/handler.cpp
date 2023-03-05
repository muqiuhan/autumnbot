#pragma once

#include "app.cpp"
#include "config.cpp"
#include "log.cpp"

#include <mirai.h>

namespace AutumnBot::Client::QQ {
    class Handler {
      public:
        static auto friendMessageHandler(const Cyan::FriendMessage & message) noexcept -> void {
            if (message.MessageChain.GetPlainText() == "Hi") {
                message.Reply(Cyan::MessageChain().Plain(
                    App<App_Type::SAY_HELLO>(WEBSOCKET_HOSTNAME, WEBSOCKET_PORT, message.MessageChain.GetPlainText())
                        .request()));
            }
        }
    };
} // namespace AutumnBot::Client::QQ