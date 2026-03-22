// ============================================================
// tray_macmini_m2.scad  –  Tray for Mac mini M2
// Device: 196.85 × 196.85 × 35.8 mm
// Features: vent slots, front retention lip, cable relief,
//           side tongues for rail slides, M3 insert pockets.
// ============================================================
include <config.scad>

tray_macmini_m2();

module tray_macmini_m2() {
    dw = MM2_W + 2*FIT;   // device width  + fit
    dd = MM2_D + 2*FIT;   // device depth  + fit
    dh = MM2_H;           // device height (used for wall calc)

    tw = dw + 2*WALL;          // tray outer width
    td = dd + 2*WALL;          // tray outer depth
    th = FLOOR + dh + WALL;    // tray total height (floor + device + top lip)

    difference() {
        union() {
            // ── Tray body ────────────────────────────────────
            rr3d(tw, td, th, r=2);

            // ── Front retention lip ──────────────────────────
            _tray_front_lip(tw, td, th);

            // ── Side rail tongues ────────────────────────────
            _tray_side_tongues(tw, td, th);
        }

        // ── Device pocket ────────────────────────────────────
        translate([WALL, WALL, FLOOR])
            cube([dw, dd, th]);    // open top

        // ── Floor vent slots ─────────────────────────────────
        _tray_floor_vents(tw, td);

        // ── Side vent slots ───────────────────────────────────
        _tray_side_vents(tw, td, th);

        // ── Cable relief notches (rear) ───────────────────────
        _tray_cable_relief(tw, td, th);

        // ── Front lip clearance ───────────────────────────────
        translate([WALL + CABLE_NOTCH_W, -1, FLOOR + dh - TRAY_LIP_H])
            cube([tw - 2*WALL - 2*CABLE_NOTCH_W, TRAY_LIP_D + 2, TRAY_LIP_H + 1]);

        // ── Rail-tongue through-holes (M3 to lock tray) ──────
        _tray_lock_holes(tw, td, th);
    }

    // ── M3 insert pockets (underside of floor) ────────────────
    _tray_mount_inserts(tw, td);
}

// ── Front retention lip ──────────────────────────────────────
module _tray_front_lip(tw, td, th) {
    translate([WALL, 0, th - TRAY_LIP_H])
        cube([tw - 2*WALL, TRAY_LIP_D, TRAY_LIP_H]);
}

// ── Side tongues that engage the T-slot in the rail ──────────
module _tray_side_tongues(tw, td, th) {
    tongue_h = TRAY_RAIL_W;
    for (sign = [-1, 1]) {
        x = sign < 0 ? -tongue_h : tw;
        translate([x, WALL*2, WALL])
            cube([tongue_h, td - 4*WALL, FLOOR]);
    }
}

// ── Vent slots through floor ──────────────────────────────────
module _tray_floor_vents(tw, td) {
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

// ── Vent slots in side walls ──────────────────────────────────
module _tray_side_vents(tw, td, th) {
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

// ── Cable-relief notches at rear of tray ─────────────────────
module _tray_cable_relief(tw, td, th) {
    // Two notches either side of centre at the back wall
    for (sign = [-1, 1]) {
        cx = tw/2 + sign * (CABLE_NOTCH_W + 5);
        translate([cx - CABLE_NOTCH_W/2, td - WALL - 1, FLOOR])
            cube([CABLE_NOTCH_W, WALL + 2, CABLE_NOTCH_H]);
    }
}

// ── M3 screw holes to lock tray to rail after sliding ────────
module _tray_lock_holes(tw, td, th) {
    for (sign = [-1, 1]) {
        x = sign < 0 ? -1 : tw + 1;
        translate([x, td/2, FLOOR/2])
            rotate([0, 90, 0])
                cylinder(d=M3_SCREW_D, h=TRAY_RAIL_W + WALL + 2, $fn=$fn_fine);
    }
}

// ── M3 insert pockets underneath (for sub-mounting) ──────────
module _tray_mount_inserts(tw, td) {
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
