// ─────────────────────────────────────────────────────────────────────────────
//  plate_pi5.scad  –  Mounting plate for Raspberry Pi 5
//
//  Board envelope : 85 × 56 mm  (W × D)
//  Plate outer width : INNER_W = 210 mm  (slides between side rails)
//
//  Features
//    • FLOOR-thick carrier plate
//    • 4 × M2.5 standoff posts at official Pi hole positions
//    • Optional 40 mm fan bracket at the rear of the plate
//    • M3 clearance holes in flanges for rail attachment
// ─────────────────────────────────────────────────────────────────────────────
include <config.scad>

// ── 40 mm fan mount parameters ────────────────────────────────────────────────
FAN40_SIDE   = 40;     // fan frame side length
FAN40_HOLE_S = 32;     // mounting hole pitch (32 × 32 mm)
FAN40_HOLE_D = 3.4;    // M3 clearance hole Ø
FAN40_FRAME_H = 10;    // height of the bracket walls that accept fan screws

// ── Board-plate geometry ──────────────────────────────────────────────────────
_plate_w    = INNER_W;                      // 210 mm
_board_ox   = (_plate_w - PI5_W) / 2;      // X offset to board origin
_board_oy   = WALL;                         // Y offset to board origin (gap at front)
_plate_d    = PI5_D + 2 * WALL + FAN40_SIDE + WALL;  // board + gap + fan bracket
_flange_gap = _board_ox;                    // space outside board → flange

module _standoff(h, od, hole_d) {
    difference() {
        cylinder(d = od, h = h);
        translate([0, 0, -0.1])
            cylinder(d = hole_d, h = h + 0.2);
    }
}

module _fan40_bracket(ox, oy) {
    // Square frame sized for 40 × 40 mm fan with four M3 screw bosses
    translate([ox, oy, 0]) {
        difference() {
            union() {
                // Four corner boss pillars
                boss_offset = (FAN40_SIDE - FAN40_HOLE_S) / 2;
                for (bx = [boss_offset, FAN40_SIDE - boss_offset]) {
                    for (by = [boss_offset, FAN40_SIDE - boss_offset]) {
                        translate([bx, by, FLOOR])
                            cylinder(d = 8, h = FAN40_FRAME_H);
                    }
                }
                // Thin floor for fan recess
                cube([FAN40_SIDE, FAN40_SIDE, FLOOR]);
            }
            // Central fan opening
            margin = (FAN40_SIDE - 36) / 2;
            translate([margin, margin, -0.1])
                cube([36, 36, FLOOR + FAN40_FRAME_H + 0.2]);
            // Boss screw holes
            boss_offset = (FAN40_SIDE - FAN40_HOLE_S) / 2;
            for (bx = [boss_offset, FAN40_SIDE - boss_offset]) {
                for (by = [boss_offset, FAN40_SIDE - boss_offset]) {
                    translate([bx, by, -0.1])
                        cylinder(d = FAN40_HOLE_D, h = FLOOR + FAN40_FRAME_H + 0.2);
                }
            }
        }
    }
}

module plate_pi5() {
    difference() {
        union() {
            // ── Carrier plate ─────────────────────────────────────────────────
            cube([_plate_w, _plate_d, FLOOR]);

            // ── Pi 5 standoffs ────────────────────────────────────────────────
            for (hx = [PI5_HOLE_X1, PI5_HOLE_X2]) {
                for (hy = [PI5_HOLE_Y1, PI5_HOLE_Y2]) {
                    translate([_board_ox + hx, _board_oy + hy, FLOOR])
                        _standoff(PI5_STANDOFF_H, PI5_STANDOFF_OD, PI5_HOLE_D);
                }
            }

            // ── 40 mm fan bracket at rear of board ────────────────────────────
            fan_ox = (_plate_w - FAN40_SIDE) / 2;
            fan_oy = _board_oy + PI5_D + WALL;
            _fan40_bracket(fan_ox, fan_oy);
        }

        // ── M3 clearance holes in left flange ────────────────────────────────
        for (fy = [_plate_d * 0.3, _plate_d * 0.7]) {
            translate([_flange_gap / 2, fy, -0.1])
                cylinder(d = M3_CLEAR_D, h = FLOOR + 0.2);
        }

        // ── M3 clearance holes in right flange ───────────────────────────────
        for (fy = [_plate_d * 0.3, _plate_d * 0.7]) {
            translate([_plate_w - _flange_gap / 2, fy, -0.1])
                cylinder(d = M3_CLEAR_D, h = FLOOR + 0.2);
        }
    }
}

plate_pi5();
