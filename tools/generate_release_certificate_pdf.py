#!/usr/bin/env python3
"""Generate the CompareFramework release certificate PDF from Markdown.

Usage:
    python3 tools/generate_release_certificate_pdf.py
    python3 tools/generate_release_certificate_pdf.py \
        --source docs/RELEASE_CERTIFICATE.md \
        --output dist/RELEASE_CERTIFICATE_3.8.0-RC1.pdf
"""

from __future__ import annotations

import argparse
import html
import re
from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import (
    PageBreak,
    Paragraph,
    SimpleDocTemplate,
    Spacer,
    Table,
    TableStyle,
)


def project_root() -> Path:
    return Path(__file__).resolve().parents[1]


def read_version(root: Path) -> str:
    version_file = root / "VERSION"
    if version_file.exists():
        value = version_file.read_text(encoding="utf-8").strip()
        if value:
            return value
    return "3.8.0-RC1"


def register_font() -> str:
    candidates = [
        Path("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"),
        Path("/usr/share/fonts/truetype/liberation2/LiberationSans-Regular.ttf"),
    ]
    for candidate in candidates:
        if candidate.exists():
            pdfmetrics.registerFont(TTFont("CertificateSans", str(candidate)))
            return "CertificateSans"
    return "Helvetica"


def inline_markup(text: str) -> str:
    text = html.escape(text, quote=False)
    text = re.sub(r"`([^`]+)`", r"<font name='Courier'>\1</font>", text)
    text = re.sub(r"\*\*([^*]+)\*\*", r"<b>\1</b>", text)
    return text


def parse_table(lines: list[str], start: int) -> tuple[list[list[str]], int]:
    rows: list[list[str]] = []
    index = start
    while index < len(lines) and lines[index].lstrip().startswith("|"):
        cells = [cell.strip() for cell in lines[index].strip().strip("|").split("|")]
        if not all(re.fullmatch(r":?-{3,}:?", cell or "") for cell in cells):
            rows.append(cells)
        index += 1
    return rows, index


def build_story(markdown_text: str, font_name: str) -> list:
    styles = getSampleStyleSheet()
    styles.add(ParagraphStyle(
        name="CertificateTitle",
        parent=styles["Title"],
        fontName=font_name,
        fontSize=19,
        leading=23,
        alignment=TA_CENTER,
        spaceAfter=8 * mm,
    ))
    for name in ("Heading1", "Heading2", "BodyText"):
        styles[name].fontName = font_name
    styles["Heading1"].fontSize = 14
    styles["Heading1"].leading = 18
    styles["Heading1"].spaceBefore = 5 * mm
    styles["Heading1"].spaceAfter = 2 * mm
    styles["Heading2"].fontSize = 12
    styles["BodyText"].fontSize = 9.5
    styles["BodyText"].leading = 13
    bullet_style = ParagraphStyle(
        name="CertificateBullet",
        parent=styles["BodyText"],
        leftIndent=6 * mm,
        firstLineIndent=-3 * mm,
        spaceAfter=1.2 * mm,
    )

    story: list = []
    lines = markdown_text.splitlines()
    paragraph_buffer: list[str] = []

    def flush_paragraph() -> None:
        if paragraph_buffer:
            text = " ".join(item.strip() for item in paragraph_buffer).strip()
            if text:
                story.append(Paragraph(inline_markup(text), styles["BodyText"]))
                story.append(Spacer(1, 1.5 * mm))
            paragraph_buffer.clear()

    index = 0
    while index < len(lines):
        line = lines[index].rstrip()
        stripped = line.strip()

        if not stripped:
            flush_paragraph()
            index += 1
            continue

        if stripped.startswith("|"):
            flush_paragraph()
            rows, index = parse_table(lines, index)
            if rows:
                table_data = [[Paragraph(inline_markup(cell), styles["BodyText"]) for cell in row] for row in rows]
                table = Table(table_data, repeatRows=1, hAlign="LEFT")
                table.setStyle(TableStyle([
                    ("FONTNAME", (0, 0), (-1, -1), font_name),
                    ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#E8E8E8")),
                    ("GRID", (0, 0), (-1, -1), 0.35, colors.HexColor("#777777")),
                    ("VALIGN", (0, 0), (-1, -1), "TOP"),
                    ("LEFTPADDING", (0, 0), (-1, -1), 5),
                    ("RIGHTPADDING", (0, 0), (-1, -1), 5),
                    ("TOPPADDING", (0, 0), (-1, -1), 4),
                    ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
                ]))
                story.append(table)
                story.append(Spacer(1, 2 * mm))
            continue

        if stripped.startswith("# "):
            flush_paragraph()
            story.append(Paragraph(inline_markup(stripped[2:]), styles["CertificateTitle"]))
        elif stripped.startswith("## "):
            flush_paragraph()
            story.append(Paragraph(inline_markup(stripped[3:]), styles["Heading1"]))
        elif stripped.startswith("### "):
            flush_paragraph()
            story.append(Paragraph(inline_markup(stripped[4:]), styles["Heading2"]))
        elif stripped.startswith("- "):
            flush_paragraph()
            story.append(Paragraph("- " + inline_markup(stripped[2:]), bullet_style))
        elif stripped == "---":
            flush_paragraph()
            story.append(Spacer(1, 2 * mm))
        else:
            paragraph_buffer.append(stripped.replace("  ", " "))
        index += 1

    flush_paragraph()
    return story


def page_decorator(canvas, doc) -> None:
    canvas.saveState()
    canvas.setFont("Helvetica", 8)
    canvas.setFillColor(colors.HexColor("#666666"))
    canvas.drawString(18 * mm, 12 * mm, "CompareFramework - Release Certificate")
    canvas.drawRightString(A4[0] - 18 * mm, 12 * mm, f"Page {doc.page}")
    canvas.restoreState()


def main() -> int:
    root = project_root()
    version = read_version(root)

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, default=root / "docs" / "RELEASE_CERTIFICATE.md")
    parser.add_argument(
        "--output",
        type=Path,
        default=root / "dist" / f"RELEASE_CERTIFICATE_{version}.pdf",
    )
    args = parser.parse_args()

    if not args.source.exists():
        parser.error(f"Markdown source not found: {args.source}")

    args.output.parent.mkdir(parents=True, exist_ok=True)
    markdown_text = args.source.read_text(encoding="utf-8")
    font_name = register_font()

    document = SimpleDocTemplate(
        str(args.output),
        pagesize=A4,
        rightMargin=18 * mm,
        leftMargin=18 * mm,
        topMargin=18 * mm,
        bottomMargin=20 * mm,
        title=f"CompareFramework {version} - Release Certificate",
        author="CompareFramework",
    )
    document.build(
        build_story(markdown_text, font_name),
        onFirstPage=page_decorator,
        onLaterPages=page_decorator,
    )
    print(args.output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
