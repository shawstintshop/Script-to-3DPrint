// ─────────────────────────────────────────────────────────────────────────────
//  side_rail_left.scad  –  Left side rail with M3 heat-set insert pockets
//
//  Origin: outer-left-front-bottom corner of the rack (X=0, Y=0, Z=0).
//  The rail body occupies [0…RAIL_W] × [0…RAIL_D] × [0…RAIL_H].
//
//  Inner face (+X) carries heat-set insert pockets arranged in a grid so
//  crossbars and device trays can be bolted at any height.
// ─────────────────────────────────────────────────────────────────────────────
include <config.scad>

// ── Shared sub-modules ────────────────────────────────────────────────────────

// Heat-set insert pocket (opens toward +Z of local coordinate system).
// Caller translates / rotates into the correct face orientation.
module _insert_pocket() {
    cylinder(d = M3_INSERT_D + 0.15, h = M3_INSERT_H + 0.5);
}

// M3 clearance hole (through-hole, opens toward +Z locally).
module _m3_clear(depth) {
    cylinder(d = M3_CLEAR_D, h = depth + 0.2);
}

// ── Main module ───────────────────────────────────────────────────────────────
module side_rail_left() {
    difference() {

        // ── Solid body ───────────────────────────────────────────────────────
        cube([RAIL_W, RAIL_D, RAIL_H]);

        // ── Weight-relief pocket (open on top) ───────────────────────────────
        // Leaves WALL thickness on all faces except the open top.
        translate([WALL, WALL, WALL])
            cube([RAIL_W - 2*WALL,
                  RAIL_D - 2*WALL,
                  RAIL_H - WALL + 0.1]);

        // ── Inner-face (+X) heat-set insert grid ────────────────────────────
        //    Two columns in Y at CBAR_MOUNT_Y1 and CBAR_MOUNT_Y2 so a crossbar
        //    placed at the front of the rack (Y = 0…CBAR_D) can be secured.
        //    Same Y columns also serve front-positioned trays.
        //    Additional columns at the rear mirror positions for rear crossbars.
        for (z = [SLOT_PITCH : SLOT_PITCH : RAIL_H - SLOT_PITCH/2]) {
            for (y = [CBAR_MOUNT_Y1,
                      CBAR_MOUNT_Y2,
                      RAIL_D - CBAR_MOUNT_Y2,
                      RAIL_D - CBAR_MOUNT_Y1]) {
                // Pocket enters from the +X face, opening inward toward −X
                translate([RAIL_W + 0.1, y, z])
                    rotate([0, -90, 0])
                        _insert_pocket();
            }
        }

        // ── Front-face (−Y) heat-set inserts ────────────────────────────────
        //    For optional front-panel attachment.
        for (z = [SLOT_PITCH : SLOT_PITCH : RAIL_H - SLOT_PITCH/2]) {
            translate([RAIL_W / 2, -0.1, z])
                rotate([-90, 0, 0])
                    _insert_pocket();
        }

        // ── Bottom M3 clearance holes for foot-screw attachment ──────────────
        for (y = [RAIL_D * 0.25, RAIL_D * 0.75]) {
            translate([RAIL_W / 2, y, -0.1])
                _m3_clear(WALL);
        }
    }
}

side_rail_left();
