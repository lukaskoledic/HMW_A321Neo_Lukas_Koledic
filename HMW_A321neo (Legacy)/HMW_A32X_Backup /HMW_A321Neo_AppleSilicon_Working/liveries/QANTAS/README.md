# QANTAS livery note

The PNGs currently in this livery are 4096x4096, but their names match the removed new-model texture set. The active aircraft is legacy-only, so those files are not automatically applied to the legacy OBJ files.

To create a correctly mapped legacy paint set, run from the aircraft package root:

    zsh tools/prepare_legacy_livery.command "QANTAS Legacy"

Then paint the generated files under liveries/<name> Legacy>/objects/legacy/texture/. Keep the supplied blue cockpit textures unchanged. See docs/LEGACY_TEXTURE_WORKFLOW.md for the complete map.
