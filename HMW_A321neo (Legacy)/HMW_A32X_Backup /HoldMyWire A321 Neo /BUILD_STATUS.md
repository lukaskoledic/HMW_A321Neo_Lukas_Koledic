
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
