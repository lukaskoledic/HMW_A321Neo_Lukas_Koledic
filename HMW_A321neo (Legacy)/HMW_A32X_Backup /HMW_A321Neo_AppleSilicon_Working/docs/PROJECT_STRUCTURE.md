# HMW A321neo -- Project Structure

> Active package state: legacy-only model. The new root fuselage/front-gear objects, model selector, and native AT bridge have been removed. Historical implementation notes below are retained for audit context; use the whole-simulator Rosetta launcher for the original Intel AT plugin.

## Locations and provenance

| Role | Exact path |
|---|---|
| Source parent | `/Users/lukas/Desktop/HMW_A32X_Family/` |
| Selected source | `/Users/lukas/Desktop/HMW_A32X_Family/HoldMyWire A321 Neo ` |
| Fresh working project | `/Users/lukas/Desktop/HMW_A321Neo_AppleSilicon_Working/` |
| X-Plane 12 installation | `/Users/lukas/X-Plane 12/` |

The selected source directory name ends in a real ASCII space. The similarly named `A321Neo-FXPL-master-dev ` directory was used only for comparison. No A320-family variant was copied.

## Working tree

```text
HMW_A321Neo_AppleSilicon_Working/
├── A321.acf                         aircraft configuration
├── airfoils/                         A321neo airfoil files
├── cockpit_3D/                       panel artwork and cockpit resources
├── doc/                              older development/user documentation
├── docs/
│   ├── audit/                        manifests and reproducible audit record
│   └── source-reference/             preserved source documentation
├── fmod/                             FMOD bank, sound definition, and license
├── liveries/                         QANTAS/XLR assets plus legacy texture template
├── objects/                          aircraft and cockpit OBJ geometry/textures
├── plugins/
│   ├── AT/                           adaptive auto-throttle SASL project
│   ├── avionicsbay/                  platform binaries and WMM.COF
│   └── sasl/                         SASL runtime, Lua modules, fonts, assets
├── tools/                            standalone tests and Rosetta launcher
├── .github/                          copied project metadata
├── .gitignore                        inherited ignore rules
└── LICENSE/README/STATUS/etc.       inherited project and licensing documents
```

The source contained 1,450 files. The fresh copy retained 1,434 source files, then added audit/documentation files, the Rosetta launcher, and a rollback copy for the universal avionics-bay library. The following were deliberately excluded from the working copy:

- two `.DS_Store` files;
- the source `~` subtree, which contained one nested x86_64 avionics-bay backup dylib and was not normal aircraft content;
- four `.vscode` settings files and six `.vs`/Visual Studio state files;
- two `.suo` files, one Lua swap file, and two particle autosave files.

The excluded material remains untouched in the source. The preserved source `docs/BUILD_STATUS.md` is available at `docs/source-reference/BUILD_STATUS.source.md`; it is reference material, not an instruction set.

## Runtime ownership

- X-Plane reads `A321.acf` and the `airfoils/`, `objects/`, `cockpit_3D/`, `fmod/`, `liveries/`, and `plugins/` trees.
- SASL loads `plugins/sasl/64/mac.xpl` and its Lua project under `plugins/sasl/data/`.
- The active ACF uses the legacy-only exterior and gear package: `objects/legacy/under carriage.obj` and `objects/legacy/front gear.obj`. The new root fuselage/front-gear objects and model selector were removed during rollback.
- The aircraft Lua code loads `plugins/avionicsbay/libavionicsbay.dylib` through FFI on macOS; the working copy's dylib is universal and its original arm64-only file is preserved under `plugins/avionicsbay/backups/`.
- The separate AT project loads `plugins/AT/64/mac.xpl`; its Mac binary remains Intel-only. `tools/run_xplane_rosetta.command` launches the complete simulator under x86_64 when AT is required.
- `plugins/avionicsbay/WMM.COF` is a data file used by the native library; the X-Plane default navigation/CIFP data are supplied by the X-Plane installation.

## Local Git-readiness checklist

This is a local checklist only. No Git repository has been initialized.

- [x] Aircraft root is separated from the original source and unrelated A320-family variants.
- [x] Source and working paths, copy exclusions, and the source hash manifest are recorded.
- [x] Required operating/build/testing documents exist under `docs/`.
- [x] Obvious backup, IDE-state, swap, and autosave files are excluded from the fresh working copy.
- [ ] Add a deliberate ignore policy for future CMake/build output, X-Plane logs, crash dumps, and local test copies before initializing Git.
- [ ] Perform a dedicated secrets scan before any repository creation or sharing; this task did not publish or push anything.
- [ ] Confirm redistribution permissions for SASL/AT binaries, model OBJ files, FMOD assets, fonts, and third-party data against `ACKNOWLEDGMENTS.md` and each component license.
- [x] Resolve the three local case/path texture references; document `Clark-Y (good propeller).afl` as an installed X-Plane fallback.
- [x] Add the legacy-only rollback, clickspot mapping, and blue-cockpit preservation audit records.
- [ ] Add automated static checks for ACF object/airfoil paths, exact-case OBJ texture paths, Mach-O architecture, and FFI symbol presence.
- [x] Preserve a rollback copy before replacing the working native avionics library; retain the separate simulator test-copy gate.
