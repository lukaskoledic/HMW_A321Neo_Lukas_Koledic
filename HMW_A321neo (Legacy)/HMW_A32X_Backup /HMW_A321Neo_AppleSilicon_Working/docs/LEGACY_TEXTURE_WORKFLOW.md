# Legacy exterior and livery texture workflow

The active package is intentionally legacy-only. A321.acf attaches the textured legacy objects under objects/legacy/; the removed new root fuselage/front-gear objects and their selector are not part of the runtime package.

## What the current log shows

The bundled QANTAS and XLR livery PNGs are valid 4096x4096 images. They use the removed new-model names (fuselage_baked.png, stabs_baked.png, wing_baked.png, and undercarriage_baked.png), so they are not the texture names used by the active legacy OBJ files. That path mismatch can make the aircraft appear to use the default scheme or look soft even though the source PNGs are high resolution.

The observed X-Plane log reported texture target scale 1.0 with substantial texture memory available, so the current evidence does not show macOS downscaling these files. If a correctly mapped livery is still soft, check X-Plane's Graphics > Texture Quality setting and restart the simulator.

## Legacy texture map

Livery overrides should mirror the relative path after the aircraft's objects/ directory:

liveries/<Livery>/objects/legacy/texture/

| Legacy object | Day/diffuse texture | Normal map | Notes |
|---|---|---|---|
| fuselage.obj, fuse misc items.obj | fuselage_fuselage_ALB.png | fuselage_fuselage_NRM.png | Main fuselage UV layout |
| h stabs.obj | fuselage_h_stabs_ALB.png | fuselage_h_stabs_NRM.png | Horizontal stabilizers |
| wing.obj | fuselage_wing_ALB.png | fuselage_wing_NRM.png | Wings |
| under carriage.obj | fuselage_wingbox_ALB.png | fuselage_wingbox_NRM.png | Current legacy rear gear/wing-box map; the optional HMW House livery includes a plain-white paint-ready version |
| front gear.obj | front_gears_baked.png | front_gears_baked_NML.png | Nose gear is already textured |
| door.obj | fuselage_inside_doors_ALB.png | fuselage_inside_doors_NRM.png | Interior door surfaces |
| cargo.obj | fuselage_cargo_bay_ALB.png | fuselage_cargo_bay_NRM.png | Optional cargo detail |

The legacy OBJ files use exact-case names. Keep the normal maps from the aircraft unless you have matching legacy normal maps. Do not use undercarriage_baked.png directly on the legacy undercarriage unless it has been repainted/exported for the legacy UV layout; its existing map belongs to the removed new model.

Cabin textures are under the same livery mirror path:

liveries/<Livery>/objects/legacy/cabin_texture/

The blue cockpit textures are outside this livery map and remain preserved in the aircraft package. Do not replace them while painting exterior or gear textures.

## Make a paint-ready starter

From the aircraft package root, run:

    zsh tools/prepare_legacy_livery.command "My Legacy Livery"

The helper creates a new livery directory and copies the current legacy exterior, gear, door, and cargo diffuse maps into the correct paths. Paint those copies, keeping the 4096x4096 dimensions, PNG format, UV placement, and exact filenames. Add matching _NRM.png files only when you have deliberately authored legacy normal maps.

The liveries/_LEGACY_TEXTURE_TEMPLATE/ directory is a non-painted placeholder showing the folder layout and required filenames. It is not a finished livery.

## Quick validation

1. Make sure every file is inside the livery's objects/legacy/ mirror path.
2. Check that filenames and capitalization match the table.
3. Keep images power-of-two; 4096x4096 is the supplied legacy size.
4. Select the livery in X-Plane after restarting the aircraft.
5. If the tail/fuselage artwork is misaligned, the image was made for the removed new-model UVs; start from the legacy starter maps instead.
