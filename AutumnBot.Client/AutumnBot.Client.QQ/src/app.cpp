#include "include/app.h"

namespace AutumnBot::Client::QQ {
    auto App<App_Type::SAY_HELLO>::request() noexcept -> std::string {
        return m_client.request(make());
    }

    auto App<App_Type::SAY_HELLO>::make() const noexcept -> std::string {
        return configor::json::dump(Service_Request{ "AutumnBot.Client.QQ", SERVICE, m_body });
    }

} // namespace AutumnBot::Client::QQ