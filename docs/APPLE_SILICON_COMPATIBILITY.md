# Apple Silicon Compatibility

> Active package state: legacy-only model. The new root fuselage/front-gear objects, model selector, and native AT bridge have been removed. Historical implementation notes below are retained for audit context; use the whole-simulator Rosetta launcher for the original Intel AT plugin.

Last verified: 2026-10-20 on an arm64 Apple Silicon host.

## Binary matrix

| Artifact | Detected format/architecture | Native arm64 status |
|---|---|---|
| `plugins/sasl/64/mac.xpl` | Mach-O universal: `x86_64 arm64` | Compatible by architecture; fresh X-Plane load not yet performed |
| `plugins/AT/64/mac.xpl` | Mach-O `x86_64` only | Incompatible with a native arm64 X-Plane process |
| `plugins/avionicsbay/libavionicsbay.dylib` | Mach-O universal: `x86_64 arm64` | Architecture/API probes and direct navdata initialization pass in both modes; full SASL flight still pending |
| `plugins/sasl/64/lin.xpl` | Linux ELF x86_64 | Not a macOS runtime |
| `plugins/AT/64/lin.xpl` | Linux ELF x86_64 | Not a macOS runtime |
| `plugins/avionicsbay/libavionicsbay.so` | Linux ELF x86_64 | Not a macOS runtime |
| `plugins/sasl/64/win.xpl` | Windows PE32+ x86-64 | Not a macOS runtime |
| `plugins/AT/64/win.xpl` | Windows PE32+ x86-64 | Not a macOS runtime |
| `plugins/avionicsbay/libavionicsbay.dll` | Windows PE32+ x86-64 | Not a macOS runtime |
| Lua scripts, config, OBJ, PNG, FMOD data | Architecture-independent data/scripts | Still require runtime/API compatibility checks |

The current Mac avionics-bay dylib is linked to `/usr/lib/libc++.1.dylib` and `/usr/lib/libSystem.B.dylib`. The working copy now contains a universal file assembled from the active arm64 slice and the matching x86_64 reference/backup slice. The arm64 slice reports a minimum macOS version of 26.0 with SDK 26.5; the x86_64 slice reports 12.6 with SDK 13.1. Both slices have an embedded ad-hoc code signature. The current host is macOS 26.5.2, but X-Plane still must load and initialize the library in context.

## Avionics-bay API/ABI check

`avionics_bay.lua` loads the platform-specific library with `ffi.load()` and then calls `initialize()`; the macOS path is `plugins/avionicsbay/libavionicsbay.dylib`. A static comparison found 27 distinct `AvionicsBay.c.*` names used by the Lua wrapper and all 27 corresponding exported C symbols in both universal slices. A separate dynamic probe resolved all 28 public entry points used by the wrapper in both native arm64 and translated x86_64 execution.

This is an API/loader check, not an X-Plane flight test. It does not prove that the C struct packing, boolean widths, pointer ownership, thread behavior, or full SASL integration are compatible. A separate direct initialization probe against the real X-Plane installation now returns `true` and reaches `xpdata_is_ready` in both native arm64 and translated x86_64 execution; only a full X-Plane flight can establish the remaining in-sim result.

## X-Plane 12 navdata compatibility link

The active arm64 avionics slice was built against the older X-Plane navdata path:

```text
Resources/default scenery/default apt dat/Earth nav data/apt.dat
```

The current X-Plane 12 installation stores the same airport data at:

```text
Global Scenery/Global Airports/Earth nav data/apt.dat
```

The aircraft's avionics wrapper creates this compatibility link at runtime, after X-Plane has completed its scenery scan, and removes it on normal module shutdown:

```text
/Users/lukas/X-Plane 12/Resources/default scenery/default apt dat/Earth nav data/apt.dat
    -> /Users/lukas/X-Plane 12/Global Scenery/Global Airports/Earth nav data/apt.dat
```

With that link present, direct library initialization returned `true` and navdata became ready within 30 seconds under both native arm64 and translated x86_64 probes. The final working package creates the link only during avionics initialization, avoiding the X-Plane startup warning caused by presenting the old path during scenery discovery. The standalone C probe requires a temporary copy of the link for an equivalent direct test; the aircraft wrapper handles this automatically.

## Rosetta process model

macOS chooses an architecture for the process, not for an individual `.xpl` loaded into that process. A native arm64 X-Plane process cannot load the x86_64 AT plugin, and an AT-specific Rosetta bubble cannot be created without moving the entire simulator process to x86_64. The supplied `tools/run_xplane_rosetta.command` launches the universal X-Plane executable with `arch -x86_64`; that is the supported fallback for using the existing AT binary.

The working copy's avionics-bay dylib now contains both slices so that it does not block either native arm64 or whole-process Rosetta operation. The original arm64-only file is preserved at `plugins/avionicsbay/backups/libavionicsbay.arm64.original.dylib`. Any other third-party X-Plane plugin loaded in a Rosetta session must also have an x86_64 slice.

## Native arm64 adaptive A/T

Because the original AT executable cannot be rebuilt from the supplied package, the working copy includes a new native Lua implementation inside the universal main SASL plugin. It preserves the historical A32NX AT dataref names, follows the FCU speed/Mach target, and feeds `ATHR_desired_N1` into the aircraft's existing FADEC/N1 loop. It never writes X-Plane's raw throttle-ratio dataref, so it does not compete with the aircraft's throttle override.

The legacy AT Lua module sets `a32nx/compat/legacy_at_present` when its x86 plugin is loaded. The native bridge then stays passive under Rosetta, leaving the original AT implementation in charge. Native arm64 starts with the new bridge available; use the A321NEO plugin menu's `Native arm64 adaptive A/T` submenu or the documented commands to enable/disable it. The native bridge has a standalone LuaJIT smoke test; full aircraft flight behavior remains a simulator test gate.

## SASL error handling and the STOP/KEEP question

The source uses `sasl.options.setLuaErrorsHandling(SASL_STOP_PROCESSING)` in both:

- `plugins/sasl/data/modules/main.lua:38`; and
- `plugins/AT/data/modules/main.lua:24`.

The SASL API stub defines both `SASL_KEEP_PROCESSING` and `SASL_STOP_PROCESSING`, but the project uses `SASL_STOP_PROCESSING` and has no `SASL_KEEP_PROCESSING` call. The official [SASL Reference Manual](https://1-sim.com/files/SASL3Manual.pdf) describes KEEP as the default error mode and STOP as a development mode that stops SASL processing when a Lua error occurs. STOP is therefore a diagnostic/project-processing policy, not an architecture bridge.

In the current wrapper, `ffi.load(path)` is not protected by `pcall`; a failed or incompatible dylib load raises at the load site before the wrapper can expose normal avionics functions. Changing STOP to KEEP could change how later Lua errors are handled, but it cannot make an x86_64 library load in arm64 or guarantee that the remaining components continue meaningfully. It also cannot make avionics available when the underlying library failed. No STOP/KEEP source change was made because the actual runtime behavior has not yet been observed in X-Plane.

The main SASL component list places `avionics_bay {}` first. The project also has a debug flag, `debug_disable_avionicsbay`, which intentionally disables the dependency but warns that ND/OANS/MCDU features will be unavailable. That is a diagnostic mode, not a fix or a production replacement.

## Historical comparison

The nested source backup `/Users/lukas/Desktop/HMW_A32X_Family/HoldMyWire A321 Neo /~/Desktop/HoldMyWire A321 Neo/plugins/avionicsbay/avionicsbay_backup_20261020_074528/libavionicsbay.dylib` is x86_64-only and was excluded from the working copy as a normal source asset. Its bytes are identical to the older-reference x86_64 library and were used only as the x86_64 slice for the working universal fallback. The active source dylib was arm64-only and remains untouched.

