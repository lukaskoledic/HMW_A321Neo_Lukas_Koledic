-------------------------------------------------------------------------------
-- File: rudder_pedal_clickspots.lua
-- Short description: Rudder pedal clickspots overlay - maps to physical rudder input
-------------------------------------------------------------------------------

size = { 400, 200 }

-- Dataref for physical rudder pedal position (used by FBW system)
local Rudder_pedal_pos = rawget(_G, "Rudder_pedal_pos") or createGlobalPropertyf("a321neo/cockpit/FBW/rudder_pedals_pos", 0, false, true, false)

-- X-Plane native yaw input (for direct control)
local XP_YAW = rawget(_G, "XP_YAW") or globalProperty("sim/joystick/yoke_heading_ratio")

local function rudder_set(value)
    return function()
        set(Rudder_pedal_pos, value)
        set(XP_YAW, value)
    end
end

-- Rudder pedal positions: LEFT_FULL (-1.0), CENTER (0.0), RIGHT_FULL (1.0)
local RUDDER_LEFT_FULL  = -1.0
local RUDDER_LEFT_HALF  = -0.5
local RUDDER_CENTER     = 0.0
local RUDDER_RIGHT_HALF = 0.5
local RUDDER_RIGHT_FULL = 1.0

-- Left pedal clickspots (left side of cockpit)
local CLICK_RECT_RUDDER_L = {start_vec = {x = 20, y = 160, w = 80, h = 30}, offset_vec = {x = 0, y = -35, w = 0, h = 0}, rpt = {x = 1, y = 5}}
CLICK_RECT_RUDDER_L.cmd = {}
CLICK_RECT_RUDDER_L.cmd[1] = {}
CLICK_RECT_RUDDER_L.cmd[1][1] = rudder_set(RUDDER_LEFT_FULL)
CLICK_RECT_RUDDER_L.cmd[2] = {}
CLICK_RECT_RUDDER_L.cmd[2][1] = rudder_set(RUDDER_LEFT_HALF)
CLICK_RECT_RUDDER_L.cmd[3] = {}
CLICK_RECT_RUDDER_L.cmd[3][1] = rudder_set(RUDDER_CENTER)
CLICK_RECT_RUDDER_L.cmd[4] = {}
CLICK_RECT_RUDDER_L.cmd[4][1] = rudder_set(RUDDER_RIGHT_HALF)
CLICK_RECT_RUDDER_L.cmd[5] = {}
CLICK_RECT_RUDDER_L.cmd[5][1] = rudder_set(RUDDER_RIGHT_FULL)

-- Right pedal clickspots (right side of cockpit)
local CLICK_RECT_RUDDER_R = {start_vec = {x = 300, y = 160, w = 80, h = 30}, offset_vec = {x = 0, y = -35, w = 0, h = 0}, rpt = {x = 1, y = 5}}
CLICK_RECT_RUDDER_R.cmd = {}
CLICK_RECT_RUDDER_R.cmd[1] = {}
CLICK_RECT_RUDDER_R.cmd[1][1] = rudder_set(RUDDER_LEFT_FULL)
CLICK_RECT_RUDDER_R.cmd[2] = {}
CLICK_RECT_RUDDER_R.cmd[2][1] = rudder_set(RUDDER_LEFT_HALF)
CLICK_RECT_RUDDER_R.cmd[3] = {}
CLICK_RECT_RUDDER_R.cmd[3][1] = rudder_set(RUDDER_CENTER)
CLICK_RECT_RUDDER_R.cmd[4] = {}
CLICK_RECT_RUDDER_R.cmd[4][1] = rudder_set(RUDDER_RIGHT_HALF)
CLICK_RECT_RUDDER_R.cmd[5] = {}
CLICK_RECT_RUDDER_R.cmd[5][1] = rudder_set(RUDDER_RIGHT_FULL)

local CLICK_RECTS = {CLICK_RECT_RUDDER_L, CLICK_RECT_RUDDER_R}
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