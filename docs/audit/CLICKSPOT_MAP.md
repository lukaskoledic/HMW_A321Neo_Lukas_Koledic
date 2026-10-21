# Clickspot and command mapping audit

The cockpit OBJ clickspots use SASL command manipulators. The shipped package is legacy-only, so the existing clickspot coordinates are not subject to exterior-model switching.

## Repaired mapping

The two MCDU popup clickspots referenced `a321neo/cockpit/mcdu/toggle_popup`, but that command was not declared in the Lua command table. It is now declared in `cockpit_commands.lua` and handled by `main_menu.lua`:

`a321neo/cockpit/mcdu/toggle_popup` → `MCDU_toggle_popup` → `Show_hide_MCDU()` → `MCDU_window`

This keeps the clickspot behavior aligned with the existing plugin-menu action and the single shared MCDU popup window.

## Dynamic command families

The static audit treats the command, knob, and switch command manipulators in `objects/cockpit_obj/cockpit_3d.obj` as one mapping surface. After including literal `createCommand`/`findCommand` declarations, the only aircraft-local names without a literal declaration are the known runtime-generated families below plus two built-in X-Plane electrical commands. The repaired MCDU popup name is no longer in that set.

| Family | Count | Runtime owner |
|---|---:|---|
| `draims/...` | 90 | `DRAIMS/DRAIMS_handlers.lua` |
| `mcdu_2/...` | 70 | `MCDU/handlers.lua` |
| `overhead/guards/...` | 25 | `graphics.lua` |
| `lights/...` | 20 | `graphics.lua` |
| `sim/electrical/...` | 2 | X-Plane built-in commands |

These dynamic/built-in commands are intentionally not duplicated in the aircraft-local declaration table. The legacy-only rollback adds no model-switch commands or clickspots.

The one dataref-bearing cockpit manipulator remains the simulator-standard flap control, `sim/cockpit2/controls/flap_ratio`, used by the flap drag-rotate spot. It was checked and left unchanged because the reference is already the correct X-Plane dataref; the model swap does not alter that cockpit control.

## Runtime check

The acceptance run should click at least one MCDU popup spot on each side, exercise the DRAIMS/MCDU dynamic command families, and verify the same controls after switching new → legacy. A static command-name match is not a substitute for an in-sim interaction test.
