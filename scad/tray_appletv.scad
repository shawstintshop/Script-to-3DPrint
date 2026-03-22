// ============================================================
// tray_appletv.scad  –  Tray for Apple TV 4K 3rd generation
// Device: 93 × 93 × 31 mm (cylinder-puck shape approximated
//         as a square for the tray pocket)
// Features: vent slots, front retention lip, cable relief,
//           side tongues for rail slides.
// ============================================================
include <config.scad>

tray_appletv();

module tray_appletv() {
    dw = ATV_W + 2*FIT;
    dd = ATV_D + 2*FIT;
    dh = ATV_H;

    tw = dw + 2*WALL;
    td = dd + 2*WALL;
    th = FLOOR + dh + WALL;

    difference() {
        union() {
            rr3d(tw, td, th, r=2);
            _atv_front_lip(tw, td, th);
            _atv_side_tongues(tw, td, th);
        }

        // Device pocket
        translate([WALL, WALL, FLOOR])
            cube([dw, dd, th]);

        // Floor vent slots
        _atv_floor_vents(tw, td);

        // Side vent slots
        _atv_side_vents(tw, td, th);

        // Cable relief
        _atv_cable_relief(tw, td, th);

        // Front lip open span
        translate([WALL + 5, -1, FLOOR + dh - TRAY_LIP_H])
            cube([tw - 2*WALL - 10, TRAY_LIP_D + 2, TRAY_LIP_H + 1]);

        // Lock holes
        _atv_lock_holes(tw, td, th);
    }
}

module _atv_front_lip(tw, td, th) {
    translate([WALL, 0, th - TRAY_LIP_H])
        cube([tw - 2*WALL, TRAY_LIP_D, TRAY_LIP_H]);
}

module _atv_side_tongues(tw, td, th) {
    tongue_h = TRAY_RAIL_W;
    for (sign = [-1, 1]) {
        x = sign < 0 ? -tongue_h : tw;
        translate([x, WALL*2, WALL])
            cube([tongue_h, td - 4*WALL, FLOOR]);
    }
}

module _atv_floor_vents(tw, td) {
    sw    = SLOT_W;
    sh    = td * 0.55;
    pitch = SLOT_PITCH;
    n     = floor((tw - 2*WALL*3) / pitch);
    ox    = (tw - n*pitch) / 2 + pitch/2;
    for (i = [0 : n-1]) {
        translate([ox + i*pitch, td/2, -1])
            linear_extrude(FLOOR + 2)
                vent_slot(sw, sh);
    }
}

module _atv_side_vents(tw, td, th) {
    sw    = SLOT_W;
    sh    = th * 0.45;
    pitch = SLOT_PITCH;
    n     = floor((td - 2*WALL*3) / pitch);
    oy    = (td - n*pitch) / 2 + pitch/2;
    for (sign = [-1, 1]) {
        x = sign < 0 ? -1 : tw + 1;
        for (i = [0 : n-1]) {
            translate([x, oy + i*pitch, th/2])
                rotate([0, 90, 0])
                    linear_extrude(WALL + 2)
                        vent_slot(sw, sh);
        }
    }
}

module _atv_cable_relief(tw, td, th) {
    // Single centred notch at rear – Apple TV has one HDMI port
    translate([tw/2 - CABLE_NOTCH_W/2, td - WALL - 1, FLOOR])
        cube([CABLE_NOTCH_W, WALL + 2, CABLE_NOTCH_H]);
}

module _atv_lock_holes(tw, td, th) {
    for (sign = [-1, 1]) {
        x = sign < 0 ? -1 : tw + 1;
        translate([x, td/2, FLOOR/2])
            rotate([0, 90, 0])
                cylinder(d=M3_SCREW_D, h=TRAY_RAIL_W + WALL + 2, $fn=$fn_fine);
    }
}
