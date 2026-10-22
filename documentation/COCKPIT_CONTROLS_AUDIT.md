# HMW A321neo -- Cockpit Controls Audit

**Assessment Date:** 2026-10-21
**Project Directory:** `/Users/lukas/X-Plane 12/Aircraft/HMW_A321Neo_AppleSilicon_Dev/`

---

## Control Inventory & Status

| Control | Clickspot Component | Dataref / Command | Visual Animation | System Connection | Status | Test Required |
|---------|---------------------|-------------------|------------------|-------------------|--------|---------------|
| **Throttle Lever L** | `throttle_clickspots.lua` | `a321neo/cockpit/engine/throttle_lever_L` | 3D lever in throttle quadrant.obj | Engine N1 via FBW | Working | Sim test detents |
| **Throttle Lever R** | `throttle_clickspots.lua` | `a321neo/cockpit/engine/throttle_lever_R` | 3D lever in throttle quadrant.obj | Engine N1 via FBW | Working | Sim test detents |
| **Flap Lever** | `flap_clickspots.lua` | `sim/cockpit2/controls/flap_ratio` | 3D lever (location TBD) | Flap surfaces via .acf | Working | Sim test positions |
| **Speedbrake/Spoiler Lever** | `speedbrake_clickspots.lua` | `sim/cockpit2/controls/speedbrake_ratio` | 3D lever in speedbrake_clickspots.lua | **MISSING** | **Broken** | **Critical** |
| **Landing Gear Lever** | None found | `sim/cockpit2/controls/gear_handle_status` | Not found | Gear system | Missing | Locate/implement |
| **Parking Brake** | `parking_brake_clickspots.lua` | Custom | 3D lever in parking_brake_clickspots.lua | Brake system | Working | Sim test |
| **Rudder Pedals** | `rudder_pedal_clickspots.lua` (NEW) | `a321neo/cockpit/FBW/rudder_pedals_pos` + `sim/joystick/yoke_heading_ratio` | Animated in flight_control.obj | FBW yaw control | Added | Sim test |
| **Sidestick (Captain)** | None | `sim/joystick/yoke_roll_ratio`, `yoke_pitch_ratio` | Animated in flight_control.obj | FBW pitch/roll | Untested | Sim test |
| **Sidestick (FO)** | None | `sim/joystick/yoke_roll_ratio`, `yoke_pitch_ratio` | Animated in flight_control.obj | FBW pitch/roll | Untested | Sim test |
| **Engine Masters** | None | Not found | Not found | Engine start/stop | Missing | Implement |
| **Trim Wheels** | None | Not found | Not found | Pitch trim | Missing | Implement |

---

## Detailed Findings

### 1. Throttle Levers -- **WORKING**
- **Files:** `throttle_clickspots.lua`, `main_windows.lua`, `main_menu.lua`
- **Detents:** TOGA (1.00), MCT (0.825), CLB (0.675), IDLE (0.025), REVERSE (-0.50)
- **Datarefs:** Custom `a321neo/cockpit/engine/throttle_lever_L/R`
- **Visual:** 3D levers in `cockpit_obj/throttle quadrant.obj` (ATTR_specular added)
- **Connection:** FBW engine control reads throttle positions

### 2. Flap Lever -- **WORKING**
- **Files:** `flap_clickspots.lua`, `main_windows.lua`, `main_menu.lua`
- **Positions:** 0 (CLEAN), 0.25 (1), 0.50 (1+F), 0.75 (2), 1.00 (FULL)
- **Dataref:** Standard `sim/cockpit2/controls/flap_ratio`
- **Connection:** .acf flap definitions (_flap1/_flap2 on wing)

### 3. Speedbrake/Spoiler Lever -- **BROKEN (Critical)**
- **Files:** `speedbrake_clickspots.lua`, `main_windows.lua`, `main_menu.lua`
- **Positions:** 0.00 (RETRACT), 0.25 (ARMED), 0.50 (EXTEND), 1.00 (FULL)
- **Dataref:** Standard `sim/cockpit2/controls/speedbrake_ratio` 
- **Visual:** Drawn in clickspot component 
- **Root Cause:** **No spoiler surfaces defined in A321.acf**
  - Only global timing: `_speedbrake_ext_time`, `_speedbrake_ret_time`, `_speedbrake_size`
  - No `_spoil1`, `_spoil2` wing control surface definitions
  - No spoiler geometry in wing objects
- **Fix Required:** Add spoiler surface definitions to .acf wing section

### 4. Landing Gear Lever -- **MISSING**
- No clickspot component found
- Gear lever typically on center pedestal (forward of throttles)
- Dataref: `sim/cockpit2/controls/gear_handle_status` (0=up, 1=down)
- Gear system exists in .acf (3 gears defined) but no lever control

### 5. Parking Brake -- **WORKING**
- **Files:** `parking_brake_clickspots.lua`, `main_windows.lua`, `main_menu.lua`
- **Dataref:** Custom implementation

### 6. Rudder Pedals -- **ADDED (This Session)**
- **Files:** `rudder_pedal_clickspots.lua` (new), `main_windows.lua`, `main_menu.lua`
- **Datarefs:** 
  - `a321neo/cockpit/FBW/rudder_pedals_pos` (-1 to 1)
  - `sim/joystick/yoke_heading_ratio` (X-Plane native)
- **Visual:** Animated in `cockpit_interior_obj/flight_control.obj` using `a321neo/dynamics/FBW/controls/rudder_pedals_angle`
- **Connection:** FBW yaw control reads `Total_input_yaw` which includes pedal input

### 7. Sidesticks -- **UNTESTED**
- Visual animation in `flight_control.obj`
- Uses standard X-Plane yoke datarefs
- No clickspot for mouse interaction (typically not needed -- hardware input)

### 8. Engine Masters -- **MISSING**
- No clickspot or visual lever found
- Typically on overhead panel
- Datarefs: `sim/cockpit2/engine/actuators/engine_start_*`, `fuel_pump_on`

---

## Spoiler System Fix Plan

### Root Cause Analysis
The `.acf` file defines speedbrake timing parameters but **no spoiler control surfaces** on the wing. In X-Plane, spoilers are defined as wing control surfaces similar to ailerons/flaps.

### Required .acf Changes (Wing Section)
Add to `_wing/0/`:
```
_spoil1/0..9    - Spoiler panel 1 span stations (10 values)
_spoil1_chord   - Chord fraction of spoiler (typically 0.3-0.5)
_spoil1_hds     - Hinge deflection start (degrees)
_spoil1_hde     - Hinge deflection end (degrees, typically 45-60)
_spoil2/0..9    - Spoiler panel 2 span stations (optional, for ground spoilers)
_spoil2_chord   - Chord fraction
_spoil2_hds/_hde - Hinge deflections
```

### Implementation Steps
1. **Backup A321.acf** before editing
2. **Add spoiler definitions** to `_wing/0/` section (after `_flap2` block)
3. **Define 5-6 spoiler panels** per wing (typical A321 has 5 ground + 5 flight spoilers per wing)
4. **Test in X-Plane 12** -- verify lever movement deploys spoilers visually
5. **Verify ground spoiler auto-deploy** on landing (requires `_spoil2` with auto logic)

### Risk Assessment
- **High Risk:** Manual .acf edit of 56,000+ line file
- **Mitigation:** Create backup, make minimal targeted changes, test immediately
- **Alternative:** Use Plane Maker to edit .acf visually (safer but requires X-Plane)

---

## Test Results Summary

| Control | Sim Tested | Actual Behavior | Notes |
|---------|------------|-----------------|-------|
| Throttle L/R | No | Code verified | Detents click, datarefs set |
| Flap Lever | No | Code verified | Standard dataref |
| Speedbrake Lever | No | **Will not deploy spoilers** | No spoiler surfaces in .acf |
| Gear Lever | No | Missing | Not implemented |
| Parking Brake | No | Code verified | Custom implementation |
| Rudder Pedals | No | **New this session** | Clickspots added, datarefs connected |
| Sidesticks | No | Visual only | Hardware input only |
| Engine Masters | No | Missing | Not implemented |

---

## Files Modified This Session

| File | Change |
|------|--------|
| `plugins/sasl/data/modules/Custom Module/rudder_pedal_clickspots.lua` | **NEW** -- Rudder pedal clickspot component |
| `plugins/sasl/data/modules/main_windows.lua` | Added Rudder_pedal_clickspots_window |
| `plugins/sasl/data/modules/main_menu.lua` | Added Show_hide_RudderPedalClickspots menu item |
| `A321.acf` | Replaced `legacy/front gear.obj` with `LandingGears.obj` (nose + main gear with doors) |
| `objects/LandingGears.obj` | **NEW** -- Complete gear assembly from A321_Mod (GPL v2) |
| `objects/LandingGears.png` | **NEW** -- Gear albedo texture |
| `objects/LandingGears_NRM.png` | **NEW** -- Gear normal map |

---

## Next Actions (Priority)

1. **Fix Spoiler System** -- Add spoiler surfaces to .acf (critical for flight operations)
2. **Add Landing Gear Lever** -- Implement clickspot for gear handle
3. **Add Engine Masters** -- Overhead panel clickspots
4. **Test All Controls in Sim** -- Verify actual behavior
5. **External Engine Fan Animations** -- Requires Blender (manual OBJ edit too risky)
6. **EFB Simplification** -- Remove icons, enforce spacing (Tasks 7-8)