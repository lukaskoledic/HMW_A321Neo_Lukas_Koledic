# HMW A321neo — Testing Workflow

> Active package state: legacy-only model. The new root fuselage/front-gear objects, model selector, and native AT bridge have been removed. Historical implementation notes below are retained for audit context; use the whole-simulator Rosetta launcher for the original Intel AT plugin.

## Current test state

Performed:

- read-only inventory of the source and older/reference trees;
- isolated Desktop working-copy creation;
- source-manifest/hash verification;
- ACF object and airfoil path checks;
- OBJ texture-path and exact-case checks;
- cockpit panel/UV presence checks;
- legacy-only ACF/object/gear/clickspot mapping checks; the earlier model-switch audit is retained only as history;
- blue cockpit texture preservation hash capture;
- Mach-O/ELF/PE architecture, linkage, code-signature, and FFI symbol checks;
- universal avionics-bay composition, rollback preservation, and architecture-specific `dlopen`/`dlsym` probes;
- direct avionics-bay initialization and navdata-readiness probes in native arm64 and translated x86_64 modes;
- native adaptive A/T LuaJIT smoke test and legacy-AT hand-off wiring;
- discovery of the X-Plane 12 installation and review of the existing `Log.txt`.
- a clean whole-process Rosetta aircraft load through X-Plane's local interface;
- SASL module initialization after restoring `initAvionics.lua` and updating the current font-hinting API;
- legacy FMOD command/dataref compatibility checks, including 3,956 registered aircraft commands.

Not performed:

- the automated Rosetta load did not replace a human cockpit/gear/livery inspection; the aircraft ACF and SASL module tree did load successfully, while manual visual and systems exercise remains for the user flight test;
- no manual cold-and-dark or systems flight was completed after the automated load;
- `libavionicsbay.dylib` was not initialized through the full SASL/X-Plane flight stack (direct library initialization and navdata readiness were separately verified);
- the original AT executable was not rebuilt; the new native Lua bridge was unit-tested but not flight-tested;
- no native-arm64 aircraft load was completed; the whole-process Rosetta aircraft load is documented above;
- no native avionics-bay source build was run.

Accordingly, the package has a verified aircraft-load/plugin pass under Rosetta, but not a complete human flight-acceptance pass. The static model/resource changes and the whole-process Rosetta fallback are ready for the user flight test.

## Discovered locations

- X-Plane 12: `/Users/lukas/X-Plane 12/`
- X-Plane executable: `/Users/lukas/X-Plane 12/X-Plane.app/Contents/MacOS/X-Plane` (universal `x86_64` + `arm64`)
- X-Plane log: `/Users/lukas/X-Plane 12/Log.txt`
- Dedicated test copy: `/Users/lukas/X-Plane 12/Aircraft/HMW_A321Neo_AppleSilicon_Test/`
- No current `Aircraft/HMW_A321Neo_Test` directory exists. The existing log references an older, now-absent `Aircraft/HMW_A321Neo_Test` copy.

## Safe test-copy procedure

Use a new test name that does not collide with an existing aircraft. Keep the source and Desktop working project outside X-Plane. Do not overwrite an existing test directory.

1. Stop X-Plane and verify the destination is absent.
2. If a destination already exists and must be retained, make a timestamped backup before changing anything. Verify the backup path and hash before proceeding.
3. Copy the working project to a dedicated test path such as `/Users/lukas/X-Plane 12/Aircraft/HMW_A321Neo_AppleSilicon_Test/`. Do not install the source path.
4. Verify the test copy’s key hashes and architecture before launching.
5. Start X-Plane, load the test aircraft, and allow the aircraft to reach the normal flight state. Record the test date, X-Plane version, aircraft path, and whether the flight was cold-and-dark or already running.
6. Close X-Plane normally. Copy the resulting `Log.txt` to `docs/audit/` with a timestamped filename; keep the original X-Plane log intact.
7. Review the log in separate gates: aircraft/OBJ loading, plugin discovery, SASL project errors, avionics-bay initialization/data readiness, AT plugin loading, and FMOD/sound errors.
8. Remove or archive only the dedicated test copy after the evidence is preserved; never delete the source or working project as cleanup.

For an AT-enabled Apple Silicon run, start the simulator by double-clicking `/Users/lukas/Desktop/HMW_A321Neo_AppleSilicon_Working/tools/run_xplane_rosetta.command`. This launches the entire X-Plane process as x86_64; an individual AT plugin cannot be translated independently inside native arm64 X-Plane. Check every other third-party plugin in the log for x86_64 compatibility before treating that run as valid.

Before either native or Rosetta testing, no persistent navdata link is required: the installed avionics wrapper creates the old-path link only after X-Plane's scenery discovery and removes it during normal shutdown. This keeps the simulator's startup scenery scan clean while satisfying the arm64 library.

## Result gates

| Gate | Evidence required | Current status |
|---|---|---|
| Static paths | ACF objects and local OBJ textures resolve exactly; simulator-supplied airfoil fallback is present | Local object/texture paths pass; `Clark-Y (good propeller).afl` resolves from the installed X-Plane 12 Airfoils directory |
| Model selector | Legacy is default; no new-model selector is active after rollback | Legacy-only ACF load pass; no selector is installed |
| Clickspots | MCDU popup command is declared and dynamic command families have known runtime owners | Static mapping passes; in-sim click test not run |
| Blue cockpit textures | Preservation manifest hashes are unchanged | Pass; all tracked hashes match after the copy |
| Binary architecture | `file`/`lipo` results for all platform binaries | SASL and avionics-bay are universal; the original AT remains x86_64-only, while the native Lua bridge is available in the main SASL plugin |
| Plugin discovery | Fresh `Log.txt` shows SASL/AT discovery without `dlopen` architecture errors | Rosetta aircraft load pass |
| SASL project | Fresh log shows no fatal Lua/FFI load error and project remains active | Pass: `Module loaded`, 3,956 commands, no bootstrap/font API errors |
| Avionics-bay | Fresh log shows successful initialization and data readiness; exercise navaid/CIFP paths | Direct arm64/x86 readiness pass; SASL aircraft load pass; full navaid/CIFP exercise remains manual |
| Native A/T | Native bridge owns `ATHR_desired_N1` only when enabled and legacy marker is absent; exercise speed/Mach hold and disengagement | Not applicable to the active rollback; original AT remains the Rosetta path |
| In-sim aircraft | Aircraft loads with intended objects, cockpit, systems, and sound behavior | ACF/SASL load pass; manual visual, gear, livery, systems, and AT acceptance remains |

The dual-architecture avionics-bay loader probe confirms that both slices can be opened and that the expected public symbols resolve. The newer direct initialization probes additionally confirm library startup and navdata readiness against the real X-Plane root, but they still do not substitute for full SASL integration or an X-Plane flight.

The earlier 2026-10-20 desktop-bridge attempt reached only simulator startup/scenery discovery. A later clean Rosetta run loaded the final test ACF through X-Plane's local interface and produced the SASL results recorded above. This distinction matters: the old bridge failure is not evidence that the aircraft or the legacy-only ACF failed.

## Historical baseline only

The pre-existing `/Users/lukas/X-Plane 12/Log.txt` contains a prior `HMW_A321Neo_Test` attempt. Its recorded failures include x86_64-only AT and SASL binaries, missing engine/flight-control texture paths, and missing legacy object files in that older test copy. Those lines establish what happened in the old copy; they do not prove the state of this fresh working copy.

# CURRENT ACTIVE PACKAGE OVERRIDE

The active package has been rolled back to the legacy-only model format. The new root fuselage/front-gear objects, model selector, and native AT bridge are removed. Use the original AT plugin through the whole-simulator Rosetta launcher. The historical implementation details below describe the earlier hybrid build and are retained only as audit history.

---

