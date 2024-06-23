#include <memory>
#include <vector>
#include "plugins/logger/logger.hpp"
#include "plugins/plugins.hpp"

using namespace autumnbot;

const static std::vector<plugins::Plugin *> PLUGINS = {(plugins::Plugin *) new plugins::logger::Logger{"AutumnBot"}};

int main(int argc, char **argv)
{
  plugins::PluginManager pluginManager{PLUGINS};
  return 0;
}