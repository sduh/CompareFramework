from tools.architecture.__main__ import main

def test_cli_reports_error_for_missing_repository(tmp_path):
    rc = main(["--root", str(tmp_path)])
    assert rc == 3
