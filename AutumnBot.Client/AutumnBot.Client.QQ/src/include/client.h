#ifndef __AUTUMNBOT_CLIENT_QQ_CLIENT_H__
#define __AUTUMNBOT_CLIENT_QQ_CLIENT_H__

#include "log.h"

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

        auto get_received_cache() noexcept -> std::future<std::string>;
        auto request(std::string data) noexcept -> std::string;
        auto init() noexcept -> void;

      private:
        const std::string        m_webSocketHostname;
        const std::string        m_webSocketPort;
        cyanray::WebSocketClient m_client;
        std::string              m_received_cache;
    };
} // namespace AutumnBot::Client::QQ

#endif