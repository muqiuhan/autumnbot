#include "include/handler.h"

namespace AutumnBot::Client::QQ {
    auto Handler::friendMessageHandler(const Cyan::FriendMessage & message) noexcept -> void {
        Log::info("Received message from message source " + std::to_string(message.Sender.QQ.ToInt64()) + " -> "
                  + message.MessageChain.GetPlainText());
    }
} // namespace AutumnBot::Client::QQ