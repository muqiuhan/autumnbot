#ifndef __AUTUMNBOT_CLIENT_QQ_MESSAGE_SOURCE_H__
#define __AUTUMNBOT_CLIENT_QQ_MESSAGE_SOURCE_H__

#include "handler.h"
#include "log.h"

#include <cstdint>
#include <mirai.h>
#include <string>

namespace AutumnBot::Client::QQ {
    class Message_Source {
      public:
        Message_Source(const Cyan::QQ_t  botQQ,
                       const std::string httpHostname,
                       const std::string webSocketHostname,
                       const uint16_t    httpPort,
                       const uint16_t    webSocketPort,
                       const std::string verifyKey)
            : m_miraiBotOptions(
                makeSessionOptions(botQQ, httpHostname, webSocketHostname, httpPort, webSocketPort, verifyKey)) {
            m_miraiBot.On<Cyan::LostConnection>([&](const Cyan::LostConnection & e) {
                Log::error("Lost connection with mirai-api-http: " + e.ErrorMessage);
                try {
                    Log::info("Try to re-establish connection with mirai-api-http...");
                    m_miraiBot.Reconnect();
                    Log::info("Successfully re-establish a connection with mirai-api-http");
                } catch (const std::exception & e) {
                    Log::error("Failed to re-establish connection with mirai-api-http -> " + std::string(e.what()));
                }
            });

            m_miraiBot.On<Cyan::FriendMessage>(Handler::friendMessageHandler);
        }

        ~Message_Source() {
            m_miraiBot.Disconnect();
        }

        auto init() noexcept -> void;

      private:
        static auto makeSessionOptions(const Cyan::QQ_t  botQQ,
                                       const std::string httpHostname,
                                       const std::string webSocketHostname,
                                       const uint16_t    httpPort,
                                       const uint16_t    webSocketPort,
                                       const std::string verifyKey) noexcept -> Cyan::SessionOptions;

      private:
        Cyan::MiraiBot             m_miraiBot;
        const Cyan::SessionOptions m_miraiBotOptions;
    };
} // namespace AutumnBot::Client::QQ

#endif