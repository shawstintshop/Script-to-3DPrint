// ============================================================
// tray_macmini_m4.scad  –  Tray for Mac mini M4
// Device: 127 × 127 × 50 mm
// Features: vent slots, front retention lip, cable relief,
//           side tongues for rail slides, M3 insert pockets.
// ============================================================
include <config.scad>

tray_macmini_m4();

module tray_macmini_m4() {
    dw = MM4_W + 2*FIT;
    dd = MM4_D + 2*FIT;
    dh = MM4_H;

    tw = dw + 2*WALL;
    td = dd + 2*WALL;
    th = FLOOR + dh + WALL;

    difference() {
        union() {
            rr3d(tw, td, th, r=2);
            _m4_front_lip(tw, td, th);
            _m4_side_tongues(tw, td, th);
        }

        // Device pocket
        translate([WALL, WALL, FLOOR])
            cube([dw, dd, th]);

        // Floor vent slots
        _m4_floor_vents(tw, td);

        // Side vent slots
        _m4_side_vents(tw, td, th);

        // Cable relief notches (rear)
        _m4_cable_relief(tw, td, th);

        // Front lip open span
        translate([WALL + CABLE_NOTCH_W, -1, FLOOR + dh - TRAY_LIP_H])
            cube([tw - 2*WALL - 2*CABLE_NOTCH_W, TRAY_LIP_D + 2, TRAY_LIP_H + 1]);

        // Tongue lock holes
        _m4_lock_holes(tw, td, th);
    }

    _m4_mount_inserts(tw, td);
}

module _m4_front_lip(tw, td, th) {
    translate([WALL, 0, th - TRAY_LIP_H])
        cube([tw - 2*WALL, TRAY_LIP_D, TRAY_LIP_H]);
}

module _m4_side_tongues(tw, td, th) {
    tongue_h = TRAY_RAIL_W;
    for (sign = [-1, 1]) {
        x = sign < 0 ? -tongue_h : tw;
        translate([x, WALL*2, WALL])
            cube([tongue_h, td - 4*WALL, FLOOR]);
    }
}

module _m4_floor_vents(tw, td) {
    sw    = SLOT_W;
    sh    = td * 0.6;
    pitch = SLOT_PITCH;
    n     = floor((tw - 2*WALL*3) / pitch);
    ox    = (tw - n*pitch) / 2 + pitch/2;
    for (i = [0 : n-1]) {
        translate([ox + i*pitch, td/2, -1])
            linear_extrude(FLOOR + 2)
                vent_slot(sw, sh);
    }
}

module _m4_side_vents(tw, td, th) {
    sw    = SLOT_W;
    sh    = th * 0.5;
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

module _m4_cable_relief(tw, td, th) {
    for (sign = [-1, 1]) {
        cx = tw/2 + sign * (CABLE_NOTCH_W + 5);
        translate([cx - CABLE_NOTCH_W/2, td - WALL - 1, FLOOR])
            cube([CABLE_NOTCH_W, WALL + 2, CABLE_NOTCH_H]);
    }
}

module _m4_lock_holes(tw, td, th) {
    for (sign = [-1, 1]) {
        x = sign < 0 ? -1 : tw + 1;
        translate([x, td/2, FLOOR/2])
            rotate([0, 90, 0])
                cylinder(d=M3_SCREW_D, h=TRAY_RAIL_W + WALL + 2, $fn=$fn_fine);
    }
}

module _m4_mount_inserts(tw, td) {
    positions = [
        [tw*0.25, td*0.25],
        [tw*0.75, td*0.25],
        [tw*0.25, td*0.75],
        [tw*0.75, td*0.75],
    ];
    for (p = positions) {
        translate([p[0], p[1], 0])
            rotate([180, 0, 0])
                translate([0, 0, -(M3_INSERT_H + 0.5)])
                    m3_insert_pocket();
    }
}
