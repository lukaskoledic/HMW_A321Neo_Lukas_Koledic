# HMW A321 Neo — Legacy-only Apple Silicon rollback

Last updated: 2026-10-20 (Europe/Vienna)

The active aircraft package is intentionally back on the legacy format:

- Only the legacy exterior/cabin/gear objects are attached in A321.acf.
- The new root fuselage.obj and front gear.obj objects are removed.
- Model-switch and native-AT modules are removed from the active package.
- The original Intel AT plugin remains available and should be tested by launching the complete simulator under Rosetta.
- The avionics-bay library remains universal (arm64 + x86_64) and the MCDU popup clickspot mapping remains fixed.
- Blue cockpit textures remain hash-verified.

Working package:

/Users/lukas/Desktop/HMW_A321Neo_AppleSilicon_Working/

X-Plane test copy:

/Users/lukas/X-Plane 12/Aircraft/HMW_A321Neo_AppleSilicon_Test/

The original source tree was not modified. A full interactive flight-stack test was not completed because X-Plane stalled during its own startup/scenery-discovery phase; this rollback is ready for user testing.

