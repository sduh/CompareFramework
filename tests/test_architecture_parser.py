from pathlib import Path

from tools.architecture.parser import parse_module, parse_module_file


def test_parses_procedure_signature_parameters_and_bounds():
    module = parse_module(
        """Option Explicit
Public Function CF_Find(ByVal key As String, Optional limit As Long = 10) As Boolean
    CF_Find = True
End Function
Private Sub CF_Reset()
End Sub
""",
        "Sample",
    )

    assert module.option_explicit is True
    assert len(module.procedures) == 2
    function = module.procedures[0]
    assert function.name == "CF_Find"
    assert function.kind == "Function"
    assert function.visibility == "Public"
    assert function.return_type == "Boolean"
    assert function.line == 2
    assert function.end_line == 4
    assert function.parameters[0].name == "key"
    assert function.parameters[0].passing == "ByVal"
    assert function.parameters[0].type_name == "String"
    assert function.parameters[1].optional is True
    assert function.parameters[1].default_value == "10"

    procedure = module.procedures[1]
    assert procedure.visibility == "Private"
    assert procedure.end_line == 6


def test_parses_module_constants_and_variables():
    module = parse_module(
        """Public Const CF_NAME As String = "CompareFramework"
Private cache() As String
Dim count As Long, enabled As Boolean
""",
        "Declarations",
    )

    assert [(item.name, item.type_name, item.value) for item in module.constants] == [
        ("CF_NAME", "String", '"CompareFramework"')
    ]
    assert [(item.name, item.type_name, item.is_array) for item in module.variables] == [
        ("cache", "String", True),
        ("count", "Long", False),
        ("enabled", "Boolean", False),
    ]


def test_parses_type_and_enum_blocks():
    module = parse_module(
        """Public Type CF_Item
    Name As String
    Values() As Double
End Type
Private Enum CF_State
    CF_None = 0
    CF_Ready
End Enum
""",
        "Structures",
    )

    assert module.types[0].name == "CF_Item"
    assert module.types[0].end_line == 4
    assert [(member.name, member.type_name, member.is_array) for member in module.types[0].members] == [
        ("Name", "String", False),
        ("Values", "Double", True),
    ]
    assert module.enums[0].visibility == "Private"
    assert [(member.name, member.value) for member in module.enums[0].members] == [
        ("CF_None", "0"),
        ("CF_Ready", None),
    ]


def test_repository_corpus_has_expected_procedure_inventory():
    root = Path(__file__).resolve().parents[1]
    modules = [parse_module_file(path, root / "src") for path in sorted((root / "src").rglob("*.bas"))]

    procedures = [procedure for module in modules for procedure in module.procedures]
    assert len(modules) == 20
    assert len(procedures) == 285
    assert sum(procedure.visibility == "Public" for procedure in procedures) == 204
    assert sum(procedure.visibility == "Private" for procedure in procedures) == 81
    assert not [warning for module in modules for warning in module.parse_warnings]
