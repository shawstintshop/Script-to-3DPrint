// ─────────────────────────────────────────────────────────────────────────────
//  crossbar.scad  –  Horizontal crossbar with vent slots
//
//  Spans the full rack width (CBAR_W = RACK_W = 250 mm).
//  Each end overlaps the respective side rail (RAIL_W = 20 mm) and carries
//  two M3 clearance holes that align with the inner-face insert grid in the
//  side rails.
//
//  Vent slots run front-to-back (Y direction) through the inner span,
//  maximising airflow while preserving the end flanges.
// ─────────────────────────────────────────────────────────────────────────────
include <config.scad>

module crossbar() {
    difference() {
        // ── Solid body ───────────────────────────────────────────────────────
        cube([CBAR_W, CBAR_D, CBAR_H]);

        // ── Vent slots (run in Y, spaced along X through the inner span) ─────
        for (x = [RAIL_W + VENT_PITCH
                  : VENT_PITCH
                  : RACK_W - RAIL_W - VENT_PITCH / 2]) {
            translate([x - VENT_W / 2, -0.1, FLOOR])
                cube([VENT_W, CBAR_D + 0.2, CBAR_H - FLOOR + 0.1]);
        }

        // ── Left-rail M3 clearance holes (left end flange) ───────────────────
        for (y = [CBAR_MOUNT_Y1, CBAR_MOUNT_Y2]) {
            translate([-0.1, y, CBAR_H / 2])
                rotate([0, 90, 0])
                    cylinder(d = M3_CLEAR_D, h = RAIL_W + 0.2);
        }

        // ── Right-rail M3 clearance holes (right end flange) ─────────────────
        for (y = [CBAR_MOUNT_Y1, CBAR_MOUNT_Y2]) {
            translate([RACK_W - RAIL_W - 0.1, y, CBAR_H / 2])
                rotate([0, 90, 0])
                    cylinder(d = M3_CLEAR_D, h = RAIL_W + 0.2);
        }
    }
}

crossbar();
