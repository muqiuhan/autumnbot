#include <cstdlib>
#include <opencv2/highgui.hpp>
#include <opencv2/opencv.hpp>
#include <opencv2/videoio.hpp>

#include "plugins/logger/logger.hpp"
#include "plugins/plugins.hpp"
#include "services/camera/camera.hpp"
#include "services/ollama/ollama.hpp"
#include "services/services.hpp"

using namespace autumnbot;

const static std::vector<plugins::Plugin *> PLUGINS = {
  reinterpret_cast<plugins::Plugin *>(new plugins::logger::Logger{"plugin", "logger"})};

const static std::map<std::string, services::Service *> SERVICES = {
  {"Camera", reinterpret_cast<services::Service *>(new services::camera::Camera{})},
  {"Ollama", reinterpret_cast<services::Service *>(new services::ollama::Ollama{})}};

int main(int argc, char **argv) {
  plugins::PluginManager   pluginManager{PLUGINS};
  services::ServiceManager servicesManager{SERVICES};

  std::cin.get();
  return 0;
}