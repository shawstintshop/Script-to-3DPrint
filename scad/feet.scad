// ─────────────────────────────────────────────────────────────────────────────
//  feet.scad  –  Anti-vibration foot for the rack
//
//  One foot attaches below each bottom corner of a side rail via an M3 screw
//  that passes up through the foot and into the rail's bottom clearance hole.
//
//  Geometry
//    • Cylindrical outer body  (FOOT_OD × FOOT_H)
//    • Central M3 clearance hole (through)
//    • Counterbore on top for M3 cap-head screw (seats flush)
//    • Recess on bottom for silicone/rubber anti-vibration pad (FOOT_RUBBER_D × FOOT_RUBBER_H)
//    • Six perimeter ventilation cutouts at base ring for rubber pad placement
//
//  Print 4 × (two per side rail, front and rear foot positions).
// ─────────────────────────────────────────────────────────────────────────────
include <config.scad>

module foot() {
    difference() {
        // ── Outer body ────────────────────────────────────────────────────────
        cylinder(d = FOOT_OD, h = FOOT_H);

        // ── Central M3 clearance hole (full height) ───────────────────────────
        translate([0, 0, -0.1])
            cylinder(d = M3_CLEAR_D, h = FOOT_H + 0.2);

        // ── Counterbore on top for M3 cap-head screw ──────────────────────────
        translate([0, 0, FOOT_H - M3_HEAD_H - 0.5])
            cylinder(d = M3_CBORE_D, h = M3_HEAD_H + 0.6);

        // ── Rubber-pad recess on bottom ───────────────────────────────────────
        translate([0, 0, -0.1])
            cylinder(d = FOOT_RUBBER_D, h = FOOT_RUBBER_H + 0.1);
    }
}

foot();
