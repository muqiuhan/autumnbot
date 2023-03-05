#pragma once

#include "log.cpp"

#include <WebSocketClient.h>
#include <future>

namespace AutumnBot::Client::QQ {
    class Client {
      public:
        Client(std::string webSocketHostname, std::string webSocketPort)
            : m_webSocketHostname(std::move(webSocketHostname))
            , m_webSocketPort(webSocketPort) {
            m_client.OnTextReceived([&](cyanray::WebSocketClient & client, string text) {
                Log::info("Received message...");
                m_received_cache = text;
            });

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
        }

        ~Client() {
            m_client.Close();
        }

        auto get_received_cache() const noexcept -> std::future<std::string> {
            return std::async([&]() {
                while (m_received_cache.empty())
                    ;

                return m_received_cache;
            });
        }

        auto request(std::string data) noexcept -> std::string {
            m_client.SendText(std::move(data));

            return get_received_cache().get();
        }

        auto init() noexcept -> void {
            try {
                Log::info("Try to connect to AutumnBot.Core...");
                m_client.Connect("ws://" + m_webSocketHostname + ":" + m_webSocketPort);
                Log::info("Successfully connected to AutumnBot.Core");
            } catch (const std::exception & e) {
                Log::info("Unable to connect to AutumnBot.Core -> " + std::string(e.what()));
            }
        }

      private:
        const std::string        m_webSocketHostname;
        const std::string        m_webSocketPort;
        cyanray::WebSocketClient m_client;
        std::string              m_received_cache;
    };
} // namespace AutumnBot::Client::QQ