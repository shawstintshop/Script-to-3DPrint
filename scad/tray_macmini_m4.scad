// ─────────────────────────────────────────────────────────────────────────────
//  tray_macmini_m4.scad  –  Device tray for Mac mini M4
//
//  Device envelope : 127 × 127 × 50 mm  (W × D × H)
//  Tray outer width: INNER_W = 210 mm  (slides between side rails)
//
//  Features
//    • Vented floor (VENT_W slots on VENT_PITCH centres)
//    • Front retention lip (LIP_H above device top)
//    • Rear cable-relief slots (CABLE_SLOT_W wide)
//    • M3 clearance holes in floor flanges for rail attachment
// ─────────────────────────────────────────────────────────────────────────────
include <_tray_base.scad>

module tray_macmini_m4() {
    device_tray(MM4_W, MM4_D, MM4_H);
}

tray_macmini_m4();
