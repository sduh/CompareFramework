import json
from .repository import load_repository
from .config import BUILD_DIR
def run():
    repo=load_repository()
    BUILD_DIR.mkdir(parents=True,exist_ok=True)
    data={"schema_version":"1.0.0","repository":{"version":repo.version},"modules":[m.__dict__ for m in repo.modules],"statistics":{"module_count":len(repo.modules)}}
    (BUILD_DIR/"architecture.json").write_text(json.dumps(data,indent=2),encoding="utf-8")
    return data
