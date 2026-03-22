#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  export_all.sh  –  CLI export of all rack STLs via OpenSCAD
#
#  Usage:
#    ./scripts/export_all.sh [--outdir <dir>] [--openscad <path>]
#
#  Requirements:
#    openscad (>= 2021.01) must be on PATH or supplied via --openscad.
#    Run from the repository root:  bash scripts/export_all.sh
#
#  Output:
#    One .stl per .scad source file, written to <outdir> (default: stl/).
#    Skips _tray_base.scad (helper module, not a stand-alone part).
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

# ── Defaults ─────────────────────────────────────────────────────────────────
OUTDIR="stl"
OPENSCAD="${OPENSCAD_BIN:-openscad}"

# ── Argument parsing ──────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
    case "$1" in
        --outdir)   OUTDIR="$2";   shift 2 ;;
        --openscad) OPENSCAD="$2"; shift 2 ;;
        *) echo "Unknown argument: $1" >&2; exit 1 ;;
    esac
done

# ── Sanity checks ─────────────────────────────────────────────────────────────
if ! command -v "$OPENSCAD" &>/dev/null; then
    echo "ERROR: OpenSCAD not found at '${OPENSCAD}'." >&2
    echo "       Install it or pass --openscad /path/to/openscad" >&2
    exit 1
fi

SCAD_DIR="$(cd "$(dirname "$0")/../scad" && pwd)"
mkdir -p "$OUTDIR"

echo "OpenSCAD : $("$OPENSCAD" --version 2>&1 | head -1)"
echo "SCAD dir : ${SCAD_DIR}"
echo "Output   : ${OUTDIR}"
echo ""

# ── Export loop ───────────────────────────────────────────────────────────────
PASS=0
FAIL=0
SKIP=0

for scad_file in "${SCAD_DIR}"/*.scad; do
    basename_noext="$(basename "${scad_file}" .scad)"

    # Skip helper / include-only files (prefix underscore)
    if [[ "${basename_noext}" == _* ]]; then
        echo "  SKIP  ${basename_noext}.scad  (helper module)"
        (( SKIP++ )) || true
        continue
    fi

    stl_file="${OUTDIR}/${basename_noext}.stl"

    printf "  %-35s -> %s\n" "${basename_noext}.scad" "${stl_file}"

    if "$OPENSCAD" \
            --hardwarnings \
            -o "${stl_file}" \
            "${scad_file}" 2>&1 | sed 's/^/         /'; then
        (( PASS++ )) || true
    else
        echo "  FAILED: ${basename_noext}.scad" >&2
        (( FAIL++ )) || true
    fi
done

echo ""
echo "Done  –  ${PASS} exported, ${FAIL} failed, ${SKIP} skipped."

[[ $FAIL -eq 0 ]]   # exit non-zero if any export failed
