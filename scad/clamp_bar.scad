// ─────────────────────────────────────────────────────────────────────────────
//  clamp_bar.scad  –  Clamp bar for hook-and-loop strap retention
//
//  Used as the opposing half of the strap system on the FX4100 cradle (and
//  any other cradle that needs lateral strap retention).
//
//  The bar slots through the strap-routing openings in the cradle side wall.
//  A M3 cap-head screw at each end threads into the side-wall insert or a
//  captured nut to lock the strap tension.
//
//  Geometry
//    • Flat rectangular bar : _bar_l × _bar_d × _bar_h
//    • Strap routing slot   : centred, STRAP_W wide, STRAP_H + CLEARANCE tall
//    • M3 counterbored holes at each end for cap-head screws
// ─────────────────────────────────────────────────────────────────────────────
include <config.scad>

// ── Clamp-bar dimensions ──────────────────────────────────────────────────────
_bar_l = 60;     // bar length  (X) – spans across device + both side walls
_bar_d = 14;     // bar depth   (Y) – slightly wider than strap
_bar_h =  8;     // bar height  (Z)

// Counterbore depth for M3 cap head
_cbore_depth = M3_HEAD_H + 0.5;

module clamp_bar() {
    difference() {
        // ── Bar body ──────────────────────────────────────────────────────────
        cube([_bar_l, _bar_d, _bar_h]);

        // ── Strap routing slot (centred, runs full bar depth) ─────────────────
        translate([(_bar_l - STRAP_W) / 2, -0.1, (_bar_h - STRAP_H - CLEARANCE) / 2])
            cube([STRAP_W, _bar_d + 0.2, STRAP_H + CLEARANCE]);

        // ── M3 counterbored screw hole – left end ─────────────────────────────
        translate([_bar_l * 0.15, _bar_d / 2, -0.1]) {
            cylinder(d = M3_CLEAR_D, h = _bar_h + 0.2);                  // shank
            cylinder(d = M3_CBORE_D, h = _cbore_depth + 0.1);            // head seat
        }

        // ── M3 counterbored screw hole – right end ────────────────────────────
        translate([_bar_l * 0.85, _bar_d / 2, -0.1]) {
            cylinder(d = M3_CLEAR_D, h = _bar_h + 0.2);
            cylinder(d = M3_CBORE_D, h = _cbore_depth + 0.1);
        }
    }
}

clamp_bar();
