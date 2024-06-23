#include <memory>
#include <opencv2/highgui.hpp>
#include <opencv2/videoio.hpp>
#include <vector>
#include "plugins/logger/logger.hpp"
#include "plugins/plugins.hpp"
#include <opencv2/opencv.hpp>

using namespace autumnbot;

const static std::vector<plugins::Plugin *> PLUGINS = {(plugins::Plugin *) new plugins::logger::Logger{"AutumnBot"}};

int main(int argc, char **argv)
{
  plugins::PluginManager pluginManager{PLUGINS};
  auto camera = cv::VideoCapture(0);
  auto img = cv::Mat();
  camera.read(img);
  camera.release();

  cv::imshow("test", img);
  cv::waitKey(0);
  return 0;
}