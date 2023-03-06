#ifndef __AUTUMNBOT_CLIENT_QQ_LOG_H__
#define __AUTUMNBOT_CLIENT_QQ_LOG_H__

#include <spdlog/spdlog.h>

namespace AutumnBot::Client::QQ {
    class Log {
      public:
        static auto info(const std::string msg) noexcept -> void;
        static auto error(const std::string msg) noexcept -> void;
    };
} // namespace AutumnBot::Client::QQ

#endif