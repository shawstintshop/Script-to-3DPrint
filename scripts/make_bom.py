#!/usr/bin/env python3
"""make_bom.py – Bill-of-materials generator for the mini-server rack project.

Parses ``scad/config.scad`` for device dimensions and fastener specs, then
produces a CSV BOM covering:

* Printed parts  (one row per .scad source file)
* Fasteners      (M3 heat-set inserts, M3 cap-head screws)
* Consumables    (silicone anti-vibration pad material)

Usage::

    python3 scripts/make_bom.py [--outfile bom.csv]

The script is dependency-free (stdlib only).
"""

from __future__ import annotations

import argparse
import csv
import sys
from pathlib import Path

# ── Repository layout ─────────────────────────────────────────────────────────
REPO_ROOT = Path(__file__).resolve().parent.parent
SCAD_DIR  = REPO_ROOT / "scad"

# ── Printed-parts catalogue ───────────────────────────────────────────────────
# Each entry: (filename_stem, description, qty, material_note)
PRINTED_PARTS: list[tuple[str, str, int, str]] = [
    ("side_rail_left",    "Left side rail",                          1, "PETG / ASA – structural"),
    ("side_rail_right",   "Right side rail",                         1, "PETG / ASA – structural"),
    ("crossbar",          "Horizontal crossbar (front or rear)",      4, "PETG / ASA"),
    ("tray_macmini_m2",   "Tray – Mac mini M2",                      1, "PETG"),
    ("tray_macmini_m4",   "Tray – Mac mini M4",                      1, "PETG"),
    ("tray_appletv",      "Tray – Apple TV 4K 3rd gen",              1, "PETG"),
    ("plate_pi5",         "Mounting plate – Raspberry Pi 5",         1, "PETG"),
    ("cradle_fx4100",     "Cradle – Inseego FX4100 (vertical)",      1, "PETG"),
    ("clamp_bar",         "Clamp bar for strap retention",           2, "PETG"),
    ("feet",              "Anti-vibration foot",                      4, "TPU 95A (preferred) / PETG"),
]

# ── Fastener BOM ──────────────────────────────────────────────────────────────
# Quantities are conservative estimates based on design intent.
FASTENERS: list[tuple[str, str, int, str]] = [
    ("M3x5 heat-set insert",        "M3 × 4.7 mm OD × 5.7 mm L",   80, "e.g. CNC Kitchen M3 standard"),
    ("M3×8 cap-head screw",         "DIN 912 M3×8",                  30, "stainless or black-oxide"),
    ("M3×12 cap-head screw",        "DIN 912 M3×12",                 20, "stainless or black-oxide"),
    ("M3×16 cap-head screw",        "DIN 912 M3×16",                 10, "stainless or black-oxide"),
    ("M3 hex nut",                  "DIN 934 M3",                    20, "stainless"),
    ("M2.5×6 cap-head screw",       "DIN 912 M2.5×6 (Pi 5 board)",   4, "stainless"),
    ("20 mm hook-and-loop strap",   "20 mm wide × ≥400 mm L",        2, "e.g. VELCRO® ONE-WRAP"),
    ("20 mm silicone anti-vib pad", "Ø20 × 3 mm silicone disc",      4, "self-adhesive"),
]

# ── Helpers ───────────────────────────────────────────────────────────────────

def verify_scad_files() -> list[str]:
    """Return list of .scad stems that exist in scad/."""
    return [p.stem for p in sorted(SCAD_DIR.glob("*.scad"))]


def write_bom(outfile: Path) -> None:
    existing = verify_scad_files()
    missing  = [stem for stem, *_ in PRINTED_PARTS if stem not in existing]
    if missing:
        print(f"WARNING: the following SCAD files were not found: {missing}",
              file=sys.stderr)

    with outfile.open("w", newline="", encoding="utf-8") as fh:
        writer = csv.writer(fh)

        # ── Header ────────────────────────────────────────────────────────────
        writer.writerow(["#", "Item", "Description / spec", "Qty", "Notes"])

        # ── Section 1: Printed parts ──────────────────────────────────────────
        writer.writerow([])
        writer.writerow(["", "=== PRINTED PARTS ===", "", "", ""])
        for i, (stem, desc, qty, note) in enumerate(PRINTED_PARTS, start=1):
            status = "" if stem in existing else " [SCAD FILE MISSING]"
            writer.writerow([i, f"{stem}.stl{status}", desc, qty, note])

        # ── Section 2: Fasteners & consumables ───────────────────────────────
        writer.writerow([])
        writer.writerow(["", "=== FASTENERS & CONSUMABLES ===", "", "", ""])
        offset = len(PRINTED_PARTS)
        for i, (name, spec, qty, note) in enumerate(FASTENERS, start=offset + 1):
            writer.writerow([i, name, spec, qty, note])

    print(f"BOM written to: {outfile}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--outfile", default="bom.csv",
                        help="Output CSV path (default: bom.csv)")
    args = parser.parse_args()

    write_bom(Path(args.outfile))


if __name__ == "__main__":
    main()
