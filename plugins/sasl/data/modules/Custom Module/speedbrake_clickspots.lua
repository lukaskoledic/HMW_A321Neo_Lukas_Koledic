-------------------------------------------------------------------------------
-- File: speedbrake_clickspots.lua
-- Short description: Speedbrake/spoiler lever clickspots overlay - maps to physical spoilers
-------------------------------------------------------------------------------

size = { 160, 400 }

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

-- Dataref for physical speedbrake/spoiler lever
local SPDBRK_HANDLE_RATIO = rawget(_G, "SPDBRK_HANDLE_RATIO") or globalProperty("sim/cockpit2/controls/speedbrake_ratio")

local function speedbrake_set(value)
    return function()
        set(SPDBRK_HANDLE_RATIO, value)
    end
end

-- Speedbrake positions: RETRACT (0.0), ARMED (0.25), EXTEND (0.5), FULL (1.0)
local SPDBRK_RETRACT = 0.00
local SPDBRK_ARMED   = 0.25
local SPDBRK_EXTEND  = 0.50
local SPDBRK_FULL    = 1.00

local CLICK_RECT_SPDBRK = {start_vec = {x = 20, y = 340, w = 120, h = 50}, offset_vec = {x = 0, y = -65, w = 0, h = 0}, rpt = {x = 1, y = 4}}
CLICK_RECT_SPDBRK.cmd = {}
CLICK_RECT_SPDBRK.cmd[1] = {}
CLICK_RECT_SPDBRK.cmd[1][1] = speedbrake_set(SPDBRK_FULL)
CLICK_RECT_SPDBRK.cmd[2] = {}
CLICK_RECT_SPDBRK.cmd[2][1] = speedbrake_set(SPDBRK_EXTEND)
CLICK_RECT_SPDBRK.cmd[3] = {}
CLICK_RECT_SPDBRK.cmd[3][1] = speedbrake_set(SPDBRK_ARMED)
CLICK_RECT_SPDBRK.cmd[4] = {}
CLICK_RECT_SPDBRK.cmd[4][1] = speedbrake_set(SPDBRK_RETRACT)

local CLICK_RECTS = {CLICK_RECT_SPDBRK}
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
    -- Speedbrake lever visual (plastic lever with detents)
    -- Background track
    sasl.gl.drawRectangle(50, 20, 60, 320, {0.08, 0.08, 0.10, 0.9})
    -- Detent notches
    for i = 0, 3 do
        local y = 340 - i * 65
        roundRect(45, y - 2, 70, 4, 2, {0.3, 0.3, 0.35, 0.8})
    end
    -- Lever position
    local pos = get(SPDBRK_HANDLE_RATIO)
    local lever_y = 340 - pos * 320
    roundRect(40, lever_y - 15, 80, 30, 6, {0.12, 0.58, 0.95, 1.0})
    -- Specular highlight
    roundRect(42, lever_y - 13, 76, 10, 4, {0.4, 0.8, 1.0, 0.5})
    -- Labels
    textc(80, 360, "RETRACT", 10, {1,1,1,0.6})
    textc(80, 295, "ARMED", 10, {1,1,1,0.6})
    textc(80, 230, "EXTEND", 10, {1,1,1,0.6})
    textc(80, 165, "FULL", 10, {1,1,1,0.6})
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