// ============================================================
// config.scad  –  Global parameters for the modular open-frame
//                 desktop mini-server rack
// ============================================================
// All dimensions in millimetres unless noted.
// Edit this file to resize the whole rack.

// ── Rack envelope ────────────────────────────────────────────
RACK_W  = 250;   // overall width  (X)
RACK_D  = 260;   // overall depth  (Y)
RACK_H  = 285;   // overall height (Z)

// ── Wall / structural thickness ──────────────────────────────
WALL    = 3.5;   // general shell wall thickness
         // Note: M3 insert pockets are placed inside dedicated bosses
         // or solid regions (not plain walls), so WALL does not directly
         // constrain insert pocket structural integrity.
RIB     = 2.4;   // thin rib / gusset thickness
FLOOR   = 2.4;   // tray / plate floor thickness

// ── Side-rail cross-section ───────────────────────────────────
RAIL_W  = 18;    // rail width  (X footprint)
RAIL_D  = 260;   // rail depth  = RACK_D
RAIL_H  = 285;   // rail height = RACK_H

// ── Crossbar ─────────────────────────────────────────────────
CB_W    = RACK_W - 2*RAIL_W;  // clear span between rails
CB_H    = 12;    // crossbar height
CB_D    = 18;    // crossbar depth (fore-aft)
CB_SLOT_W  = 6;  // vent-slot width
CB_SLOT_GAP = 4; // vent-slot pitch gap

// ── M3 heat-set insert geometry ──────────────────────────────
M3_INSERT_OD  = 4.4;   // outer diameter of insert
M3_INSERT_H   = 5.7;   // total insert height
M3_SCREW_D    = 3.2;   // clearance hole for M3 screw
M3_HEAD_D     = 6.0;   // M3 button-head recess diameter
M3_HEAD_H     = 2.4;   // M3 button-head recess depth
M3_NUT_AF     = 5.5;   // M3 hex-nut across-flats (captive nut pockets)
M3_NUT_H      = 2.4;   // M3 hex-nut height

// ── Vent-slot defaults ────────────────────────────────────────
SLOT_W  = 4.0;   // vent slot width
SLOT_H  = 20;    // vent slot height (for side vents)
SLOT_R  = 2.0;   // slot corner radius
SLOT_PITCH = 7;  // centre-to-centre vent pitch

// ── Tray mounting ─────────────────────────────────────────────
TRAY_RAIL_W  = 8;    // tray side tongue that slides onto rail
TRAY_LIP_H   = 4;    // front retention lip height
TRAY_LIP_D   = 3;    // front retention lip depth
CABLE_NOTCH_W = 20;  // cable-relief notch width
CABLE_NOTCH_H = 12;  // cable-relief notch height

// ── Standoff (Pi plate) ───────────────────────────────────────
SO_OD    = 7.0;  // standoff outer diameter
SO_ID    = 3.2;  // standoff through-hole (M3 clearance)
SO_H     = 8.0;  // standoff height (clearance under PCB)

// ── Foot ──────────────────────────────────────────────────────
FOOT_OD  = 28;   // foot base diameter
FOOT_H   = 12;   // foot total height
FOOT_RUBBER_OD = 20; // rubber-pad seat diameter
FOOT_RUBBER_H  =  4; // rubber-pad seat depth

// ── Tolerance / fit ───────────────────────────────────────────
FIT     = 0.2;   // general press-fit clearance per side
SLOP    = 0.4;   // slide-fit clearance per side

// ── Render quality ────────────────────────────────────────────
$fn_coarse  = 24;
$fn_fine    = 48;
$fn         = $fn_coarse;

// ── Device dimensions ────────────────────────────────────────
// Mac mini M2
MM2_W = 196.85;
MM2_D = 196.85;
MM2_H = 35.8;

// Mac mini M4
MM4_W = 127;
MM4_D = 127;
MM4_H = 50;

// Raspberry Pi 5 PCB (bare board)
PI5_W = 85;
PI5_D = 56;
PI5_H = 1.6;   // PCB thickness

// Pi 5 mounting-hole positions (from board origin corner)
PI5_MH = [[3.5, 3.5], [3.5, 52.5], [61.5, 3.5], [61.5, 52.5]];

// Apple TV 4K 3rd gen
ATV_W = 93;
ATV_D = 93;
ATV_H = 31;

// Inseego FX4100 modem
FX_W  = 167;
FX_D  = 104;
FX_H  = 52;

// ── Fan mount (Pi 5 plate) ────────────────────────────────────
FAN40_W      = 40;   // 40 mm fan frame size
FAN40_BOLT_C = 32;   // bolt-hole circle (centre to centre)
FAN40_SCREW_D = 3.2; // M3 clearance

// ── Strap slot (FX4100 cradle) ────────────────────────────────
STRAP_W   = 20;   // hook-and-loop strap width
STRAP_T   = 2.5;  // strap thickness
STRAP_SLOT_W = STRAP_W + 1.0;
STRAP_SLOT_H = STRAP_T + 1.0;

// ── Helper: rounded-rectangle (2-D) ───────────────────────────
module rr2d(w, d, r) {
    offset(r=r) offset(r=-r)
        square([w, d]);
}

// ── Helper: rounded box (3-D) ─────────────────────────────────
module rr3d(w, d, h, r=1.5) {
    linear_extrude(h) rr2d(w, d, r);
}

// ── Helper: M3 insert pocket (upward-facing) ──────────────────
module m3_insert_pocket(depth=M3_INSERT_H + 0.5) {
    cylinder(d=M3_INSERT_OD + 2*FIT, h=depth, $fn=$fn_fine);
}

// ── Helper: M3 clearance hole ────────────────────────────────
module m3_hole(h=20) {
    cylinder(d=M3_SCREW_D, h=h, $fn=$fn_fine);
}

// ── Helper: vent slot (rounded ends, XY plane) ───────────────
module vent_slot(w=SLOT_W, h=SLOT_H) {
    r = w/2;
    hull() {
        translate([0,  h/2 - r]) circle(r=r, $fn=$fn_fine);
        translate([0, -h/2 + r]) circle(r=r, $fn=$fn_fine);
    }
}

// ── Helper: vent-slot pattern (linear, X-direction) ──────────
// count  = number of slots
// pitch  = slot centre pitch
// depth  = extrude depth (cut into wall)
module vent_row(count, pitch=SLOT_PITCH, sw=SLOT_W, sh=SLOT_H, depth=50) {
    for (i = [0 : count-1]) {
        x = (i - (count-1)/2) * pitch;
        translate([x, 0, 0])
            linear_extrude(depth)
                vent_slot(sw, sh);
    }
}
