#ifndef AUTUMNBOT_SERVICES_HPP
#define AUTUMNBOT_SERVICES_HPP

#include "plugins/logger/logger.hpp"
#include "root/root.hpp"
#include "errors/errors.hpp"

namespace autumnbot::services
{
  class Service
  {
  public:
    explicit Service(std::string serviceName)
      : Log(plugins::logger::Logger{"service", std::move(serviceName)})
    {}

    virtual ~Service() = default;
    virtual auto Start() noexcept -> result<void, errors::Error> = 0;
    virtual auto End() noexcept -> result<void, errors::Error>   = 0;

  protected:
    plugins::logger::Logger Log;
  };

  class ServiceManager
  {
  public:
    explicit ServiceManager(const std::vector<Service *> &services)
      : Services(services)
    {
      logging::info("[service] <ServiceManager>: start services...");

      for (const auto &service : Services)
        service->Start()
          .map_error([&](const auto &error) {
          logging::error(error.Msg);
          return error;
        }).expect("[service] <ServiceManager>: error.");

      logging::info("[service] <ServiceManager>: done");
    }

    ~ServiceManager()
    {
      logging::info("[service] <ServiceManager>: end services...");

      for (const auto &service : Services)
        {
          service->End()
            .map_error([&](const auto &error) {
            logging::error(error.Msg);
            return error;
          }).expect("[service] <ServiceManager>: error.");

          delete service;
        }

      logging::info("[service] <ServiceManager>: done");
    }

  private:
    const std::vector<Service *> &Services;
  };
}; // namespace autumnbot::services

#endif