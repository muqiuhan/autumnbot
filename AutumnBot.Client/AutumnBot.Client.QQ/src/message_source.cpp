#include "include/message_source.h"

namespace AutumnBot::Client::QQ {
    auto Message_Source::init() noexcept -> void {
        try {
            Log::info("Try to establish a connection with mirai-api-http...");
            m_miraiBot.Connect(m_miraiBotOptions);
            Log::info("Successfully establish a connection with mirai-api-http");
        } catch (const std::exception & e) {
            Log::error("Failed to establish connection with mirai-api-http -> " + std::string(e.what()));
        }
    }

    auto Message_Source::makeSessionOptions(const Cyan::QQ_t  botQQ,
                                            const std::string httpHostname,
                                            const std::string webSocketHostname,
                                            const uint16_t    httpPort,
                                            const uint16_t    webSocketPort,
                                            const std::string verifyKey) noexcept -> Cyan::SessionOptions {
        Log::info("Initialize the message source from : " + std::to_string(botQQ.ToInt64()));
        Cyan::SessionOptions options;
        options.BotQQ             = botQQ;
        options.HttpHostname      = httpHostname;
        options.WebSocketHostname = webSocketHostname;
        options.HttpPort          = httpPort;
        options.WebSocketPort     = webSocketPort;
        options.VerifyKey         = verifyKey;
        return options;
    }

} // namespace AutumnBot::Client::QQ