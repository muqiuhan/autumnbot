#ifndef AUTUMNBOT_SERVICES_CAMERA_HPP
#define AUTUMNBOT_SERVICES_CAMERA_HPP

#include "opencv2/videoio.hpp"
#include "services/services.hpp"
#include <cstdlib>

namespace autumnbot::services::camera
{
  class Camera : private Service
  {
  public:
    Camera()
      : Service("Camera")
    {
      Log.Info("initialize");
    }

    virtual ~Camera() = default;

    auto End() noexcept -> result<void, errors::Error> override;
    auto Start() noexcept -> result<void, errors::Error> override;

  private:
    cv::VideoCapture                Camera0;
    std::jthread                    CameraSaverThread;

  private:
    auto CameraSaver() noexcept -> result<void, errors::Error>;
  };
}; // namespace autumnbot::services::camera

#endif