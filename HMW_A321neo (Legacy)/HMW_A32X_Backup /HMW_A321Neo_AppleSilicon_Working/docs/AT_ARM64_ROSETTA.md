# AT and Rosetta test mode

Last updated: 2026-10-20 (Europe/Vienna)

The active aircraft package is back on the legacy format. The native AT bridge and model selector were removed. The original AT binary remains unchanged and is Intel x86_64-only.

On Apple Silicon, test this package by launching the complete simulator under Rosetta:

/Users/lukas/Desktop/HMW_A321Neo_AppleSilicon_Working/tools/run_xplane_rosetta.command

Then load:

/Users/lukas/X-Plane 12/Aircraft/HMW_A321Neo_AppleSilicon_Test/A321.acf

macOS cannot translate one embedded X-Plane plugin independently inside a native arm64 simulator process. Rosetta must run the full X-Plane process. The simulator's universal SASL and avionics binaries remain compatible with the x86_64 process.

Do not add a persistent navdata link. The aircraft's avionics wrapper creates the compatibility link only after aircraft initialization and removes it on normal shutdown.

