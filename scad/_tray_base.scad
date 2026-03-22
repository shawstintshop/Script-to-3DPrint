// ─────────────────────────────────────────────────────────────────────────────
//  _tray_base.scad  –  Shared parametric tray module
//
//  Included (not used) by device-specific tray files so the module definition
//  is available along with config.scad variables.
//
//  Tray outer width always equals INNER_W (210 mm) so the part slides cleanly
//  between the two side rails.  The device is centred in the pocket.
//
//  All trays feature:
//    • FLOOR-thick vented floor
//    • WALL-thick side, front and rear walls
//    • Front retention lip (LIP_H above device top)
//    • Rear cable-relief slots
//    • Two M3 clearance holes per side flange for rail attachment
// ─────────────────────────────────────────────────────────────────────────────
include <config.scad>

// ─────────────────────────────────────────────────────────────────────────────
//  device_tray(dev_w, dev_d, dev_h)
//
//  dev_w  – device width  (X) mm
//  dev_d  – device depth  (Y) mm
//  dev_h  – device height (Z) mm
// ─────────────────────────────────────────────────────────────────────────────
module device_tray(dev_w, dev_d, dev_h) {

    // ── Derived geometry ──────────────────────────────────────────────────────
    pocket_w = dev_w + 2 * CLEARANCE;      // inner pocket width
    pocket_d = dev_d + 2 * CLEARANCE;      // inner pocket depth

    outer_w  = INNER_W;                    // always 210 mm → fits between rails
    outer_d  = pocket_d + 2 * WALL;
    box_h    = dev_h + FLOOR;              // tray height (without lip)
    lip_top  = box_h + LIP_H;             // total height including front lip

    // X position where the device pocket starts
    pocket_x = (outer_w - pocket_w) / 2;
    pocket_y = WALL;

    // ── Vent slot grid (punched through floor) ────────────────────────────────
    // Slots run in X direction, spaced in Y across the floor pocket area.
    vent_nx = floor(pocket_w / VENT_PITCH) - 1;
    vent_ny = floor(pocket_d / (VENT_L + 3)) ;
    vent_ny = (vent_ny < 1) ? 1 : vent_ny;

    // ── Cable-relief slot count (rear wall) ───────────────────────────────────
    cable_n = max(1, floor(pocket_w / (CABLE_SLOT_W + 6)));

    difference() {
        union() {
            // Floor plate (full outer width × outer depth)
            cube([outer_w, outer_d, FLOOR]);

            // Left inner wall
            translate([pocket_x - WALL, 0, 0])
                cube([WALL, outer_d, box_h]);

            // Right inner wall
            translate([pocket_x + pocket_w, 0, 0])
                cube([WALL, outer_d, box_h]);

            // Front wall + retention lip (full height)
            translate([pocket_x - WALL, 0, 0])
                cube([pocket_w + 2 * WALL, WALL, lip_top]);

            // Rear wall (no lip)
            translate([pocket_x - WALL, outer_d - WALL, 0])
                cube([pocket_w + 2 * WALL, WALL, box_h]);
        }

        // ── Vent slots in floor ───────────────────────────────────────────────
        x_pitch = pocket_w / (vent_nx + 1);
        for (ix = [1 : vent_nx]) {
            sx = pocket_x + ix * x_pitch - VENT_W / 2;
            y_pitch = pocket_d / (vent_ny + 1);
            for (iy = [1 : vent_ny]) {
                sy = pocket_y + iy * y_pitch - VENT_L / 2;
                translate([sx, sy, -0.1])
                    cube([VENT_W, VENT_L, FLOOR + 0.2]);
            }
        }

        // ── Cable-relief slots in rear wall ───────────────────────────────────
        c_pitch = pocket_w / (cable_n + 1);
        for (ic = [1 : cable_n]) {
            cx = pocket_x + ic * c_pitch - CABLE_SLOT_W / 2;
            translate([cx, outer_d - WALL - 0.1, FLOOR])
                cube([CABLE_SLOT_W, WALL + 0.2, CABLE_SLOT_H]);
        }

        // ── M3 clearance holes in left flange for rail bolts ─────────────────
        for (fy = [outer_d * 0.3, outer_d * 0.7]) {
            translate([pocket_x / 2, fy, -0.1])
                cylinder(d = M3_CLEAR_D, h = FLOOR + 0.2);
        }

        // ── M3 clearance holes in right flange for rail bolts ────────────────
        for (fy = [outer_d * 0.3, outer_d * 0.7]) {
            translate([pocket_x + pocket_w + WALL + pocket_x / 2, fy, -0.1])
                cylinder(d = M3_CLEAR_D, h = FLOOR + 0.2);
        }
    }
}
