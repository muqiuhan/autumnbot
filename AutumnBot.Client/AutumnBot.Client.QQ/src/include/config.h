#ifndef __AUTUMNBOT_CLIENT_QQ_CONFIG_H__
#define __AUTUMNBOT_CLIENT_QQ_CONFIG_H__

#include <string>

namespace AutumnBot::Client::QQ {

    struct Config {
        inline const static std::string WEBSOCKET_HOSTNAME = "127.0.0.1";
        inline const static std::string WEBSOCKET_PORT     = "3000";
    };

} // namespace AutumnBot::Client::QQ

#endif