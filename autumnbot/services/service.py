import utils.logging
import pykka
import typing


class Service(pykka.ThreadingActor, utils.logging.Logging):
    module_name = "service"

    def __init__(self, class_name: str) -> None:
        super().__init__()

    def on_failure(
        self,
        exception_type: typing.Optional[type[BaseException]],
        exception_value: typing.Optional[BaseException],
        traceback: typing.Optional[typing.Any],
    ) -> None:
        return super().on_failure(exception_type, exception_value, traceback)

    def on_receive(self, message: typing.Any) -> typing.Any:
        self.info("receive")
        return super().on_receive(message)

    def on_start(self) -> None:
        self.info("start")
        return super().on_start()

    def on_stop(self) -> None:
        self.info("stop")
        return super().on_stop()
