#!/usr/bin/env python3
"""Build all distributable artifacts for the current CompareFramework version."""
from __future__ import annotations
import hashlib
import json
import shutil
import subprocess
import sys
import zipfile
from datetime import date
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DIST = ROOT / "dist"


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def run(script: str) -> None:
    subprocess.run([sys.executable, str(ROOT / "tools" / script)], cwd=ROOT, check=True)


def main() -> int:
    version = (ROOT / "VERSION").read_text(encoding="utf-8").strip()
    DIST.mkdir(parents=True, exist_ok=True)

    # Remove generated files from previous builds while preserving .gitkeep.
    for path in DIST.iterdir():
        if path.name != ".gitkeep":
            if path.is_dir():
                shutil.rmtree(path)
            else:
                path.unlink()

    run("build_monolith.py")
    run("generate_release_certificate_pdf.py")

    monolith = DIST / f"CompareFramework-{version}.bas"
    certificate = DIST / f"RELEASE_CERTIFICATE_{version}.pdf"
    build_manifest = DIST / "BUILD_MANIFEST.json"

    copied = []
    for name in ("README.md", "CHANGELOG.md", "RELEASE_NOTES.md", "VERSION"):
        source = ROOT / name
        target = DIST / name
        shutil.copy2(source, target)
        copied.append(target)

    artifacts = [monolith, certificate, build_manifest, *copied]
    release_manifest = {
        "name": "CompareFramework",
        "version": version,
        "release_type": "release-candidate",
        "build_date": date.today().isoformat(),
        "publication_status": "pending-libreoffice-validation",
        "version_source": "VERSION",
        "artifacts": [
            {
                "path": path.relative_to(ROOT).as_posix(),
                "size_bytes": path.stat().st_size,
                "sha256": sha256(path),
            }
            for path in artifacts
        ],
    }
    manifest_path = ROOT / "RELEASE_MANIFEST.json"
    manifest_path.write_text(json.dumps(release_manifest, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    shutil.copy2(manifest_path, DIST / "RELEASE_MANIFEST.json")

    checksum_files = artifacts + [manifest_path]
    checksums = "\n".join(f"{sha256(p)}  {p.relative_to(ROOT).as_posix()}" for p in checksum_files) + "\n"
    (DIST / "SHA256SUMS.txt").write_text(checksums, encoding="utf-8")

    archive = DIST / f"CompareFramework-{version}.zip"
    included = [
        monolith,
        certificate,
        DIST / "README.md",
        DIST / "CHANGELOG.md",
        DIST / "RELEASE_NOTES.md",
        DIST / "VERSION",
        DIST / "BUILD_MANIFEST.json",
        DIST / "RELEASE_MANIFEST.json",
        DIST / "SHA256SUMS.txt",
    ]
    with zipfile.ZipFile(archive, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as zf:
        for path in included:
            zf.write(path, arcname=path.name)

    print(archive)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
