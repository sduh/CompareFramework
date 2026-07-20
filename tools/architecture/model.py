from dataclasses import dataclass, field
@dataclass
class Procedure:
    name:str; module:str; visibility:str; kind:str
@dataclass
class RepositoryModel:
    procedures:list=field(default_factory=list)
