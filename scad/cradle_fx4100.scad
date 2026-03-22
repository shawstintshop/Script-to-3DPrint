// ─────────────────────────────────────────────────────────────────────────────
//  cradle_fx4100.scad  –  Vertical open-sided strap-retained cradle for
//                          Inseego FX4100 mobile hotspot
//
//  Device envelope (lying flat on wide face): 167 × 104 × 52 mm  (W × D × H)
//  Mounted vertically: device stands on its 167 × 52 mm base, tallest
//  dimension (104 mm) pointing upward.
//
//  Cradle architecture
//    • Bottom platform (FLOOR thick, device stands on it)
//    • Left and right side walls (WALL thick, open front and rear for airflow)
//    • Two strap-routing slots on each side wall to accept a hook-and-loop strap
//    • Two M3 heat-set insert pockets in the base for optional screw retention
//    • M3 clearance holes in base flanges for mounting to a crossbar
// ─────────────────────────────────────────────────────────────────────────────
include <config.scad>

// ── Cradle-specific geometry ──────────────────────────────────────────────────
// Device stands upright: footprint is FX_W × FX_H, wall height ≥ FX_D / 3
_dev_fw  = FX_W + 2 * CLEARANCE;   // 167.4 mm  – device footprint width (X)
_dev_fd  = FX_H + 2 * CLEARANCE;   // 52.4  mm  – device footprint depth (Y)
_wall_h  = max(FX_D / 3, 30);      // side-wall height (~34.7 mm) – keeps device
                                    // stable while remaining open-sided

_outer_w = _dev_fw + 2 * WALL;     // cradle outer width
_outer_d = _dev_fd + 2 * WALL;     // cradle outer depth

// Strap slots: two per side wall, centred in X on the wall, stacked in Z
_strap_z1 = _wall_h * 0.30;
_strap_z2 = _wall_h * 0.70;

// M3 insert pocket helper (opens toward +Z)
module _insert_pocket_z() {
    cylinder(d = M3_INSERT_D + 0.15, h = M3_INSERT_H + 0.5);
}

module cradle_fx4100() {
    difference() {
        union() {
            // ── Bottom platform ───────────────────────────────────────────────
            cube([_outer_w, _outer_d, FLOOR]);

            // ── Left side wall (−X face of device pocket) ────────────────────
            translate([0, 0, 0])
                cube([WALL, _outer_d, FLOOR + _wall_h]);

            // ── Right side wall (+X face of device pocket) ───────────────────
            translate([WALL + _dev_fw, 0, 0])
                cube([WALL, _outer_d, FLOOR + _wall_h]);
        }

        // ── Strap slots in left wall ──────────────────────────────────────────
        for (sz = [_strap_z1, _strap_z2]) {
            translate([-0.1, (_outer_d - STRAP_W) / 2, FLOOR + sz - STRAP_H / 2])
                cube([WALL + 0.2, STRAP_W, STRAP_H]);
        }

        // ── Strap slots in right wall ─────────────────────────────────────────
        for (sz = [_strap_z1, _strap_z2]) {
            translate([WALL + _dev_fw - 0.1,
                       (_outer_d - STRAP_W) / 2,
                       FLOOR + sz - STRAP_H / 2])
                cube([WALL + 0.2, STRAP_W, STRAP_H]);
        }

        // ── M3 heat-set insert pockets in base (optional screw retention) ─────
        for (ix = [_outer_w * 0.25, _outer_w * 0.75]) {
            translate([ix, _outer_d / 2, -0.1])
                _insert_pocket_z();
        }

        // ── M3 clearance holes in base flanges for crossbar mounting ──────────
        for (fy = [_outer_d * 0.25, _outer_d * 0.75]) {
            // left flange
            translate([WALL / 2, fy, -0.1])
                cylinder(d = M3_CLEAR_D, h = FLOOR + 0.2);
            // right flange
            translate([_outer_w - WALL / 2, fy, -0.1])
                cylinder(d = M3_CLEAR_D, h = FLOOR + 0.2);
        }
    }
}

cradle_fx4100();
