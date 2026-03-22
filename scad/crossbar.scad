// ============================================================
// crossbar.scad  –  Horizontal crossbar
// Spans between left and right side rails.
// Vent slots for maximum airflow.
// Two M3 clearance holes each end for screwing into rail inserts.
// ============================================================
include <config.scad>

crossbar();

module crossbar() {
    w = CB_W;   // clear span
    h = CB_H;
    d = CB_D;

    difference() {
        // ── Body ────────────────────────────────────────────
        rr3d(w, d, h, r=2);

        // ── Vent slots (runs along width) ───────────────────
        _cb_vent_slots(w, d, h);

        // ── End screw holes (each end, 2 holes per end) ─────
        _cb_end_holes(w, d, h);
    }

    // ── End bosses (raised pads around screw holes) ─────────
    // Printed integrally; add extra wall material at ends.
    _cb_end_bosses(w, d, h);
}

// ── Vent slots ───────────────────────────────────────────────
module _cb_vent_slots(w, d, h) {
    sw    = CB_SLOT_W;
    gap   = CB_SLOT_GAP;
    pitch = sw + gap;
    n     = floor((w - 2*WALL*4) / pitch);
    margin = (w - n*pitch + gap) / 2;

    for (i = [0 : n-1]) {
        x = margin + i*pitch + sw/2;
        translate([x, d/2, -1])
            linear_extrude(h + 2)
                vent_slot(sw, d - 2*WALL);
    }
}

// ── End clearance holes (2 per end, through the short side) ──
module _cb_end_holes(w, d, h) {
    y_pos = [d * 0.3, d * 0.7];
    for (sign = [0, 1]) {
        x = sign == 0 ? -1 : w + 1;
        for (y = y_pos) {
            translate([x, y, h/2])
                rotate([0, 90, 0])
                    cylinder(d=M3_SCREW_D, h=RAIL_W + 2, $fn=$fn_fine);
        }
    }
}

// ── End bosses (solid pads at ends to provide screw purchase) ─
module _cb_end_bosses(w, d, h) {
    boss_l = 8;
    for (sign = [0, 1]) {
        x = sign == 0 ? 0 : w - boss_l;
        translate([x, 0, 0])
            difference() {
                cube([boss_l, d, h]);
                // hollow interior of boss to save material
                translate([sign==0 ? 2 : 0, WALL, WALL])
                    cube([boss_l - WALL, d - 2*WALL, h - 2*WALL]);
            }
    }
}
