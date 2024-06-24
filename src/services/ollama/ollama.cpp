#include "ollama.hpp"
#include "cpr/body.h"
#include "cpr/cprtypes.h"
#include <iostream>

namespace autumnbot::services::ollama
{
  auto Ollama::End() noexcept -> result<void, errors::Error>
  {
    Log.Info("end");
    return {};
  }

  auto Ollama::Start() noexcept -> result<void, errors::Error>
  {
    Log.Info("start");
    return {};
  }

  [[nodiscard]] auto Ollama::Chat(std::string msg) noexcept -> result<std::string, errors::Error>
  {
    return ChatContext.Request(msg).map_error([&](const auto & err) {
      Log.Fail(err.Msg);
      return err;
    });
  }

  [[nodiscard]] auto request::Chat::Request(std::string rawMsg) const noexcept -> result<std::string, errors::Error>
  {
    Messages.push_back({"user", std::move(rawMsg)});

    std::string messages = "[";
    for (const auto message : Messages)
      messages += std::format("{{\"role\": \"{}\", \"content\": \"{}\"}},", message.Role, message.Content);
    messages[messages.length() - 1] = ']';

    const auto response = cpr::Post(
      cpr::Url{api::CHAT},
      cpr::Body{std::format("{{ \"messages\": {}, \"stream\": {}, \"model\": \"{}\" }}", messages, Stream, Model)});

    const auto json = json::parse(response.text);

    Messages.push_back({json["message"]["role"], json["message"]["content"]});
    return json["message"]["content"];
  }
} // namespace autumnbot::services::ollama