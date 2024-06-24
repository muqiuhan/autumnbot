#ifndef AUTUMNBOT_ROOT_HPP
#define AUTUMNBOT_ROOT_HPP

#include <string>
#include <format>
#include <spdlog/spdlog.h>
#include <spdlog/spdlog.h>
#include <spdlog/sinks/stdout_color_sinks.h>
#include <nlohmann/json.hpp>
#include <cpr/cpr.h>
#include "./result.hpp"

using namespace cpp;
using json = nlohmann::json;

namespace logging
{
  using namespace spdlog;
}

#endif