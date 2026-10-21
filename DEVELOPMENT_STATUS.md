# HMW A321neo — Development Status & Quality Audit

**Project Directory:** `/Users/lukas/X-Plane 12/Aircraft/HMW_A321Neo_AppleSilicon_Dev/`
**Git Repository:** Local only, 7 commits, branch `main`, no remotes, private
**Audit Date:** 2026-10-21
**Simulator Testing:** NOT performed (X-Plane 12 not accessible in this session)

---

## 1. Git & Change Integrity

| Property | Value |
|----------|-------|
| Repository location | `/Users/lukas/X-Plane 12/Aircraft/HMW_A321Neo_AppleSilicon_Dev/.git` |
| Current branch | `main` |
| Remotes | None configured |
| Total commits | 7 (including initial baseline) |
| Working tree | Clean (no uncommitted changes) |
| Original project recoverable | Yes — initial commit `4f792ef` preserves baseline |

### Commit History

| Commit | Message | Files Changed |
|--------|---------|---------------|
| `4f792ef` | Initial commit: baseline | All project files |
| `ba66622` | Add DEVELOPMENT_STATUS.md | DEVELOPMENT_STATUS.md |
| `e28f5e6` | Integrate LandingGears.obj | A321.acf (1 line), LandingGears.obj, LandingGears.png, LandingGears_NRM.png |
| `9d590dc` | Add rudder pedal clickspots | rudder_pedal_clickspots.lua (new), main_windows.lua, main_menu.lua |
| `08e99c7` | Add COCKPIT_CONTROLS_AUDIT.md | COCKPIT_CONTROLS_AUDIT.md |
| `fac05c6` | Simplify EFB home: remove icons | efb_home_widgets.lua |
| `d6798cd` | Fix EFB overlap + dock padding | efb_home_widgets.lua, EFB_LAYOUT_AUDIT.md |

### Change Verification

- **No accidental deletions** — diff stat shows 52,470 insertions, 97 deletions (mostly LandingGears.obj content)
- **No unrelated edits** — all changes map to specific tasks
- **.acf change** — exactly 1 line: object 46 `legacy/front gear.obj` → `LandingGears.obj`
- **No commits pushed, no remotes configured** — repository is local and private

---

## 2. Landing Gear Integration — VERDICT: PARTIAL / DEFECTS FOUND

### What Was Done
- Copied `LandingGears.obj`, `LandingGears.png`, `LandingGears_NRM.png` from `/Users/lukas/Desktop/A321_Mod/objects/`
- Updated `A321.acf` line 19207: object 46 `legacy/front gear.obj` → `LandingGears.obj`
- Object 43 (`legacy/under carriage.obj` — wingbox) preserved unchanged

### Verification Results

| Check | Result | Evidence |
|-------|--------|----------|
| Object referenced in .acf | PASS | Line 19207: `P _obja/46/_v10_att_file_stl LandingGears.obj` |
| File exists at correct path | PASS | `objects/LandingGears.obj` (4.8 MB), textures present |
| Textures referenced correctly | PASS | OBJ header: `TEXTURE LandingGears.png`, `TEXTURE_NORMAL LandingGears_NRM.png` |
| Uses valid X-Plane 12 datarefs | PASS | `sim/flightmodel2/gear/deploy_ratio[0/1/2]`, `tire_rotation_angle_deg[0/1/2]`, `tire_steer_command_deg[0]` |
| Nose gear geometry present | PASS | Meshes: NLGFitting, NLGDragStrutAssembly, NLGWheels, etc. |
| Main gear geometry present | PASS | Meshes: MLGFittingL/R, MLGWheelsL/R, etc. |
| **Gear door animations** | **FAIL** | Zero references to "door" in LandingGears.obj. Assessment was incorrect — no door animations exist. |
| **X-Plane load test** | **NOT VERIFIED** | Log shows ACF error about `legacy/front gear.obj` (pre-existing, from session before .acf change). Cannot verify fix without simulator restart. |

### Licensing

| Asset | License | Source | Attribution |
|-------|---------|--------|-------------|
| LandingGears.obj | GPL v2 | A321_Mod root LICENSE | Josh Davidson, Jonathan Redpath, merspieler, Matthew Maring, Thorsten Herrmann, Semir Gebran |
| LandingGears.png | GPL v2 (assumed) | A321_Mod/objects/ | Same as above |
| LandingGears_NRM.png | GPL v2 (assumed) | A321_Mod/objects/ | Same as above |

**Licensing Uncertainty:** The A321_Mod LICENSE file is GPL v2 but does not specifically mention LandingGears.obj or its textures. No per-file copyright notices found in the OBJ. GPL v2 covers all files in the project by default, but individual asset attribution is not documented. HMW's own objects are CC BY-NC-ND 4.0 (JonathanOrr) — different license family. Mixing GPL v2 gear with CC BY-NC-ND aircraft is legally permissible for internal use but redistribution requires careful review.

### Recommended Repair
1. **Gear doors missing**: LandingGears.obj has no door animations. Need separate door geometry or confirm doors are not needed.
2. **X-Plane verification**: Restart X-Plane and confirm `LandingGears.obj` loads without errors (replacing the pre-existing `legacy/front gear.obj` error).

---

## 3. Rudder Pedals — VERDICT: FAIL (FUNCTIONAL DEFECT)

### What Was Done
- Created `rudder_pedal_clickspots.lua` — 5 click positions per pedal side
- Integrated into `main_windows.lua` (Rudder_pedal_clickspots_window) and `main_menu.lua` (Show_hide_RudderPedalClickspots menu item)

### Defects Found

| Defect | Severity | Evidence |
|--------|----------|----------|
| **Clickspot settings overwritten every frame** | HIGH | `wheel.lua:289-300` reads `XP_YAW` and writes `Rudder_pedal_pos` every frame, overwriting clickspot values. Clickspot has no lasting effect on rudder control. |
| No visual pedal movement feedback | MEDIUM | Clickspots set datarefs but no visual animation tied to clickspot input (pedals animate via `a321neo/dynamics/FBW/controls/rudder_pedals_angle` driven by FBW system, not clickspots). |
| Left and right pedals use same 5 positions | LOW | Both sides send identical values; no independent left/right pedal differentiation. |

### Code Verification
- Lua syntax: brackets balanced (98 opens / 98 closes)
- Datarefs verified: `a321neo/cockpit/FBW/rudder_pedals_pos` (defined in cockpit_datarefs.lua:40), `sim/joystick/yoke_heading_ratio` (defined in dynamic_datarefs.lua:564)
- Clickspot hitboxes: Left panel x=20-100, Right panel x=300-380, no overlap with other controls
- 5 positions per side: -1.0, -0.5, 0.0, 0.5, 1.0

### Recommended Repair
1. Modify `wheel.lua` to not overwrite clickspot-set values, or use a separate dataref for clickspot rudder input that the FBW system reads as override.
2. Add visual feedback (pedal animation) tied to clickspot state.

---

## 4. Cockpit Controls Audit — VERDICT: PARTIAL

### Document Status
- `COCKPIT_CONTROLS_AUDIT.md` exists and accurately documents known state
- Spoiler lever correctly identified as BROKEN

### Spoiler Investigation — Detailed

| Check | Result |
|-------|--------|
| `_speedbrake_ext_time`, `_speedbrake_ret_time`, `_speedbrake_size` in .acf | Present (lines 55323-55325) |
| `_spoil1` / `_spoil2` wing control surface definitions | **NOT FOUND** — searched entire .acf, no spoiler surface definitions |
| Spoiler geometry in wing objects | Not found |
| Speedbrake clickspot sets valid dataref | Yes — `sim/cockpit2/controls/speedbrake_ratio` |
| Simulated spoiler deployment | **Will not work** — no spoiler surfaces defined in .acf |

### Root Cause
The `.acf` defines global speedbrake timing but no spoiler control surfaces on the wing. In X-Plane, spoilers require `_spoil1`/`_spoil2` parameters in the wing section defining span stations, chord fraction, hinge deflections, etc.

### Repair Path
1. Add spoiler surface definitions to `_wing/0/` section in `A321.acf`
2. **Requires Plane Maker or careful manual .acf edit** — do not blindly invent fields
3. Test in X-Plane 12 to verify spoiler deployment

### Other Controls

| Control | Visual | Clickspot | Dataref | System | Status |
|---------|--------|-----------|---------|--------|--------|
| Throttle L/R | 3D lever | throttle_clickspots.lua | custom a321neo/... | FBW engine | Working (code verified) |
| Flap | 3D lever | flap_clickspots.lua | sim/cockpit2/controls/flap_ratio | .acf flap surfaces | Working (code verified) |
| Speedbrake/Spoiler | Drawn in Lua | speedbrake_clickspots.lua | sim/cockpit2/controls/speedbrake_ratio | **None** | **Broken** |
| Parking Brake | 3D lever | parking_brake_clickspots.lua | Custom | Brake system | Working (code verified) |
| Rudder Pedals | Animated in OBJ | rudder_pedal_clickspots.lua | custom + XP_YAW | FBW yaw | **Not functional** (overwritten) |
| Landing Gear Lever | Not found | None | gear_handle_status | Gear system | Missing |
| Engine Masters | Not found | None | Not found | Engine start | Missing |
| Sidesticks | Animated in OBJ | None | yoke_roll/pitch_ratio | FBW | Untested |

---

## 5. EFB Layout — VERDICT: PASS WITH CAVEATS

### What Was Verified

| Change | Status | Evidence |
|--------|--------|----------|
| `frostedIcon()` function removed | PASS | Zero occurrences in file |
| Old `fenixProgressBar()` (with aircraft icon) removed | PASS | Zero occurrences |
| New `drawFplnBar()` text-only | PASS | Line 730, no aircraft drawing commands |
| Dock uses text labels | PASS | Lines 792-802, `textc()` calls only |
| Mock panel overlap fixed (y=120→225) | PASS | Line 784: `glassCard(30, 225, ...)` |
| Dock padding 5px | PASS | Line 801: `roundRect(x + 5, dock_y + 5, cxmin - 10, ...)` |
| FPLN bar ends y=210, mock panel starts y=225 | PASS | 15px gap between elements |

### Unverified Pages
- Pages 2-9 (MCDU, Performance, Fuel, Systems, Manuals, placeholders) — NOT audited for spacing
- No automated intersection checks implemented
- No simulator testing of EFB layout

### Caveat
Only page 1 (Home) was modified and audited. All other EFB pages remain unverified for the 5px spacing requirement.

---

## 6. Engine Fan Animations — VERDICT: NOT IMPLEMENTED

### Status
- **Internal engine fans**: Animated via `a321neo/dynamics/engines/fan_angle[0/1]` in `left/right engine internal.obj` (5 animations each) — **WORKING**
- **External engine fans**: NO animations in `left/right engine external.obj` — **NOT IMPLEMENTED**

### Why Not Implemented
Manual OBJ editing of external engine fan animations is high-risk without Blender. The external engine objects (1.6 MB each, 16,758 vertices) have no existing ANIM definitions for fan blades. Adding animations requires identifying the fan blade mesh indices and wrapping them with ANIM_rotate_begin/end — this requires Blender or a similar 3D tool.

### Dataref Available
- `a321neo/dynamics/engines/fan_angle[0/1]` — custom SASL dataref, already used by internal fans
- `leap1a.lua` has `fan_n1_rpm_max = 3855.0` and `n1_to_nfan()` function

### Recommended Repair
Use Blender to add fan blade rotation animations to external engine OBJs, referencing `a321neo/dynamics/engines/fan_angle[0/1]`.

---

## 7. Documentation — VERDICT: PARTIAL

| File | Exists | Accurate | Notes |
|------|--------|----------|-------|
| DEVELOPMENT_STATUS.md | YES | Partial | Needs update with audit findings (this document) |
| ASSET_CLEANUP_REPORT.md | **NO** | N/A | Required by Section 3.4, not created |
| COCKPIT_CONTROLS_AUDIT.md | YES | Yes | Accurately documents spoiler issue |
| EFB_LAYOUT_AUDIT.md | YES | Yes | Covers page 1 only |
| ASSET_REUSE_REGISTER.md | **NO** | N/A | Required by Section 10, not created |
| README.md | YES (pre-existing) | N/A | Not modified |
| ACKNOWLEDGMENTS.md | YES (pre-existing) | N/A | Not modified |
| CONTRIBUTING.md | YES (pre-existing) | N/A | Not modified |
| LICENSE | YES (pre-existing) | N/A | GPL v3 for HMW code |

### Missing Attribution
- LandingGears.obj/textures from A321_Mod: no per-file copyright notice in OBJ, GPL v2 license applies by project but individual attribution not documented
- A321_Mod copyright holders: Josh Davidson, Jonathan Redpath, merspieler, Matthew Maring, Thorsten Herrmann, Semir Gebran

---

## 8. Testing — VERDICT: NOT PERFORMED

| Test Type | Performed | Result |
|-----------|-----------|--------|
| Lua syntax validation | Partial | Bracket balance OK, no Lua interpreter available |
| X-Plane 12 load test | **NO** | Simulator not accessible |
| Gear deployment test | **NO** | |
| Spoiler deployment test | **NO** | |
| EFB layout test | **NO** | |
| Rudder pedal test | **NO** | |
| Engine fan animation test | **NO** | |

### Static Checks Available
- X-Plane Log.txt shows pre-existing ACF error: `legacy/front gear.obj` not found (file is in `deactivated/` subfolder)
- Our .acf change should resolve this, but unverified
- Sound errors in fmod/A321.snd are pre-existing, unrelated to our changes

---

## 9. Defect Summary

| ID | Subsystem | Defect | Severity | Repair |
|----|-----------|--------|----------|--------|
| D1 | Landing Gear | No gear door animations in LandingGears.obj | MEDIUM | Add door geometry/animations or document as missing |
| D2 | Rudder Pedals | wheel.lua overwrites clickspot datarefs every frame | HIGH | Modify wheel.lua or use override dataref |
| D3 | Spoiler | No `_spoil1`/`_spoil2` in .acf wing section | HIGH | Add spoiler surface definitions (Plane Maker recommended) |
| D4 | Documentation | ASSET_CLEANUP_REPORT.md missing | LOW | Create per Section 3.4 |
| D5 | Documentation | ASSET_REUSE_REGISTER.md missing | LOW | Create per Section 10 |
| D6 | Licensing | LandingGears asset attribution not documented | MEDIUM | Add copyright notices to OBJ or documentation |
| D7 | Engine Fans | External engine fan animations missing | MEDIUM | Blender OBJ edit required |

---

## 10. Regressions & Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| LandingGears.obj scale/position mismatch with HMW .acf gear positions | MEDIUM | HIGH | Verify in X-Plane; adjust OBJ or .acf gear offsets |
| Mixing GPL v2 gear with CC BY-NC-ND aircraft | LOW | MEDIUM | Internal use OK; redistribution requires legal review |
| Rudder clickspots non-functional | HIGH | MEDIUM | Fix wheel.lua integration |
| .acf change breaks aircraft load | LOW | HIGH | Revert .acf line 19207 if X-Plane fails to load |

---

## 11. Remaining Work

1. **Fix spoiler system** — Add `_spoil1`/`_spoil2` to .acf wing section (Plane Maker recommended)
2. **Fix rudder pedals** — Prevent wheel.lua from overwriting clickspot values
3. **Add gear doors** — Source or create door geometry with animations
4. **External engine fan animations** — Blender OBJ edit
5. **Asset cleanup** — Create ASSET_CLEANUP_REPORT.md, identify unused assets
6. **License audit** — Document LandingGears attribution, create ASSET_REUSE_REGISTER.md
7. **X-Plane testing** — Load aircraft, verify all changes work in simulator
8. **Documentation updates** — Update README, ACKNOWLEDGMENTS, CONTRIBUTING as needed

---

## 12. Final Recommendation

**NOT SAFE for internal development testing** without the following fixes:

1. **Critical**: Verify .acf change loads LandingGears.obj correctly in X-Plane (revert if load fails)
2. **High**: Fix rudder pedal clickspots being overwritten by wheel.lua
3. **High**: Fix spoiler system (no spoiler surfaces in .acf)

The EFB simplification (icon removal, text labels, overlap fix) is safe and correctly implemented. The LandingGears.obj integration is structurally correct but unverified in simulator and missing door animations.

**Aircraft was NOT loaded and tested in X-Plane 12 during this audit session.**
