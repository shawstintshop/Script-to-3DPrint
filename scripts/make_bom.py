#!/usr/bin/env python3
"""
make_bom.py  –  Bill of Materials generator for the modular open-frame
                desktop mini-server rack.

Reads scad/config.scad for key parameters and emits a structured BOM
in both plain-text table form and CSV.

Usage:
    python3 scripts/make_bom.py [--csv] [--out <file>]

Options:
    --csv       Also write CSV to <file>.csv (default: bom.csv)
    --out FILE  Write plain-text table to FILE (default: stdout)
"""

import argparse
import csv
import os
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import List, Optional

# ── Locate repo root ──────────────────────────────────────────
SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT  = SCRIPT_DIR.parent
SCAD_DIR   = REPO_ROOT / "scad"
CONFIG     = SCAD_DIR / "config.scad"


# ── Data model ────────────────────────────────────────────────
@dataclass
class BOMLine:
    item: str
    qty: int
    material: str
    color: str
    notes: str
    part_no: str = ""


# ── Parse a numeric parameter from config.scad ────────────────
def parse_param(name: str, source: str) -> Optional[float]:
    pattern = rf"^\s*{re.escape(name)}\s*=\s*([\d.]+)\s*;"
    m = re.search(pattern, source, re.MULTILINE)
    return float(m.group(1)) if m else None


# ── Build BOM ─────────────────────────────────────────────────
def build_bom(config_src: str) -> List[BOMLine]:
    # ── 3-D Printed parts ─────────────────────────────────────
    printed_parts = [
        BOMLine("Side Rail Left",             1,  "PETG", "Black",  "Print flat; no supports needed",         "SRL-01"),
        BOMLine("Side Rail Right",            1,  "PETG", "Black",  "Mirror of left; print flat",             "SRR-01"),
        BOMLine("Crossbar",                   6,  "PETG", "Black",  "6× to fill vertical pitch slots",        "CB-01"),
        BOMLine("Tray – Mac mini M2",         1,  "PETG", "Black",  "Supports MM2; vent slots; cable notch",  "TR-MM2"),
        BOMLine("Tray – Mac mini M4",         1,  "PETG", "Black",  "Supports MM4; vent slots; cable notch",  "TR-MM4"),
        BOMLine("Plate – Raspberry Pi 5",     1,  "PETG", "Black",  "Standoffs + optional 40 mm fan bracket", "PL-PI5"),
        BOMLine("Tray – Apple TV 4K",         1,  "PETG", "Black",  "Supports ATV 93×93×31 mm",              "TR-ATV"),
        BOMLine("Cradle – Inseego FX4100",    1,  "PETG", "Black",  "Vertical; open sides; strap loops",      "CR-FX4"),
        BOMLine("Clamp Bar",                  4,  "PETG", "Black",  "Locks trays to rails",                   "CLB-01"),
        BOMLine("Foot Base",                  4,  "PETG", "Black",  "Print upside-down; M3 insert top",       "FT-BASE"),
        BOMLine("Foot Pad (TPU insert)",      4,  "TPU 95A", "Gray","Press-fit into foot base cup",           "FT-PAD"),
    ]

    # ── Hardware ───────────────────────────────────────────────
    hardware = [
        BOMLine("M3 × 8 mm Button-Head SHCS",   40, "Stainless", "—", "Crossbar & tray attachment",           "HW-M3x8"),
        BOMLine("M3 × 12 mm Button-Head SHCS",  16, "Stainless", "—", "Clamp bar & rail foot attachment",     "HW-M3x12"),
        BOMLine("M3 × 6 mm Button-Head SHCS",   16, "Stainless", "—", "Fan mount & Pi 5 standoff top",        "HW-M3x6"),
        BOMLine("M3 Heat-Set Insert (M3×5.7)",  72, "Brass",     "—", "All insert pockets in rails/trays",    "HW-INS-M3"),
        BOMLine("M2.5 × 6 mm Pan-Head Screw",    4, "Stainless", "—", "Pi 5 PCB to standoffs",                "HW-M25x6"),
        BOMLine("M2.5 Hex Nut",                  4, "Stainless", "—", "Captive in standoff top",              "HW-M25N"),
        BOMLine("20 mm Hook-and-Loop Strap",     2, "Nylon",     "—", "FX4100 cradle retention, 300 mm ea.",  "HW-STRAP"),
        BOMLine("40 mm × 40 mm × 10 mm Fan",    1, "—",         "—", "Optional – Pi 5 fan bracket",          "HW-FAN40"),
        BOMLine("Rubber Foot Pad (20 mm Ø)",     4, "Rubber",    "—", "Self-adhesive; fits foot-pad recess",  "HW-RPAD"),
    ]

    return printed_parts + hardware


# ── Format table ──────────────────────────────────────────────
def format_table(bom: List[BOMLine]) -> str:
    cols = ["Part No.", "Item", "Qty", "Material", "Color", "Notes"]
    rows = [(l.part_no, l.item, str(l.qty), l.material, l.color, l.notes) for l in bom]

    widths = [len(c) for c in cols]
    for row in rows:
        for i, cell in enumerate(row):
            widths[i] = max(widths[i], len(cell))

    def fmt_row(row):
        return "| " + " | ".join(cell.ljust(widths[i]) for i, cell in enumerate(row)) + " |"

    sep = "+-" + "-+-".join("-" * w for w in widths) + "-+"
    lines = [sep, fmt_row(cols), sep]
    for row in rows:
        lines.append(fmt_row(row))
    lines.append(sep)
    return "\n".join(lines)


# ── Write CSV ─────────────────────────────────────────────────
def write_csv(bom: List[BOMLine], path: Path) -> None:
    with open(path, "w", newline="") as fh:
        writer = csv.DictWriter(fh, fieldnames=["part_no","item","qty","material","color","notes"])
        writer.writeheader()
        for l in bom:
            writer.writerow({
                "part_no":   l.part_no,
                "item":      l.item,
                "qty":       l.qty,
                "material":  l.material,
                "color":     l.color,
                "notes":     l.notes,
            })
    print(f"CSV written to: {path}")


# ── Main ──────────────────────────────────────────────────────
def main() -> int:
    parser = argparse.ArgumentParser(description="Generate rack BOM")
    parser.add_argument("--csv",  action="store_true", help="Also write CSV output")
    parser.add_argument("--out",  metavar="FILE",      help="Write table to FILE instead of stdout")
    args = parser.parse_args()

    config_src = CONFIG.read_text() if CONFIG.exists() else ""
    bom   = build_bom(config_src)
    table = format_table(bom)

    header = (
        "Bill of Materials – Modular Open-Frame Desktop Mini-Server Rack\n"
        "================================================================\n"
        f"Generated from: {CONFIG.relative_to(REPO_ROOT)}\n\n"
    )
    output = header + table + "\n"

    if args.out:
        Path(args.out).write_text(output)
        print(f"BOM written to: {args.out}")
    else:
        print(output)

    if args.csv:
        csv_path = Path(args.out).with_suffix(".csv") if args.out else REPO_ROOT / "bom.csv"
        write_csv(bom, csv_path)

    return 0


if __name__ == "__main__":
    sys.exit(main())
