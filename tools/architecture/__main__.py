"""Command-line entrypoint for the architecture analyzer."""

from .engine import run


if __name__ == "__main__":
    data = run()
    stats = data["statistics"]
    print(
        "Generated architecture.json for "
        f"{stats['module_count']} modules and {stats['procedure_count']} procedures."
    )
