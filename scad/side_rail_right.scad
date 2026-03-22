// ─────────────────────────────────────────────────────────────────────────────
//  side_rail_right.scad  –  Right side rail (mirror of the left rail)
//
//  Origin: outer-right-front-bottom corner of the rack (X=RACK_W, Y=0, Z=0).
//  The rail body occupies [RACK_W-RAIL_W … RACK_W] × [0…RAIL_D] × [0…RAIL_H].
//
//  Produced by translating to the right edge and mirroring side_rail_left so
//  all insert pockets remain on the inward-facing (−X) face of this rail.
// ─────────────────────────────────────────────────────────────────────────────
include <config.scad>
use <side_rail_left.scad>

module side_rail_right() {
    // Shift the origin to the right edge then flip so the inner face
    // (originally +X of the left rail) becomes the −X face of the right rail.
    translate([RACK_W, 0, 0])
        mirror([1, 0, 0])
            side_rail_left();
}

side_rail_right();
