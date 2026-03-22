// ─────────────────────────────────────────────────────────────────────────────
//  tray_appletv.scad  –  Device tray for Apple TV 4K (3rd generation)
//
//  Device envelope : 93 × 93 × 31 mm  (W × D × H)
//  Tray outer width: INNER_W = 210 mm  (slides between side rails)
//
//  Features
//    • Vented floor (VENT_W slots on VENT_PITCH centres)
//    • Front retention lip (LIP_H above device top)
//    • Rear cable-relief slots (CABLE_SLOT_W wide)
//    • M3 clearance holes in floor flanges for rail attachment
// ─────────────────────────────────────────────────────────────────────────────
include <_tray_base.scad>

module tray_appletv() {
    device_tray(ATV_W, ATV_D, ATV_H);
}

tray_appletv();
