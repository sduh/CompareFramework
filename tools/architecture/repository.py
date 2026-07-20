from pathlib import Path
from .config import SRC_DIR,VERSION_FILE
from .model import Repository,Module
def load_repository():
    repo=Repository()
    if VERSION_FILE.exists():
        repo.version=VERSION_FILE.read_text(encoding="utf-8").strip()
    for f in sorted(SRC_DIR.rglob("*.bas")):
        repo.modules.append(Module(f.stem,str(f.relative_to(SRC_DIR)),sum(1 for _ in f.open(encoding="utf-8",errors="ignore"))))
    return repo
