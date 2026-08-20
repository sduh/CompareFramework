from tools.architecture.validation import (
    ArchitectureValidationError,
    validate_architecture_document,
)

def valid_document():
    return {
        "schema_version": "1.0.0",
        "repository": {"name": "x", "version": "1.0.0", "root": "."},
        "languages": [],
        "modules": [{"name": "M", "path": "src/M.bas", "line_count": 1, "procedures": []}],
        "statistics": {"module_count": 1},
    }

def test_validation_accepts_valid_document():
    validate_architecture_document(valid_document())

def test_validation_rejects_missing_field():
    doc = valid_document()
    del doc["modules"]
    try:
        validate_architecture_document(doc)
    except ArchitectureValidationError:
        return
    assert False, "Expected ArchitectureValidationError"

def test_validation_rejects_duplicate_module_paths():
    doc = valid_document()
    doc["modules"].append(dict(doc["modules"][0]))
    doc["statistics"]["module_count"] = 2
    try:
        validate_architecture_document(doc)
    except ArchitectureValidationError:
        return
    assert False, "Expected ArchitectureValidationError"
