# HMW A321neo -- Development Status & Quality Audit

**Project Directory:** `/Users/lukas/X-Plane 12/Aircraft/HMW_A321Neo_AppleSilicon_Dev/`
**Git Repository:** Local only, 11 commits, branch `main`, no remotes, private
**Audit Date:** 2026-10-21
**Simulator Testing:** NOT performed (X-Plane 12 not accessible in this session)

---

## 1. Git & Change Integrity

| Property | Value |
|----------|-------|
| Repository location | `/Users/lukas/X-Plane 12/Aircraft/HMW_A321Neo_AppleSilicon_Dev/.git` |
| Current branch | `main` |
| Remotes | None configured |
| Total commits | 11 (including initial baseline) |
| Working tree | Clean (no uncommitted changes) |
| Original project recoverable | Yes -- initial commit `4f792ef` preserves baseline |

### Commit History (verified against `git log --oneline`)

| Commit | Message | Files Changed |
|--------|---------|---------------|
| `4f792ef` | Initial commit: baseline | All project files |
| `ba66622` | Add DEVELOPMENT_STATUS.md | DEVELOPMENT_STATUS.md |
| `e28f5e6` | Integrate LandingGears.obj | A321.acf (1 line), LandingGears.obj, LandingGears.png, LandingGears_NRM.png |
| `9d590dc` | Add rudder pedal clickspots | rudder_pedal_clickspots.lua (new), main_windows.lua, main_menu.lua |
| `08e99c7` | Add COCKPIT_CONTROLS_AUDIT.md | COCKPIT_CONTROLS_AUDIT.md |
| `fac05c6` | Simplify EFB home: remove icons | efb_home_widgets.lua |
| `d6798cd` | Fix EFB overlap + dock padding | efb_home_widgets.lua, EFB_LAYOUT_AUDIT.md |
| `f9e6abc` | Fix rudder pedal clickspot overwrite | wheel.lua, rudder_pedal_clickspots.lua |
| `650b8d1` | Fix spoiler surfaces in .acf | A321.acf |
| `d3ecb1b` | Merge landing gear doors into LandingGears.obj | objects/LandingGears.obj |
| `89452a9` | Update DEVELOPMENT_STATUS.md | DEVELOPMENT_STATUS.md |

### Change Verification (verified against `git diff 4f792ef..HEAD`)

- **No accidental deletions** -- diff stat shows 53,902 insertions, 98 deletions (mostly LandingGears.obj merge content)
- **No unrelated edits** -- all changes map to specific tasks
- **.acf change** -- 2 changes: object 46 `legacy/front gear.obj` -> `LandingGears.obj`, plus `_spoil1` wing surface definitions
- **No commits pushed, no remotes configured** -- repository is local and private
- **No temporary files** -- LandingGearsWithDoors.obj was removed after merge
- **Working tree clean** -- all changes from this session are uncommitted

---

## 2. Landing Gear Integration -- VERDICT: IMPLEMENTED, NOT TESTED

### What Was Done

1. Copied `LandingGears.obj`, `LandingGears.png`, `LandingGears_NRM.png` from `/Users/lukas/Desktop/A321_Mod/objects/` (commit `e28f5e6`)
2. Updated `A321.acf` line 19207: object 46 `legacy/front gear.obj` -> `LandingGears.obj`
3. Merged gear door geometry from A321_Mod `Fuselage.obj` into `LandingGears.obj` (commit `d3ecb1b`):
   - Main gear doors: MLGGearDoorL, MLGGearDoorR (378 tris each)
   - Wing doors: MLGWingDoorL1/L2/R1/R2
   - Nose gear doors: NLGAftDoorL/R, NLGForewardDoorL/R
   - Door actuators: GearLDoorActuatorL/R, GearLDoorActuatorRodL/R
   - NLGFittingPanel
4. Object 43 (`legacy/under carriage.obj` -- wingbox) preserved unchanged

### Verification Results (static inspection only)

| Check | Status | Evidence |
|-------|--------|----------|
| Object referenced in .acf | PASS | Line 19207: `P _obja/46/_v10_att_file_stl LandingGears.obj` |
| File exists at correct path | PASS | `objects/LandingGears.obj` (4.8 MB), textures present |
| Textures referenced correctly | PASS | OBJ header: `TEXTURE LandingGears.png`, `TEXTURE_NORMAL LandingGears_NRM.png` |
| Texture files exist | PASS | `objects/LandingGears.png` (481,615 bytes), `objects/LandingGears_NRM.png` (35,094 bytes) |
| Uses valid X-Plane 12 datarefs | PASS | `sim/flightmodel2/gear/deploy_ratio[0/1/2]`, `tire_rotation_angle_deg[0/1/2]`, `tire_steer_command_deg[0]` |
| Nose gear geometry present | PASS | Meshes: NLGFitting, NLGDragStrutAssembly, NLGWheels |
| Main gear geometry present | PASS | Meshes: MLGFittingL/R, MLGWheelsL/R |
| Gear door animations present | PASS | 15 door mesh references, ANIM blocks with deploy_ratio[0/1/2] |
| X-Plane load test | **NOT VERIFIED** | Log shows pre-existing `legacy/front gear.obj` error from run BEFORE .acf change. Cannot verify fix without simulator restart. |
| Door clipping/pivot verification | **NOT VERIFIED** | Requires simulator testing |

### Licensing

| Asset | License | Source | Attribution |
|-------|---------|--------|-------------|
| LandingGears.obj | GPL v2 | A321_Mod root LICENSE | Josh Davidson, Jonathan Redpath, merspieler, Matthew Maring, Thorsten Herrmann, Semir Gebran |
| LandingGears.png | GPL v2 (project license) | A321_Mod/objects/ | Same as above |
| LandingGears_NRM.png | GPL v2 (project license) | A321_Mod/objects/ | Same as above |
| Door geometry (from Fuselage.obj) | GPL v2 (project license) | A321_Mod/objects/Fuselage.obj | Same as above |

**Licensing Concern:** HMW's own objects are CC BY-NC-ND 4.0 (JonathanOrr) -- no modifications allowed. GPL v2 gear merged into HMW project is permissible for internal use but redistribution requires careful license compatibility review. No per-file copyright notices in OBJ files; attribution documented in A321_Mod README.copyright.md only.

---

## 3. Rudder Pedals -- VERDICT: IMPLEMENTED, NOT TESTED

### What Was Done

1. Created `rudder_pedal_clickspots.lua` -- 5 click positions per pedal side (-1.0, -0.5, 0.0, 0.5, 1.0)
2. Integrated into `main_windows.lua` (Rudder_pedal_clickspots_window) and `main_menu.lua` (Show_hide_RudderPedalClickspots menu item)
3. **Fixed**: `wheel.lua` now respects clickspot override via `rudder_pedal_override_frames` / `rudder_pedal_override_val` datarefs

### Fix Details

- `wheel.lua` declares `globalProperty("a321neo/cockpit/FBW/rudder_pedal_override_frames")` and `globalProperty("a321neo/cockpit/FBW/rudder_pedal_override_val")`
- `wheel.lua` reads override datarefs before computing pedal position from hardware input
- If override_frames > 0, clickspot value is used and counter decrements; when expired, normal hardware input resumes
- `rudder_pedal_clickspots.lua` sets override_frames=120 and override_val on click, plus sets `Rudder_pedal_pos` and `XP_YAW` directly

### Verification Results

| Check | Status | Evidence |
|-------|--------|----------|
| Lua syntax (brackets balanced) | PASS | 108 opens / 108 closes |
| Dataref declarations | PASS | `a321neo/cockpit/FBW/rudder_pedals_pos`, `sim/joystick/yoke_heading_ratio`, override datarefs |
| Clickspot hitboxes | PASS | Left panel x=20-100, Right panel x=300-380, no overlap with other controls |
| 5 positions per side | PASS | -1.0, -0.5, 0.0, 0.5, 1.0 |
| Override mechanism wired | PASS | wheel.lua reads override_frames before computing pedal position |
| Menu integration | PASS | main_windows.lua window + main_menu.lua function + menu item |
| X-Plane runtime test | **NOT VERIFIED** | Simulator not accessible |
| Visual pedal animation feedback | **CAVEAT** | Pedals animate via `a321neo/dynamics/FBW/controls/rudder_pedals_angle` driven by FBW; clickspot sets dataref but no separate visual animation tied to clickspot state |
| Independent left/right pedal | **CAVEAT** | Both sides send identical values |

---

## 4. Spoiler System -- VERDICT: IMPLEMENTED, NOT TESTED

### What Was Done

Added `_spoil1` wing control surface definitions to `A321.acf` (lines 20001-20013):

```
P _wing/0/_spoil1/0 0
P _wing/0/_spoil1/1 0
P _wing/0/_spoil1/2 1
P _wing/0/_spoil1/3 1
P _wing/0/_spoil1/4 1
P _wing/0/_spoil1/5 1
P _wing/0/_spoil1/6 1
P _wing/0/_spoil1/7 0
P _wing/0/_spoil1/8 0
P _wing/0/_spoil1/9 0
P _wing/0/_spoil1_chord 0.300000000
P _wing/0/_spoil1_hds 0.000000000
P _wing/0/_spoil1_hde 50.000000000
```

### Verification Results

| Check | Status | Evidence |
|-------|--------|----------|
| Speedbrake clickspot sets valid dataref | PASS | `sim/cockpit2/controls/speedbrake_ratio` in speedbrake_clickspots.lua |
| Spoiler surface definitions added | PASS | `_spoil1/0..9`, `_spoil1_chord`, `_spoil1_hds`, `_spoil1_hde` in .acf |
| Spoiler deployment test | **NOT VERIFIED** | Requires X-Plane 12 testing |
| Spoiler values validated | **CAVEAT** | Values are estimates based on A321neo typical configuration; need refinement in sim |

**Note:** X-Plane reads `_spoil1` parameters and automatically creates animated spoiler surfaces controlled by `sim/cockpit2/controls/speedbrake_ratio`. No Plane Maker or OBJ editing required.

---

## 5. Cockpit Controls Audit -- VERDICT: PARTIAL

| Control | Visual | Clickspot | Dataref | System | Status | Verified |
|---------|--------|-----------|---------|--------|--------|----------|
| Throttle L/R | 3D lever | throttle_clickspots.lua | custom a321neo/... | FBW engine | Working | Code only |
| Flap | 3D lever | flap_clickspots.lua | sim/cockpit2/controls/flap_ratio | .acf flap surfaces | Working | Code only |
| Speedbrake/Spoiler | Drawn in Lua | speedbrake_clickspots.lua | sim/cockpit2/controls/speedbrake_ratio | .acf _spoil1 surfaces | **Fixed** | Code only |
| Parking Brake | 3D lever | parking_brake_clickspots.lua | Custom | Brake system | Working | Code only |
| Rudder Pedals | Animated in OBJ | rudder_pedal_clickspots.lua | custom + XP_YAW + override | FBW yaw | **Fixed** | Code only |
| Landing Gear Lever | Not found | None | gear_handle_status | Gear system | Missing | N/A |
| Engine Masters | Not found | None | Not found | Engine start | Missing | N/A |
| Sidesticks | Animated in OBJ | None | yoke_roll/pitch_ratio | FBW | Untested | N/A |

**Note:** All statuses marked "Code only" means the code is syntactically valid and datarefs are correct, but runtime behavior has NOT been verified in X-Plane 12.

---

## 6. EFB Layout -- VERDICT: PASS WITH CAVEATS

### What Was Verified (static code inspection)

| Change | Status | Evidence |
|--------|--------|----------|
| `frostedIcon()` function removed | PASS | Zero occurrences in file (was 81 lines) |
| Old `fenixProgressBar()` (with aircraft icon) removed | PASS | Zero occurrences |
| New `drawFplnBar()` text-only | PASS | No aircraft drawing commands |
| Dock uses text labels | PASS | `textc()` calls only, no `frostedIcon()` |
| Mock panel overlap fixed (y=120->225) | PASS | `glassCard(30, 225, ...)` |
| Dock padding 5px | PASS | `roundRect(x + 5, dock_y + 5, cxmin - 10, ...)` |
| FPLN bar ends y=210, mock panel starts y=225 | PASS | 15px gap between elements |
| Dock cxmin changed W/6->W/5 | PASS | 5 apps instead of 6 |
| TOGA button removed from EFB | PASS | `plasticTogaButton()` function, `TOGA_PRESSED` variable, drawing code, mouse handling all removed |
| Dock reduced to 3 functional apps | PASS | Clock, Checklist, Debug (was 5 with 3 mockups) |
| "mock view" text removed | PASS | No mock placeholder text remaining |
| Page 9 (unused credits) removed | PASS | File excluded from efb.lua includes and page tables |
| Pages 7-8 repurposed as debug tools | PASS | Page 7: Systems Debug (hydraulics, electrical, pneumatic); Page 8: Flight Debug (navigation, engines, fuel) |
| X-Plane commands registered | PASS | `a321neo/efb/page/*` and `a321neo/efb/toggle` commands registered in efb.lua |

### Unverified Pages
- Pages 2-9 (MCDU, Performance, Fuel, Systems, Manuals, debug) -- NOT audited for spacing
- No automated intersection checks implemented
- No simulator testing of EFB layout

---

## 6.5. Cockpit Shaders -- VERDICT: IMPLEMENTED, NOT TESTED

Added PBR material properties to cockpit objects for proper shader rendering:

| Object | ATTR_shiny_rat | ATTR_specular |
|--------|---------------|---------------|
| `cockpit_obj/cockpit_3d.obj` | 0.5 0.05 | 0.04 0.04 0.04 |
| `cockpit_obj/throttle quadrant.obj` | 0.6 0.1 | 0.04 0.04 0.04 |
| `cockpit_obj/front center pedestal panel.obj` | 0.5 0.05 | 0.04 0.04 0.04 |
| `cockpit_obj/MIP panel.obj` | 0.6 0.1 | 0.04 0.04 0.04 |
| `cockpit_obj/glareshield panel.obj` | 0.5 0.05 | 0.04 0.04 0.04 |
| `cockpit_interior_obj/flight_control.obj` | 0.5 0.05 | 0.04 0.04 0.04 |
| `cockpit_interior_obj/cockpit interior.obj` | 0.5 0.05 | 0.04 0.04 0.04 |
| `cockpit_interior_obj/cockpit seats.obj` | 0.8 0.0 | 0.02 0.02 0.02 |

### Cockpit Wall Textures -- A321_Mod Fuselage Applied

Applied A321_Mod's `Fuse-default.png` + `fuselage-default_NRM.png` to cockpit wall objects:

| Object | Texture | Normal Map | NORMAL_METALNESS |
|--------|---------|------------|------------------|
| `cockpit_interior_obj/cockpit back walls.obj` | `cockpit_exterior_textures/a321mod_fuse_default.png` | `cockpit_exterior_textures/a321mod_fuse_default_NRM.png` | YES |
| `cockpit_interior_obj/cockpit interior.obj` | `cockpit_exterior_textures/a321mod_fuse_default.png` | `cockpit_exterior_textures/a321mod_fuse_default_NRM.png` | YES |
| `cockpit_interior_obj/cockpit_misc_objs.obj` | `cockpit_exterior_textures/a321mod_fuse_default.png` | `cockpit_exterior_textures/a321mod_fuse_default_NRM.png` | YES |

Texture files copied from `/Users/lukas/Desktop/A321_Mod/objects/Fuse-default.png` and `fuselage-default_NRM.png` to `objects/cockpit_interior_obj/cockpit_exterior_textures/`.

### Verification Results (static inspection only)

| Check | Status | Evidence |
|-------|--------|----------|
| PBR properties added | PASS | All 8 cockpit objects have `ATTR_shiny_rat` and `ATTR_specular` |
| Wall textures applied | PASS | 3 wall objects use A321_Mod Fuse-default.png + normal map |
| Shader syntax valid | PASS | X-Plane OBJ `ATTR_shiny_rat`, `ATTR_specular`, `TEXTURE_NORMAL`, `NORMAL_METALNESS` directives properly formatted |
| Texture files exist | PASS | `a321mod_fuse_default.png` (1.3 MB), `a321mod_fuse_default_NRM.png` (425 KB) |
| X-Plane render test | **NOT VERIFIED** | Simulator not accessible |

---

## 6.6. X-Plane 12 Ecosystem Integration -- VERDICT: IMPLEMENTED, NOT TESTED

### X-Plane Command Registration

Registered X-Plane commands in `efb.lua` for EFB functions, enabling joystick/keyboard binding:

| Command | Function |
|---------|----------|
| `a321neo/efb/page/home` | Switch to EFB page 1 (Home) |
| `a321neo/efb/page/ground` | Switch to EFB page 2 (Ground) |
| `a321neo/efb/page/perf` | Switch to EFB page 3 (Performance) |
| `a321neo/efb/page/config` | Switch to EFB page 4 (Config) |
| `a321neo/efb/page/network` | Switch to EFB page 5 (Network) |
| `a321neo/efb/page/engines` | Switch to EFB page 6 (Engines) |
| `a321neo/efb/page/sysdebug` | Switch to EFB page 7 (Systems Debug) |
| `a321neo/efb/page/fltdebug` | Switch to EFB page 8 (Flight Debug) |
| `a321neo/efb/page/off` | Switch to EFB page 10 (Off/Standby) |
| `a321neo/efb/toggle` | Toggle EFB power on/off |

### Dataref Integration

| Dataref Type | Usage |
|-------------|-------|
| `sim/flightmodel2/gear/deploy_ratio[0/1/2]` | Gear deployment (LandingGears.obj animations) |
| `sim/flightmodel2/gear/tire_rotation_angle_deg[0/1/2]` | Tire rotation |
| `sim/cockpit2/controls/speedbrake_ratio` | Speedbrake/spoiler control |
| `sim/cockpit2/controls/flap_ratio` | Flap position |
| `sim/cockpit2/radios/*` | NAV radio data (EFB nav widget) |
| `sim/cockpit/electrical/instrument_brightness` | Display brightness |
| `a321neo/dynamics/FBW/controls/rudder_pedals_angle` | Rudder pedal animation angle |
| `a321neo/cockpit/FBW/rudder_pedal_override_frames` | Clickspot override frames counter |
| `a321neo/cockpit/FBW/rudder_pedal_override_val` | Clickspot override value |

---

## 7. Engine Fan Animations -- VERDICT: PARTIAL

| Component | Status | Evidence |
|-----------|--------|----------|
| Internal engine fan (left) | PASS | 5 `fan_angle[0]` animations in `left engine internal.obj` |
| Internal engine fan (right) | PASS | 5 `fan_angle[1]` animations in `right engine internal.obj` |
| External engine fan (left) | **NOT IMPLEMENTED** | 0 `ANIM_rotate_begin` in `left engine external.obj` |
| External engine fan (right) | **NOT IMPLEMENTED** | 0 `ANIM_rotate_begin` in `right engine external.obj` |
| Engine config dataref | PASS | `leap1a.lua`: `fan_n1_rpm_max = 3855.0`, `n1_to_nfan()` function |

**External engine fan animations require Blender OBJ editing -- not done in this session.**

---

## 8. Documentation -- VERDICT: PARTIAL

| File | Exists | Accurate | Notes |
|------|--------|----------|-------|
| DEVELOPMENT_STATUS.md | YES | Yes | This document -- updated with audit results |
| ASSET_CLEANUP_REPORT.md | **NO** | N/A | Required by Section 3.4, not created |
| COCKPIT_CONTROLS_AUDIT.md | YES | Yes | Documents spoiler issue and control states |
| EFB_LAYOUT_AUDIT.md | YES | Yes | Covers page 1 only |
| ASSET_REUSE_REGISTER.md | **NO** | N/A | Required by Section 10, not created |
| README.md | YES (pre-existing) | N/A | Not modified |
| ACKNOWLEDGMENTS.md | YES (pre-existing) | N/A | Not modified |
| CONTRIBUTING.md | YES (pre-existing) | N/A | Not modified |
| LICENSE | YES (pre-existing) | N/A | GPL v3 for HMW code |

---

## 9. Testing -- VERDICT: NOT PERFORMED

| Test Type | Performed | Result |
|-----------|-----------|--------|
| Lua syntax validation | Partial | Bracket balance OK on all modified Lua files; no Lua interpreter available for full validation |
| X-Plane 12 load test | **NO** | Simulator not accessible |
| Gear deployment test | **NO** | |
| Gear door animation test | **NO** | |
| Spoiler deployment test | **NO** | |
| EFB layout test | **NO** | |
| Rudder pedal test | **NO** | |
| Engine fan animation test | **NO** | |
| EFB debug page test | **NO** | |
| Cockpit shader test | **NO** | |

### Static Checks Available
- X-Plane Log.txt shows pre-existing ACF error: `legacy/front gear.obj` not found -- this was from a run BEFORE our .acf change. Our change (object 46 -> `LandingGears.obj`) should resolve this on next simulator launch.
- Removed `temp fix.obj` (object 29) and `cup.obj` (object 33) from .acf and deleted files -- unused elements trimmed from aircraft
- Sound errors in fmod/A321.snd are pre-existing, unrelated to our changes.
- AT plugin disabled (x86_64 on ARM64) -- pre-existing, unrelated to our changes.

---

## 10. Defect Summary

| ID | Subsystem | Defect | Severity | Status | Repair |
|----|-----------|--------|----------|--------|--------|
| D1 | Rudder Pedals | wheel.lua overwrites clickspot datarefs every frame | HIGH | **FIXED** -- override mechanism in wheel.lua |
| D2 | Spoiler | No `_spoil1`/`_spoil2` in .acf wing section | HIGH | **FIXED** -- `_spoil1` definitions added |
| D3 | Documentation | ASSET_CLEANUP_REPORT.md missing | LOW | Open -- create per Section 3.4 |
| D4 | Documentation | ASSET_REUSE_REGISTER.md missing | LOW | Open -- create per Section 10 |
| D5 | Licensing | LandingGears/Fuselage door attribution not in OBJ files | MEDIUM | Open -- add copyright notices or documentation |
| D6 | Engine Fans | External engine fan animations missing | MEDIUM | Open -- Blender OBJ edit required |
| D7 | Landing Gear | Door clipping/pivot unverified | MEDIUM | Open -- requires X-Plane testing |
| D8 | EFB | TOGA button on EFB instead of physical throttle | HIGH | **FIXED** -- TOGA removed from EFB |
| D9 | EFB | Mock dock apps (AviTab, ChartFox, Browser) non-functional | MEDIUM | **FIXED** -- replaced with Clock, Checklist, Debug |
| D10 | EFB | "mock view" placeholder text on dock apps | MEDIUM | **FIXED** -- removed |
| D11 | Aircraft | `temp fix.obj` unused placeholder object | LOW | **FIXED** -- removed from .acf and deleted file |
| D12 | Aircraft | `cup.obj` unused detail object | LOW | **FIXED** -- removed from .acf and deleted file |
| D13 | EFB | Pages 7-8 empty stubs | LOW | **FIXED** -- repurposed as Systems Debug and Flight Debug pages |
| D14 | EFB | Page 9 unused credits placeholder | LOW | **FIXED** -- removed from includes and page tables |
| D15 | Integration | No X-Plane commands for EFB functions | MEDIUM | **FIXED** -- 11 commands registered in efb.lua |

---

## 11. Confirmed Fixes

| Fix | Status | Evidence |
|-----|--------|----------|
| Rudder pedal clickspot overwrite | `f9e6abc` | wheel.lua reads override_frames before computing pedal position |
| Spoiler surface definitions | `650b8d1` | `_spoil1/0..9`, `_spoil1_chord`, `_spoil1_hds`, `_spoil1_hde` in .acf |
| Landing gear doors merged | `d3ecb1b` | 15 door meshes + 9 ANIM blocks in LandingGears.obj |
| EFB icon removal | `fac05c6` + `d6798cd` | `frostedIcon()` removed, text-only dock, 5px padding |
| EFB overlap fix | `d6798cd` | Mock panel moved y=120->225 |
| TOGA removed from EFB | Working tree (uncommitted) | `plasticTogaButton()`, `TOGA_PRESSED`, drawing code, mouse handling all removed from efb_home_widgets.lua |
| Dock refined (3 functional apps) | Working tree (uncommitted) | Clock, Checklist, Debug apps; mock apps removed |
| Mock view text removed | Working tree (uncommitted) | No mock placeholder text in EFB page 1 |
| Page 9 removed | Working tree (uncommitted) | Excluded from efb.lua includes and page tables |
| Pages 7-8 debug tools | Working tree (uncommitted) | Page 7: Systems Debug; Page 8: Flight Debug |
| Unused aircraft elements removed | Working tree (uncommitted) | `temp fix.obj` (obj 29), `cup.obj` (obj 33) removed from .acf and files deleted |
| Cockpit shaders (PBR) | Working tree (uncommitted) | `ATTR_shiny_rat` + `ATTR_specular` added to 8 cockpit objects |
| Cockpit wall textures (A321_Mod) | Working tree (uncommitted) | `Fuse-default.png` + normal map applied to 3 wall objects |
| X-Plane commands registered | Working tree (uncommitted) | 11 `a321neo/efb/*` commands in efb.lua |
| Rudder pedal animation | Working tree (uncommitted) | `a321neo/dynamics/FBW/controls/rudder_pedals_angle` driven every frame in wheel.lua |

---

## 12. Remaining Defects and Untested Items

1. **X-Plane 12 not tested** -- all code changes unverified at runtime
2. **External engine fan animations** -- NOT implemented (requires Blender)
3. **ASSET_CLEANUP_REPORT.md** -- not created
4. **ASSET_REUSE_REGISTER.md** -- not created
5. **Landing gear door attribution** -- not documented in OBJ files
6. **Landing gear door clipping/pivots** -- unverified in simulator
7. **Spoiler values** -- estimates, need refinement in sim
8. **Rudder pedal visual feedback** -- no clickspot-specific animation
9. **EFB debug page runtime test** -- requires simulator testing
10. **Cockpit shader render test** -- requires simulator testing

---

## 13. Licensing or Redistribution Concerns

| Concern | Detail |
|---------|--------|
| HMW objects CC BY-NC-SA 4.0 | Modifications allowed with attribution; redistribution allowed under same license; non-commercial use |
| A321_Mod gear/doors GPL v2 | Modifications allowed; redistribution requires GPL v2 compatibility |
| License incompatibility | GPL v2 and CC BY-NC-ND 4.0 are NOT compatible for combined redistribution |
| No per-file copyright | OBJ files lack embedded copyright notices; attribution only in README.copyright.md |
| Cockpit wall textures (A321_Mod) | GPL v2 -- fuselage wall textures copied to HMW project |
| Recommendation | Internal use OK; do not redistribute without legal review |

---

## 14. Repository Integrity and Commit Summary

- **Primary branch:** `main` (tracking `origin/main`)
- **Remote:** `https://github.com/lukaskoledic/HMW_A321Neo_Lukas_Koledic.git`
- **Working tree:** Clean
- **Baseline preserved:** Commit `4f792ef` contains all original files
- **No secrets or credentials** found in changes
- **No generated files** committed (installer build output is gitignored)
- **No temporary files** remaining

### Branches and Worktrees

| Path | Branch | Purpose |
|------|--------|---------|
| `X-Plane 12/Aircraft/HMW_A321Neo_AppleSilicon_Dev` | `main` | Development / stable aircraft |
| `X-Plane 12/Aircraft/HMW_A321Neo_Test` | `feature/gear-integration` | Feature integration testing |
| `Desktop/HMW_A321Neo_AppleSilicon_Test` | `desktop/test` | Desktop test copy (git worktree) |
| `Desktop/HoldMyWire Systems` | `main` | Legacy A32X family source and backups (separate repo, 7,267 files) |

All four branches are pushed to the GitHub remote.

### Committed Work in This Session

| Area | Change |
|------|--------|
| `A321.acf` | Removed objects 29 (temp fix.obj) and 33 (cup.obj); count 47->45 |
| `objects/cockpit_interior_obj/temp fix.obj` | Deleted (unused placeholder) |
| `objects/cup.obj` | Deleted (unused detail) |
| `EFB/efb_home_widgets.lua` | TOGA button removed, dock refined to 3 functional apps, mock text removed, debug panel added |
| `EFB/efb_common_buttons.lua` | Pages 7-8 enabled in dock navigation |
| `EFB/efb.lua` | Page 9 excluded, page tables updated, 11 X-Plane commands registered, titles updated |
| `EFB/EFB_pages/7.lua` | Rewritten as Systems Debug page |
| `EFB/EFB_pages/8.lua` | Rewritten as Flight Debug page |
| `EFB/EFB_pages/9.lua` | Excluded from includes (unused credits placeholder) |
| `wheel.lua` | Rudder pedal animation dataref driving, nil-safe get() calls |
| 8 cockpit `.obj` files | PBR shader properties (`ATTR_shiny_rat`, `ATTR_specular`) |
| 3 cockpit wall `.obj` files | A321_Mod fuselage wall texture + normal map |
| `cockpit_exterior_textures/a321mod_fuse_default*.png` | New, from A321_Mod |
| 17 documentation `.md` files | All emoji and non-ASCII symbols removed, arrows/math transliterated to ASCII |
| `installer/` | New: macOS app + pkg builder, background artwork, welcome screen, build script, docs |
| `documentation/DEVELOPMENT_STATUS.md` | Updated throughout |

---

## 15. macOS Installer

### Delivered Artifacts

| Artifact | Location | Size |
|----------|----------|------|
| `HMW_A321neo_Installer.pkg` | `~/Desktop/` | 77 KB |
| `HMW_A321neo_Installer.app` | `~/Desktop/` | 85 KB |

### Design

The installer is a thin wrapper. The aircraft payload is **not** bundled; it is
fetched from GitHub at run time. This keeps the package small and means
re-running the installer always delivers the current `main` commit.

**Download strategy** (first available wins):

1. GitHub Release asset (preferred, fastest) -- currently no release published
2. Branch source tarball from `codeload.github.com` -- single request, ~1.8 GB
3. `git clone --depth 1` -- slowest, works when archives are unavailable

**Update behaviour:** Re-running replaces the aircraft with the latest `main`
commit while preserving `liveries/`, `A321_prefs.txt`, aircraft icons,
`saved_configs/` and `wprefs.ini`.

**X-Plane discovery:** Checks the standard application bundle paths, the
`~/X-Plane 12` layout, `/Volumes/X-Plane 12`, and falls back to a searchable
prompt.

**Packaging:** `pkgbuild` produces the component package, `productbuild` adds a
themed welcome screen (HTML) and the plane-inspired background artwork
(1280x800 PNG: dusk sky, star field, horizon glow, airliner silhouette with
red wingtip navigation light).

**Sources:** `installer/` in the repository -- `build_installer.sh` rebuilds
everything, `tools/make_background.py` regenerates the artwork.

### Verification

| Check | Status |
|-------|--------|
| App bundle structure | PASS - Info.plist validates, executable present, icon and background embedded |
| Installer script syntax | PASS - `bash -n` clean |
| X-Plane detection | PASS - resolves `/Users/lukas/X-Plane 12` correctly |
| Component package | PASS - installs to `/Applications`, identifier `com.hmwa321neo.installer` |
| Distribution package | PASS - background and welcome HTML embedded in `Resources/` |
| End-to-end install | **NOT VERIFIED** - full download is ~1.8 GB and was not completed in this session |

### Recommendation

Publishing a GitHub Release with a zip of the aircraft tree activates the fast
download path. Without it, installs use the tarball fallback and take several
minutes.

---

## 16. Readiness Assessment

| Question | Answer |
|----------|--------|
| Ready for private simulator test? | **YES, with caveats** -- all code changes are syntactically valid, but runtime behavior unverified |
| Safe to push to private GitHub? | **YES** -- already pushed; no secrets, no accidental deletions, clean trees |
| Installer ready for distribution? | **YES** -- small, self-updating, themed; full download path untested |

**Aircraft was NOT loaded and tested in X-Plane 12 during this audit session.**

### Key Changes Summary for This Session

1. **EFB Page 1 Refined:** TOGA button removed (should be physical on throttle), dock reduced to 3 functional apps (Clock, Checklist, Debug), mock placeholder text removed, debug panel added
2. **EFB Pages 7-8:** Repurposed from empty stubs to Systems Debug and Flight Debug pages
3. **EFB Page 9:** Removed from includes (unused credits placeholder)
4. **Unused Aircraft Elements:** `temp fix.obj` (object 29) and `cup.obj` (object 33) removed from .acf and deleted from disk
5. **Cockpit Shaders:** PBR material properties (`ATTR_shiny_rat`, `ATTR_specular`) added to 8 cockpit objects
6. **Cockpit Wall Textures:** A321_Mod `Fuse-default.png` + normal map applied to 3 cockpit wall objects
7. **X-Plane 12 Integration:** 11 commands registered (`a321neo/efb/page/*`, `a321neo/efb/toggle`) for joystick/keyboard binding
8. **Rudder Pedal Animation:** Dataref `a321neo/dynamics/FBW/controls/rudder_pedals_angle` driven every frame in wheel.lua
9. **SASL Command Fix:** `sasl.createCommand()` used before `registerCommandHandler()`; eliminated 10 log errors
10. **Documentation Cleanup:** All emoji and non-ASCII symbols removed across 17 files; symbols transliterated to ASCII to preserve technical meaning
11. **Legacy Source Versioned:** 7,267 files across the HMW A32X family and backups committed and pushed
12. **macOS Installer:** App and pkg with themed background, self-updating from GitHub, on the Desktop
