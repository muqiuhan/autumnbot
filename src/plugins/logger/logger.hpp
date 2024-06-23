#ifndef AUTUMNBOT_PLUGINS_LOGGER_HPP
#define AUTUMNBOT_PLUGINS_LOGGER_HPP

#include "plugins/plugins.hpp"
#include "root/root.hpp"

namespace autumnbot::plugins::logger
{
  class Error : public plugins::Error
  {
  public:
    explicit Error(std::string msg) : plugins::Error(std::format("[plugin] <Logger> {}", msg)) {}
  };

  class Logger : public plugins::Plugin
  {
  public:
    explicit Logger(std::string moduleName) : plugins::Plugin(), ModuleName(std::move(moduleName)) {}

    auto Mount() noexcept -> result<void, errors::Error> override;
    auto Umount() noexcept -> result<void, errors::Error> override;

  public:
    const std::string ModuleName;
  };
} // namespace autumnbot::plugins::logger

#endif