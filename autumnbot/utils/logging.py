import structlog
import abc
import typing


class Logging(abc.ABC):
    """All classes in this project inherit the Logging class to use specialized logging functions."""

    module_name: str = "Unknown"
    class_name: str = "Unknown"
    
    _logger: typing.Any = structlog.get_logger()

    def __init__(self, module_name: str, class_name: str) -> None:
        self.module_name = module_name
        self.class_name = class_name

    def info(self, msg: str) -> None:
        self._logger.info("[{}] <{}>: {}".format(self.module_name, self.class_name, msg))

    def error(self, msg: str) -> None:
        self._logger.error(
            "[{}] <{}>: {}".format(self.module_name, self.class_name, msg)
        )

    def warn(self, msg: str) -> None:
        self._logger.warn("[{}] <{}>: {}".format(self.module_name, self.class_name, msg))
