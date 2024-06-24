#ifndef AUTUMNBOT_ERRORS_HPP
#define AUTUMNBOT_ERRORS_HPP

#include "root/root.hpp"

namespace autumnbot::errors {
  /** Errors is the parent class of all errors in autumnbot.
   ** autumnbot globally disables exceptions and uses result<T, E> to handle
   *errors. */
  class Error {
  public:
    explicit Error(std::string msg)
      : Msg(std::move(msg)) {}

    virtual ~Error() = default;

  public:
    const std::string Msg;
  };
} // namespace autumnbot::errors

#endif