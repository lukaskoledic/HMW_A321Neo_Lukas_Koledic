# HMW A321neo — Changelog

> Active package state: legacy-only model. The new root fuselage/front-gear objects, model selector, and native AT bridge have been removed. Historical implementation notes below are retained for audit context; use the whole-simulator Rosetta launcher for the original Intel AT plugin.

## 2026-10-20 — HMW EFB home-page redesign (light theme, widgets, dock)

- Replaced `plugins/sasl/data/modules/Custom Module/EFB/EFB_pages/1.lua` placeholder with a light-theme MacOS-style EFB home page (dark page remains for pages 2–10)
- Added `plugins/sasl/data/modules/Custom Module/EFB/efb_home_widgets.lua` with dock icons, random plane facts, clock, battery with auto-refill on new flight, and mock app pages
- Dock: six bottom-dock icon tabs — SimBrief, AviTab, ChartFox, Browser, Clock, Checklist — each with drawn programmatic icon + label
- Checklist tab: simplified checklist list pulled from aircraft checklist families (BEFORE START, PUSH/START, BEFORE TAKEOFF, AFTER TAKEOFF, DESCENT, LANDING) with checkable items
- Battery widget: drains over sim time, auto-refills to 100% on new flight (sim time reset), persists to `saved_configs/EFB_home.cfg`, EFB goes dead at 0%
- Yellow finger cursor preserved untouched

## 2026-10-20 — Native arm64 adaptive A/T and avionics initialization compatibility

- Added `plugins/sasl/data/modules/Custom Module/native_at.lua`, a native Lua adaptive A/T bridge that follows the FCU speed/Mach target and feeds the existing A321 FADEC/N1 controller without writing the raw X-Plane throttle-ratio dataref.
- Added native A/T commands/menu entries and the `a32nx/compat/legacy_at_present` hand-off marker. The legacy x86 AT plugin sets the marker, so the native bridge stays passive during a Rosetta session and the two controllers cannot fight each other.
- Added a runtime-only, reversible X-Plane 12 navdata compatibility link for the older path expected by the arm64 avionics slice. It is created after scenery discovery and removed on normal shutdown; direct arm64 and translated x86_64 initialization return `true` and reach navdata readiness within 30 seconds.
- Added and passed standalone LuaJIT coverage for the native AT enable/disable, demand, safety, and legacy hand-off paths.

## 2026-10-20 — Universal avionics-bay fallback and Rosetta launcher

- Confirmed the bundled AT Mac plugin is a prebuilt x86_64-only binary with no arm64 slice or native source/build tree available in the supplied package; it was not replaced or reverse-engineered.
- Confirmed that macOS cannot isolate one in-process X-Plane plugin under Rosetta. Added `tools/run_xplane_rosetta.command` to launch the complete universal X-Plane process as x86_64 when AT is required.
- Built a universal `plugins/avionicsbay/libavionicsbay.dylib` from the active arm64 slice and the byte-identical x86_64 reference/backup slice. Preserved the original arm64 file at `plugins/avionicsbay/backups/libavionicsbay.arm64.original.dylib`.
- Verified both architecture slices with `dlopen`/`dlsym` probes and direct initialization/navdata-readiness probes. Full X-Plane flight behavior remains pending runtime validation.

## 2026-10-20 — Legacy visual-model default and reference cleanup

- Added the SASL `model_swap.lua` component with explicit legacy, new, and toggle commands/datarefs; the textured legacy exterior and the ACF-attached legacy gear/undercarriage group are now the load default.
- Added plugin-menu entries for selecting legacy, selecting new, and toggling the exterior/gear package.
- Attached the animated legacy and new front-gear OBJ variants to `A321.acf` with mutually exclusive model hide-datarefs so gear visibility and steering/extension animations follow the selected package.
- Resolved the exact OBJ texture references for front gear, flight-control geometry, and cup artwork without duplicating or replacing legacy textures.
- Added an explicit blue cockpit texture preservation manifest and recorded the clickspot command mapping audit.
- Declared and handled the previously unmapped MCDU popup clickspot command through the existing shared MCDU window.
- Documented `Clark-Y (good propeller).afl` as an installed X-Plane fallback rather than copying a simulator asset into the aircraft.
- Static verification is complete; a fresh X-Plane run is still required for runtime visibility, clickspot, plugin, and system acceptance.
- Created the dedicated X-Plane test copy and attempted a runtime launch before the final ACF gear wiring; X-Plane stalled during startup/scenery discovery before aircraft selection, so no in-sim pass was claimed. The test copy was then updated with the final gear entries.

## 2026-10-20 — Fresh Apple Silicon working copy

- Selected `/Users/lukas/Desktop/HMW_A32X_Family/HoldMyWire A321 Neo ` as the source after resolving the real trailing-space directory name.
- Created `/Users/lukas/Desktop/HMW_A321Neo_AppleSilicon_Working/` as a separate working project.
- Copied verified A321neo assets and preserved originals; excluded only macOS metadata, IDE state, editor swap/autosave files, and the nested `~` backup subtree.
- Preserved the source `docs/BUILD_STATUS.md` under `docs/source-reference/BUILD_STATUS.source.md` before creating the new project-status documents.
- Added a SHA-256 source manifest and recorded the copy/verification commands in `docs/audit/COMMANDS.md`.
- Confirmed the working copy has a universal SASL Mac plugin, an x86_64-only AT Mac plugin, and an arm64-only avionics-bay Mac dylib.
- Confirmed the avionics-bay Lua wrapper’s 27 called symbol names are exported by the current dylib; runtime initialization remains untested.
- Recorded missing/case-mismatched OBJ texture references, the missing `Clark-Y (good propeller).afl` reference, and zero-byte Lua files without altering source assets.
- Confirmed no `avionicsbay-main` source/build tree is present; no native build or binary replacement was attempted.
- Discovered the X-Plane 12 installation and documented a separate-copy testing workflow. No fresh X-Plane installation or in-sim test was performed.

