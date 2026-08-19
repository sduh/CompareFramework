import json
from pathlib import Path

from tools.architecture.engine import run


def test_engine_writes_canonical_architecture_json():
    data = run()
    root = Path(__file__).resolve().parents[1]
    output = root / "build" / "architecture" / "architecture.json"

    assert output.exists()
    persisted = json.loads(output.read_text(encoding="utf-8"))
    assert persisted == data
    assert data["schema_version"] == "1.0.0"
    assert data["statistics"]["module_count"] == 20
    assert data["statistics"]["procedure_count"] == 285
    assert data["statistics"]["parse_warning_count"] == 0
