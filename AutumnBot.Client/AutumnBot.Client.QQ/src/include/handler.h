#ifndef __AUTUMNBOT_CLIENT_HANDLER_LOG_H__
#define __AUTUMNBOT_CLIENT_HANDLER_LOG_H__

#include "app.h"
#include "config.h"
#include "log.h"

#include <mirai.h>

namespace AutumnBot::Client::QQ {
    class Handler {
      public:
        static auto friendMessageHandler(const Cyan::FriendMessage & message) noexcept -> void;
    };
} // namespace AutumnBot::Client::QQ

#endif