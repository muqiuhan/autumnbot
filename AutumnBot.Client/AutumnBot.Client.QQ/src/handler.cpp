#include "include/handler.h"

namespace AutumnBot::Client::QQ {
    auto Handler::friendMessageHandler(const Cyan::FriendMessage & message) noexcept -> void {
        Log::info("Received message from message source " + std::to_string(message.Sender.QQ.ToInt64()) + " -> "
                  + message.MessageChain.GetPlainText());
        if (message.MessageChain.GetPlainText() == "Hi") {
            message.Reply(
                Cyan::MessageChain().Plain(App<App_Type::SAY_HELLO>(message.MessageChain.GetPlainText()).request()));
        }
    }
} // namespace AutumnBot::Client::QQ