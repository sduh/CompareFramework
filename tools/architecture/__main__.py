"""Command-line entrypoint for the architecture analyzer."""

from .config import BUILD_DIR
from .engine import run


if __name__ == "__main__":
    data = run()
    stats = data["statistics"]
    print(
        "Architecture analysis generated: "
        f"{stats['module_count']} modules, "
        f"{stats['procedure_count']} procedures, "
        f"{stats['symbol_count']} symbols."
    )
    print(f"Output: {BUILD_DIR}")
