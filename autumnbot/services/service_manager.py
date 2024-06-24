from services.service import Service

import utils.logging
import typing
import pykka


class ServiceManager(utils.logging.Logging):
    module_name: str = "service"
    class_name: str = "ServiceManager"

    services: set[typing.Type[Service]]
    started_services: dict[typing.Type[Service], pykka.ActorRef[typing.Any]] = {}

    def __init__(self, services: set[typing.Type[Service]]) -> None:
        self.info("initialize")
        self.services = services

    def __get_service(
        self, service: typing.Type[Service]
    ) -> typing.Optional[typing.Type[Service]]:
        return next((s for s in self.services if s == service), None)

    def get_started_service(
        self, service: typing.Type[Service]
    ) -> typing.Optional[pykka.ActorRef[typing.Any]]:
        self.info("get started service {}".format(service))

        try:
            return self.started_services[service]
        except KeyError:
            self.error("The service {} is not started.".format(service))
            return None

    def add_service(self, service: typing.Type[Service]) -> None:
        self.services.add(service)

    def start_all_service(self) -> None:
        for service_name in self.services:
            self.start_service(service_name)

    def start_service(self, service: typing.Type[Service]) -> None:
        self.info("start service {}".format(Service))

        service_will_be_started = self.__get_service(service)
        if service_will_be_started is not None:
            self.started_services[service] = typing.cast(
                typing.Type[Service], service_will_be_started
            ).start()
        else:
            self.error("Unable to start service {}".format(service))

    def stop_all_service(self) -> None:
        for service_name in self.services:
            self.stop_service(service_name)

    def stop_service(self, service: typing.Type[Service]) -> None:
        self.info("stop service {}".format(Service))
        try:
            self.started_services.pop(service).stop()
        except KeyError:
            self.error("The service {} is not started.".format(service))
