#ifndef AUTUMNBOT_PLUGINS_LOGGER_HPP
#define AUTUMNBOT_PLUGINS_LOGGER_HPP

#include "plugins/plugins.hpp"
#include "root/root.hpp"
#include "spdlog/spdlog.h"

namespace autumnbot::plugins::logger {
  class Error : public plugins::Error {
  public:
    explicit Error(std::string msg)
      : plugins::Error(std::format("[plugin] <Logger> {}", msg)) {}
  };

  class Logger : private plugins::Plugin {
  public:
    explicit Logger(std::string moduleName, std::string pluginName)
      : ModuleName(std::move(moduleName))
      , plugins::Plugin(std::move(pluginName)) {}

    auto Mount() noexcept -> result<void, errors::Error> override;
    auto Umount() noexcept -> result<void, errors::Error> override;

  public:
    inline void Info(std::string msg) noexcept { logging::info("[{}] <{}>: {}", ModuleName, PluginName, msg); }

    inline void Fail(std::string msg) noexcept { logging::error("[{}] <{}>: {}", ModuleName, PluginName, msg); }

  protected:
    const std::string ModuleName;
  };
} // namespace autumnbot::plugins::logger

#endif