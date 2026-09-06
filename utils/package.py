from __future__ import annotations
from dataclasses import dataclass, field
from pathlib import Path
from typing import List


# ---------------------------------------------------------------------------
# Package model
# ---------------------------------------------------------------------------
@dataclass
class Package:
    name: str
    config_dir: Path | None = field(default=None)
    activation_cmd: str | None = field(default=None)
    services: List[Service] = field(default_factory=list)


@dataclass
class Service:
    name: str
    is_user_service: bool = False
