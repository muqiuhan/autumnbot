#include "include/log.h"

namespace AutumnBot::Client::QQ {
    auto Log::info(const std::string msg) noexcept -> void {
        spdlog::info("AutumnBot.Client.QQ: {}", msg);
    }

    auto Log::error(const std::string msg) noexcept -> void {
        spdlog::error("AutumnBot.Client.QQ: {}", msg);
    }
} // namespace AutumnBot::Client::QQ