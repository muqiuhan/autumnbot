#ifndef __AUTUMNBOT_CLIENT_QQ_CLIENT_H__
#define __AUTUMNBOT_CLIENT_QQ_CLIENT_H__

#include "config.h"
#include "log.h"

#include <WebSocketClient.h>
#include <future>

namespace AutumnBot::Client::QQ {
    class Client {
      public:
        Client(std::string webSocketHostname, std::string webSocketPort)
            : m_webSocketHostname(std::move(webSocketHostname))
            , m_webSocketPort(webSocketPort) {
            init();
        }

        Client() { init(); }

        ~Client() { m_client.Close(); }

        auto get_received_cache() noexcept -> std::future<std::string>;
        auto request(std::string data) noexcept -> std::string;

      private:
        auto init() noexcept -> void;

      private:
        const std::string        m_webSocketHostname = Config::WEBSOCKET_HOSTNAME;
        const std::string        m_webSocketPort     = Config::WEBSOCKET_PORT;
        cyanray::WebSocketClient m_client;
        std::string              m_received_cache;
    };
} // namespace AutumnBot::Client::QQ

#endif