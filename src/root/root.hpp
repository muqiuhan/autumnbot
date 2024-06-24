#ifndef AUTUMNBOT_ROOT_HPP
#define AUTUMNBOT_ROOT_HPP

#include <cpr/cpr.h>
#include <spdlog/sinks/stdout_color_sinks.h>
#include <spdlog/spdlog.h>

#include <format>
#include <nlohmann/json.hpp>
#include <string>

#include "./result.hpp"

using namespace cpp;
using json = nlohmann::json;

namespace logging {
  using namespace spdlog;
}

#endif