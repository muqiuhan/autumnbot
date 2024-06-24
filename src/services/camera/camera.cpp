#include "camera.hpp"

#include <ctime>
#include <format>
#include <stop_token>
#include <string>
#include <thread>

#include "opencv2/core/mat.hpp"
#include "opencv2/imgcodecs.hpp"

namespace autumnbot::services::camera {
  auto Camera::End() noexcept -> result<void, errors::Error> {
    Camera0.release();
    CameraSaverThread.request_stop();
    Log.Info("end");
    return {};
  }

  auto Camera::Start() noexcept -> result<void, errors::Error> {
    Log.Info("start");

    if (!Camera0.open(0))
      Log.Fail("Unable to open camera");

    CameraSaver()
      .map_error([&](const auto &err) {
        Log.Fail(err.Msg);
        return err;
      })
      .expect("Cannot start camera");

    return {};
  }

  auto Camera::CameraSaver() noexcept -> result<void, errors::Error> {
    CameraSaverThread = std::jthread{[&](std::stop_token stopToken) {
      cv::Mat img{};
      while (!stopToken.stop_requested())
        {
          while (true)
            {
              const auto path = std::format("camera.png", std::time(nullptr));
              Camera0.read(img);
              if (!img.empty())
                {
                  Log.Info(std::format("capture camera to {}", path));
                  cv::imwrite(path, img);
                }
              std::this_thread::sleep_for(std::chrono::duration(std::chrono::seconds{1}));
            }
        }
    }};

    return {};
  }
} // namespace autumnbot::services::camera