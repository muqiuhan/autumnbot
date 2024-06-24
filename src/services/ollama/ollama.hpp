#ifndef AUTUMNBOT_SERVICES_OLLAMA_HPP
#define AUTUMNBOT_SERVICES_OLLAMA_HPP

#include "cpr/cprtypes.h"
#include "services/services.hpp"

namespace autumnbot::services::ollama
{
  namespace api
  {
    inline static const std::string API  = "http://localhost:11434";
    inline static const std::string CHAT = std::format("{}/api/chat", API);
  }; // namespace api

  namespace request
  {
    class Chat
    {
    public:
      class Message
      {
      public:
        const std::string Role = "user";
        const std::string Content;
      };

    public:
      const bool                   Stream = false;
      const std::string            Model  = "qwen";
      mutable std::vector<Message> Messages;

    public:
      [[nodiscard]] auto Request(std::string msg) const noexcept -> result<std::string, errors::Error>;
    };
  }; // namespace request

  class Ollama : public Service
  {
  public:
    Ollama()
      : Service("Ollama")
    {
      Log.Info("initialize");

      if (cpr::Get(cpr::Url{api::API}).text != "Ollama is running")
        Log.Fail("ollama service is not started");
    }

    auto End() noexcept -> result<void, errors::Error> override;
    auto Start() noexcept -> result<void, errors::Error> override;

    [[nodiscard]] auto Chat(std::string msg) noexcept -> result<std::string, errors::Error>;

  private:
    const request::Chat ChatContext;
  };

} // namespace autumnbot::services::ollama

#endif