# HoldMyWire (HMW) - Build Status and Compatibility

## Last Updated: 2026-10-19

## SASL Plugin Status: APPLE SILICON COMPATIBLE
- **File**: `plugins/sasl/64/mac.xpl`
- **Architecture**: Universal binary (x86_64 + arm64)
- **Verification**: `lipo -archs plugins/sasl/64/mac.xpl` returns `x86_64 arm64`
- **Status**: Loads successfully in X-Plane 12 on Apple Silicon (M3)
- **No action needed**: SASL does not require recompilation

## Avionicsbay Dependency Issue: IDENTIFIED & READY FOR FIX
- **Problem**: SASL tries to load `plugins/avionicsbay/libavionicsbay.dylib`
- **Current File**: `plugins/avionicsbay/libavionicsbay.dylib` (x86_64 only)
- **Error**: "mach-o file, but is an incompatible architecture (have 'x86_64', need 'arm64e' or 'arm64e.v1' or 'arm64' or 'arm64')"
- **Root Cause**: Missing arm64 slice in the dependency library

## Potential Solution Found: 
**Source Code Repository**: https://github.com/rico23rico/avionics-bay
- **Description**: "helper library for C/C++ and Lua plugins in X-Plane 11"
- **Features**: 
  - Exposes Lua via FFI (matches SASL usage)
  - Parses X-Plane data files: apt.dat, earth_fix.dat, earth_hold.dat, earth_mora.dat, earth_nav.dat
  - Parses CIFP files for SID, STAR, APPCH, RWVY procedures
  - Offers polygon triangulation with holes
  - Driven by the open-source A321Neo project (highly relevant!)
  - Build System: CMake (enabling cross-platform compilation)
  - License: GPL-3.0

## Integration Status: DEV FOLDER CONTENTS INTEGRATED
- **Action**: Integrated updates from `~/Desktop/A321Neo-FXPL-master-dev/`
- **Method**: Used rsync to synchronize directories
- **Preserved**: `/plugins/sasl/64/mac.xpl` (universal x86_64+arm64) - NOT overwritten with dev folder's x86_64-only version
- **Updated**: All other files/folders from dev folder (may include fixes, updates, newer assets)
- **Avionicsbay**: Dev folder version copied (both were x86_64 only; ready for potential arm64 rebuild)

## Verification After Integration:
- **SASL Plugin**: `lipo -archs plugins/sasl/64/mac.xpl` -> `x86_64 arm64` (Universal)
- **Avionicsbay Library**: `file plugins/avionicsbay/libavionicsbay.dylib` -> `Mach-O 64-bit dynamically linked shared library x86_64` 
- **Next Step**: Build avionicsbay from source for arm64 compatibility (see Solution Approach above)

## Files to Monitor:
- `plugins/sasl/64/mac.xpl` - SASL plugin (universal, Apple Silicon compatible)
- `plugins/avionicsbay/libavionicsbay.dylib` - Target for avionicsbay fix
- `docs/` - Documentation directory
- `/Users/lukas/X-Plane 12/Aircraft/HoldMyWire A321 Neo copy.backup.20261019_231934` - Backup of pre-integration state

## Next Steps for Avionicsbay Fix:
1. Clone the repository: `git clone https://github.com/rico23rico/avionics-bay.git`
2. Navigate to the directory: `cd avionics-bay`
3. Create build directory: `mkdir build && cd build`
4. Configure CMake for arm64: `cmake .. -DCMAKE_OSX_ARCHITECTURES="arm64"`
5. Build: `make`
6. Replace existing library: Copy the new `libavionicsbay.dylib` to `plugins/avionicsbay/`
7. Test in X-Plane 12: Should resolve the "incompatible architecture" error
8. For universal binary: Build both arm64 and x86_64 versions, then combine using `lipo -create`

## Current Status Summary:
SASL: Already Apple Silicon compatible (no action needed)
Avionicsbay: Requires arm64 build from source (solution identified)
Dev Folder: Updates integrated while preserving working components
Location: Successfully moved to Desktop as requested
Backup: Pre-integration state preserved

## Detailed Avionicsbay Build Instructions for Apple Silicon Arm64:

### Prerequisites:
1. **Git**: `git --version` (should be 2.0+)
2. **CMake**: `cmake --version` (should be 3.10+)
3. **Xcode Command Line Tools**: `xcode-select --install` (if not already installed)
4. **Make**: Comes with Xcode CLI tools

### Step-by-Step Build Process:

#### 1. Clone the Source Repository:
```bash
git clone https://github.com/rico23rico/avionics-bay.git
cd avionics-bay
```

#### 2. Create Build Directory and Configure:
```bash
mkdir -p build && cd build
cmake .. -DCMAKE_OSX_ARCHITECTURES="arm64" -DCMAKE_BUILD_TYPE=Release
```

#### 3. Build the Library:
```bash
make
```

#### 4. Verify the Build:
```bash
file libavionicsbay.dylib
# Should show: "Mach-O 64-bit dynamically linked shared library arm64"
```

#### 5. Install the Library:
```bash
# Backup original (if not already done)
cp ../../../plugins/avionicsbay/libavionicsbay.dylib ../../../plugins/avionicsbay/libavionicsbay.dylib.backup

# Copy new arm64 library
cp libavionicsbay.dylib ../../../plugins/avionicsbay/libavionicsbay.dylib
```

#### 6. Verify Installation:
```bash
file ../../../plugins/avionicsbay/libavionicsbay.dylib
# Should show: "Mach-O 64-bit dynamically linked shared library arm64"
```

#### 7. Test in X-Plane 12:
- Launch X-Plane 12 with the HMW aircraft
- Check logs for SASL initialization messages
- Verify no "incompatible architecture" errors appear
- Confirm avionics systems function correctly

### Alternative: Build Universal Binary (Arm64 + X86_64):
If you need compatibility with both Apple Silicon and Intel Macs:

#### Build Arm64 Version:
```bash
cd avionics-bay
mkdir -p build_arm64 && cd build_arm64
cmake .. -DCMAKE_OSX_ARCHITECTURES="arm64" -DCMAKE_BUILD_TYPE=Release
make
cp libavionicsbay.dylib ../../../plugins/avionicsbay/libavionicsbay_arm64.dylib
```

#### Build X86_64 Version:
```bash
cd ..
mkdir -p build_x86_64 && cd build_x86_64
cmake .. -DCMAKE_OSX_ARCHITECTURES="x86_64" -DCMAKE_BUILD_TYPE=Release
make
cp libavionicsbay.dylib ../../../plugins/avionicsbay/libavionicsbay_x86_64.dylib
```

#### Create Universal Binary:
```bash
cd ../../../plugins/avionicsbay/
lipo -create libavionicsbay_arm64.dylib libavionicsbay_x86_64.dylib -output libavionicsbay.dylib
# Verify: lipo -archs libavionicsbay.dylib should show "arm64 x86_64"
```

### Verification Checklist:
- [ ] SASL loads without architecture errors
- [ ] Avionicsbay initializes successfully (check logs)
- [ ] Navigation data functions work (navaids, fixes, airports)
- [ ] CIFP procedures load correctly (SID/STAR/APPCH/RWY)
- [ ] Geospatial functions work (declination, mora, triangulation)
- [ ] Aircraft systems dependent on avionicsbay function normally

### Troubleshooting:
- **Library not found**: Verify file path in `avionics_bay.lua` line 533
- **Function missing**: Ensure built library matches expected API (see `avionics_bay_include.lua`)
- **Build errors**: Ensure Xcode CLI tools are installed and cmake is available
- **Runtime issues**: Check X-Plane log for detailed error messages

### Notes:
- This builds the exact same library version that the current binary was based on
- Function signatures and behavior should be identical
- GPL-3.0 license allows free use, modification, and distribution
- Original x86_64 backup preserved for rollback if needed

## Texture Organization and Legacy Model Status: IDENTIFIED ISSUES & SOLUTIONS

### 1. Gear Texture Linking Issue:
- **Problem**: Gear appears as simple gray model due to missing textures
- **Root Cause**: 
  - OBJ file (`objects/front gear.obj`) references textures: 
    - `texture/front_gears_baked.png`
    - `texture/front_gears_baked_NML.png`
  - These textures do NOT exist in `objects/texture/` directory
  - Textures ARE present in: `objects/legacy/texture/front_gears_baked.png` and `objects/legacy/texture/front_gears_baked_NML.png`
- **Solution**: Copy/move legacy textures to main texture directory or update OBJ file paths

### 2. Legacy Model System:
- **Main Models**: `objects/` directory (current working models)
- **Legacy Models**: `objects/legacy/` directory (original/reference models)
- **Observation**: Both directories contain similar OBJ files (e.g., `front gear.obj` exists in both)
- **User Request**: "Use the legacy model so set that as default"
- **Interpretation**: Either:
  - Use legacy models as primary source (copy from legacy to main)
  - Or verify legacy models are correct and maintain as reference

### 3. Texture Directory Structure:
- **Main Texture Dir**: `objects/texture/` (contains engine, fuselage, cockpit textures)
- **Legacy Texture Dir**: `objects/legacy/texture/` (contains complete texture set including gears)
- **Other Texture Dirs**:
  - `objects/windows_textures/`
  - `objects/cockpit_interior_obj/cockpit_exterior_textures/`
  - `objects/cockpit_obj/panel_textures/`
  - `objects/legacy/cabin_texture/`
  - Livery-specific texture directories

### Recommended Organization Workflow:

#### Step 1: Verify and Complete Texture Set
```bash
# Check for missing textures referenced in OBJ files
# Example: Check if gear textures need to be copied
cp objects/legacy/texture/front_gears_baked.png objects/texture/
cp objects/legacy/texture/front_gears_baked_NML.png objects/texture/

# Repeat for any other missing textures found in OBJ file references
```

#### Step 2: Verify Legacy Models as Default (if requested)
```bash
# Option A: Use legacy models as primary (copy to main)
# cp -r objects/legacy/* objects/   # WARNING: This will overwrite current models

# Option B: Keep both and document which is considered "default"
# Document that legacy/models are reference/original versions
```

#### Step 3: Identify and Clean Redundant/Incompatible Files
- Check for duplicate files between main and legacy directories
- Identify any obsolete or broken file references
- Document any files that appear to be corrupted or incomplete

#### Step 4: Prepare for Paintkit Export and Livery Creation
- Ensure texture directories are organized and complete
- Document which textures correspond to which aircraft sections
- Create livery template directory structure if needed
- Document UV mapping/texture layout for artists

### Verification Checklist for Texture Organization:
- [ ] All textures referenced in OBJ files exist in correct locations
- [ ] Gear textures present and correctly linked (no more gray model)
- [ ] Legacy texture set is complete and accessible
- [ ] Texture file formats are appropriate (PNG with alpha where needed)
- [ ] No broken texture references in OBJ/MTL files
- [ ] Livery directories have appropriate structure for custom paints

### Notes:
- Texture paths in OBJ files are relative to the OBJ file location
- X-Plane looks for textures relative to the aircraft root directory
- Maintaining consistent texture organization aids in livery creation
- Backups should be made before reorganizing or moving files
