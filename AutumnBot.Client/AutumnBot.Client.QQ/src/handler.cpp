#include "include/handler.h"

namespace AutumnBot::Client::QQ {
    auto Handler::friendMessageHandler(const Cyan::FriendMessage & message) noexcept -> void {
        if (message.MessageChain.GetPlainText() == "Hi") {
            message.Reply(Cyan::MessageChain().Plain(App<App_Type::SAY_HELLO>(Config::WEBSOCKET_HOSTNAME,
                                                                              Config::WEBSOCKET_PORT,
                                                                              message.MessageChain.GetPlainText())
                                                         .request()));
        }
    }
} // namespace AutumnBot::Client::QQ