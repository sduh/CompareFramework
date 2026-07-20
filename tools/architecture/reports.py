from pathlib import Path
def generate_reports(results):
    out=Path("build/architecture")
    out.mkdir(parents=True, exist_ok=True)
    (out/"README.txt").write_text(
        "Architecture reports will be generated here during D2-03.x\n",
        encoding="utf-8")
