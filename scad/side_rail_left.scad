// ============================================================
// side_rail_left.scad  –  Left side rail
// Open-frame rack – modular screw-together assembly
// ============================================================
include <config.scad>

side_rail_left();

module side_rail_left() {
    _side_rail(mirror_flag=false);
}

// ── Internal ──────────────────────────────────────────────────
module _side_rail(mirror_flag=false) {
    sc = mirror_flag ? [-1,1,1] : [1,1,1];
    scale(sc) _side_rail_body();
}

module _side_rail_body() {
    // Rail outer envelope: RAIL_W × RAIL_D × RAIL_H
    // Large trapezoidal cutouts for max airflow
    // M3 insert pockets on inner face for crossbar attachment
    // Tray-slide channel on inner face

    difference() {
        // ── Solid body ──────────────────────────────────────
        rr3d(RAIL_W, RAIL_D, RAIL_H, r=2);

        // ── Main airflow cutouts (side face, XZ plane) ──────
        _rail_airflow_cutouts();

        // ── Tray-slide channel (inner face, inset from +X) ──
        _tray_slide_channel();

        // ── Crossbar M3 insert pockets (inner face) ─────────
        _crossbar_insert_pockets();

        // ── Foot M3 insert pockets (bottom face) ────────────
        _foot_insert_pockets();

        // ── Top cap M3 insert pockets ───────────────────────
        _top_insert_pockets();
    }
}

// ── Airflow cutouts on the outer side face (Y = 0 plane) ─────
module _rail_airflow_cutouts() {
    slot_h  = 40;
    slot_w  = SLOT_W;
    pitch   = 12;
    rows    = floor((RAIL_D - 30) / pitch);
    start_y = 15;
    z_lo    = 20;
    z_hi    = RAIL_H - 20;
    col_z   = floor((z_hi - z_lo) / 14);

    for (col = [0 : col_z]) {
        z_c = z_lo + col * 14 + 7;
        for (row = [0 : rows - 1]) {
            y_c = start_y + row * pitch + pitch/2;
            translate([-1, y_c, z_c])
                rotate([0, 90, 0])
                    linear_extrude(RAIL_W + 2)
                        vent_slot(slot_w, slot_h);
        }
    }
}

// ── Tray-slide T-channel on inner face (+X side) ─────────────
// The channel runs the full depth (Y-axis) so trays slide in
// from the front.  The T profile lets a 8 mm tongue lock under
// the lip.
module _tray_slide_channel() {
    ch_x   = RAIL_W - WALL - TRAY_RAIL_W - SLOP;
    ch_w   = TRAY_RAIL_W + 2*SLOP;
    ch_d   = RAIL_D + 2;        // full depth, slightly proud
    lip_w  = 2.5;               // T-slot lip
    lip_h  = 2.0;

    // Slot body (rectangular, runs full depth)
    translate([ch_x, -1, WALL])
        cube([ch_w + lip_w, ch_d, RAIL_H]);  // overcut – lips remain

    // Under-cut lips (make T shape)
    for (sign = [-1, 1]) {
        translate([ch_x + (sign < 0 ? -lip_w : ch_w), -1, WALL])
            cube([lip_w + 0.01, ch_d, lip_h]);
    }
}

// ── M3 insert pockets on inner face at crossbar heights ──────
// Crossbars sit at regular vertical pitch; 4 per rail per side
module _crossbar_insert_pockets() {
    heights = _crossbar_z_positions();
    x_inner = RAIL_W;       // inner face
    y_positions = [RAIL_D*0.25, RAIL_D*0.75];

    for (z = heights) {
        for (y = y_positions) {
            translate([x_inner, y, z])
                rotate([0, -90, 0])
                    m3_insert_pocket();
        }
    }
}

// ── M3 insert pockets on bottom face for feet ────────────────
module _foot_insert_pockets() {
    offsets = [
        [RAIL_W*0.5, RAIL_D*0.2],
        [RAIL_W*0.5, RAIL_D*0.8],
    ];
    for (o = offsets) {
        translate([o[0], o[1], 0])
            rotate([180, 0, 0])
                translate([0, 0, -(M3_INSERT_H + 1)])
                    m3_insert_pocket();
    }
}

// ── M3 insert pockets on top face ────────────────────────────
module _top_insert_pockets() {
    offsets = [
        [RAIL_W*0.5, RAIL_D*0.2],
        [RAIL_W*0.5, RAIL_D*0.8],
    ];
    for (o = offsets) {
        translate([o[0], o[1], RAIL_H])
            m3_insert_pocket();
    }
}

// ── Shared crossbar Z positions ───────────────────────────────
function _crossbar_z_positions() =
    let(
        n     = 6,
        z_lo  = 30,
        z_hi  = RAIL_H - 30,
        pitch = (z_hi - z_lo) / (n - 1)
    )
    [ for (i = [0 : n-1]) z_lo + i * pitch ];
