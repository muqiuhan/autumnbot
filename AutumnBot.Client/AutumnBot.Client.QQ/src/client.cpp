#include "include/client.h"

namespace AutumnBot::Client::QQ {
    auto Client::get_received_cache() noexcept -> std::future<std::string> {
        return std::async([&]() {
            while (m_received_cache.empty())
                ;

            Log::info("Receive kernel feedback" + m_received_cache);
            const std::string m_received_cache_copy = m_received_cache;
            m_received_cache                        = "";
            return m_received_cache_copy;
        });
    }

    auto Client::request(std::string data) noexcept -> std::string {
        Log::info("Request service from Core : " + data);
        m_client.SendText(std::move(data));

        return get_received_cache().get();
    }

    auto Client::init() noexcept -> void {
        m_client.OnTextReceived([&](cyanray::WebSocketClient & client, string text) { m_received_cache = text; });

        m_client.OnLostConnection([&](cyanray::WebSocketClient & client, int code) {
            Log::error("Lost connection with AutumnBot.Core: " + std::to_string(code));
            try {
                Log::info("Try to reconnect AutumnBot.Core...");
                m_client.Connect("ws://" + m_webSocketHostname + ":" + m_webSocketPort);
                Log::info("Successfully reconnected to AutumnBot.Core");
            } catch (const std::exception & e) {
                Log::info("Unable to reconnect to AutumnBot.Core -> " + std::string(e.what()));
            }
        });

        try {
            Log::info("Try to connect to AutumnBot.Core...");
            m_client.Connect("ws://" + m_webSocketHostname + ":" + m_webSocketPort);
            Log::info("Successfully connected to AutumnBot.Core");
        } catch (const std::exception & e) {
            Log::info("Unable to connect to AutumnBot.Core -> " + std::string(e.what()));
        }
    }

} // namespace AutumnBot::Client::QQ
