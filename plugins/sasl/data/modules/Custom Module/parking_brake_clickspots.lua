-------------------------------------------------------------------------------
-- File: parking_brake_clickspots.lua
-- Short description: Parking brake lever clickspots overlay - maps to physical brake
-------------------------------------------------------------------------------

size = { 160, 200 }

-- Dataref for physical parking brake lever
local XPlane_parkbrake_ratio = rawget(_G, "XPlane_parkbrake_ratio") or globalProperty("sim/cockpit2/controls/parking_brake_ratio")

-- Drawing helpers
local function rect(x, y, w, h, c) sasl.gl.drawRectangle(x, y, w, h, c) end
local function text(x, y, s, size, c, align)
    sasl.gl.drawText(Font_Airbus_panel, x, y, s, size, false, false, align or TEXT_ALIGN_LEFT, c)
end
local function textc(x, y, s, size, c) text(x, y, s, size, c, TEXT_ALIGN_CENTER) end
local function roundRect(x, y, w, h, r, c)
    r = math.min(r, w/2, h/2)
    sasl.gl.drawRectangle(x+r, y, w-2*r, h, c)
    sasl.gl.drawRectangle(x, y+r, w, h-2*r, c)
    sasl.gl.drawCircle(x+r, y+r, r, true, c)
    sasl.gl.drawCircle(x+w-r, y+r, r, true, c)
    sasl.gl.drawCircle(x+r, y+h-r, r, true, c)
    sasl.gl.drawCircle(x+w-r, y+h-r, r, true, c)
end

-- Dataref for physical parking brake lever
local XPlane_parkbrake_ratio = rawget(_G, "XPlane_parkbrake_ratio") or globalProperty("sim/cockpit2/controls/parking_brake_ratio")

local function parkbrake_set(value)
    return function()
        set(XPlane_parkbrake_ratio, value)
    end
end

-- Parking brake: OFF (0.0) and ON (1.0)
local CLICK_RECT_PARKBRAKE = {start_vec = {x = 20, y = 160, w = 120, h = 70}, offset_vec = {x = 0, y = -80, w = 0, h = 0}, rpt = {x = 1, y = 2}}
CLICK_RECT_PARKBRAKE.cmd = {}
CLICK_RECT_PARKBRAKE.cmd[1] = {}
CLICK_RECT_PARKBRAKE.cmd[1][1] = function() set(XPlane_parkbrake_ratio, 1.0) end  -- ON (up)
CLICK_RECT_PARKBRAKE.cmd[2] = {}
CLICK_RECT_PARKBRAKE.cmd[2][1] = function() set(XPlane_parkbrake_ratio, 0.0) end  -- OFF (down)

local CLICK_RECTS = {CLICK_RECT_PARKBRAKE}
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
    -- Parking brake lever visual (plastic lever)
    -- Background
    sasl.gl.drawRectangle(50, 10, 60, 180, {0.08, 0.08, 0.10, 0.9})
    -- Lever
    local pos = get(XPlane_parkbrake_ratio)
    local lever_y = 160 - pos * 150
    roundRect(55, lever_y - 10, 50, 20, 5, {0.85, 0.08, 0.08, 1.0})
    -- ON/OFF labels
    textc(80, 170, "ON", 12, {1,1,1,0.9})
    textc(80, 20, "OFF", 12, {1,1,1,0.9})
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