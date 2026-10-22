# HMW A321neo House Livery Paint Kit

This is a separate, paint-ready starter for the active legacy-only HMW A321neo package. It is not installed into X-Plane and it does not change the aircraft.

The copied PNGs are the current legacy UV maps, all supplied at 4096 x 4096. Paint these files to create the HMW house livery.

## Ready-to-paint livery

The `HMW House/` subfolder is already in X-Plane livery format and contains a plain-white base with dark windows, openings, and hardware retained. Copy that folder into the aircraft package's `liveries/` directory, then edit its PNGs in place.

## Paint here

Edit the files in:

`objects/legacy/texture/`

- `fuselage_fuselage_ALB.png` -- fuselage and fuselage details
- `fuselage_h_stabs_ALB.png` -- horizontal stabilizers
- `fuselage_wing_ALB.png` -- wings
- `fuselage_wingbox_ALB.png` -- wing box and rear-gear area
- `front_gears_baked.png` -- nose gear
- `fuselage_inside_doors_ALB.png` -- door surfaces
- `fuselage_cargo_bay_ALB.png` -- cargo-bay surfaces
- `fuselage_cargo_bay_LIT.png` -- cargo-bay lighting

Keep the exact filenames, capitalization, PNG format, 4096 x 4096 dimensions, and existing UV layout. Do not rename the maps to the old `fuselage_baked.png` or `undercarriage_baked.png` names; those belong to the removed new-model layout.

## Install the finished livery

1. Choose a livery name, such as `HMW House`.
2. In the aircraft package, create:

   `liveries/HMW House/objects/legacy/texture/`

3. Copy the painted PNGs from this kit into that folder.
4. Start or reload the aircraft and select the livery in X-Plane.

Only painted maps need to be copied. The aircraft supplies the matching normal maps unless you deliberately create legacy normal maps with the exact corresponding `_NRM.png` names.

## Placeholders and protected areas

- `objects/legacy/cabin_texture/` is reserved for future cabin-texture overrides. See its README before adding files.
- No fake normal-map PNGs are included. This prevents accidental replacement of the working aircraft normals.
- The blue cockpit textures are intentionally not included in the kit. They remain preserved in the aircraft package and should not be replaced by the house livery.
- The rear gear uses `fuselage_wingbox_ALB.png`; paint that map if you want the rear gear and wing-box area to match. The nose gear has its own map.

## Quality notes

Keep the maps at 4096 x 4096 and avoid exporting them as indexed or heavily compressed images. If the livery looks soft in X-Plane, check Graphics > Texture Quality before reducing the source artwork.

The reference workflow is included in `reference/LEGACY_TEXTURE_WORKFLOW.md`.
