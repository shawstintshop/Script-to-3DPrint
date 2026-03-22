#!/usr/bin/env python3
"""validate_dims.py – Dimension-validation script for the mini-server rack.

Checks that every device fits inside the rack's inner envelope, that tray
outer widths are ≤ INNER_W, and that the Pi 5 mounting-hole grid falls within
the board outline.

Reads all required values directly from ``scad/config.scad`` by scanning for
lines of the form:

    VARNAME = <value>;     // optional comment

Usage::

    python3 scripts/validate_dims.py

Exit code 0 = all checks pass.
Exit code 1 = one or more checks failed.

No third-party dependencies required.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path
from typing import Any

# ── Repository layout ─────────────────────────────────────────────────────────
REPO_ROOT   = Path(__file__).resolve().parent.parent
CONFIG_FILE = REPO_ROOT / "scad" / "config.scad"

# ── Parse config.scad ─────────────────────────────────────────────────────────
_ASSIGN_RE = re.compile(
    r"(?:^|(?<=;))\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*([^;/][^;]*?)\s*;",
    re.MULTILINE,
)

def _parse_config(path: Path) -> dict[str, Any]:
    """Return a dict of {name: value} by evaluating simple assignments."""
    text = path.read_text(encoding="utf-8")
    env: dict[str, Any] = {}
    for m in _ASSIGN_RE.finditer(text):
        name, expr = m.group(1), m.group(2).strip()
        # Remove inline comments
        expr = expr.split("//")[0].strip()
        try:
            # Safe-eval: allow previously defined names
            env[name] = eval(expr, {"__builtins__": {}}, env)  # noqa: S307
        except Exception:
            pass  # skip expressions we cannot evaluate (e.g. $fn)
    return env


# ── Validation rules ──────────────────────────────────────────────────────────

def run_checks(c: dict[str, Any]) -> list[str]:
    """Return a list of failure messages (empty = all pass)."""
    failures: list[str] = []

    def check(label: str, condition: bool, detail: str = "") -> None:
        mark = "PASS" if condition else "FAIL"
        msg = f"  [{mark}]  {label}"
        if detail:
            msg += f"  ({detail})"
        print(msg)
        if not condition:
            failures.append(label)

    rack_w  = c["RACK_W"]
    rack_d  = c["RACK_D"]
    rack_h  = c["RACK_H"]
    rail_w  = c["RAIL_W"]
    inner_w = c["INNER_W"]
    wall    = c["WALL"]
    floor_  = c["FLOOR"]
    clr     = c["CLEARANCE"]

    print("\n── Rack envelope ────────────────────────────────────────────────")
    check("RACK_W <= 350 (Bambu H2D bed width)",  rack_w  <= 350,
          f"{rack_w} mm")
    check("RACK_D <= 320 (Bambu H2D bed depth)",  rack_d  <= 320,
          f"{rack_d} mm")
    check("INNER_W == RACK_W - 2*RAIL_W",
          abs(inner_w - (rack_w - 2 * rail_w)) < 0.01,
          f"{inner_w} vs expected {rack_w - 2*rail_w}")

    print("\n── Side rail printability (longest dim ≤ bed) ───────────────────")
    check("RAIL_H <= 350 (fits on H2D bed)",       c["RAIL_H"] <= 350,
          f"{c['RAIL_H']} mm")
    check("RAIL_D <= 320 (fits on H2D bed)",       c["RAIL_D"] <= 320,
          f"{c['RAIL_D']} mm")

    print("\n── Device fit inside inner envelope ─────────────────────────────")
    devices = [
        ("Mac mini M2",           c["MM2_W"], c["MM2_D"], c["MM2_H"]),
        ("Mac mini M4",           c["MM4_W"], c["MM4_D"], c["MM4_H"]),
        ("Raspberry Pi 5",        c["PI5_W"], c["PI5_D"], c["PI5_H"]),
        ("Apple TV 4K 3rd gen",   c["ATV_W"], c["ATV_D"], c["ATV_H"]),
        ("Inseego FX4100",        c["FX_W"],  c["FX_D"],  c["FX_H"]),
    ]
    for name, dw, dd, dh in devices:
        check(f"{name}: width ({dw}) + 2×CLEARANCE ≤ INNER_W ({inner_w})",
              dw + 2 * clr <= inner_w,
              f"{dw + 2*clr:.2f} vs {inner_w}")
        check(f"{name}: depth ({dd}) + 2×CLEARANCE + 2×WALL ≤ RACK_D ({rack_d})",
              dd + 2 * clr + 2 * wall <= rack_d,
              f"{dd + 2*clr + 2*wall:.2f} vs {rack_d}")
        check(f"{name}: height ({dh}) + FLOOR ≤ RACK_H ({rack_h})",
              dh + floor_ <= rack_h,
              f"{dh + floor_:.2f} vs {rack_h}")

    print("\n── Pi 5 mounting-hole grid ──────────────────────────────────────")
    for hx in [c["PI5_HOLE_X1"], c["PI5_HOLE_X2"]]:
        for hy in [c["PI5_HOLE_Y1"], c["PI5_HOLE_Y2"]]:
            check(f"Pi hole ({hx}, {hy}) within board ({c['PI5_W']}×{c['PI5_D']})",
                  0 <= hx <= c["PI5_W"] and 0 <= hy <= c["PI5_D"])

    print("\n── Fastener geometry ────────────────────────────────────────────")
    check("M3_INSERT_D < RAIL_W (insert fits in rail)",
          c["M3_INSERT_D"] < rail_w,
          f"{c['M3_INSERT_D']} < {rail_w}")
    check("M3_INSERT_H < RAIL_W (pocket depth fits in rail)",
          c["M3_INSERT_H"] < rail_w,
          f"{c['M3_INSERT_H']} < {rail_w}")
    check("WALL >= 2.4 (≥ 2 perimeters at 1.2 mm line width)",
          wall >= 2.4,
          f"{wall} mm")
    check("FLOOR >= 2.0 (≥ 2 layers at 0.2 mm layer height)",
          floor_ >= 2.0,
          f"{floor_} mm")

    return failures


def main() -> None:
    if not CONFIG_FILE.exists():
        print(f"ERROR: config file not found: {CONFIG_FILE}", file=sys.stderr)
        sys.exit(1)

    print(f"Parsing: {CONFIG_FILE}")
    config = _parse_config(CONFIG_FILE)

    failures = run_checks(config)

    print()
    if failures:
        print(f"RESULT: {len(failures)} check(s) FAILED:")
        for f in failures:
            print(f"  • {f}")
        sys.exit(1)
    else:
        print("RESULT: All checks PASSED.")
        sys.exit(0)


if __name__ == "__main__":
    main()
