// ============================================================
// plate_pi5.scad  –  Mounting plate for Raspberry Pi 5
// Board: 85 × 56 mm, 4× M2.5 mounting holes
// Features:
//   - M2.5 brass-insert standoffs matching Pi 5 hole pattern
//   - Optional 40 mm fan mount bracket at one end
//   - Vent holes for airflow under board
//   - Side tongues for rack-rail slide
//   - Cable relief notch at rear
// ============================================================
include <config.scad>

SHOW_FAN_BRACKET = true;   // set false to omit fan bracket

plate_pi5();

module plate_pi5() {
    // Plate is slightly larger than the board on all sides
    margin = 5;
    pw = PI5_W + 2*margin;   // plate width
    pd = PI5_D + 2*margin;   // plate depth
    ph = FLOOR;              // plate thickness

    // Fan-bracket adds depth at +Y if enabled
    fan_extra_d = SHOW_FAN_BRACKET ? FAN40_W + WALL*2 + 4 : 0;
    pd_total = pd + fan_extra_d;

    difference() {
        union() {
            // ── Plate body ───────────────────────────────────
            rr3d(pw, pd_total, ph, r=2);

            // ── Standoffs ────────────────────────────────────
            _pi5_standoffs(margin, ph);

            // ── Side tongues ─────────────────────────────────
            _pi5_side_tongues(pw, pd_total, ph);

            // ── Fan bracket ──────────────────────────────────
            if (SHOW_FAN_BRACKET)
                translate([0, pd, 0])
                    _pi5_fan_bracket(pw, fan_extra_d, ph);
        }

        // ── Vent holes under board ───────────────────────────
        _pi5_vent_holes(margin, pw, pd);

        // ── Cable-relief notch (rear of board area) ──────────
        translate([pw/2 - CABLE_NOTCH_W/2, pd - WALL - 1, 0])
            cube([CABLE_NOTCH_W, WALL + 2, ph + 1]);

        // ── Lock holes through tongues ───────────────────────
        _pi5_lock_holes(pw, pd_total, ph);
    }
}

// ── Standoffs (M2.5 scale, reuse M3 helpers with 2.5 dia) ────
// Pi 5 mounting holes: [3.5,3.5], [3.5,52.5], [61.5,3.5], [61.5,52.5]
module _pi5_standoffs(margin, ph) {
    for (mh = PI5_MH) {
        translate([mh[0] + margin, mh[1] + margin, ph]) {
            difference() {
                cylinder(d=SO_OD, h=SO_H, $fn=$fn_fine);
                cylinder(d=2.7, h=SO_H + 1, $fn=$fn_fine);  // M2.5 medium-clearance (ISO 273 "medium") for easier assembly
            }
        }
    }
}

// ── Vent holes through the plate floor ───────────────────────
module _pi5_vent_holes(margin, pw, pd) {
    hole_d = 4;
    pitch  = 8;
    cols   = floor((PI5_W - 6) / pitch);
    rows   = floor((PI5_D - 6) / pitch);
    ox     = margin + 3 + pitch/2;
    oy     = margin + 3 + pitch/2;

    for (c = [0 : cols-1]) {
        for (r = [0 : rows-1]) {
            translate([ox + c*pitch, oy + r*pitch, -1])
                cylinder(d=hole_d, h=FLOOR + 2, $fn=$fn_coarse);
        }
    }
}

// ── Side tongues for rail slide ───────────────────────────────
module _pi5_side_tongues(pw, pd, ph) {
    tongue_h = TRAY_RAIL_W;
    for (sign = [-1, 1]) {
        x = sign < 0 ? -tongue_h : pw;
        translate([x, WALL*2, 0])
            cube([tongue_h, pd - 4*WALL, ph]);
    }
}

// ── Tongue lock holes ─────────────────────────────────────────
module _pi5_lock_holes(pw, pd, ph) {
    for (sign = [-1, 1]) {
        x = sign < 0 ? -1 : pw + 1;
        translate([x, pd/2, ph/2])
            rotate([0, 90, 0])
                cylinder(d=M3_SCREW_D, h=TRAY_RAIL_W + WALL + 2, $fn=$fn_fine);
    }
}

// ── 40 mm fan mount bracket ───────────────────────────────────
// Bracket: vertical wall with 4× M3 fan-mount holes (32 mm circle)
// Sits at the +Y end of the plate.
module _pi5_fan_bracket(pw, fan_extra_d, ph) {
    bracket_w = pw;
    bracket_h = FAN40_W + WALL*2;  // tall enough to clear fan
    wall_t    = WALL;

    difference() {
        // bracket wall
        cube([bracket_w, wall_t, bracket_h]);

        // fan aperture (square with rounded corners, centred)
        translate([bracket_w/2, -1, bracket_h/2])
            rotate([-90, 0, 0])
                linear_extrude(wall_t + 2)
                    rr2d(FAN40_W - 2, FAN40_W - 2, 3);

        // 4× M3 fan-mount holes on 32 mm circle
        for (angle = [45, 135, 225, 315]) {
            translate([
                bracket_w/2 + FAN40_BOLT_C/2 * cos(angle),
                -1,
                bracket_h/2  + FAN40_BOLT_C/2 * sin(angle)
            ])
                rotate([-90, 0, 0])
                    cylinder(d=FAN40_SCREW_D, h=wall_t + 2, $fn=$fn_fine);
        }
    }

    // Gussets connecting bracket wall to plate floor
    for (sign = [-1, 1]) {
        x = sign < 0 ? WALL*2 : bracket_w - WALL*2 - WALL;
        translate([x, 0, 0])
            linear_extrude(WALL)
                polygon([[0,0],[WALL,0],[0, bracket_h*0.4]]);
    }
}
