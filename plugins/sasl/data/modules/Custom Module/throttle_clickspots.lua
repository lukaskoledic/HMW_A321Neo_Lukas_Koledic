-------------------------------------------------------------------------------
-- A32NX Freeware Project
-- Copyright (C) 2020
-------------------------------------------------------------------------------
-- LICENSE: GNU General Public License v3.0
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    Please check the LICENSE file in the root of the repository for further
--    details or check <https://www.gnu.org/licenses/>
-------------------------------------------------------------------------------
-- File: throttle_clickspots.lua
-- Short description: Throttle lever detent clickspots overlay - maps to physical levers
-------------------------------------------------------------------------------

size = { 320, 500 }

local DETENT_TOGA    = 1.00
local DETENT_MCT     = 0.825
local DETENT_CLB     = 0.675
local DETENT_IDLE    = 0.025
local DETENT_REVERSE = -0.50

-- Datarefs for physical throttle levers (move actual 3D levers)
local Cockpit_throttle_lever_L = rawget(_G, "Cockpit_throttle_lever_L") or createGlobalPropertyf("a321neo/cockpit/engine/throttle_lever_L", 0, false, true, false)
local Cockpit_throttle_lever_R = rawget(_G, "Cockpit_throttle_lever_R") or createGlobalPropertyf("a321neo/cockpit/engine/throttle_lever_R", 0, false, true, false)

local function throttle_L(value)
    return function()
        set(Cockpit_throttle_lever_L, value)
    end
end

local function throttle_R(value)
    return function()
        set(Cockpit_throttle_lever_R, value)
    end
end

-- Left throttle lever clickspots (y=440 down to 200, 5 detents)
local CLICK_RECT_THROTTLE_L = {start_vec = {x = 10, y = 440, w = 130, h = 50}, offset_vec = {x = 0, y = -60, w = 0, h = 0}, rpt = {x = 1, y = 5}}
CLICK_RECT_THROTTLE_L.cmd = {}
CLICK_RECT_THROTTLE_L.cmd[1] = {}
CLICK_RECT_THROTTLE_L.cmd[1][1] = throttle_L(DETENT_TOGA)
CLICK_RECT_THROTTLE_L.cmd[2] = {}
CLICK_RECT_THROTTLE_L.cmd[2][1] = throttle_L(DETENT_MCT)
CLICK_RECT_THROTTLE_L.cmd[3] = {}
CLICK_RECT_THROTTLE_L.cmd[3][1] = throttle_L(DETENT_CLB)
CLICK_RECT_THROTTLE_L.cmd[4] = {}
CLICK_RECT_THROTTLE_L.cmd[4][1] = throttle_L(DETENT_IDLE)
CLICK_RECT_THROTTLE_L.cmd[5] = {}
CLICK_RECT_THROTTLE_L.cmd[5][1] = throttle_L(DETENT_REVERSE)

-- Right throttle lever clickspots
local CLICK_RECT_THROTTLE_R = {start_vec = {x = 160, y = 440, w = 130, h = 50}, offset_vec = {x = 0, y = -60, w = 0, h = 0}, rpt = {x = 1, y = 5}}
CLICK_RECT_THROTTLE_R.cmd = {}
CLICK_RECT_THROTTLE_R.cmd[1] = {}
CLICK_RECT_THROTTLE_R.cmd[1][1] = throttle_R(DETENT_TOGA)
CLICK_RECT_THROTTLE_R.cmd[2] = {}
CLICK_RECT_THROTTLE_R.cmd[2][1] = throttle_R(DETENT_MCT)
CLICK_RECT_THROTTLE_R.cmd[3] = {}
CLICK_RECT_THROTTLE_R.cmd[3][1] = throttle_R(DETENT_CLB)
CLICK_RECT_THROTTLE_R.cmd[4] = {}
CLICK_RECT_THROTTLE_R.cmd[4][1] = throttle_R(DETENT_IDLE)
CLICK_RECT_THROTTLE_R.cmd[5] = {}
CLICK_RECT_THROTTLE_R.cmd[5][1] = throttle_R(DETENT_REVERSE)

local CLICK_RECTS = {CLICK_RECT_THROTTLE_L, CLICK_RECT_THROTTLE_R}
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