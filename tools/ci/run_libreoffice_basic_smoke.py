from __future__ import annotations

import argparse
import os
import shutil
import socket
import subprocess
import sys
import tempfile
import time
from pathlib import Path

EXPECTED_VERSION = "7.4.7.2"
EXPECTED_STATUS = "OK"
EXPECTED_MARKER = "COMPAREFRAMEWORK_CI_SMOKE_OK"
RESULT_SHEET = "CompareFramework_CI"
DEFAULT_MACRO = "CF_CI_RuntimeSmoke"
BASIC_LIBRARY = "Standard"
BASIC_MODULE = "CompareFramework"


class HarnessError(RuntimeError):
    pass


class InputContractError(HarnessError):
    pass


class RuntimeContractError(HarnessError):
    pass


class UnoConnectionError(HarnessError):
    pass


class BasicInjectionError(HarnessError):
    pass


class MacroInvocationError(HarnessError):
    pass


class ResultContractError(HarnessError):
    pass


def validate_result_values(
    status: str,
    marker: str,
    expected_marker: str = EXPECTED_MARKER,
) -> None:
    if status != EXPECTED_STATUS:
        raise ResultContractError(
            f"result validation failed: expected STATUS=OK, got {status!r}"
        )
    if marker != expected_marker:
        raise ResultContractError(
            f"result validation failed: expected marker {expected_marker!r}, got {marker!r}"
        )


def validate_version_output(output: str) -> None:
    if EXPECTED_VERSION not in output:
        raise RuntimeContractError(
            f"runtime validation failed: expected LibreOffice {EXPECTED_VERSION}, got {output.strip()!r}"
        )


def validate_inputs(fixture: Path, monolith: Path, macro_name: str) -> None:
    if not fixture.is_file() or fixture.stat().st_size == 0:
        raise InputContractError(f"fixture missing or empty: {fixture}")
    if not monolith.is_file() or monolith.stat().st_size == 0:
        raise InputContractError(f"monolith missing or empty: {monolith}")
    source = monolith.read_text(encoding="utf-8-sig")
    if macro_name not in source:
        raise InputContractError(
            f"macro resolution precheck failed: {macro_name!r} not present in monolith {monolith}"
        )


def choose_local_port() -> int:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        sock.bind(("127.0.0.1", 0))
        return int(sock.getsockname()[1])


def file_url(path: Path) -> str:
    return path.resolve().as_uri()


def connect_uno(port: int, timeout: int):
    try:
        import uno
    except ImportError as exc:
        raise UnoConnectionError(
            "UNO Python bridge is unavailable; run the harness with LibreOffice/PyUNO Python"
        ) from exc

    local_ctx = uno.getComponentContext()
    resolver = local_ctx.ServiceManager.createInstanceWithContext(
        "com.sun.star.bridge.UnoUrlResolver", local_ctx
    )
    deadline = time.monotonic() + timeout
    target = (
        f"uno:socket,host=127.0.0.1,port={port};urp;"
        "StarOffice.ComponentContext"
    )
    last_error = None
    while time.monotonic() < deadline:
        try:
            return resolver.resolve(target)
        except Exception as exc:  # UNO exceptions are runtime-specific.
            last_error = exc
            time.sleep(0.25)
    raise UnoConnectionError(
        f"UNO connection timeout after {timeout}s on port {port}: {last_error}"
    )


def open_document(remote_ctx, fixture_copy: Path):
    smgr = remote_ctx.ServiceManager
    desktop = smgr.createInstanceWithContext("com.sun.star.frame.Desktop", remote_ctx)
    try:
        doc = desktop.loadComponentFromURL(file_url(fixture_copy), "_blank", 0, ())
    except Exception as exc:
        raise HarnessError(f"document open failed: {fixture_copy}: {exc}") from exc
    if doc is None:
        raise HarnessError(f"document open failed: LibreOffice returned no document for {fixture_copy}")
    return desktop, doc


def inject_monolith(document, monolith: Path) -> None:
    source = monolith.read_text(encoding="utf-8-sig")
    try:
        libraries = document.BasicLibraries
        if not libraries.hasByName(BASIC_LIBRARY):
            libraries.createLibrary(BASIC_LIBRARY)
        if not libraries.isLibraryLoaded(BASIC_LIBRARY):
            libraries.loadLibrary(BASIC_LIBRARY)
        library = libraries.getByName(BASIC_LIBRARY)
        if library.hasByName(BASIC_MODULE):
            library.replaceByName(BASIC_MODULE, source)
        else:
            library.insertByName(BASIC_MODULE, source)
    except Exception as exc:
        raise BasicInjectionError(f"Basic injection failed: {exc}") from exc


def invoke_macro(document, macro_name: str) -> None:
    uri = (
        f"vnd.sun.star.script:{BASIC_LIBRARY}.{BASIC_MODULE}.{macro_name}"
        "?language=Basic&location=document"
    )
    try:
        provider = document.getScriptProvider()
        script = provider.getScript(uri)
        script.invoke((), (), ())
    except Exception as exc:
        raise MacroInvocationError(
            f"macro resolution/invocation failed for {macro_name!r}: {exc}"
        ) from exc


def read_result(document) -> tuple[str, str]:
    try:
        sheets = document.Sheets
        if not sheets.hasByName(RESULT_SHEET):
            raise ResultContractError(f"result sheet missing: {RESULT_SHEET}")
        sheet = sheets.getByName(RESULT_SHEET)
        status = sheet.getCellRangeByName("B1").String
        marker = sheet.getCellRangeByName("B2").String
        return status, marker
    except ResultContractError:
        raise
    except Exception as exc:
        raise ResultContractError(f"result read failed: {exc}") from exc


def run_smoke(
    soffice: str,
    fixture: Path,
    monolith: Path,
    macro_name: str = DEFAULT_MACRO,
    expected_marker: str = EXPECTED_MARKER,
    timeout: int = 60,
) -> None:
    validate_inputs(fixture, monolith, macro_name)
    version = subprocess.run(
        [soffice, "--version"],
        check=True,
        capture_output=True,
        text=True,
        timeout=15,
    ).stdout
    validate_version_output(version)
    print(f"[runtime] {version.strip()}")

    port = choose_local_port()
    process = None
    document = None
    desktop = None

    with tempfile.TemporaryDirectory(prefix="compareframework-ci-") as tmp:
        tmpdir = Path(tmp)
        profile = tmpdir / "profile"
        profile.mkdir()
        fixture_copy = tmpdir / fixture.name
        shutil.copy2(fixture, fixture_copy)
        accept = (
            f"--accept=socket,host=127.0.0.1,port={port};urp;"
            "StarOffice.ServiceManager"
        )
        command = [
            soffice,
            "--headless",
            "--nologo",
            "--nodefault",
            "--nofirststartwizard",
            f"-env:UserInstallation={file_url(profile)}",
            accept,
        ]
        print(f"[runtime] starting isolated LibreOffice on port {port}")
        process = subprocess.Popen(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
        try:
            remote_ctx = connect_uno(port, timeout)
            desktop, document = open_document(remote_ctx, fixture_copy)
            inject_monolith(document, monolith)
            invoke_macro(document, macro_name)
            status, marker = read_result(document)
            validate_result_values(status, marker, expected_marker)
            print(f"[basic] STATUS={status}")
            print(f"[basic] MARKER={marker}")
        finally:
            if document is not None:
                try:
                    document.close(True)
                except Exception:
                    try:
                        document.dispose()
                    except Exception:
                        pass
            if desktop is not None:
                try:
                    desktop.terminate()
                except Exception:
                    pass
            if process is not None:
                try:
                    process.wait(timeout=10)
                except subprocess.TimeoutExpired:
                    process.terminate()
                    try:
                        process.wait(timeout=5)
                    except subprocess.TimeoutExpired:
                        process.kill()
                        process.wait(timeout=5)


def parse_args(argv=None):
    parser = argparse.ArgumentParser(description="Run CompareFramework Basic smoke through UNO")
    parser.add_argument("--soffice", required=True)
    parser.add_argument("--fixture", type=Path, required=True)
    parser.add_argument("--monolith", type=Path, required=True)
    parser.add_argument("--macro-name", default=DEFAULT_MACRO)
    parser.add_argument("--expected-marker", default=EXPECTED_MARKER)
    parser.add_argument("--timeout", type=int, default=60)
    parser.add_argument("--negative-missing-macro", action="store_true")
    parser.add_argument("--negative-wrong-marker", action="store_true")
    return parser.parse_args(argv)


def main(argv=None) -> int:
    args = parse_args(argv)
    macro_name = "CF_CI_ProcedureThatDoesNotExist" if args.negative_missing_macro else args.macro_name
    expected_marker = "INTENTIONALLY_WRONG_MARKER" if args.negative_wrong_marker else args.expected_marker
    try:
        run_smoke(
            soffice=args.soffice,
            fixture=args.fixture,
            monolith=args.monolith,
            macro_name=macro_name,
            expected_marker=expected_marker,
            timeout=args.timeout,
        )
    except HarnessError as exc:
        print(f"D2-04.1 FAIL: {exc}", file=sys.stderr)
        return 2
    except (subprocess.SubprocessError, OSError) as exc:
        print(f"D2-04.1 INFRASTRUCTURE FAIL: {exc}", file=sys.stderr)
        return 3
    print("D2-04.1 PASS: real Basic smoke contract verified")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
