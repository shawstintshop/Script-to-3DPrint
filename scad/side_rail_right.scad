// ============================================================
// side_rail_right.scad  –  Right side rail (mirror of left)
// Open-frame rack – modular screw-together assembly
// ============================================================
include <config.scad>
use <side_rail_left.scad>

side_rail_right();

module side_rail_right() {
    // Mirror about the X axis centre of the rail body so all
    // pockets and channels remain on the correct (inner) face.
    mirror([1, 0, 0])
        translate([-RAIL_W, 0, 0])
            side_rail_left();
}
