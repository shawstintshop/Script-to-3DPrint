// ─────────────────────────────────────────────────────────────────────────────
//  config.scad  –  Global parameters for modular open-frame desktop
//                  mini-server rack
//
//  Rack outer envelope : 250 × 260 × 285 mm  (W × D × H)
//  Fastener standard   : M3 heat-set inserts + M3 cap-head screws
//  Print target        : Bambu H2D (350 × 320 mm bed)
// ─────────────────────────────────────────────────────────────────────────────

// ── Rack outer envelope ───────────────────────────────────────────────────────
RACK_W = 250;    // overall width   (X) mm
RACK_D = 260;    // overall depth   (Y) mm
RACK_H = 285;    // overall height  (Z) mm

// ── Side rail cross-section ───────────────────────────────────────────────────
RAIL_W = 20;     // rail thickness  (X) mm
RAIL_D = RACK_D; // rail runs full depth
RAIL_H = RACK_H; // rail runs full height

// Usable inner width between the two rails
INNER_W = RACK_W - 2 * RAIL_W;   // 210 mm

// Pitch (mm) between mounting-insert rows along rail height
SLOT_PITCH = 20;

// ── Crossbar ─────────────────────────────────────────────────────────────────
CBAR_W = RACK_W;  // full rack width  (X)
CBAR_D = 25;      // front-to-back depth (Y)
CBAR_H = 8;       // thickness (Z)

// Y offsets of the two mounting screws per crossbar end
// (measured from the crossbar's own front face)
CBAR_MOUNT_Y1 = CBAR_D * 0.30;   // ≈ 7.5 mm
CBAR_MOUNT_Y2 = CBAR_D * 0.70;   // ≈ 17.5 mm

// ── Device dimensions  W × D × H  (all in mm) ────────────────────────────────
MM2_W = 196.85;  MM2_D = 196.85;  MM2_H = 35.8;   // Mac mini M2
MM4_W = 127.0;   MM4_D = 127.0;   MM4_H = 50.0;   // Mac mini M4
PI5_W = 85.0;    PI5_D = 56.0;    PI5_H = 17.0;   // Raspberry Pi 5 PCB
ATV_W = 93.0;    ATV_D = 93.0;    ATV_H = 31.0;   // Apple TV 4K 3rd gen
FX_W  = 167.0;   FX_D  = 104.0;   FX_H  = 52.0;   // Inseego FX4100

// ── Raspberry Pi 5 mounting-hole grid (from board origin corner) ──────────────
PI5_HOLE_X1 = 3.5;
PI5_HOLE_X2 = 61.5;
PI5_HOLE_Y1 = 3.5;
PI5_HOLE_Y2 = 52.5;
PI5_STANDOFF_H  = 5.0;   // height of standoff posts above plate floor
PI5_STANDOFF_OD = 6.0;   // standoff outer diameter
PI5_HOLE_D      = 2.7;   // M2.5 clearance hole through standoff

// ── Fasteners – M3 heat-set inserts + M3 screws ───────────────────────────────
M3_INSERT_D = 4.7;   // insert outer Ø  (press-fit into 4.5 mm hole → +0.2 entry)
M3_INSERT_H = 5.7;   // insert depth
M3_CLEAR_D  = 3.4;   // M3 clearance hole Ø
M3_HEAD_D   = 6.0;   // M3 cap-head Ø
M3_HEAD_H   = 3.0;   // M3 cap-head height
M3_CBORE_D  = 6.5;   // counterbore Ø (seat for cap head)

// ── Print / geometry ──────────────────────────────────────────────────────────
WALL      = 3.0;   // shell wall thickness
FLOOR     = 2.5;   // tray / plate floor thickness
LIP_H     = 6.0;   // front retention-lip height above device top
CLEARANCE = 0.2;   // per-side fit clearance (0.4 mm total)

// ── Vent slots ────────────────────────────────────────────────────────────────
VENT_W     = 3.0;    // slot width
VENT_L     = 20.0;   // slot length (along its own long axis)
VENT_PITCH = 6.0;    // centre-to-centre pitch between slots

// ── Cable-relief slots in rear tray wall ─────────────────────────────────────
CABLE_SLOT_W = 8.0;
CABLE_SLOT_H = 20.0;  // height of opening in rear wall

// ── Anti-vibration feet ───────────────────────────────────────────────────────
FOOT_OD       = 25;   // outer Ø
FOOT_H        = 10;   // total height
FOOT_RUBBER_D = 20;   // rubber-pad recess Ø
FOOT_RUBBER_H = 3;    // rubber-pad recess depth

// ── Strap slot for FX4100 cradle ─────────────────────────────────────────────
STRAP_W = 20;    // strap width
STRAP_H =  3;    // strap slot thickness (clearance)

// ── Render quality ────────────────────────────────────────────────────────────
$fn = 64;
