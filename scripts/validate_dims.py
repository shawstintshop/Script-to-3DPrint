#!/usr/bin/env python3
"""
validate_dims.py  –  Dimension validation for the modular open-frame
                     desktop mini-server rack.

Parses scad/config.scad and verifies that:
  1. Every device fits inside the rack envelope with clearance.
  2. Tray outer dimensions don't exceed the rack clear width.
  3. Key constants are self-consistent (e.g. insert OD < wall thickness*2).
  4. The rack envelope matches the spec (250 × 260 × 285 mm).

Exits 0 on success, non-zero if any check fails.

Usage:
    python3 scripts/validate_dims.py
    python3 scripts/validate_dims.py --verbose
"""

import argparse
import re
import sys
from pathlib import Path
from typing import Dict, List, Tuple

# ── Paths ─────────────────────────────────────────────────────
SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT  = SCRIPT_DIR.parent
CONFIG     = REPO_ROOT / "scad" / "config.scad"

# ── Parse all numeric assignments from config.scad ────────────
def parse_params(src: str) -> Dict[str, float]:
    """Return {name: value} for all `NAME = number;` lines."""
    params: Dict[str, float] = {}
    pattern = re.compile(r"^\s*([A-Z_][A-Z0-9_]*)\s*=\s*([\d.]+)\s*;", re.MULTILINE)
    for m in pattern.finditer(src):
        params[m.group(1)] = float(m.group(2))
    return params


# ── Individual checks ─────────────────────────────────────────
Check = Tuple[str, bool, str]   # (description, passed, detail)

def check_rack_envelope(p: Dict[str, float]) -> List[Check]:
    results = []
    specs = [("RACK_W", 250), ("RACK_D", 260), ("RACK_H", 285)]
    for key, expected in specs:
        val = p.get(key)
        ok  = val == expected
        results.append((
            f"Rack envelope {key} == {expected} mm",
            ok,
            f"got {val}" if not ok else f"{val} mm ✓"
        ))
    return results


def check_device_fits_in_rack(p: Dict[str, float]) -> List[Check]:
    """Each device W and D must fit inside RACK_W / RACK_D with rail clearance."""
    results = []
    wall    = p.get("WALL", 3)
    rail_w  = p.get("RAIL_W", 18)
    clear_w = p.get("RACK_W", 250) - 2 * rail_w
    clear_d = p.get("RACK_D", 260)
    clear_h = p.get("RACK_H", 285)

    devices = {
        "Mac mini M2": (p.get("MM2_W", 0), p.get("MM2_D", 0), p.get("MM2_H", 0)),
        "Mac mini M4": (p.get("MM4_W", 0), p.get("MM4_D", 0), p.get("MM4_H", 0)),
        "Apple TV 4K": (p.get("ATV_W", 0), p.get("ATV_D", 0), p.get("ATV_H", 0)),
        # Pi 5 board is 85 × 56 – well within envelope
        "Raspberry Pi 5": (p.get("PI5_W", 0), p.get("PI5_D", 0), 20),
        # FX4100 stands vertically: footprint 104×52, height 167
        "Inseego FX4100 (vertical)": (p.get("FX_D", 0), p.get("FX_H", 0), p.get("FX_W", 0)),
    }

    for name, (dw, dd, dh) in devices.items():
        tray_w = dw + 2 * wall
        tray_d = dd + 2 * wall
        ok_w   = tray_w <= clear_w
        ok_d   = tray_d <= clear_d
        ok_h   = dh <= clear_h
        results.append((
            f"{name} tray width ({tray_w:.1f}) ≤ clear width ({clear_w:.1f})",
            ok_w,
            "✓" if ok_w else f"FAIL: tray_w={tray_w:.1f} > clear_w={clear_w:.1f}"
        ))
        results.append((
            f"{name} tray depth ({tray_d:.1f}) ≤ rack depth ({clear_d:.1f})",
            ok_d,
            "✓" if ok_d else f"FAIL: tray_d={tray_d:.1f} > clear_d={clear_d:.1f}"
        ))
        results.append((
            f"{name} device height ({dh:.1f}) ≤ rack height ({clear_h:.1f})",
            ok_h,
            "✓" if ok_h else f"FAIL: dh={dh:.1f} > clear_h={clear_h:.1f}"
        ))
    return results


def check_insert_vs_wall(p: Dict[str, float]) -> List[Check]:
    results = []
    insert_od = p.get("M3_INSERT_OD", 4.4)
    wall      = p.get("WALL", 3.0)
    # Insert pocket needs at least wall material on each side
    min_wall  = insert_od / 2 + 1.0   # 1 mm min surround
    ok = wall >= min_wall
    results.append((
        f"WALL ({wall}) ≥ M3_INSERT_OD/2 + 1 mm ({min_wall:.1f})",
        ok,
        "✓" if ok else f"FAIL: wall too thin for insert pocket"
    ))
    return results


def check_slot_pitch(p: Dict[str, float]) -> List[Check]:
    results = []
    sw    = p.get("SLOT_W", 4.0)
    pitch = p.get("SLOT_PITCH", 7.0)
    ok = pitch > sw
    results.append((
        f"SLOT_PITCH ({pitch}) > SLOT_W ({sw})  [rib between slots > 0]",
        ok,
        "✓" if ok else "FAIL: slots overlap"
    ))
    return results


def check_fan_bolt_circle(p: Dict[str, float]) -> List[Check]:
    results = []
    frame = p.get("FAN40_W", 40)
    circle= p.get("FAN40_BOLT_C", 32)
    ok = circle < frame
    results.append((
        f"FAN40_BOLT_C ({circle}) < FAN40_W ({frame})",
        ok,
        "✓" if ok else "FAIL: bolt circle outside fan frame"
    ))
    return results


def check_strap_slot(p: Dict[str, float]) -> List[Check]:
    results = []
    sw = p.get("STRAP_W", 20)
    slot_w = p.get("STRAP_SLOT_W", 21)
    ok = slot_w > sw
    results.append((
        f"STRAP_SLOT_W ({slot_w}) > STRAP_W ({sw})  [strap has clearance]",
        ok,
        "✓" if ok else "FAIL: strap slot too narrow"
    ))
    return results


# ── Runner ────────────────────────────────────────────────────
def run_checks(params: Dict[str, float], verbose: bool) -> int:
    all_checks: List[Check] = []
    all_checks += check_rack_envelope(params)
    all_checks += check_device_fits_in_rack(params)
    all_checks += check_insert_vs_wall(params)
    all_checks += check_slot_pitch(params)
    all_checks += check_fan_bolt_circle(params)
    all_checks += check_strap_slot(params)

    passed = sum(1 for _, ok, _ in all_checks if ok)
    failed = sum(1 for _, ok, _ in all_checks if not ok)

    print(f"Rack dimension validation — {len(all_checks)} checks")
    print("=" * 60)
    for desc, ok, detail in all_checks:
        status = "PASS" if ok else "FAIL"
        if verbose or not ok:
            print(f"  [{status}] {desc}")
            if detail and detail != "✓":
                print(f"          {detail}")

    print("=" * 60)
    print(f"  {passed} passed  |  {failed} failed")

    return 0 if failed == 0 else 1


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate rack dimensions")
    parser.add_argument("--verbose", "-v", action="store_true",
                        help="Show all checks (not just failures)")
    args = parser.parse_args()

    if not CONFIG.exists():
        print(f"ERROR: config.scad not found at {CONFIG}", file=sys.stderr)
        return 2

    src    = CONFIG.read_text()
    params = parse_params(src)

    if not params:
        print("ERROR: No parameters parsed from config.scad", file=sys.stderr)
        return 2

    if args.verbose:
        print(f"Parsed {len(params)} parameters from {CONFIG.relative_to(REPO_ROOT)}\n")

    return run_checks(params, args.verbose)


if __name__ == "__main__":
    sys.exit(main())
