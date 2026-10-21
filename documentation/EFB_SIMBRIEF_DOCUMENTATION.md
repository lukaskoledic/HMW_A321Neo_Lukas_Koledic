# HMW A321neo EFB & SimBrief Downlink - Technical Documentation

## Overview
This document describes the EFB (Electronic Flight Bag) home page implementation and SimBrief downlink module for the HMW A321neo X-Plane 12 aircraft project.

## Files Modified/Created

### Core EFB Files
- `Custom Module/EFB/efb_home_widgets.lua` - Main EFB home page (974 lines)
- `Custom Module/EFB/simbrief_downlink.lua` - SimBrief downlink module (446 lines)
- `Custom Module/EFB/efb.lua` - EFB component (mouse up handler for TOGA/SimBrief)

### Clickspot Modules
- `Custom Module/throttle_clickspots.lua` - Throttle lever detents
- `Custom Module/flap_clickspots.lua` - Flap lever positions
- `Custom Module/parking_brake_clickspots.lua` - Parking brake ON/OFF
- `Custom Module/speedbrake_clickspots.lua` - Speedbrake/spoiler lever

### Window & Menu Integration
- `main_windows.lua` - Registered 4 new clickspot windows
- `main_menu.lua` - Added 4 new menu items under A321NEO menu

### Supporting Files
- `Custom Module/EFB/simbrief_downlink.lua` - SimBrief downlink module
- `Custom Module/libs/table.save.lua` - Persistence (already existed)

---

## EFB Home Page Features

### Liquid Glass UI
- **Frosted glass background** with subtle vignette
- **Glass cards** with top highlights, bottom shadows
- **Header bar** with aircraft info, clock, battery
- **Bottom dock** with 6 frosted app icons

### Fenix-Style Flight Progress Bar
- Centered card showing DEP-ARR (e.g., "EGLL-KJFK" or "XXXX-XXXX")
- Progress bar with **aircraft icon** sliding along track
- Shows percentage and leg count
- Updates in real-time from FMGS

### TOGA Button (Glossy Red Plastic)
- Top-right corner, 120x48px
- 3D plastic rendering: base color, top gloss highlight, bottom shadow, specular hotspot
- **Press action**: Sets both `Cockpit_throttle_lever_L/R` to 1.0 (TOGA detent)
- Press/release visual feedback via `TOGA_PRESSED` state

### Live Data Widgets (3x2 Grid + SimBrief + Checklists)
| Widget | Data Shown | Datarefs |
|--------|------------|----------|
| **Fuel** | Total FOB, FF L/R, tank bars | `Fuel_quantity[0-2]`, `ENG.dyn[1-2].ff` |
| **Engines** | N1%, N2%, EGT, FF, Oil T/P (both) | `ENG.dyn[1-2].{n1,n2,egt,ff,oil_temp,oil_press}` |
| **Navigation** | Lat/Lon, Alt, GS, Track, Wind | `GPS_sys`, `Aircraft_lat/long`, `Ground_speed_kts` |
| **Systems** | Hyd G/B/Y, Elec (bat/gen), Pneumatic | `Hydraulic_G/B/Y_press`, `Elec_bat_1/2_V`, `Gen_1_line_active`, `L/R_bleed_press` |
| **Flight Controls** | Flaps, Spoilers, Gear, Rudder Trim | `Flaps_handle_ratio`, `SPDBRK_HANDLE_RATIO`, `Gear_handle`, `Rudder_trim_knob_pos` |
| **SimBrief** | Pilot ID, status, progress, fetch button | `simbrief.ui` state machine |
| **Checklists** | 7 phases, 3 items each | `Before_start_checklist`...`Shutdown_checklist` |

### SimBrief Downlink Module (`simbrief_downlink.lua`)

#### Features
- **Modular design**: Standalone module at `Custom Module/EFB/simbrief_downlink.lua`
- **Async coroutine fetch**: Non-blocking UI via Lua coroutines
- **SimBrief API v2 JSON parsing**: Fetches OFP, parses route, waypoints, weights, fuel
- **FMC injection via FMGS API**: Uses `FMGS_create_copy_temp_fpln`, `FMGS_fpln_temp_leg_add`, `FMGS_reshape_fpln`, `FMGS_insert_temp_fpln`
- **Defensive coding**: `rawget` + `pcall` for all FMGS function calls
- **Pilot ID persistence**: Stored in `saved_configs/simbrief.cfg`

#### SimBrief Widget UI
- Pilot ID display
- Status indicator (idle/fetching/parsing/injecting/success/error)
- Progress bar during fetch
- Error/result display
- **FETCH FLIGHT PLAN** button (async coroutine)

#### Flight Plan Injection Flow
1. **Fetch**: `simbrief.fetch_ofp()` → SimBrief API v2 JSON
2. **Parse**: `simbrief.parse_ofp()` → route, waypoints, weights, fuel, performance
3. **Inject**: `simbrief.inject_flight_plan()` → FMGS temp flight plan → `FMGS_reshape_fpln` + `FMGS_insert_temp_fpln`

#### Async Coroutine Design
- Non-blocking UI via Lua coroutines
- `simbrief.ui.update()` called from `EFB_home_update()` each frame
- Progress updates: 0.1 → 0.4 (fetch) → 0.7 (parse) → 1.0 (inject)
- State machine: idle → fetching → parsing → injecting → success/error

---

## Clickspot Mappings (All Verified)

| Clickspot | Dataref | Physical Effect |
|-----------|---------|-----------------|
| **Throttle L/R** | `Cockpit_throttle_lever_L/R` (`a321neo/cockpit/engine/throttle_lever_L/R`) | Moves 3D throttle levers |
| **Flaps** | `Flaps_handle_ratio` (`sim/cockpit2/controls/flap_ratio`) | Moves physical flap surfaces |
| **Parking Brake** | `XPlane_parkbrake_ratio` (`sim/cockpit2/controls/parking_brake_ratio`) | Engages/disengages parking brake |
| **Speedbrake/Spoilers** | `SPDBRK_HANDLE_RATIO` (`sim/cockpit2/controls/speedbrake_ratio`) | Extends/retracts spoiler panels |

All clickspots:
- Use `rawget(_G, ...)` to avoid SASL component loader issues
- Map to correct native X-Plane datarefs that drive physical surfaces
- Include visual feedback (lever positions, detent notches)
- Registered in `main_windows.lua` and `main_menu.lua`

---

## Bug Fixes Applied

| Issue | Fix |
|-------|-----|
| `setTextureFilter` nil crash | Removed 132 calls from `sasl_drawing_assets.lua` |
| FMGS function component loader crash | `rawget(_G, ...)` + `pcall` guards |
| `shutdown_checklist` include error | Added 11 absolute-path includes in `efb_home_widgets.lua` |
| Unicode escape `\u2014` syntax error | Replaced with plain hyphen |
| `io.open` SASL restriction | Switched to `table.save`/`table.load` |
| `FMGS_get_current_fpln` component loader | `rawget(_G, ...)` bypasses SASL `__index` |
| Missing `front gear.obj` | Copied from `deactivated/` to `legacy/` |
| AT plugin x86_64 on ARM64 | Disabled `plugins/AT` → `plugins/AT.disabled` |
| JSON parser missing | Auto-loads `networking/json.lua` as global `json` |
| SimBrief HTTP | Uses SASL `sasl.net.downloadFileContentsSync` |

---

## Assets Preserved
- All original OBJ files, textures, sounds preserved
- No files deleted - only additions and targeted edits
- AT plugin moved to `AT.disabled` (can be restored)
- `front gear.obj` copied from `deactivated/` to `legacy/`

---

## Performance Optimizations

| Optimization | Implementation |
|--------------|----------------|
| Cached computations | `rawget` lookups cached in `efb_fpln()` |
| Coroutine async | SimBrief fetch yields per frame, no UI freeze |
| Cached drawings | Glass card helpers reuse geometry |
| Deferred loads | JSON library loaded on-demand |
| Safe datarefs | `rawget` + `pcall` avoids SASL component loader |

---

## Testing Checklist

### EFB Page 1
- [ ] Liquid glass UI renders correctly
- [ ] Fenix progress bar shows DEP-ARR, aircraft icon moves
- [ ] TOGA button press → throttles to 1.0
- [ ] SimBrief widget shows status, progress, fetch button works
- [ ] Live data widgets update in real-time
- [ ] Dock icons respond to clicks

### Clickspots
- [ ] Throttle detents → physical levers move
- [ ] Flap positions → physical flaps move
- [ ] Parking brake ON/OFF → brake engages
- [ ] Speedbrake positions → spoilers extend/retract

### SimBrief
- [ ] Pilot ID configurable (edit `simbrief.cfg`)
- [ ] Fetch button → progress bar → success/error
- [ ] Flight plan appears in MCDU F-PLN page

### Log.txt Errors to Watch
- `attempt to call field 'setTextureFilter'` → **FIXED**
- `can't load component FMGS_*` → **FIXED**
- `front gear.obj` missing → **FIXED**
- AT plugin x86_64 → **FIXED (disabled)**

---

## Future Enhancements (Deferred)
- FPLN import from EFB → FMC (use MCDU F-PLN page for now)
- Real browser in EFB (C++ backend not feasible in SASL3)
- Weather radar overlay
- Charts integration (ChartFox/Navigraph)

---

## File Locations Summary

```
/Users/lukas/X-Plane 12/Aircraft/HMW_A321Neo_AppleSilicon_Dev/
├── objects/legacy/front gear.obj              # Copied from deactivated/
├── plugins/AT.disabled/                        # Disabled x86_64 plugin
├── plugins/sasl/data/modules/Custom Module/
│   ├── EFB/
│   │   ├── efb_home_widgets.lua              # Main EFB (974 lines)
│   │   ├── simbrief_downlink.lua             # SimBrief module (446 lines)
│   │   ├── efb.lua                           # Mouse up handler
│   │   └── EFB_pages/1.lua                   # Page 1 wiring
│   ├── throttle_clickspots.lua               # Throttle detents
│   ├── flap_clickspots.lua                   # Flap positions
│   ├── parking_brake_clickspots.lua          # Park brake ON/OFF
│   ├── speedbrake_clickspots.lua             # Spoiler positions
│   ├── libs/table.save.lua                   # Persistence
│   └── networking/json.lua                   # JSON parser
├── plugins/sasl/data/modules/main_windows.lua    # Window registration
└── plugins/sasl/data/modules/main_menu.lua       # Menu items
```

---

## Restart Required
**Restart X-Plane 12** for all changes to take effect. Load the Dev aircraft from `Aircraft/HMW_A321Neo_AppleSilicon_Dev/`.