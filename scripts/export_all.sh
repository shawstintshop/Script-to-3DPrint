#!/usr/bin/env bash
# ============================================================
# export_all.sh  –  Export every SCAD file to STL via OpenSCAD
# Usage: bash scripts/export_all.sh [output_dir]
#
# Requires openscad (CLI) in PATH.
# On macOS:  brew install openscad  or download from openscad.org
# On Linux:  apt install openscad   or snap install openscad
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SCAD_DIR="${REPO_ROOT}/scad"
OUT_DIR="${1:-${REPO_ROOT}/stl}"

# Verify openscad is available
if ! command -v openscad &>/dev/null; then
    echo "ERROR: openscad not found in PATH." >&2
    echo "  macOS:  brew install openscad" >&2
    echo "  Linux:  sudo apt install openscad" >&2
    exit 1
fi

mkdir -p "${OUT_DIR}"

# ── Files to export and their module entry points ─────────────
# Format: "scad_file:stl_basename"
FILES=(
    "side_rail_left.scad:side_rail_left"
    "side_rail_right.scad:side_rail_right"
    "crossbar.scad:crossbar"
    "tray_macmini_m2.scad:tray_macmini_m2"
    "tray_macmini_m4.scad:tray_macmini_m4"
    "plate_pi5.scad:plate_pi5"
    "tray_appletv.scad:tray_appletv"
    "cradle_fx4100.scad:cradle_fx4100"
    "clamp_bar.scad:clamp_bar"
    "feet.scad:foot_base"
)

# Separate export for foot_pad (second module in feet.scad)
FEET_EXTRA="feet.scad:foot_pad"

echo "=== Exporting STL files to: ${OUT_DIR} ==="
ERRORS=0

export_stl() {
    local scad_file="$1"
    local stl_name="$2"
    local extra_args="${3:-}"
    local src="${SCAD_DIR}/${scad_file}"
    local dst="${OUT_DIR}/${stl_name}.stl"

    if [[ ! -f "${src}" ]]; then
        echo "  SKIP  ${scad_file} (not found)"
        return
    fi

    echo -n "  Exporting ${stl_name}.stl ... "
    # shellcheck disable=SC2086
    if openscad \
        --export-format binstl \
        ${extra_args} \
        -o "${dst}" \
        "${src}" \
        2>/tmp/openscad_err.log; then
        echo "OK"
    else
        echo "FAILED"
        cat /tmp/openscad_err.log >&2
        ERRORS=$(( ERRORS + 1 ))
    fi
}

for entry in "${FILES[@]}"; do
    scad="${entry%%:*}"
    name="${entry##*:}"
    export_stl "${scad}" "${name}"
done

# ── foot_pad: override the top-level call so only the pad is exported
# We do this by wrapping with -D to suppress foot_base() and translate()
# In practice both modules are exported from feet.scad; we use a thin
# wrapper approach via a temporary override file.
FEET_TMP="$(mktemp /tmp/foot_pad_XXXXXX.scad)"
# Write the temp file with absolute paths directly (avoids sed -i portability issues)
cat > "${FEET_TMP}" <<SCAD_EOF
include <${SCAD_DIR}/config.scad>
use <${SCAD_DIR}/feet.scad>
foot_pad();
SCAD_EOF

echo -n "  Exporting foot_pad.stl ... "
if openscad \
    --export-format binstl \
    -o "${OUT_DIR}/foot_pad.stl" \
    "${FEET_TMP}" \
    2>/tmp/openscad_err.log; then
    echo "OK"
else
    echo "FAILED"
    cat /tmp/openscad_err.log >&2
    ERRORS=$(( ERRORS + 1 ))
fi
rm -f "${FEET_TMP}"

echo ""
if [[ ${ERRORS} -eq 0 ]]; then
    echo "All STL files exported successfully to ${OUT_DIR}"
    ls -lh "${OUT_DIR}"/*.stl
else
    echo "WARNING: ${ERRORS} export(s) failed." >&2
    exit 1
fi
