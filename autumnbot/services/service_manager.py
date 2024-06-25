# Copyright (c) 2024 Muqiu Han
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
#     * Redistributions of source code must retain the above copyright notice,
#       this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright notice,
#       this list of conditions and the following disclaimer in the documentation
#       and/or other materials provided with the distribution.
#     * Neither the name of AutumnBot nor the names of its contributors
#       may be used to endorse or promote products derived from this software
#       without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

from services.service import Service

import utils.logging
from preimport import *


# Dynamically manage AutumnBot services
class ServiceManager(utils.logging.Logging):
    module_name: str = "service"
    class_name: str = "ServiceManager"

    # Initial service collection (not started)
    services: set[Type[Service]]

    # A started service can access its started ActorRef through itself
    started_services: dict[Type[Service], ActorRef[Any]] = {}

    def __init__(self, services: set[Type[Service]]) -> None:
        self.info("initialize")
        self.services = services

    # Get unstarted services, return None if the service does not exist
    def __get_service(self, service: Type[Service]) -> Optional[Type[Service]]:
        return next((s for s in self.services if s == service), None)

    # Get the started service, return None if the service does not exist
    def get_started_service(self, service: Type[Service]) -> Optional[ActorRef[Any]]:
        self.info("get service {}".format(service.class_name))

        try:
            return self.started_services[service]
        except KeyError:
            self.error("The service {} is not started.".format(service.class_name))
            return None

    # Add a service without starting it, If now = True, start immediately。
    def add_service(self, service: Type[Service], now: bool = False) -> None:
        self.services.add(service)

        if now:
            self.start_service(service)

    # Start all services at once
    def start_all_services(self) -> None:
        self.info("start all services")
        for service_name in self.services:
            self.start_service(service_name)

    # Start a service that has not been started. If the service is already started, it will do nothing.
    # NOTE: If the service doesn't exist, something strange might be going on :(
    def start_service(self, service: Type[Service]) -> None:
        self.info("start service {}".format(service.class_name))

        service_will_be_started = self.__get_service(service)
        if service_will_be_started is not None:
            self.started_services[service] = cast(
                Type[Service], service_will_be_started
            ).start()
        else:
            self.warn("unable to start service {}".format(service.class_name))

    # Stop all services at once
    def stop_all_services(self) -> None:
        self.info("stop all services")
        for service_name in self.services:
            self.stop_service(service_name)

    # Stop a service that has been started. If the service is not started, it will do nothing.
    def stop_service(self, service: Type[Service]) -> None:
        self.info("stop service {}".format(service.class_name))
        try:
            self.started_services.pop(service).stop()
        except KeyError:
            self.error("service {} is not started.".format(service.class_name))
