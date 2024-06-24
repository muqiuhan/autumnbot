#ifndef AUTUMNBOT_PLUGINS_HPP
#define AUTUMNBOT_PLUGINS_HPP

#include "root/root.hpp"
#include "errors/errors.hpp"

namespace autumnbot::plugins
{

  /** All errors that occur in the autumnbot::plugins inherit from this class. */
  class Error : public errors::Error
  {
  public:
    explicit Error(std::string msg)
      : errors::Error(std::format("[plugin] {}", msg))
    {}
  };

  /** Plugin is an abstraction of various built-in plugins in autumnbot,
   ** such as log plugins, etc. */
  class Plugin
  {
  public:
    /** Mount a plugin. Returns void if successful, or Error with error information if failed. */
    virtual auto Mount() noexcept -> result<void, errors::Error> = 0;

    /** Umount a plugin. Returns void if successful, or Error with error information if failed. */
    virtual auto Umount() noexcept -> result<void, errors::Error> = 0;

    virtual ~Plugin() = default;

    explicit Plugin(std::string pluginName)
      : PluginName(std::move(pluginName))
    {}

  protected:
    const std::string PluginName;
  };

  /** PluginManager is used to unify the mount and umount plugins. */
  class PluginManager
  {
  public:
    explicit PluginManager(const std::vector<Plugin *> &plugins)
      : Plugins(plugins)
    {
      logging::info("[plugin] <PluginManager>: mount plugins...");

      for (const auto &plugin : Plugins)
        plugin->Mount()
          .map_error([&](const auto &error) {
          logging::error(error.Msg);
          return error;
        }).expect("[plugin] <PluginManager>: error.");

      logging::info("[plugin] <PluginManager>: done");
    }

    ~PluginManager()
    {
      logging::info("[plugin] <PluginManager>: umount plugins...");

      for (const auto &plugin : Plugins)
        {
          plugin->Umount()
            .map_error([&](const auto &error) {
            logging::error(error.Msg);
            return error;
          }).expect("[plugin] <PluginManager>: error.");

          delete plugin;
        }

      logging::info("[plugin] <PluginManager>: done");
    }

  private:
    const std::vector<Plugin *> &Plugins;
  };
} // namespace autumnbot::plugins

#endif /* AUTUMNBOT_PLUGINS_HPP */