#ifndef __AUTUMNBOT_CLIENT_QQ_APP_H__
#define __AUTUMNBOT_CLIENT_QQ_APP_H__

#include "client.h"

#include <WebSocketClient.h>
#include <configor/json.hpp>

namespace AutumnBot::Client::QQ {
    struct Service_Request {
        std::string header;
        std::string service;
        std::string body;

        CONFIGOR_BIND(configor::json::value, Service_Request, REQUIRED(service), REQUIRED(body))
    };

    enum class App_Type { SAY_HELLO };

    template <App_Type _Tp_appType> class App {
      public:
        virtual auto request() const noexcept -> std::string = 0;

      private:
        virtual auto make() const noexcept -> std::string = 0;
    };

    template <> class App<App_Type::SAY_HELLO> {
      public:
        explicit App(std::string webSocketHostname, std::string webSocketPort, std::string body)
            : m_body(std::move(body))
            , m_client(Client(webSocketHostname, webSocketPort)) {
            m_client.init();
        }

        auto request() noexcept -> std::string;

      private:
        auto make() const noexcept -> std::string;

      private:
        const std::string         m_body;
        inline static std::string SERVICE = "say hello";
        Client                    m_client;
    };
} // namespace AutumnBot::Client::QQ

#endif