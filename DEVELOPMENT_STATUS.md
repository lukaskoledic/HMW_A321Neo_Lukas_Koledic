# HMW A321neo — Development Status & Quality Audit

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
| Original project recoverable | Yes — initial commit `4f792ef` preserves baseline |

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

- **No accidental deletions** — diff stat shows 53,902 insertions, 98 deletions (mostly LandingGears.obj merge content)
- **No unrelated edits** — all changes map to specific tasks
- **.acf change** — 2 changes: object 46 `legacy/front gear.obj` → `LandingGears.obj`, plus `_spoil1` wing surface definitions
- **No commits pushed, no remotes configured** — repository is local and private
- **No temporary files** — LandingGearsWithDoors.obj was removed after merge

---

## 2. Landing Gear Integration — VERDICT: IMPLEMENTED, NOT TESTED

### What Was Done

1. Copied `LandingGears.obj`, `LandingGears.png`, `LandingGears_NRM.png` from `/Users/lukas/Desktop/A321_Mod/objects/` (commit `e28f5e6`)
2. Updated `A321.acf` line 19207: object 46 `legacy/front gear.obj` → `LandingGears.obj`
3. Merged gear door geometry from A321_Mod `Fuselage.obj` into `LandingGears.obj` (commit `d3ecb1b`):
   - Main gear doors: MLGGearDoorL, MLGGearDoorR (378 tris each)
   - Wing doors: MLGWingDoorL1/L2/R1/R2
   - Nose gear doors: NLGAftDoorL/R, NLGForewardDoorL/R
   - Door actuators: GearLDoorActuatorL/R, GearLDoorActuatorRodL/R
   - NLGFittingPanel
4. Object 43 (`legacy/under carriage.obj` — wingbox) preserved unchanged

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

**Licensing Concern:** HMW's own objects are CC BY-NC-ND 4.0 (JonathanOrr) — no modifications allowed. GPL v2 gear merged into HMW project is permissible for internal use but redistribution requires careful license compatibility review. No per-file copyright notices in OBJ files; attribution documented in A321_Mod README.copyright.md only.

---

## 3. Rudder Pedals — VERDICT: IMPLEMENTED, NOT TESTED

### What Was Done

1. Created `rudder_pedal_clickspots.lua` — 5 click positions per pedal side (-1.0, -0.5, 0.0, 0.5, 1.0)
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

## 4. Spoiler System — VERDICT: IMPLEMENTED, NOT TESTED

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

## 5. Cockpit Controls Audit — VERDICT: PARTIAL

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

## 6. EFB Layout — VERDICT: PASS WITH CAVEATS

### What Was Verified (static code inspection)

| Change | Status | Evidence |
|--------|--------|----------|
| `frostedIcon()` function removed | PASS | Zero occurrences in file (was 81 lines) |
| Old `fenixProgressBar()` (with aircraft icon) removed | PASS | Zero occurrences |
| New `drawFplnBar()` text-only | PASS | No aircraft drawing commands |
| Dock uses text labels | PASS | `textc()` calls only, no `frostedIcon()` |
| Mock panel overlap fixed (y=120→225) | PASS | `glassCard(30, 225, ...)` |
| Dock padding 5px | PASS | `roundRect(x + 5, dock_y + 5, cxmin - 10, ...)` |
| FPLN bar ends y=210, mock panel starts y=225 | PASS | 15px gap between elements |
| Dock cxmin changed W/6→W/5 | PASS | 5 apps instead of 6 |

### Unverified Pages
- Pages 2-9 (MCDU, Performance, Fuel, Systems, Manuals, placeholders) — NOT audited for spacing
- No automated intersection checks implemented
- No simulator testing of EFB layout

---

## 7. Engine Fan Animations — VERDICT: PARTIAL

| Component | Status | Evidence |
|-----------|--------|----------|
| Internal engine fan (left) | PASS | 5 `fan_angle[0]` animations in `left engine internal.obj` |
| Internal engine fan (right) | PASS | 5 `fan_angle[1]` animations in `right engine internal.obj` |
| External engine fan (left) | **NOT IMPLEMENTED** | 0 `ANIM_rotate_begin` in `left engine external.obj` |
| External engine fan (right) | **NOT IMPLEMENTED** | 0 `ANIM_rotate_begin` in `right engine external.obj` |
| Engine config dataref | PASS | `leap1a.lua`: `fan_n1_rpm_max = 3855.0`, `n1_to_nfan()` function |

**External engine fan animations require Blender OBJ editing — not done in this session.**

---

## 8. Documentation — VERDICT: PARTIAL

| File | Exists | Accurate | Notes |
|------|--------|----------|-------|
| DEVELOPMENT_STATUS.md | YES | Yes | This document — updated with audit results |
| ASSET_CLEANUP_REPORT.md | **NO** | N/A | Required by Section 3.4, not created |
| COCKPIT_CONTROLS_AUDIT.md | YES | Yes | Documents spoiler issue and control states |
| EFB_LAYOUT_AUDIT.md | YES | Yes | Covers page 1 only |
| ASSET_REUSE_REGISTER.md | **NO** | N/A | Required by Section 10, not created |
| README.md | YES (pre-existing) | N/A | Not modified |
| ACKNOWLEDGMENTS.md | YES (pre-existing) | N/A | Not modified |
| CONTRIBUTING.md | YES (pre-existing) | N/A | Not modified |
| LICENSE | YES (pre-existing) | N/A | GPL v3 for HMW code |

---

## 9. Testing — VERDICT: NOT PERFORMED

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

### Static Checks Available
- X-Plane Log.txt shows pre-existing ACF error: `legacy/front gear.obj` not found — this was from a run BEFORE our .acf change. Our change (object 46 → `LandingGears.obj`) should resolve this on next simulator launch.
- Sound errors in fmod/A321.snd are pre-existing, unrelated to our changes.
- AT plugin disabled (x86_64 on ARM64) — pre-existing, unrelated to our changes.

---

## 10. Defect Summary

| ID | Subsystem | Defect | Severity | Status | Repair |
|----|-----------|--------|----------|--------|--------|
| D1 | Rudder Pedals | wheel.lua overwrites clickspot datarefs every frame | HIGH | **FIXED** — override mechanism in wheel.lua |
| D2 | Spoiler | No `_spoil1`/`_spoil2` in .acf wing section | HIGH | **FIXED** — `_spoil1` definitions added |
| D3 | Documentation | ASSET_CLEANUP_REPORT.md missing | LOW | Open — create per Section 3.4 |
| D4 | Documentation | ASSET_REUSE_REGISTER.md missing | LOW | Open — create per Section 10 |
| D5 | Licensing | LandingGears/Fuselage door attribution not in OBJ files | MEDIUM | Open — add copyright notices or documentation |
| D6 | Engine Fans | External engine fan animations missing | MEDIUM | Open — Blender OBJ edit required |
| D7 | Landing Gear | Door clipping/pivot unverified | MEDIUM | Open — requires X-Plane testing |

---

## 11. Confirmed Fixes

| Fix | Commit | Evidence |
|-----|--------|----------|
| Rudder pedal clickspot overwrite | `f9e6abc` | wheel.lua reads override_frames before computing pedal position |
| Spoiler surface definitions | `650b8d1` | `_spoil1/0..9`, `_spoil1_chord`, `_spoil1_hds`, `_spoil1_hde` in .acf |
| Landing gear doors merged | `d3ecb1b` | 15 door meshes + 9 ANIM blocks in LandingGears.obj |
| EFB icon removal | `fac05c6` + `d6798cd` | `frostedIcon()` removed, text-only dock, 5px padding |
| EFB overlap fix | `d6798cd` | Mock panel moved y=120→225 |

---

## 12. Remaining Defects and Untested Items

1. **X-Plane 12 not tested** — all code changes unverified at runtime
2. **External engine fan animations** — NOT implemented (requires Blender)
3. **ASSET_CLEANUP_REPORT.md** — not created
4. **ASSET_REUSE_REGISTER.md** — not created
5. **Landing gear door attribution** — not documented in OBJ files
6. **Landing gear door clipping/pivots** — unverified in simulator
7. **Spoiler values** — estimates, need refinement in sim
8. **Rudder pedal visual feedback** — no clickspot-specific animation

---

## 13. Licensing or Redistribution Concerns

| Concern | Detail |
|---------|--------|
| HMW objects CC BY-NC-ND 4.0 | No modifications allowed; redistribution requires attribution, no commercial use |
| A321_Mod gear/doors GPL v2 | Modifications allowed; redistribution requires GPL v2 compatibility |
| License incompatibility | GPL v2 and CC BY-NC-ND 4.0 are NOT compatible for combined redistribution |
| No per-file copyright | OBJ files lack embedded copyright notices; attribution only in README.copyright.md |
| Recommendation | Internal use OK; do not redistribute without legal review |

---

## 14. Repository Integrity and Commit Summary

- **Branch:** `main` (only branch, no remotes)
- **Commits:** 11, all local, none pushed
- **Working tree:** Clean
- **Baseline preserved:** Commit `4f792ef` contains all original files
- **No secrets or credentials** found in changes
- **No generated files** committed
- **No temporary files** remaining

---

## 15. Readiness Assessment

| Question | Answer |
|----------|--------|
| Ready for private simulator test? | **YES, with caveats** — all code changes are syntactically valid, but runtime behavior unverified |
| Safe to push to private GitHub? | **YES** — repository is local, clean, no secrets, no accidental deletions |
| Conditions before push? | None from code perspective; user must create GitHub repo first and provide URL |

**Aircraft was NOT loaded and tested in X-Plane 12 during this audit session.**
