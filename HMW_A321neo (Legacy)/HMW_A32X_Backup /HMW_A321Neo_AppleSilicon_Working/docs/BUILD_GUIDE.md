# HMW A321neo -- Build Guide

> Active package state: legacy-only model. The new root fuselage/front-gear objects, model selector, and native AT bridge have been removed. Historical implementation notes below are retained for audit context; use the whole-simulator Rosetta launcher for the original Intel AT plugin.

## Current toolchain

Verified on 2026-10-20:

- host architecture: `arm64` Apple Silicon;
- macOS: 26.5.2;
- Apple Clang 21.0.0;
- CMake 4.4.3 at `/opt/homebrew/bin/cmake`;
- Make, `lipo`, `otool`, `nm`, `codesign`, and `file` available;
- full Xcode is not selected; `xcodebuild -version` reports that the active developer directory is Command Line Tools.

## Static preflight

Run these from the working project before any simulator installation:

```sh
WORK=/Users/lukas/Desktop/HMW_A321Neo_AppleSilicon_Working
file "$WORK/plugins/sasl/64/mac.xpl" \
     "$WORK/plugins/AT/64/mac.xpl" \
     "$WORK/plugins/avionicsbay/libavionicsbay.dylib"
lipo -info "$WORK/plugins/sasl/64/mac.xpl"
lipo -info "$WORK/plugins/AT/64/mac.xpl"
lipo -info "$WORK/plugins/avionicsbay/libavionicsbay.dylib"
otool -L "$WORK/plugins/avionicsbay/libavionicsbay.dylib"
```

The expected current result is SASL universal, the original AT executable x86_64-only, and avionics-bay universal. This task verified that result. The original AT executable remains unavailable to a native arm64 X-Plane process; the aircraft's native Lua bridge is the arm64 path.

The aircraft itself has no source build step: X-Plane consumes the ACF, airfoil, OBJ, texture, FMOD, and Lua resources directly. Static path checks must pass before a simulator run. The three local OBJ texture references identified during the first audit are now corrected. The `Clark-Y (good propeller).afl` reference is intentionally left as an X-Plane-supplied fallback because it is present in the installed simulator Airfoils directory.

## Legacy visual model and gear

The shipped package is intentionally legacy-only. The ACF attaches `legacy/fuselage.obj`, `legacy/under carriage.obj`, and `legacy/front gear.obj`; the removed root `fuselage.obj` and `front gear.obj` are not part of the runtime package, and no model selector is loaded.

The legacy rear gear uses the existing `texture/fuselage_wingbox_ALB.png` and `texture/fuselage_wingbox_NRM.png` maps. The nose gear uses `texture/front_gears_baked.png` and `texture/front_gears_baked_NML.png`. The optional `HMW House` livery includes the correctly mapped legacy rear-gear/wing-box diffuse map for paint and visual testing.

The cockpit clickspot handlers and aircraft systems remain independent of the exterior model objects. Validate cockpit interaction, gear animation, and system pages in X-Plane after loading the legacy package.

## SASL and AT

The bundled SASL runtime is a prebuilt SASL 3.12.1 Free Edition plugin. Its Mac binary is already universal, so no SASL rebuild was attempted. The original AT plugin is also prebuilt, but its Mac binary is x86_64-only and cannot be loaded by a native arm64 X-Plane process. No AT source or arm64 build output is present in this package, so the original executable was not replaced or reverse-engineered.

For native arm64, the working package now includes `plugins/sasl/data/modules/Custom Module/native_at.lua`. It uses the existing A321 FADEC/N1 loop through `ATHR_desired_N1`, follows the FCU selected speed or Mach, and does not write the raw X-Plane throttle-ratio dataref. The legacy AT module sets a shared presence marker so the native bridge remains off when the whole simulator is running under Rosetta. Use the A321NEO plugin menu's `Native arm64 adaptive A/T` submenu, or bind these commands:

```text
a321neo/autothrust/native_toggle
a321neo/autothrust/native_enable
a321neo/autothrust/native_disable
a321neo/autothrust/target_speed_up
a321neo/autothrust/target_speed_down
```

The new bridge is unit-tested with LuaJIT. It still needs an in-sim flight test for final tuning/acceptance.

There is no per-plugin Rosetta switch because X-Plane loads AT in-process. When AT is required, launch the complete simulator under Rosetta with the included executable command file:

```text
/Users/lukas/Desktop/HMW_A321Neo_AppleSilicon_Working/tools/run_xplane_rosetta.command
```

The universal X-Plane executable, universal SASL plugin, x86_64 AT plugin, and universal avionics-bay library are then all selected as x86_64. Other third-party plugins loaded in that session must also include an x86_64 slice.

## X-Plane 12 navdata compatibility link

The arm64 avionics slice expects an older airport-data path. The installed X-Plane 12 data is at the newer path. The final aircraft wrapper creates the following link only after the SASL aircraft module starts, then removes it during normal shutdown:

```text
/Users/lukas/X-Plane 12/Resources/default scenery/default apt dat/Earth nav data/apt.dat
    -> /Users/lukas/X-Plane 12/Global Scenery/Global Airports/Earth nav data/apt.dat
```

This timing avoids making X-Plane classify the old path as a startup scenery package. No persistent manual link is required. Direct initialization and navdata readiness pass in both native arm64 and translated x86_64 probes when an equivalent temporary link is present.

## Avionics-bay native build and universal fallback

No `avionicsbay-main` source tree or build files were available in the supplied family tree. The aircraft contains only `libavionicsbay.dylib`, `.so`, `.dll`, `WMM.COF`, and the Lua FFI declarations. The current dylib reports embedded version `1.0.1` and commit hash `Unknown`; its provenance cannot be reconstructed from the supplied files.

No native source build was run. The working package now uses a universal dylib assembled with `lipo` from the active arm64 file and the byte-identical x86_64 reference/backup. Both slices report version `1.0.1`, commit `Unknown`, export the same public API, pass separate `dlopen`/`dlsym` probes, and pass direct initialization/navdata-readiness probes against the installed X-Plane root with an equivalent temporary compatibility link. The previous arm64-only file is preserved at `plugins/avionicsbay/backups/libavionicsbay.arm64.original.dylib`. This composition provides an architecture fallback but does not prove full SASL ABI behavior or a completed flight.

If the exact corresponding source is obtained later, use an isolated build directory outside the aircraft tree:

```sh
AVIONICS_SOURCE=/absolute/path/to/verified/avionics-bay-source
AVIONICS_BUILD=/absolute/path/to/avionics-bay-build-arm64
cmake -S "$AVIONICS_SOURCE" -B "$AVIONICS_BUILD" \
  -DCMAKE_OSX_ARCHITECTURES=arm64 \
  -DCMAKE_BUILD_TYPE=Release
cmake --build "$AVIONICS_BUILD" --parallel
```

Do not assume the output filename or ABI. Locate the actual output from the build system, then verify:

```sh
file /absolute/path/to/output.dylib
lipo -info /absolute/path/to/output.dylib
otool -L /absolute/path/to/output.dylib
nm -gU /absolute/path/to/output.dylib
```

Before considering another replacement, compare the exported C symbols and the C struct declarations in `plugins/sasl/data/modules/Custom Module/avionics_bay_include.lua`. The current universal binary has all 27 names called by `avionics_bay.lua` in both slices, but that symbol-name match does not prove struct layout, ownership, threading, or initialization behavior. Keep the rollback dylib until a clean X-Plane test confirms initialization and navigation-data behavior.

## Build records

Record the exact CMake configure command, compiler/toolchain, build command, exit status, output path, `file`/`lipo`/`otool` output, and the final SHA-256 hash in `docs/audit/`. Never describe an unperformed build as successful.
