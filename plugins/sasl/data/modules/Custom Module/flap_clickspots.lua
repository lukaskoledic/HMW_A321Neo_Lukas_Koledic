-------------------------------------------------------------------------------
-- File: flap_clickspots.lua
-- Short description: Flap lever position clickspots overlay - maps to physical flaps
-------------------------------------------------------------------------------

size = { 320, 800 }

-- Flap handle ratio values (0.0 = clean, 1.0 = full)
local FLAP_CLEAN = 0.00
local FLAP_1     = 0.25
local FLAP_1F    = 0.50
local FLAP_2     = 0.75
local FLAP_FULL  = 1.00

-- Dataref for physical flap handle (moves actual flap surfaces)
local Flaps_handle_ratio = rawget(_G, "Flaps_handle_ratio") or globalProperty("sim/cockpit2/controls/flap_ratio")

local function flap_set(value)
    return function()
        set(Flaps_handle_ratio, value)
    end
end

-- Flap lever clickspots (y=740 down to 540, 5 positions: CLEAN, 1, 1+F, 2, FULL)
local CLICK_RECT_FLAPS = {start_vec = {x = 10, y = 740, w = 300, h = 40}, offset_vec = {x = 0, y = -50, w = 0, h = 0}, rpt = {x = 1, y = 5}}
CLICK_RECT_FLAPS.cmd = {}
CLICK_RECT_FLAPS.cmd[1] = {}
CLICK_RECT_FLAPS.cmd[1][1] = flap_set(FLAP_CLEAN)
CLICK_RECT_FLAPS.cmd[2] = {}
CLICK_RECT_FLAPS.cmd[2][1] = flap_set(FLAP_1)
CLICK_RECT_FLAPS.cmd[3] = {}
CLICK_RECT_FLAPS.cmd[3][1] = flap_set(FLAP_1F)
CLICK_RECT_FLAPS.cmd[4] = {}
CLICK_RECT_FLAPS.cmd[4][1] = flap_set(FLAP_2)
CLICK_RECT_FLAPS.cmd[5] = {}
CLICK_RECT_FLAPS.cmd[5][1] = flap_set(FLAP_FULL)

local CLICK_RECTS = {CLICK_RECT_FLAPS}
local click_rect_all = {}

for i, click_rect in ipairs(CLICK_RECTS) do
    for j = 1, click_rect.rpt.x do
        for k = 1, click_rect.rpt.y do
            local rpt_x = j - 1
            local rpt_y = k - 1
            local cmd = nil
            if click_rect.cmd[k] ~= nil then
                if click_rect.cmd[k][j] ~= nil then
                    cmd = click_rect.cmd[k][j]
                end
            end
            if cmd then
                table.insert(click_rect_all, {
                    x = click_rect.start_vec.x + (click_rect.offset_vec.x * rpt_x),
                    y = click_rect.start_vec.y + (click_rect.offset_vec.y * rpt_y),
                    w = click_rect.start_vec.w + (click_rect.offset_vec.w * rpt_x),
                    h = click_rect.start_vec.h + (click_rect.offset_vec.h * rpt_y),
                    cmd = cmd
                })
            end
        end
    end
end

function draw()
    -- Optional: semi-transparent overlay for debugging
    -- sasl.gl.drawRectangle(0, 0, size[1], size[2], {0.1, 0.1, 0.1, 0.35})
end

function onMouseDown(component, x, y, button, parentX, parentY)
    for i, click_rect in ipairs(click_rect_all) do
        if x > click_rect.x and x < click_rect.x + click_rect.w then
            if y > click_rect.y and y < click_rect.y + click_rect.h then
                if button == MB_LEFT then
                    if click_rect.cmd then
                        click_rect.cmd()
                        break
                    end
                end
            end
        end
    end
    return true
end