// ============================================================
// feet.scad  –  Anti-vibration rubber-pad feet
// Printed in two parts:
//   1. foot_base  – PETG/PLA structural cup
//   2. foot_pad   – TPU vibration-absorbing insert (optional)
// M3 heat-set insert in top face mates with rail bottom insert.
// ============================================================
include <config.scad>

foot_base();
translate([FOOT_OD * 1.5, 0, 0]) foot_pad();

module foot_base() {
    difference() {
        union() {
            // Outer cup body
            cylinder(d=FOOT_OD, h=FOOT_H, $fn=$fn_fine);
            // Flange at base for stability
            cylinder(d=FOOT_OD + 4, h=2, $fn=$fn_fine);
        }

        // Rubber-pad seat (recessed from bottom)
        translate([0, 0, -1])
            cylinder(d=FOOT_RUBBER_OD, h=FOOT_RUBBER_H + 1, $fn=$fn_fine);

        // M3 insert pocket at top face (for rail attachment)
        translate([0, 0, FOOT_H - M3_INSERT_H - 0.5])
            m3_insert_pocket();

        // Weight-saving cross cut in side wall
        for (angle = [0, 90]) {
            rotate([0, 0, angle])
                translate([-2, -(FOOT_OD + 2)/2, FOOT_RUBBER_H + 2])
                    cube([4, FOOT_OD + 2, FOOT_H - FOOT_RUBBER_H - WALL - 2]);
        }
    }
}

// ── TPU pad insert ────────────────────────────────────────────
module foot_pad() {
    difference() {
        cylinder(d=FOOT_RUBBER_OD - FIT*2, h=FOOT_RUBBER_H - FIT, $fn=$fn_fine);
        // Central through-hole for M3 screw (passes through pad to insert)
        cylinder(d=M3_SCREW_D, h=FOOT_RUBBER_H + 1, $fn=$fn_fine);
    }
}
