# HMW A321neo — Build Status

> Active package state: legacy-only model. The new root fuselage/front-gear objects, model selector, and native AT bridge have been removed. Historical implementation notes below are retained for audit context; use the whole-simulator Rosetta launcher for the original Intel AT plugin.

Last verified: 2026-10-20 (Europe/Vienna)

## Current status

The active Apple Silicon working copy is now legacy-only: the textured legacy exterior and gear objects are the only ACF-attached visual model, and the removed new-model selector/native AT bridge are not present. The missing SASL initAvionics.lua bootstrap was restored after the X-Plane output log showed that SASL was stopping before module initialization. The legacy SASL resource loader was also updated to the current font-hinting API, and the legacy FBW/FMOD command/dataref compatibility names were restored. The MCDU AC-status page now guards invalid avionics nav-cycle values and renders `LOADING...` instead of concatenating nil data. A clean Rosetta aircraft load then reached SASL `Module loaded` with 3,956 registered commands and no SASL font/bootstrap errors. The avionics-bay library is universal with a rollback copy preserved, and direct arm64/x86 initialization against the installed X-Plane navdata passes. The original AT executable remains Intel-only, so use the whole-simulator Rosetta launcher when the original AT is required.

This document separates verified observations from assumptions. It does not treat older project notes as authoritative when they conflict with current file inspection.

## Provenance and scope

- Source parent: `/Users/lukas/Desktop/HMW_A32X_Family/`
- Selected source: `/Users/lukas/Desktop/HMW_A32X_Family/HoldMyWire A321 Neo `
  - The final character of the directory name is an ASCII space (`0x20`).
- Working project: `/Users/lukas/Desktop/HMW_A321Neo_AppleSilicon_Working/`
- The other A321 tree, `/Users/lukas/Desktop/HMW_A32X_Family/A321Neo-FXPL-master-dev `, was inspected as an older/reference variant and was not copied into this project.
- No source files or originals were modified. The working copy's avionics-bay library was deliberately replaced with a verified universal composition, and its previous arm64 file is preserved under `plugins/avionicsbay/backups/`.
- No Git repository was initialized; no commit, push, publish, or remote change was performed.

The source contained 1,450 files and 228 directories, including an accidental `~` subtree containing an older x86_64 avionics-bay backup. The working copy contains 1,434 source files plus the generated audit manifest and documentation. The copy excluded only macOS metadata, IDE state, editor swap/autosave files, and the nested `~` backup; the exclusions are listed in `PROJECT_STRUCTURE.md` and the source manifest.

## Verified checks

- The pre-change source-to-working manifest matched with zero missing files and zero hash mismatches after mapping the source `docs/BUILD_STATUS.md` to `docs/source-reference/BUILD_STATUS.source.md`.
- Key copied hashes matched the source baseline for `A321.acf`, SASL, AT, avionics-bay, the main fuselage object, the legacy gear texture, and the cockpit panel image before the controlled gear-object additions and the later universal avionics-bay composition. The current ACF and avionics-bay dylib intentionally differ by those documented changes; the original arm64 dylib is retained in the rollback folder.
- All 47 unique ACF-attached object paths resolve to files in `objects/`.
- Five of the six unique ACF airfoil names are aircraft-local. `Clark-Y (good propeller).afl` is supplied by the installed X-Plane 12 `/Users/lukas/X-Plane 12/Airfoils/` directory as a simulator fallback; it was not copied into the aircraft or altered.
- The active ACF object group includes `objects/legacy/under carriage.obj` and `objects/legacy/front gear.obj`; the removed new root fuselage/front-gear entries are absent. The legacy model is therefore unambiguous at load time.
- The restored cockpit-back OBJ and `cockpit_back_wall.png` match the dev backup and upstream `3D-Model-Update` branch. The optional `HMW House` livery is installed in both packages and includes the correct legacy rear-gear/wing-box diffuse map; cockpit blue textures are not overridden.
- The three identified local OBJ texture-reference issues were resolved with exact, existing paths. The blue cockpit texture preservation manifest is `docs/audit/BLUE_COCKPIT_TEXTURES.sha256`.
- The unhandled MCDU popup clickspot command was declared and mapped to the existing `MCDU_window` popup handler. Remaining undeclared static names are known runtime-generated command families; see `docs/audit/CLICKSPOT_MAP.md`.
- The cockpit panel resources `Panel.png` and `Panel_Preview.png` are valid 4096×4096 RGBA PNGs. All but one of the 26 inspected cockpit/interior OBJ files contain `VT` coordinates; `cockpit lights.obj` is light-only by inspection and was not visually validated.
- The X-Plane 12 installation was found at `/Users/lukas/X-Plane 12/`. Its application executable is universal (`x86_64` + `arm64`).
- The AT Mac binary is x86_64-only and has no accompanying native source/build tree in the supplied package. The working package includes `tools/run_xplane_rosetta.command`; macOS architecture is process-wide, so this launcher moves the complete X-Plane process to x86_64 rather than trying to isolate AT.
- The working avionics-bay dylib is universal (`x86_64` + `arm64`). Both slices report version `1.0.1` and commit `Unknown`, export the same public FFI API, pass architecture-specific `dlopen`/`dlsym` probes, and pass direct initialization/navdata-readiness probes against the installed X-Plane root with an equivalent temporary compatibility link. The aircraft wrapper now creates that link only after scenery discovery and removes it on normal shutdown. The original arm64-only file is retained at `plugins/avionicsbay/backups/libavionicsbay.arm64.original.dylib`.
- The Rosetta launcher removes only a verified stale aircraft navdata symlink before startup and refuses unexpected files or targets; the cleanup path passed an isolated test after a forced-stop scenario.
- The active package contains the original AT project only. Its Mac binary remains x86_64-only and is intentionally exercised through the complete-simulator Rosetta launcher; no second AT controller is installed.
- The missing `plugins/sasl/data/init/initAvionics.lua` file is now present in both package copies. The SASL loader now uses the current font-hinting API, so the fresh Rosetta aircraft load completed the full module tree without the former `iHinting`/font failures.
- The legacy FBW command aliases referenced by the FMOD bank (`toggle_fac_1`, `toggle_fac_2`, and `toggle_sec_3`) and the two legacy FMOD dataref aliases are restored in the SASL layer. The remaining DRAIMS `Round` hold-cue messages are FMOD-bank metadata warnings, not SASL initialization failures.
- The host is Apple Silicon (`arm64`) on macOS 26.5.2. Clang, CMake 4.4.3, Make, `lipo`, `otool`, `nm`, and `codesign` are available. `xcodebuild` is not available because the active developer directory is Command Line Tools rather than a full Xcode installation.

## Static blockers and warnings

1. Four Lua files are zero bytes. `LAF_inputs.lua` is also listed as a component by `FLT_SYS/FBW/FBW_main.lua`; whether this is an intentional placeholder or an incomplete feature requires runtime/feature review.
2. The source README describes an X-Plane 11 aircraft and the ACF header is version 1200. X-Plane 12 compatibility is therefore an assumption until a clean X-Plane 12 load is performed.
3. The bundled `plugins/AT/64/mac.xpl` remains x86_64-only and cannot load inside a native arm64 X-Plane process. There is no per-plugin Rosetta bubble; use the included whole-X-Plane launcher when the original AT binary or another x86-only plugin is required.

## Binary/build status

| Component | Static result | Runtime/build result |
|---|---|---|
| `plugins/sasl/64/mac.xpl` | Universal `x86_64` + `arm64` | Rosetta aircraft load completed; SASL reached `Module loaded` with no bootstrap/font API errors |
| `plugins/AT/64/mac.xpl` | `x86_64` only; incompatible with native arm64 X-Plane | Original binary retained and tested only through whole-process Rosetta; no native bridge is active |
| `plugins/avionicsbay/libavionicsbay.dylib` | Universal `x86_64` + `arm64`; linked to system `libc++`/`libSystem` | Both slices pass dynamic-load/API and direct initialization/navdata-readiness probes; full SASL flight pending |
| `plugins/avionicsbay/libavionicsbay.so` | Linux x86_64 | Not used on macOS |
| `plugins/avionicsbay/libavionicsbay.dll` | Windows x86_64 | Not used on macOS |

The Lua FFI surface calls 27 distinct avionics-bay names; all are present in both slices of the universal dylib. A 28-symbol dynamic-load probe passes under native arm64 and translated x86_64 execution. This still is not proof of ABI layout, data-file initialization, or successful operation inside X-Plane.

No `avionicsbay-main` source tree, README, CMake file, Makefile, C/C++ source, or header was found in the supplied family tree. Consequently, no native rebuild was attempted. The working universal file was made by combining the active arm64 binary with the byte-identical x86_64 reference/backup slice; this is a compatibility composition, not a source build. The original arm64 file remains available for rollback. Direct library initialization now succeeds with the runtime-compatible navdata path, and a full X-Plane runtime test is still required.

## Test status

Static ACF/object/texture checks, the dual-architecture avionics-bay loader probe, direct arm64/x86 avionics initialization probes, the SASL output-log review, the missing-bootstrap/font-API repair, the FMOD compatibility aliases, and the legacy-only rollback checks were performed. A clean whole-process Rosetta run loaded the test ACF through X-Plane's local interface; SASL initialized, the module tree completed, and the command registry populated. The test log still contains separate FMOD hold-cue metadata warnings, so audio-bank perfection is not claimed. The current test copy includes the repaired SASL bootstrap, universal avionics library, legacy-only ACF, livery workflow, and Rosetta launcher.

See `APPLE_SILICON_COMPATIBILITY.md`, `BUILD_GUIDE.md`, and `TESTING.md` for the gates and next steps.

# CURRENT ACTIVE PACKAGE OVERRIDE

The active package has been rolled back to the legacy-only model format. The new root fuselage/front-gear objects, model selector, and native AT bridge are removed. Use the original AT plugin through the whole-simulator Rosetta launcher. The historical implementation details below describe the earlier hybrid build and are retained only as audit history.

---

