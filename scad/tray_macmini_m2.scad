// ─────────────────────────────────────────────────────────────────────────────
//  tray_macmini_m2.scad  –  Device tray for Mac mini M2
//
//  Device envelope : 196.85 × 196.85 × 35.8 mm  (W × D × H)
//  Tray outer width: INNER_W = 210 mm  (slides between side rails)
//
//  Features
//    • Vented floor (VENT_W slots on VENT_PITCH centres)
//    • Front retention lip (LIP_H above device top)
//    • Rear cable-relief slots (CABLE_SLOT_W wide)
//    • M3 clearance holes in floor flanges for rail attachment
// ─────────────────────────────────────────────────────────────────────────────
include <_tray_base.scad>

module tray_macmini_m2() {
    device_tray(MM2_W, MM2_D, MM2_H);
}

tray_macmini_m2();
