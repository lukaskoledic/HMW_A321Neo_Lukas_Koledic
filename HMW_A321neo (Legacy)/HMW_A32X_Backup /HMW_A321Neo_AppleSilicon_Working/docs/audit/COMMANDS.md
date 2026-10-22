# Audit Commands and Evidence

Audit date: 2026-10-20 (Europe/Vienna)

All source inspection commands were read-only. No command in this record initialized Git, changed a remote, committed, published, or modified the source folder.

## Inventory and provenance

```sh
find /Users/lukas/Desktop/HMW_A32X_Family -maxdepth 1 -mindepth 1 -print0
find "/Users/lukas/Desktop/HMW_A32X_Family/HoldMyWire A321 Neo " -type f
du -sh "/Users/lukas/Desktop/HMW_A32X_Family/HoldMyWire A321 Neo "
```

Observed source: 1,450 files, 228 directories, 821M. The selected source directory name ends with a real ASCII space. The family also contains the older `A321Neo-FXPL-master-dev ` tree; it was not copied.

## Copy and source manifest

The working copy was created with `rsync -a` from the selected source, excluding `.DS_Store`, the source `~` subtree, `.vscode`, `.vs`, `*.suo`, `*.swo`, `*.pss~`, and `*.pss_autosave`. The source `docs/BUILD_STATUS.md` was moved within the new working copy to `docs/source-reference/BUILD_STATUS.source.md` before new documentation was added.

The resulting manifest is [source-manifest.sha256](source-manifest.sha256). Verification mapped that one moved source document and reported:

```text
missing=0 mismatches=0
```

Selected source/working hashes:

```text
A321.acf                                      acb6ce01a372a619c8b7f9a920c6108804632f07a153c49e2878046e3eee68fb
plugins/sasl/64/mac.xpl                       539e1e21f0424f3315f3f04d11cadee9a2ce8c9bfc67d378bb4a801299df9318
plugins/AT/64/mac.xpl                         67a1a9bf0dd49d3dd3dd8a7baee39fe7806727fa1b7a03ddba9d7184f3deadb5
plugins/avionicsbay/libavionicsbay.dylib     d7638fa338d7d60cf5dbc21ada187cd91ace09a20d62ba84a801b7099a77e714
```

## Architecture and linkage

```sh
file plugins/sasl/64/mac.xpl plugins/AT/64/mac.xpl plugins/avionicsbay/libavionicsbay.dylib
lipo -info plugins/sasl/64/mac.xpl
lipo -info plugins/AT/64/mac.xpl
lipo -info plugins/avionicsbay/libavionicsbay.dylib
otool -L plugins/avionicsbay/libavionicsbay.dylib
nm -gU plugins/avionicsbay/libavionicsbay.dylib
```

Observed: SASL is universal; AT is x86_64-only; avionics-bay is arm64-only. The Linux and Windows files are x86_64. All 27 distinct `AvionicsBay.c.*` names used by the Lua wrapper were found in the arm64 dylib export table.

## Static resource checks

```sh
sed -n 's/^P .*_v10_att_file_stl //p' A321.acf
sed -n 's/^P .*_afl_file_[123] //p' A321.acf
rg -n '^TEXTURE' objects -g '*.obj'
```

Observed after the legacy-only rollback: 47/47 ACF object paths exist, the aircraft-local OBJ texture references resolve with exact case, and `Clark-Y (good propeller).afl` resolves from the installed X-Plane 12 fallback directory `/Users/lukas/X-Plane 12/Airfoils/`. No simulator asset was copied into the aircraft. The new root fuselage/front-gear objects and their selector are intentionally absent.

The corrected references are:

```text
objects/cockpit_interior_obj/flight_control.obj  cockpit_exterior_textures/flight_control_baked.png
objects/legacy/front gear.obj                    texture/front_gears_baked.png
objects/legacy/front gear.obj                    texture/front_gears_baked_NML.png
objects/cup.obj                                  texture/Cup.png
objects/cup.obj                                  texture/Cup_NML.png
```

Clickspot checks:

```sh
rg -n 'MODEL_ACTIVE|USE_LEGACY_OBJS|USE_NEW_OBJS' \
  "plugins/sasl/data/modules/Custom Module/dynamic_datarefs.lua"
rg -n 'MCDU_toggle_popup' \
  plugins/sasl/data/modules/main.lua \
  plugins/sasl/data/modules/main_menu.lua \
  "plugins/sasl/data/modules/Custom Module/cockpit_commands.lua"
```

The static cockpit audit confirms that the repaired MCDU popup path is declared. The remaining names without literal aircraft-local declarations are the known DRAIMS, MCDU-2, overhead-guard, and lights runtime-generated families plus two X-Plane built-in electrical commands. The detailed mapping is in `CLICKSPOT_MAP.md`.

Blue cockpit preservation was checked with:

```sh
shasum -a 256 \
  "cockpit_3D/-PANELS-/Panel.png" \
  "cockpit_3D/-PANELS-/Panel_Preview.png" \
  "plugins/sasl/data/modules/Custom Module/textures/PFD/static blue.png" \
  "plugins/sasl/data/modules/Custom Module/textures/ECAM/HYD/BLUE.png" \
  "plugins/sasl/data/modules/Custom Module/textures/ND/terrain-blue.png"
```

The captured preservation hashes are in `BLUE_COCKPIT_TEXTURES.sha256`.

## Build-source search

```sh
find "/Users/lukas/Desktop/HMW_A32X_Family" -type f \
  \( -name CMakeLists.txt -o -name Makefile -o -name '*.cmake' \
     -o -name '*.cpp' -o -name '*.cc' -o -name '*.c' \
     -o -name '*.h' -o -name '*.hpp' \)
```

Observed: no build files or C/C++ source/header files in the supplied family tree. No avionics-bay build was attempted.

## X-Plane discovery

```sh
test -d "/Users/lukas/X-Plane 12"
file "/Users/lukas/X-Plane 12/X-Plane.app/Contents/MacOS/X-Plane"
find "/Users/lukas/X-Plane 12/Aircraft" -maxdepth 4 -iname '*HMW*'
rg -n -i 'HMW_A321Neo_Test|incompatible architecture|avionicsbay|Failed to find resource' \
  "/Users/lukas/X-Plane 12/Log.txt"
```

Observed: X-Plane 12 exists and is universal; no current HMW test directory exists; the existing log is historical and records failures from an older `HMW_A321Neo_Test` copy.

The dedicated runtime attempt created `/Users/lukas/X-Plane 12/Aircraft/HMW_A321Neo_AppleSilicon_Test/` and started X-Plane 12.4.3-r2 before the final ACF front-gear entries were added. The process remained in startup/scenery discovery before aircraft selection, the desktop UI bridge could not bind to the simulator window, and the process was stopped. The test copy was later updated with the final gear wiring; no aircraft/plugin runtime result was inferred from the attempt.

## AT architecture and Rosetta fallback

```sh
file plugins/AT/64/mac.xpl
lipo -info plugins/AT/64/mac.xpl
find "/Users/lukas/Desktop/HMW_A32X_Family" -type f \
  \( -name CMakeLists.txt -o -name Makefile -o -name '*.cpp' -o -name '*.cc' \
     -o -name '*.c' -o -name '*.h' -o -name '*.hpp' \)
```

Observed: AT is a prebuilt x86_64-only Mach-O plugin. No AT/native source or build files were found in the supplied family tree. Because X-Plane loads AT in-process, an individual plugin cannot be placed in a separate Rosetta bubble. The working package therefore includes `tools/run_xplane_rosetta.command`, which launches the universal X-Plane executable as x86_64.

## Universal avionics-bay composition and probe

The working copy was built from the current arm64 library and the byte-identical x86_64 reference/backup library:

```sh
lipo -create \
  "/Users/lukas/Desktop/HMW_A32X_Family/HoldMyWire A321 Neo /plugins/avionicsbay/libavionicsbay.dylib" \
  "/Users/lukas/Desktop/HMW_A32X_Family/HoldMyWire A321 Neo /~/Desktop/HoldMyWire A321 Neo/plugins/avionicsbay/avionicsbay_backup_20261020_074528/libavionicsbay.dylib" \
  -output work/native-staging/libavionicsbay.universal.dylib
```

The resulting SHA-256 was:

```text
c039585ddafc05823b50c8d54017e293adbf2e3cc9e5bd05aa6c58618e47ad14  libavionicsbay.universal.dylib
d7638fa338d7d60cf5dbc21ada187cd91ace09a20d62ba84a801b7099a77e714  libavionicsbay.arm64.original.dylib
```

An architecture-specific C probe opened the universal dylib and resolved all 28 public FFI entry points under both native arm64 and `arch -x86_64` execution. This is a dynamic-loader/API check, not a full X-Plane flight pass. The installed working copy retains the previous arm64-only dylib at `plugins/avionicsbay/backups/libavionicsbay.arm64.original.dylib`.

## Native AT bridge and direct avionics initialization

The native A/T bridge was added to the universal main SASL module and its legacy hand-off marker was added to the standalone AT Lua module. Syntax and standalone behavior were checked with:

```sh
while IFS= read -r -d '' f; do
  /opt/homebrew/bin/luajit -b "$f" /dev/null
done < <(find work/model-swap-staging/plugins -type f -name '*.lua' -print0)
/opt/homebrew/bin/luajit work/tools-staging/test_native_at.lua \
  'work/model-swap-staging/plugins/sasl/data/modules/Custom Module/native_at.lua'
```

Observed: Lua syntax passed for all staged Lua files and `native_at unit test: PASS`. The native bridge only asserts `ATHR_is_controlling` and writes `ATHR_desired_N1` when its native enable flag, AT toggle, climb-detent levers, and at least one available engine are valid. It resets its demand on disable, invalid lever detent, engine unavailability, or legacy-plugin presence.

The arm64 avionics slice expected an older airport-data path. The final aircraft wrapper creates this link only after SASL starts and removes it during normal shutdown:

```sh
ln -s \
  "/Users/lukas/X-Plane 12/Global Scenery/Global Airports/Earth nav data/apt.dat" \
  "/Users/lukas/X-Plane 12/Resources/default scenery/default apt dat/Earth nav data/apt.dat"
```

For the standalone probes, an equivalent temporary link was created before calling the library and removed afterward. The direct native-arm64 and translated-x86_64 initialization probes both returned `initialize returned: true` and `navdata ready within 30s: true` against the real X-Plane root. These probes did not load the complete aircraft or SASL stack.

