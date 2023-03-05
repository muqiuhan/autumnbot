#pragma once

#include <spdlog/spdlog.h>

namespace AutumnBot::Client::QQ {
    class Log {
      public:
        inline static auto info(const std::string msg) noexcept -> void
        {
            spdlog::info("AutumnBot.Client.QQ: {}", msg);
        }

        inline static auto error(const std::string msg) noexcept -> void
        {
            spdlog::error("AutumnBot.Client.QQ: {}", msg);
        }
    };
} // namespace AutumnBot::Client::QQ