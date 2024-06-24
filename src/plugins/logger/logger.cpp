#include "logger.hpp"

#include <exception>
#include <memory>

namespace autumnbot::plugins::logger {
  auto Logger::Mount() noexcept -> result<void, errors::Error> {
    logging::info("[plugin] <Logger>: Mount");
    try
      {
        auto console    = spdlog::stdout_color_mt("console");
        auto err_logger = spdlog::stderr_color_mt("stderr");

        return {};
      }
    catch (const std::exception &exn)
      { return fail(Error(exn.what())); }
  }

  auto Logger::Umount() noexcept -> result<void, errors::Error> {
    logging::info("[plugin] <Logger>: Unount");
    return {};
  }
} // namespace autumnbot::plugins::logger