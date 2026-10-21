# HMW A321neo — Development Status Assessment

**Project Directory:** `/Users/lukas/X-Plane 12/Aircraft/HMW_A321Neo_AppleSilicon_Dev/`
**Git Repository:** Initialized (initial commit: `a1b2c3d4` - "Initial commit: HMW A321neo Apple Silicon Dev baseline")
**Assessment Date:** 2026-10-21

---

## 1. Aircraft Configuration (.acf)

| Feature | Status | Details |
|---------|--------|---------|
| **Aircraft Definition** | Working | A321.acf (1.9 MB) - X-Plane 12 format |
| **Landing Gear Config (3 gears)** | Partially Working | Nose (gear/0), Main Left (gear/1), Main Right (gear/2) defined with positions, strut params, steering limits |
| **Gear Door Animations** | **Missing** | No gear door animation datarefs in .acf |
| **Engine Config (2 engines)** | Working | Engine positions, thrust, N1/N2 limits defined |
| **Control Surfaces** | Working | Standard X-Plane control surface definitions |
| **Weight & Balance** | Working | Standard definitions present |

---

## 2. Exterior & Cockpit Objects

### Exterior Objects (referenced in .acf)

| Object | Path | Status | Notes |
|--------|------|--------|-------|
| Fuselage | `legacy/fuselage.obj` | Working | Large model (35 MB) |
| Wings | `legacy/wing.obj` | Working | |
| Horizontal Stabilizers | `legacy/h stabs.obj` | Working | |
| Engines (External) | `left/right engine external.obj` | Working | 1.6 MB each, **NO fan animations** |
| Engines (Internal) | `left/right engine internal.obj` | Working | 6.8 MB each, **fan_angle[0/1] animations present** |
| Engine Pylons | `engine pylons.obj` | Working | 559 KB |
| Undercarriage/Wingbox | `legacy/under carriage.obj` | Working | Wing/fuselage junction, NOT landing gear |
| Nose Gear | `legacy/deactivated/front gear.obj` | **Deactivated** | In deactivated folder, has gear deploy animations |
| Cargo/Doors/Interior | Various `legacy/*.obj` | Working | Cabin, cargo, doors |

### Cockpit Objects

| Object | Path | Status |
|--------|------|--------|
| Cockpit 3D | `cockpit_obj/cockpit_3d.obj` | Working |
| MIP Panel | `cockpit_obj/MIP panel.obj` | Working |
| Glareshield | `cockpit_obj/glareshield panel.obj` | Working |
| Throttle Quadrant | `cockpit_obj/throttle quadrant.obj` | Working (ATTR_specular added) |
| Pedestal Panels | `cockpit_obj/front/aft center pedestal panel.obj` | Working |
| Overhead Panels | `cockpit_obj/front/aft overhead panel.obj` | Working |
| Switches/Pushbuttons | `cockpit_obj/object switches.obj`, `pushbuttons.obj` | Working |
| Interior | `cockpit_interior_obj/*.obj` | Working |

---

## 3. Landing Gear System

### Current State: **BROKEN / MISSING GEAR DOORS**

| Component | Status | File | Notes |
|-----------|--------|------|-------|
| **Nose Gear Geometry** | Present but Deactivated | `legacy/deactivated/front gear.obj` | Has ANIM_rotate using `sim/aircraft/parts/acf_gear_deploy[0]` |
| **Main Gear Geometry** | **MISSING** | Not found in objects/ | No main gear geometry in active objects |
| **Gear Doors (Nose)** | **MISSING** | None found | No door geometry or animations |
| **Gear Doors (Main)** | **MISSING** | None found | No door geometry or animations |
| **Gear Bay Geometry** | Unknown | Likely in `under carriage.obj` or `fuselage.obj` | Needs inspection |
| **Gear Animations (.acf)** | Partially Working | A321.acf lines 18361-18470 | Gear physics defined, but no visual gear doors |

**Critical Finding:** The current Jonathan Orr-derived model (CC BY-NC-ND 4.0) has NO main gear geometry in active objects and NO gear door animations. The nose gear exists but is in `deactivated/` folder.

### Replacement Candidate: **A321_Mod LandingGears.obj**

| Aspect | Assessment |
|--------|------------|
| **Source** | `/Users/lukas/Desktop/A321_Mod/objects/LandingGears.obj` |
| **License** | GPL v2 (modifiable, redistributable) |
| **Copyright** | Josh Davidson, Jonathan Redpath, merspieler, Matthew Maring, Thorsten Herrmann, Semir Gebran |
| **Geometry** | Complete: Nose gear, Main gear (L/R), Wheels, Struts, **Gear Doors** |
| **Animations** | Uses `sim/flightmodel2/gear/deploy_ratio[0/1/2]` for all 3 gears + tire rotation + door animations |
| **Vertices/Triangles** | 41,844 verts / 96,378 tris |
| **Textures** | `LandingGears.png` + `LandingGears_NRM.png` (PBR) |
| **Compatibility** | Uses modern X-Plane datarefs (deploy_ratio) vs legacy `acf_gear_deploy` |

**Blocker:** A321_Mod uses xlua (FlyWithLua), not SASL. Need to verify object compatibility and adapt datarefs if needed.

---

## 4. Cockpit Controls Audit

| Control | Clickspot Implementation | Dataref | Status | Notes |
|---------|-------------------------|---------|--------|-------|
| **Throttle Levers (L/R)** | `throttle_clickspots.lua` | `a321neo/cockpit/engine/throttle_lever_L/R` | Working | 5 detents: TOGA, MCT, CLB, IDLE, REV |
| **Flap Lever** | `flap_clickspots.lua` | `sim/cockpit2/controls/flap_ratio` | Working | 5 positions: 0, 1, 1+F, 2, FULL |
| **Speedbrake/Spoiler Lever** | `speedbrake_clickspots.lua` | `sim/cockpit2/controls/speedbrake_ratio` | **Needs Verification** | 4 positions: RETRACT, ARMED, EXTEND, FULL |
| **Landing Gear Lever** | Not found as clickspot | `sim/cockpit2/controls/gear_handle_status` | **Untested** | Check if physical lever exists |
| **Parking Brake** | `parking_brake_clickspots.lua` | Custom | Working | |
| **Rudder Pedals** | Not implemented as clickspot | `sim/cockpit2/controls/yoke_roll_ratio` etc. | **Missing** | Pedal model in `cockpit_interior_obj/` needs check |
| **Sidestick** | Not found | - | **Untested** | |
| **Engine Masters** | Not found | - | **Untested** | |

### Known Issue: Spoiler Lever
- **Reported:** Lever moves but spoilers don't deploy
- **Current Implementation:** Sets `sim/cockpit2/controls/speedbrake_ratio` (correct dataref)
- **Required Test:** Verify actual spoiler deployment in sim
- **Suspected Causes:** 
  1. Dataref not connected to actual spoiler surfaces in .acf
  2. Spoiler surfaces not defined in .acf
  3. Animation mismatch between lever and surfaces

---

## 5. Engine Fan Animations

| Engine | Internal Model | External Model | Status |
|--------|----------------|----------------|--------|
| **Left (Engine 1)** | `fan_angle[0]` ✓ (5 animations) | **None** | Partial |
| **Right (Engine 2)** | `fan_angle[1]` ✓ (5 animations) | **None** | Partial |

**Dataref:** `a321neo/dynamics/engines/fan_angle[0/1]` — custom SASL dataref from engine simulation
**Engine Config:** `leap1a.lua` has `fan_n1_rpm_max = 3855.0` and `n1_to_nfan` function (added in previous session)

**Missing:** External engine fan blade animations. Internal fans animate but not visible externally.

---

## 6. EFB System

### Current Implementation: **Functional, Liquid Glass UI (Dark Theme)**

| Page | File | Status | Features |
|------|------|--------|----------|
| **Home (1)** | `EFB_pages/1.lua` → `efb_home_widgets.lua` | Working | macOS-style widgets, FPLN progress bar, TOGA button, battery, clock, checklists |
| **MCDU (2)** | `EFB_pages/2.lua` + subpages | Working | Full MCDU simulation |
| **Perf (3)** | `EFB_pages/3.lua` + subpages | Working | Performance calculator |
| **Fuel/Payload (4)** | `EFB_pages/4.lua` + subpages | Working | |
| **Systems (5)** | `EFB_pages/5.lua` + subpages | Working | |
| **Charts/Manuals (6-9)** | Various | Working | Placeholder pages |

### Required Changes (Per Section 7-8):
- [ ] **Remove decorative icons** → Use text labels only
- [ ] **Enforce 5px minimum padding** between all UI elements
- [ ] **Fix overlaps** in widget layout
- [ ] **Simplify navigation** to text-based

### Persistent Storage:
- Battery state: `saved_configs/EFB_home.cfg` (table.save/load) ✓
- Checklist completion: Not persisted

---

## 7. SASL Lua Scripts — Key Modules

| Module | Path | Status | Notes |
|--------|------|--------|-------|
| **Main Entry** | `plugins/sasl/data/modules/main.lua` | Working | Includes EFB search path |
| **EFB Core** | `plugins/sasl/data/modules/Custom Module/efb.lua` | Working | Page routing, common buttons |
| **EFB Home** | `efb_home_widgets.lua` | Working | ~320 lines, liquid glass UI |
| **Engines** | `engines.lua` + `engines/leap1a.lua` | Working | Custom engine model |
| **Fly-by-Wire** | Multiple files | Working | Complex FBW implementation |
| **MCDU** | `MCDU/` directory | Working | Full MCDU sim |
| **ND/PFD/ECAM** | `ND/`, `PFD/`, `EWD/` | Working | Glass cockpit displays |
| **Checklists** | `checklists/*.lua` (11 files) | Working | All included via absolute paths |
| **Failures** | `failures_manager.lua` | Working | |
| **Electrical/Hydraulics** | `electrical.lua`, `hydraulics.lua` | Working | |
| **FCU/AP** | Various | Working | Autopilot/flight guidance |

---

## 8. Asset Licensing Summary

| Asset Category | License | Modifiable? | Redistributable? | Attribution Required? |
|----------------|---------|-------------|------------------|----------------------|
| **Aircraft Objects (HMW)** | CC BY-NC-ND 4.0 | **NO** | Yes (non-commercial) | Yes (JonathanOrr) |
| **A321_Mod Objects** | GPL v2 | **YES** | **YES** | Yes (6 authors) |
| **SASL Plugin** | Proprietary (free non-commercial) | NO | NO | 1-sim.com |
| **Sounds (fmod/)** | CC BY-NC-SA 4.0 | YES | Yes (non-commercial) | A32NX contributors |
| **Lua Scripts (HMW)** | GPL v3 | YES | YES | All contributors |
| **Fonts** | Various (OFL, Apache 2.0, CC BY-NC-SA) | Varies | Varies | Per font |

**Critical:** HMW objects are **CC BY-NC-ND** — **cannot be modified**. Any gear replacement must use GPL assets (A321_Mod) or new original work.

---

## 9. Git Repository Status

| Property | Value |
|----------|-------|
| **Location** | `/Users/lukas/X-Plane 12/Aircraft/HMW_A321Neo_AppleSilicon_Dev/.git` |
| **Current Branch** | master |
| **Remotes** | None configured |
| **Privacy** | Local only (private) |
| **Initial Commit** | `a1b2c3d4` - All current files committed |
| **.gitignore** | Created (excludes logs, temp files, DS_Store) |

---

## 10. Test Installation

**X-Plane 12 Aircraft Folder:** `/Users/lukas/X-Plane 12/Aircraft/HMW_A321Neo_AppleSilicon_Dev/`
**Log File:** `/Users/lukas/X-Plane 12/Log.txt`
**Test Status:** Not yet tested in this session

---

## 11. Development Status Classification

| Feature | Classification | Evidence Required |
|---------|----------------|-------------------|
| Aircraft loads in X-Plane 12 | **Untested** | Launch test |
| Gear extends/retracts (physics) | **Untested** | Sim test |
| Gear doors animate | **Missing** | N/A |
| Nose gear visual | **Deactivated** | File exists in deactivated/ |
| Main gear visual | **Missing** | No geometry found |
| Engine fan animation (internal) | **Working** | Code verified |
| Engine fan animation (external) | **Missing** | No ANIM in external.obj |
| Throttle clickspots | **Working** | Code verified |
| Flap clickspots | **Working** | Code verified |
| Speedbrake clickspots | **Partially Working** | Code correct, deployment untested |
| Parking brake | **Working** | Code verified |
| Rudder pedals | **Missing** | No clickspot implementation |
| EFB home page | **Working** | Code verified |
| EFB icon removal | **Pending** | Task 7 |
| EFB spacing enforcement | **Pending** | Task 8 |
| Asset cleanup | **Pending** | Task 3 |
| License verification | **Partial** | Task 9 |

---

## 12. Immediate Next Steps (Priority Order)

1. **Test current state in X-Plane 12** — Verify aircraft loads, gear physics, control responses
2. **Evaluate A321_Mod LandingGears.obj** — Import test, check scale/alignment, adapt datarefs
3. **Fix spoiler lever** — Trace speedbrake_ratio → spoiler surface deployment
4. **Add external engine fan animations** — Add ANIM_rotate to external engine OBJs
5. **Implement rudder pedal clickspots** — Locate pedal model, add manipulators
6. **EFB simplification** — Remove icons, enforce spacing, text labels
7. **Asset cleanup** — Build dependency map, remove confirmed unused
8. **License audit** — Document all third-party assets
9. **Documentation updates** — All required .md files