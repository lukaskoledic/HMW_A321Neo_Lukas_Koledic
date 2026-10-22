-------------------------------------------------------------------------------
-- EFB Page 7 - Systems Debug
-- Debug datarefs for hydraulics, electrical, pneumatic systems
-------------------------------------------------------------------------------

-- Safe dataref getter with fallback
local function safeGet(dr, fallback)
    local ok, val = pcall(get, dr)
    if ok and val ~= nil then return val end
    return fallback
end

-- Format integer with fallback
local function fmtInt(val, fallback)
    if val == nil then return fallback or "---" end
    return string.format("%d", math.floor(val + 0.5))
end

local function mutual_button_loop()
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 1031,18,1099,48, function ()
        efb_subpage_number = math.min(efb_subpage_number + 1, NUMBER_OF_PAGES)
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 954,18,1021,48, function ()
        efb_subpage_number = math.max( efb_subpage_number - 1, 1)
    end)
end

local function mutual_update_loop()
end

local function mutual_draw_loop()
    SASL_draw_img_center_aligned (EFB_INFO_selector, 1026,33, 147, 32, EFB_WHITE)
    sasl.gl.drawText ( Font_Airbus_panel , 880 , 24 , "Page "..efb_subpage_number.."/"..NUMBER_OF_PAGES.."", 20 , false , false , TEXT_ALIGN_CENTER , EFB_WHITE)
end

-- Subpage 1: Hydraulics + Electrical
local function p7s1_buttons()
end

local function p7s1_draw()
    sasl.gl.drawRectangle ( 0 , 0 , 1143 , 710, EFB_BACKGROUND_COLOUR)
    sasl.gl.drawRectangle ( 0 , 710 , 1143, 90, EFB_BACKGROUND_TOP)

    local label_x = 60
    local val_x = 1083
    local row_y = 120
    local col_gap = 400

    -- Title
    drawTextCentered(Font_Airbus_panel, 571, 60, "SYSTEMS DEBUG", 24, false, false, TEXT_ALIGN_CENTER, EFB_WHITE)

    -- HYDRAULICS
    drawTextCentered(Font_Airbus_panel, 300, row_y, "HYDRAULICS", 18, false, false, TEXT_ALIGN_CENTER, EFB_BLUE)
    row_y = row_y + 30

    local hyd_g = safeGet(rawget(_G, "Hydraulic_G_press"), 0)
    local hyd_b = safeGet(rawget(_G, "Hydraulic_B_press"), 0)
    local hyd_y = safeGet(rawget(_G, "Hydraulic_Y_press"), 0)

    local function hydColor(p)
        return p >= 1450 and EFB_GREEN or EFB_RED
    end

    drawText(Font_Airbus_panel, label_x, row_y, "GREEN", 16, false, false, TEXT_ALIGN_LEFT, EFB_LIGHTGREY)
    drawTextCentered(Font_Airbus_panel, val_x, row_y, fmtInt(hyd_g) .. " PSI", 18, false, false, TEXT_ALIGN_RIGHT, hydColor(hyd_g))
    row_y = row_y + 26

    drawText(Font_Airbus_panel, label_x, row_y, "BLUE", 16, false, false, TEXT_ALIGN_LEFT, EFB_LIGHTGREY)
    drawTextCentered(Font_Airbus_panel, val_x, row_y, fmtInt(hyd_b) .. " PSI", 18, false, false, TEXT_ALIGN_RIGHT, hydColor(hyd_b))
    row_y = row_y + 26

    drawText(Font_Airbus_panel, label_x, row_y, "YELLOW", 16, false, false, TEXT_ALIGN_LEFT, EFB_LIGHTGREY)
    drawTextCentered(Font_Airbus_panel, val_x, row_y, fmtInt(hyd_y) .. " PSI", 18, false, false, TEXT_ALIGN_RIGHT, hydColor(hyd_y))
    row_y = row_y + 40

    -- ELECTRICAL
    drawTextCentered(Font_Airbus_panel, 300, row_y, "ELECTRICAL", 18, false, false, TEXT_ALIGN_CENTER, EFB_BLUE)
    row_y = row_y + 30

    local bat1_v = safeGet(rawget(_G, "Elec_bat_1_V"), 0)
    local bat2_v = safeGet(rawget(_G, "Elec_bat_2_V"), 0)
    local gen1 = safeGet(rawget(_G, "Gen_1_line_active"), 0)
    local gen2 = safeGet(rawget(_G, "Gen_2_pwr"), 0)
    local apu_gen = safeGet(rawget(_G, "Ecam_apu_gen_state"), 0)
    local ext_pwr = safeGet(rawget(_G, "Gen_EXT_pwr"), 0)

    local bat1_col = bat1_v >= 25 and EFB_GREEN or EFB_RED
    local bat2_col = bat2_v >= 25 and EFB_GREEN or EFB_RED

    drawText(Font_Airbus_panel, label_x, row_y, "BAT 1", 16, false, false, TEXT_ALIGN_LEFT, EFB_LIGHTGREY)
    drawTextCentered(Font_Airbus_panel, val_x, row_y, fmtNum(bat1_v, "%.1f V"), 18, false, false, TEXT_ALIGN_RIGHT, bat1_col)
    row_y = row_y + 26

    drawText(Font_Airbus_panel, label_x, row_y, "BAT 2", 16, false, false, TEXT_ALIGN_LEFT, EFB_LIGHTGREY)
    drawTextCentered(Font_Airbus_panel, val_x, row_y, fmtNum(bat2_v, "%.1f V"), 18, false, false, TEXT_ALIGN_RIGHT, bat2_col)
    row_y = row_y + 26

    drawText(Font_Airbus_panel, label_x, row_y, "GEN 1", 16, false, false, TEXT_ALIGN_LEFT, EFB_LIGHTGREY)
    drawTextCentered(Font_Airbus_panel, val_x, row_y, gen1 == 1 and "ON" or "OFF", 18, false, false, TEXT_ALIGN_RIGHT, gen1 == 1 and EFB_GREEN or EFB_RED)
    row_y = row_y + 26

    drawText(Font_Airbus_panel, label_x, row_y, "GEN 2", 16, false, false, TEXT_ALIGN_LEFT, EFB_LIGHTGREY)
    drawTextCentered(Font_Airbus_panel, val_x, row_y, gen2 == 1 and "ON" or "OFF", 18, false, false, TEXT_ALIGN_RIGHT, gen2 == 1 and EFB_GREEN or EFB_RED)
    row_y = row_y + 26

    drawText(Font_Airbus_panel, label_x, row_y, "APU GEN", 16, false, false, TEXT_ALIGN_LEFT, EFB_LIGHTGREY)
    local apu_txt = apu_gen == 2 and "ON" or (apu_gen == 3 and "FAIL" or "OFF")
    local apu_col = apu_gen == 2 and EFB_GREEN or (apu_gen == 3 and EFB_RED or EFB_LIGHTGREY)
    drawTextCentered(Font_Airbus_panel, val_x, row_y, apu_txt, 18, false, false, TEXT_ALIGN_RIGHT, apu_col)
    row_y = row_y + 26

    drawText(Font_Airbus_panel, label_x, row_y, "EXT PWR", 16, false, false, TEXT_ALIGN_LEFT, EFB_LIGHTGREY)
    drawTextCentered(Font_Airbus_panel, val_x, row_y, ext_pwr == 1 and "ON" or "OFF", 18, false, false, TEXT_ALIGN_RIGHT, ext_pwr == 1 and EFB_GREEN or EFB_LIGHTGREY)
end

local function p7s1_update()
end

-- Subpage 2: Pneumatic + Flight Controls
local function p7s2_buttons()
end

local function p7s2_draw()
    sasl.gl.drawRectangle ( 0 , 0 , 1143 , 710, EFB_BACKGROUND_COLOUR)
    sasl.gl.drawRectangle ( 0 , 710 , 1143, 90, EFB_BACKGROUND_TOP)

    local label_x = 60
    local val_x = 1083
    local row_y = 120

    -- Title
    drawTextCentered(Font_Airbus_panel, 571, 60, "PNEUMATIC + CONTROLS DEBUG", 24, false, false, TEXT_ALIGN_CENTER, EFB_WHITE)

    -- PNEUMATIC
    drawTextCentered(Font_Airbus_panel, 300, row_y, "PNEUMATIC / BLEED", 18, false, false, TEXT_ALIGN_CENTER, EFB_BLUE)
    row_y = row_y + 30

    local l_bleed = safeGet(rawget(_G, "L_bleed_press"), 0)
    local r_bleed = safeGet(rawget(_G, "R_bleed_press"), 0)
    local apu_bleed = safeGet(rawget(_G, "APU_bleed_switch_pos"), 0)
    local xbleed = safeGet(rawget(_G, "Ecam_bleed_xbleed_valve"), 0)

    drawText(Font_Airbus_panel, label_x, row_y, "ENG 1 BLEED", 16, false, false, TEXT_ALIGN_LEFT, EFB_LIGHTGREY)
    drawTextCentered(Font_Airbus_panel, val_x, row_y, fmtNum(l_bleed, "%.0f PSI"), 18, false, false, TEXT_ALIGN_RIGHT, l_bleed > 30 and EFB_GREEN or EFB_RED)
    row_y = row_y + 26

    drawText(Font_Airbus_panel, label_x, row_y, "ENG 2 BLEED", 16, false, false, TEXT_ALIGN_LEFT, EFB_LIGHTGREY)
    drawTextCentered(Font_Airbus_panel, val_x, row_y, fmtNum(r_bleed, "%.0f PSI"), 18, false, false, TEXT_ALIGN_RIGHT, r_bleed > 30 and EFB_GREEN or EFB_RED)
    row_y = row_y + 26

    drawText(Font_Airbus_panel, label_x, row_y, "APU BLEED", 16, false, false, TEXT_ALIGN_LEFT, EFB_LIGHTGREY)
    drawTextCentered(Font_Airbus_panel, val_x, row_y, apu_bleed == 1 and "ON" or "OFF", 18, false, false, TEXT_ALIGN_RIGHT, apu_bleed == 1 and EFB_GREEN or EFB_LIGHTGREY)
    row_y = row_y + 26

    drawText(Font_Airbus_panel, label_x, row_y, "X-BLEED", 16, false, false, TEXT_ALIGN_LEFT, EFB_LIGHTGREY)
    local xb_txt = xbleed == 2 and "OPEN" or "CLOSED"
    local xb_col = xbleed == 2 and EFB_GREEN or EFB_LIGHTGREY
    drawTextCentered(Font_Airbus_panel, val_x, row_y, xb_txt, 18, false, false, TEXT_ALIGN_RIGHT, xb_col)
    row_y = row_y + 40

    -- FLIGHT CONTROLS
    drawTextCentered(Font_Airbus_panel, 300, row_y, "FLIGHT CONTROLS", 18, false, false, TEXT_ALIGN_CENTER, EFB_BLUE)
    row_y = row_y + 30

    local flap_pos = safeGet(rawget(_G, "Flaps_handle_position"), 0)
    local spdbrk = safeGet(rawget(_G, "SPDBRK_HANDLE_RATIO"), 0)
    local gear_h = safeGet(rawget(_G, "Gear_handle"), 0)
    local rudder_angle = safeGet(rawget(_G, "a321neo/dynamics/FBW/controls/rudder_pedals_angle"), 0)

    drawText(Font_Airbus_panel, label_x, row_y, "FLAPS", 16, false, false, TEXT_ALIGN_LEFT, EFB_LIGHTGREY)
    drawTextCentered(Font_Airbus_panel, val_x, row_y, tostring(flap_pos), 18, false, false, TEXT_ALIGN_RIGHT, EFB_WHITE)
    row_y = row_y + 26

    drawText(Font_Airbus_panel, label_x, row_y, "SPOILERS", 16, false, false, TEXT_ALIGN_LEFT, EFB_LIGHTGREY)
    drawTextCentered(Font_Airbus_panel, val_x, row_y, fmtNum(spdbrk, "%.0f%%", "---"), 18, false, false, TEXT_ALIGN_RIGHT, EFB_WHITE)
    row_y = row_y + 26

    drawText(Font_Airbus_panel, label_x, row_y, "GEAR HANDLE", 16, false, false, TEXT_ALIGN_LEFT, EFB_LIGHTGREY)
    drawTextCentered(Font_Airbus_panel, val_x, row_y, gear_h == 1 and "DOWN" or "UP", 18, false, false, TEXT_ALIGN_RIGHT, gear_h == 1 and EFB_GREEN or EFB_BLUE)
    row_y = row_y + 26

    drawText(Font_Airbus_panel, label_x, row_y, "RUDDER ANGLE", 16, false, false, TEXT_ALIGN_LEFT, EFB_LIGHTGREY)
    drawTextCentered(Font_Airbus_panel, val_x, row_y, fmtNum(rudder_angle, "%.1f°", "---"), 18, false, false, TEXT_ALIGN_RIGHT, EFB_WHITE)
end

local function p7s2_update()
end

-- Number of subpages
local NUMBER_OF_PAGES = 2
local efb_subpage_number = 1

-- Exported functions
function EFB_execute_page_7_buttons()
    if efb_subpage_number == 1 then
        p7s1_buttons()
    elseif efb_subpage_number == 2 then
        p7s2_buttons()
    end
    mutual_button_loop()
end

function EFB_update_page_7()
    if efb_subpage_number == 1 then
        p7s1_update()
    elseif efb_subpage_number == 2 then
        p7s2_update()
    end
    mutual_update_loop()
end

function EFB_draw_page_7()
    if efb_subpage_number == 1 then
        p7s1_draw()
    elseif efb_subpage_number == 2 then
        p7s2_draw()
    end
    mutual_draw_loop()
end
