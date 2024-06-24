#include <opencv2/highgui.hpp>
#include <opencv2/videoio.hpp>
#include <vector>
#include "opencv2/imgcodecs.hpp"
#include "plugins/logger/logger.hpp"
#include "plugins/plugins.hpp"
#include "services/camera/camera.hpp"
#include "services/services.hpp"
#include <opencv2/opencv.hpp>

using namespace autumnbot;

const static std::vector<plugins::Plugin *> PLUGINS = {
  reinterpret_cast<plugins::Plugin *>(new plugins::logger::Logger{"plugin", "logger"})};

const static std::vector<services::Service *> SERVICES = {
  reinterpret_cast<services::Service *>(new services::camera::Camera{})};

int main(int argc, char **argv)
{
  plugins::PluginManager   pluginManager{PLUGINS};
  services::ServiceManager servicesManager{SERVICES};
  
  std::cin.get();
  return 0;
}