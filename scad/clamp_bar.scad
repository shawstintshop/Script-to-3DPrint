// ============================================================
// clamp_bar.scad  –  Clamp / retention bar
// A flat bar with M3 through-holes that screws over a tray
// tongue or strap boss to lock components in place.
// Pairs with M3 heat-set inserts in the rail or tray.
// ============================================================
include <config.scad>

clamp_bar();

module clamp_bar() {
    // Default span: full rack clear width
    bar_w = CB_W;
    bar_h = 8;
    bar_d = 14;

    difference() {
        rr3d(bar_w, bar_d, bar_h, r=2);

        // ── Clearance holes at each end ──────────────────────
        _cb_clamp_holes(bar_w, bar_d, bar_h);

        // ── Lightening slots ─────────────────────────────────
        _cb_light_slots(bar_w, bar_d, bar_h);
    }
}

module _cb_clamp_holes(w, d, h) {
    // Two holes at each end, symmetrically placed
    y_pos = [d * 0.3, d * 0.7];
    end_margin = 6;
    x_pos = [end_margin, w - end_margin];
    for (x = x_pos) {
        for (y = y_pos) {
            translate([x, y, -1])
                cylinder(d=M3_SCREW_D, h=h + 2, $fn=$fn_fine);
            // countersink / head recess from top
            translate([x, y, h - M3_HEAD_H + 0.5])
                cylinder(d=M3_HEAD_D, h=M3_HEAD_H + 1, $fn=$fn_fine);
        }
    }
}

module _cb_light_slots(w, d, h) {
    sw    = 6;
    sh    = d - 2*WALL;
    pitch = 14;
    n     = floor((w - 4*WALL*4) / pitch);
    ox    = (w - n*pitch) / 2 + pitch/2;
    for (i = [0 : n-1]) {
        translate([ox + i*pitch, d/2, -1])
            linear_extrude(h + 2)
                vent_slot(sw, sh);
    }
}
