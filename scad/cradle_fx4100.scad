// ============================================================
// cradle_fx4100.scad  –  Vertical cradle for Inseego FX4100
// Device: 167 × 104 × 52 mm (stands on its 104×52 end)
// Requirements:
//   - Vertical orientation (device stands upright, tall axis = Z)
//   - Open sides (two faces fully open) for max airflow
//   - Strap retention: two hook-and-loop strap loops
//   - Front retention lip to prevent forward slip
//   - Cable relief at base
//   - Side tongues for rack-rail slide
// ============================================================
include <config.scad>

cradle_fx4100();

module cradle_fx4100() {
    // When vertical the FX4100 footprint is 104 × 52 mm (W × D)
    // and its height is 167 mm.
    dev_w = FX_D + 2*FIT;   // 104 mm becomes the X dimension
    dev_d = FX_H + 2*FIT;   // 52 mm becomes the Y dimension
    dev_h = FX_W;            // 167 mm – device stands this tall

    cw = dev_w + 2*WALL;
    cd = dev_d + 2*WALL;
    // Cradle body only: base plate + front/back walls + floor.
    // Left & right sides are OPEN (open-sided spec).
    ch_body = FLOOR + 20;    // short cradle body – device sits in it

    difference() {
        union() {
            // ── Base plate (floor) ───────────────────────────
            rr3d(cw, cd, FLOOR, r=2);

            // ── Front wall (Y=0 face, retention) ────────────
            translate([0, 0, 0])
                cube([cw, WALL, ch_body]);

            // ── Back wall (Y=cd face) ────────────────────────
            translate([0, cd - WALL, 0])
                cube([cw, WALL, ch_body]);

            // ── Strap loop bosses ────────────────────────────
            _fx_strap_bosses(cw, cd, ch_body);

            // ── Side tongues for rail slide ──────────────────
            _fx_side_tongues(cw, cd);
        }

        // ── Device pocket (open top & sides) ─────────────────
        translate([WALL, WALL, FLOOR])
            cube([dev_w, dev_d, ch_body + 1]);

        // ── Cable relief notch at base front wall ─────────────
        translate([cw/2 - CABLE_NOTCH_W/2, -1, FLOOR])
            cube([CABLE_NOTCH_W, WALL + 2, CABLE_NOTCH_H]);

        // ── Cable relief notch at base back wall ──────────────
        translate([cw/2 - CABLE_NOTCH_W/2, cd - WALL - 1, FLOOR])
            cube([CABLE_NOTCH_W, WALL + 2, CABLE_NOTCH_H]);

        // ── Vent holes in base floor ──────────────────────────
        _fx_floor_vents(cw, cd);

        // ── Lock holes for side tongues ───────────────────────
        _fx_lock_holes(cw, cd);
    }
}

// ── Strap loop bosses ─────────────────────────────────────────
// Two bosses on the front wall with through-slots for 20 mm strap.
// One at mid-height (~10 mm from top of cradle body) and one
// near the floor.
module _fx_strap_bosses(cw, cd, ch) {
    heights = [ch * 0.25, ch * 0.75];
    boss_d  = STRAP_SLOT_H + 2*WALL;
    boss_w  = STRAP_SLOT_W + 2*WALL;
    boss_h  = WALL + boss_d;

    for (z = heights) {
        // Front boss
        difference() {
            translate([(cw - boss_w)/2, -boss_d + WALL, z - boss_h/2])
                cube([boss_w, boss_d, boss_h]);
            // Strap slot (horizontal, through boss)
            translate([(cw - STRAP_SLOT_W)/2, -(boss_d) + WALL - 1, z - STRAP_SLOT_H/2])
                cube([STRAP_SLOT_W, boss_d + 2, STRAP_SLOT_H]);
        }
        // Back boss
        difference() {
            translate([(cw - boss_w)/2, cd - WALL, z - boss_h/2])
                cube([boss_w, boss_d, boss_h]);
            translate([(cw - STRAP_SLOT_W)/2, cd - WALL - 1, z - STRAP_SLOT_H/2])
                cube([STRAP_SLOT_W, boss_d + 2, STRAP_SLOT_H]);
        }
    }
}

// ── Floor vent holes ─────────────────────────────────────────
module _fx_floor_vents(cw, cd) {
    hole_d = 5;
    pitch  = 9;
    cols   = floor((cw - 2*WALL*2) / pitch);
    rows   = floor((cd - 2*WALL*2) / pitch);
    ox     = WALL*2 + pitch/2;
    oy     = WALL*2 + pitch/2;
    for (c = [0 : cols-1]) {
        for (r = [0 : rows-1]) {
            translate([ox + c*pitch, oy + r*pitch, -1])
                cylinder(d=hole_d, h=FLOOR + 2, $fn=$fn_coarse);
        }
    }
}

// ── Side tongues ─────────────────────────────────────────────
module _fx_side_tongues(cw, cd) {
    tongue_h = TRAY_RAIL_W;
    for (sign = [-1, 1]) {
        x = sign < 0 ? -tongue_h : cw;
        translate([x, WALL*2, 0])
            cube([tongue_h, cd - 4*WALL, FLOOR]);
    }
}

// ── Lock holes ────────────────────────────────────────────────
module _fx_lock_holes(cw, cd) {
    for (sign = [-1, 1]) {
        x = sign < 0 ? -1 : cw + 1;
        translate([x, cd/2, FLOOR/2])
            rotate([0, 90, 0])
                cylinder(d=M3_SCREW_D, h=TRAY_RAIL_W + WALL + 2, $fn=$fn_fine);
    }
}
