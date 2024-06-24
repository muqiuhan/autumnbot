#include "ollama.hpp"

#include <exception>

#include "cpr/body.h"
#include "cpr/cprtypes.h"
#include "errors/errors.hpp"

namespace autumnbot::services::ollama {
  auto Ollama::End() noexcept -> result<void, errors::Error> {
    Log.Info("end");
    return {};
  }

  auto Ollama::Start() noexcept -> result<void, errors::Error> {
    Log.Info("start");
    return {};
  }

  [[nodiscard]] auto Ollama::Chat(std::string msg) noexcept -> result<std::string, errors::Error> {
    return ChatContext.Request(msg).map_error([&](const auto &err) {
      Log.Fail(err.Msg);
      return err;
    });
  }

  [[nodiscard]] auto request::Chat::ConstructMessagesRequestBody() const noexcept -> result<std::string, errors::Error> {
    std::string messages = "[";

    for (const auto message : Messages)
      messages += std::format("{{\"role\": \"{}\", \"content\": \"{}\"}},", message.Role, message.Content);

    try
      { messages[messages.length() - 1] = ']'; }
    catch (const std::exception &exn)
      { return fail(exn.what()); }

    return messages;
  }

  [[nodiscard]] auto request::Chat::ConstructRequestBody() const noexcept -> result<std::string, errors::Error> {
    const auto messages = ConstructMessagesRequestBody().value_or("");
    return std::format("{{ \"messages\": {}, \"stream\": {}, \"model\": \"{}\" }}", messages, Stream, Model);
  }

  [[nodiscard]] auto request::Chat::Request(std::string rawMsg) const noexcept -> result<std::string, errors::Error> {
    Messages.push_back({"user", std::move(rawMsg)});

    return ConstructRequestBody()
      .map([&](const auto &body) { return cpr::Post(cpr::Url{api::CHAT}, cpr::Body{body}); })
      .map([&](const auto &response) { return json::parse(response.text); })
      .map([&](const auto &json) {
        Messages.push_back({json["message"]["role"], json["message"]["content"]});
        return json["message"]["content"];
      });
  }
} // namespace autumnbot::services::ollama