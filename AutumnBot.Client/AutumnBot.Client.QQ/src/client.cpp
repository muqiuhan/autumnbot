#include "include/client.h"

namespace AutumnBot::Client::QQ {
    auto Client::get_received_cache() noexcept -> std::future<std::string> {
        return std::async([&]() {
            while (m_received_cache.empty())
                ;

            const std::string m_received_cache_copy = m_received_cache;
            m_received_cache                        = "";
            return m_received_cache_copy;
        });
    }

    auto Client::request(std::string data) noexcept -> std::string {
        m_client.SendText(std::move(data));

        return get_received_cache().get();
    }

    auto Client::init() noexcept -> void {
        try {
            Log::info("Try to connect to AutumnBot.Core...");
            m_client.Connect("ws://" + m_webSocketHostname + ":" + m_webSocketPort);
            Log::info("Successfully connected to AutumnBot.Core");
        } catch (const std::exception & e) {
            Log::info("Unable to connect to AutumnBot.Core -> " + std::string(e.what()));
        }
    }

} // namespace AutumnBot::Client::QQ
