from dataclasses import dataclass, field
from typing import List


# ---------------------------------------------------------------------------
# Package model
# ---------------------------------------------------------------------------
@dataclass
class Package:
    name: str
    services: List[Service] = field(default_factory=list)


@dataclass
class Service:
    name: str
    is_user_service: bool = False
