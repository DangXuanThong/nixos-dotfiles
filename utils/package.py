from __future__ import annotations
from dataclasses import dataclass, field
from typing import Callable, List


# ---------------------------------------------------------------------------
# Package model
# ---------------------------------------------------------------------------
@dataclass
class Package:
    name: str
    config_dir: str | None = field(default=None)
    post_install: Callable[[], None] | None = field(default=None)
    services: List[Service] = field(default_factory=list)


@dataclass
class Service:
    name: str
    is_user_service: bool = False
