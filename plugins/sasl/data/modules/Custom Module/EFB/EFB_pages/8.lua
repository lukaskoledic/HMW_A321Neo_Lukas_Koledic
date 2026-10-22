-------------------------------------------------------------------------------
-- EFB Page 8 - Flight Debug
-- Debug datarefs for navigation, engines, fuel, and flight state
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

-- Format number with fallback
local function fmtNum(val, fmt, fallback)
    if val == nil then return fallback or "---" end
    return string.format(fmt, val)
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

-- Subpage 1: Navigation + Position
local function p8s1_buttons()
end

local function p8s1_draw()
    sasl.gl.drawRectangle ( 0 , 0 , 1143 , 710, EFB_BACKGROUND_COLOUR)
    sasl.gl.drawRectangle ( 0 , 710 , 1143, 90, EFB_BACKGROUND_TOP)

    local label_x = 60
    local val_x = 1083
    local row_y = 120

    -- Title
    drawTextCentered(Font_Airbus_panel, 571, 60, "NAVIGATION DEBUG", 24, false, false, TEXT_ALIGN_CENTER, EFB_WHITE)

    local gps = rawget(_G, "GPS_sys")
    local lat, lon, alt, gs, track = 0, 0, 0, 0, 0
    local gps_ok = false
    if gps and gps[1] and gps[1].status == (rawget(_G, "GPS_STATUS_NAV") or 4) then
        lat = gps[1].lat or 0
        lon = gps[1].lon or 0
        alt = gps[1].alt or 0
        gs = gps[1].gs or 0
        track = gps[1].true_track or 0
        gps_ok = true
    elseif gps and gps[2] and gps[2].status == (rawget(_G, "GPS_STATUS_NAV") or 4) then
        lat = gps[2].lat or 0
        lon = gps[2].lon or 0
        alt = gps[2].alt or 0
        gs = gps[2].gs or 0
        track = gps[2].true_track or 0
        gps_ok = true
    end

    -- Fallback to X-Plane datarefs
    if not gps_ok then
        lat = safeGet(rawget(_G, "Aircraft_lat"), 0)
        lon = safeGet(rawget(_G, "Aircraft_long"), 0)
        alt = safeGet(rawget(_G, "Elevation_m"), 0) * 3.28084
        gs = safeGet(rawget(_G, "Ground_speed_kts"), 0)
        track = safeGet(rawget(_G, "Flightmodel_true_track"), 0)
    end

    local lat_str = string.format("%s%.4f°", lat >= 0 and "N " or "S ", math.abs(lat))
    local lon_str = string.format("%s%.4f°", lon >= 0 and "E " or "W ", math.abs(lon))

    drawText(Font_Airbus_panel, label_x, row_y, "POSITION", 16, false, false, TEXT_ALIGN_LEFT, EFB_LIGHTGREY)
    drawTextCentered(Font_Airbus_panel, val_x, row_y, lat_str, 18, false, false, TEXT_ALIGN_RIGHT, EFB_WHITE)
    row_y = row_y + 26

    drawText(Font_Airbus_panel, label_x, row_y, "LON", 16, false, false, TEXT_ALIGN_LEFT, EFB_LIGHTGREY)
    drawTextCentered(Font_Airbus_panel, val_x, row_y, lon_str, 18, false, false, TEXT_ALIGN_RIGHT, EFB_WHITE)
    row_y = row_y + 32

    drawText(Font_Airbus_panel, label_x, row_y, "ALTITUDE", 16, false, false, TEXT_ALIGN_LEFT, EFB_LIGHTGREY)
    drawTextCentered(Font_Airbus_panel, val_x, row_y, fmtNum(alt, "%.0f ft", "---"), 22, false, false, TEXT_ALIGN_RIGHT, EFB_BLUE)
    row_y = row_y + 30

    drawText(Font_Airbus_panel, label_x, row_y, "GROUND SPD", 16, false, false, TEXT_ALIGN_LEFT, EFB_LIGHTGREY)
    drawTextCentered(Font_Airbus_panel, val_x, row_y, fmtNum(gs, "%.0f kt", "---"), 18, false, false, TEXT_ALIGN_RIGHT, EFB_WHITE)
    row_y = row_y + 26

    drawText(Font_Airbus_panel, label_x, row_y, "TRACK", 16, false, false, TEXT_ALIGN_LEFT, EFB_LIGHTGREY)
    drawTextCentered(Font_Airbus_panel, val_x, row_y, fmtNum(track, "%.0f°", "---"), 18, false, false, TEXT_ALIGN_RIGHT, EFB_WHITE)
    row_y = row_y + 40

    -- FPLN info
    drawTextCentered(Font_Airbus_panel, 300, row_y, "FLIGHT PLAN", 18, false, false, TEXT_ALIGN_CENTER, EFB_BLUE)
    row_y = row_y + 30

    local get_current_fpln = rawget(_G, "FMGS_get_current_fpln")
    local fpln = nil
    if get_current_fpln then
        local ok, result = pcall(get_current_fpln)
        if ok then fpln = result end
    end

    local dep = "XXXX"
    local arr = "XXXX"
    if fpln and fpln.apts then
        if fpln.apts.dep and fpln.apts.dep.id then dep = tostring(fpln.apts.dep.id) end
        if fpln.apts.arr and fpln.apts.arr.id then arr = tostring(fpln.apts.arr.id) end
    end

    drawText(Font_Airbus_panel, label_x, row_y, "DEPARTURE", 16, false, false, TEXT_ALIGN_LEFT, EFB_LIGHTGREY)
    drawTextCentered(Font_Airbus_panel, val_x, row_y, dep, 18, false, false, TEXT_ALIGN_RIGHT, EFB_WHITE)
    row_y = row_y + 26

    drawText(Font_Airbus_panel, label_x, row_y, "ARRIVAL", 16, false, false, TEXT_ALIGN_LEFT, EFB_LIGHTGREY)
    drawTextCentered(Font_Airbus_panel, val_x, row_y, arr, 18, false, false, TEXT_ALIGN_RIGHT, EFB_WHITE)
end

local function p8s1_update()
end

-- Subpage 2: Engines + Fuel
local function p8s2_buttons()
end

local function p8s2_draw()
    sasl.gl.drawRectangle ( 0 , 0 , 1143 , 710, EFB_BACKGROUND_COLOUR)
    sasl.gl.drawRectangle ( 0 , 710 , 1143, 90, EFB_BACKGROUND_TOP)

    local label_x = 60
    local val_x = 1083
    local row_y = 120

    -- Title
    drawTextCentered(Font_Airbus_panel, 571, 60, "ENGINES + FUEL DEBUG", 24, false, false, TEXT_ALIGN_CENTER, EFB_WHITE)

    local eng_dyn = rawget(_G, "ENG.dyn")
    if eng_dyn then
        drawTextCentered(Font_Airbus_panel, 300, row_y, "ENGINES", 18, false, false, TEXT_ALIGN_CENTER, EFB_BLUE)
        row_y = row_y + 30

        local col_w = (1143 - 120) / 2
        for i = 1, 2 do
            local eng = eng_dyn[i]
            local cx = label_x + (i-1) * (col_w + 12)
            local r = row_y

            drawTextCentered(Font_Airbus_panel, cx + col_w/2, r, "ENG " .. i, 16, false, false, TEXT_ALIGN_CENTER, EFB_BLUE)
            r = r + 24

            local n1 = eng.n1 or 0
            local n2 = eng.n2 or 0
            local egt = eng.egt or 0
            local ff = (eng.ff or 0) * 3600
            local oil_temp = eng.oil_temp or 0
            local oil_press = eng.oil_press or 0

            local n1_col = eng.is_avail and EFB_GREEN or EFB_RED
            drawText(Font_Airbus_panel, cx, r, "N1", 14, false, false, TEXT_ALIGN_LEFT, EFB_LIGHTGREY)
            drawTextCentered(Font_Airbus_panel, cx + col_w, r, fmtNum(n1, "%.1f%%", "---"), 16, false, false, TEXT_ALIGN_RIGHT, n1_col)
            r = r + 22

            drawText(Font_Airbus_panel, cx, r, "N2", 14, false, false, TEXT_ALIGN_LEFT, EFB_LIGHTGREY)
            drawTextCentered(Font_Airbus_panel, cx + col_w, r, fmtNum(n2, "%.1f%%", "---"), 16, false, false, TEXT_ALIGN_RIGHT, EFB_WHITE)
            r = r + 22

            local egt_col = egt > 900 and EFB_RED or (egt > 800 and EFB_AMBER or EFB_GREEN)
            drawText(Font_Airbus_panel, cx, r, "EGT", 14, false, false, TEXT_ALIGN_LEFT, EFB_LIGHTGREY)
            drawTextCentered(Font_Airbus_panel, cx + col_w, r, fmtNum(egt, "%.0f°C", "---"), 16, false, false, TEXT_ALIGN_RIGHT, egt_col)
            r = r + 22

            drawText(Font_Airbus_panel, cx, r, "FF", 14, false, false, TEXT_ALIGN_LEFT, EFB_LIGHTGREY)
            drawTextCentered(Font_Airbus_panel, cx + col_w, r, fmtNum(ff, "%.0f kg/h", "---"), 16, false, false, TEXT_ALIGN_RIGHT, EFB_WHITE)
            r = r + 22

            drawText(Font_Airbus_panel, cx, r, "OIL T", 14, false, false, TEXT_ALIGN_LEFT, EFB_LIGHTGREY)
            drawTextCentered(Font_Airbus_panel, cx + col_w, r, fmtNum(oil_temp, "%.0f°C", "---"), 16, false, false, TEXT_ALIGN_RIGHT, oil_temp > 130 and EFB_RED or (oil_temp > 100 and EFB_AMBER or EFB_GREEN))
            r = r + 22

            drawText(Font_Airbus_panel, cx, r, "OIL P", 14, false, false, TEXT_ALIGN_LEFT, EFB_LIGHTGREY)
            drawTextCentered(Font_Airbus_panel, cx + col_w, r, fmtNum(oil_press, "%.0f PSI", "---"), 16, false, false, TEXT_ALIGN_RIGHT, oil_press < 30 and EFB_RED or (oil_press < 50 and EFB_AMBER or EFB_GREEN))
        end
        row_y = row_y + 160
    else
        drawTextCentered(Font_Airbus_panel, 571, row_y, "Engine data unavailable", 16, false, false, TEXT_ALIGN_CENTER, EFB_RED)
        row_y = row_y + 60
    end

    -- FUEL
    row_y = row_y + 20
    drawTextCentered(Font_Airbus_panel, 300, row_y, "FUEL", 18, false, false, TEXT_ALIGN_CENTER, EFB_BLUE)
    row_y = row_y + 30

    local FQ = rawget(_G, "Fuel_quantity")
    local fuel_l = FQ and safeGet(FQ[1], 0) or 0
    local fuel_r = FQ and safeGet(FQ[2], 0) or 0
    local fuel_c = FQ and safeGet(FQ[0], 0) or 0
    local fob = fuel_l + fuel_r + fuel_c

    drawText(Font_Airbus_panel, label_x, row_y, "TOTAL", 16, false, false, TEXT_ALIGN_LEFT, EFB_LIGHTGREY)
    drawTextCentered(Font_Airbus_panel, val_x, row_y, fmtNum(fob, "%.0f kg", "---"), 18, false, false, TEXT_ALIGN_RIGHT, EFB_BLUE)
    row_y = row_y + 26

    drawText(Font_Airbus_panel, label_x, row_y, "LEFT TANK", 16, false, false, TEXT_ALIGN_LEFT, EFB_LIGHTGREY)
    drawTextCentered(Font_Airbus_panel, val_x, row_y, fmtNum(fuel_l, "%.0f kg", "---"), 18, false, false, TEXT_ALIGN_RIGHT, EFB_WHITE)
    row_y = row_y + 26

    drawText(Font_Airbus_panel, label_x, row_y, "CENTER TANK", 16, false, false, TEXT_ALIGN_LEFT, EFB_LIGHTGREY)
    drawTextCentered(Font_Airbus_panel, val_x, row_y, fmtNum(fuel_c, "%.0f kg", "---"), 18, false, false, TEXT_ALIGN_RIGHT, EFB_WHITE)
    row_y = row_y + 26

    drawText(Font_Airbus_panel, label_x, row_y, "RIGHT TANK", 16, false, false, TEXT_ALIGN_LEFT, EFB_LIGHTGREY)
    drawTextCentered(Font_Airbus_panel, val_x, row_y, fmtNum(fuel_r, "%.0f kg", "---"), 18, false, false, TEXT_ALIGN_RIGHT, EFB_WHITE)
end

local function p8s2_update()
end

-- Number of subpages
local NUMBER_OF_PAGES = 2
local efb_subpage_number = 1

-- Exported functions
function EFB_execute_page_8_buttons()
    if efb_subpage_number == 1 then
        p8s1_buttons()
    elseif efb_subpage_number == 2 then
        p8s2_buttons()
    end
    mutual_button_loop()
end

function EFB_update_page_8()
    if efb_subpage_number == 1 then
        p8s1_update()
    elseif efb_subpage_number == 2 then
        p8s2_update()
    end
    mutual_update_loop()
end

function EFB_draw_page_8()
    if efb_subpage_number == 1 then
        p8s1_draw()
    elseif efb_subpage_number == 2 then
        p8s2_draw()
    end
    mutual_draw_loop()
end
