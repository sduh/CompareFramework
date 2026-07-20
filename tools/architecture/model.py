from dataclasses import dataclass, field
from pathlib import Path
@dataclass
class Module:
    name:str
    path:str
    line_count:int
@dataclass
class Repository:
    version:str=""
    modules:list[Module]=field(default_factory=list)
