-- HMW A321neo EFB Home Widgets (page 1)
-- Liquid glass UI, Fenix-style flight progress, TOGA button, text labels
-- Persistent battery, local clock, plane facts, FPLN progress bar, checklists

include(moduleDirectory .. "/Custom Module/checklists/checklist_constants.lua")
include(moduleDirectory .. "/Custom Module/checklists/before_start.lua")
include(moduleDirectory .. "/Custom Module/checklists/push_start.lua")
include(moduleDirectory .. "/Custom Module/checklists/after_start.lua")
include(moduleDirectory .. "/Custom Module/checklists/before_take_off.lua")
include(moduleDirectory .. "/Custom Module/checklists/after_take_off.lua")
include(moduleDirectory .. "/Custom Module/checklists/descent.lua")
include(moduleDirectory .. "/Custom Module/checklists/landing.lua")
include(moduleDirectory .. "/Custom Module/checklists/after_landing.lua")
include(moduleDirectory .. "/Custom Module/checklists/shutdown.lua")
include(moduleDirectory .. "/Custom Module/checklists/securing_the_aircraft.lua")
include(moduleDirectory .. "/Custom Module/checklists/before_leaving_the_aircraft.lua")
include(moduleDirectory .. "/Custom Module/libs/table.save.lua")
include(moduleDirectory .. "/Custom Module/global_constants.lua")

local W, H = 1143, 800

-- ---------- Liquid Glass Color Palette ----------
local C = {
    -- Glass surfaces
    glass_bg      = {0.08, 0.08, 0.10, 0.75},  -- frosted dark base
    glass_card    = {0.14, 0.14, 0.18, 0.82},  -- card surface
    glass_highlight = {1.0, 1.0, 1.0, 0.18},   -- top edge highlight
    glass_shadow  = {0.0, 0.0, 0.0, 0.45},     -- bottom edge shadow

    -- Accent colors
    blue        = {0.12, 0.58, 0.95, 1.0},
    blue_bright = {0.20, 0.70, 1.00, 1.0},
    blue_dim    = {0.08, 0.40, 0.70, 1.0},
    green       = {0.20, 0.85, 0.50, 1.0},
    red         = {1.00, 0.28, 0.28, 1.0},
    red_gloss   = {1.00, 0.12, 0.12, 1.0},
    amber       = {1.00, 0.75, 0.15, 1.0},
    white       = {1.00, 1.00, 1.00, 1.00},
    white_dim   = {1.00, 1.00, 1.00, 0.60},
    text_main   = {1.00, 1.00, 1.00, 0.95},
    text_muted  = {1.00, 1.00, 1.00, 0.55},
    text_dim    = {1.00, 1.00, 1.00, 0.35},

    -- Plastic TOGA button
    toga_base   = {0.85, 0.08, 0.08, 1.0},
    toga_high   = {1.00, 0.30, 0.30, 1.0},
    toga_shadow = {0.45, 0.04, 0.04, 1.0},
    toga_specular = {1.00, 1.00, 1.00, 0.95},

    -- Dock
    dock_bg     = {0.06, 0.06, 0.08, 0.92},
    dock_active = {0.12, 0.58, 0.95, 1.00},
}

local FONT = Font_Airbus_panel
local FONT_BOLD = Font_Airbus_panel

local EFB_PREF_FILE = (moduleDirectory or "").."/Custom Module/saved_configs/EFB_home.cfg"

-- ---------- Drawing Helpers ----------
local function rect(x, y, w, h, c)
    sasl.gl.drawRectangle(x, y, w, h, c)
end

local function text(x, y, s, size, c, align)
    sasl.gl.drawText(FONT, x, y, s, size, false, false, align or TEXT_ALIGN_LEFT, c)
end

local function textc(x, y, s, size, c)
    text(x, y, s, size, c, TEXT_ALIGN_CENTER)
end

local function textr(x, y, s, size, c)
    text(x, y, s, size, c, TEXT_ALIGN_RIGHT)
end

local function roundRect(x, y, w, h, r, c)
    r = math.min(r, w/2, h/2)
    rect(x+r, y, w-2*r, h, c)
    rect(x, y+r, w, h-2*r, c)
    sasl.gl.drawCircle(x+r, y+r, r, true, c)
    sasl.gl.drawCircle(x+w-r, y+r, r, true, c)
    sasl.gl.drawCircle(x+r, y+h-r, r, true, c)
    sasl.gl.drawCircle(x+w-r, y+h-r, r, true, c)
end

-- Glass card with frosted blur simulation (top highlight + bottom shadow)
local function glassCard(x, y, w, h, r, bg_col, highlight_col, shadow_col)
    -- Main surface
    roundRect(x, y, w, h, r, bg_col)
    -- Top highlight (frosted edge)
    rect(x+1, y+1, w-2, 1, highlight_col)
    -- Bottom shadow
    rect(x+1, y+h-2, w-2, 1, shadow_col)
end

-- Safe dataref getter with fallback
local function safeGet(dr, fallback)
    local ok, val = pcall(get, dr)
    if ok and val ~= nil then return val end
    return fallback
end

-- Format number with fallback
local function fmtNum(val, fmt, fallback)
    if val == nil then return fallback or "---" end
    return string.format(fmt, val)
end

-- Format integer with fallback
local function fmtInt(val, fallback)
    if val == nil then return fallback or "---" end
    return string.format("%d", math.floor(val + 0.5))
end

-- Color for value (green/amber/red based on thresholds)
local function valueColor(val, green_min, amber_min, red_min)
    if val == nil then return C.text_muted end
    if val >= green_min then return C.green end
    if val >= amber_min then return C.amber end
    return C.red
end

-- Plastic TOGA button with 3D gloss
local function plasticTogaButton(x, y, w, h, r, pressed)
    local base = pressed and C.toga_shadow or C.toga_base
    local high = pressed and C.toga_base or C.toga_high
    local shad = pressed and C.toga_base or C.toga_shadow
    local spec = C.toga_specular

    -- Main body
    roundRect(x, y, w, h, r, base)
    -- Top gloss highlight
    rect(x+2, y+2, w-4, h*0.35, high)
    -- Bottom shadow
    rect(x+2, y+h*0.7, w-4, h*0.3, shad)
    -- Specular hotspot
    roundRect(x+w*0.65, y+h*0.15, w*0.25, h*0.3, r*0.4, spec)
    -- "TOGA" text
    textc(x+w/2, y+h*0.52, "TOGA", 20, {1,1,1,1})
end

-- ---------- Persistence ----------
local EFB_PREF_FILE = (moduleDirectory or "").."/Custom Module/saved_configs/EFB_home.cfg"
local EFB_BATTERY = 100
local EFB_LAST_TIME = 0
local EFB_FACT_IDX = 1
local EFB_FACT_TIMER = 0
local EFB_DOCK_APP = 0
local TOGA_PRESSED = false

local function efb_batt_load()
    local ok, t = pcall(table.load, EFB_PREF_FILE)
    if ok and t and type(t.batt) == "number" then EFB_BATTERY = t.batt end
end
local function efb_batt_save()
    local ok, err = pcall(table.save, {batt = EFB_BATTERY}, EFB_PREF_FILE)
end
efb_batt_load()

-- ---------- Facts ----------
local FACTS = {
    "LEAP-1A engines cut fuel burn & noise ~15% over CEO.",
    "A321neo seats up to 244 passengers.",
    "neo = New Engine Option.",
    "A321neo entered service in 2018.",
    "Sharklets are standard on the neo.",
    "A321neo fuselage is 44.51 m long.",
    "Range up to 4,000 nautical miles.",
    "Cabin Flex architecture.",
    "A321neo is the largest A320 family member.",
    "Over 1,700 A321neo family aircraft ordered.",
}

-- ---------- FPLN data (defensive) ----------
local function efb_fpln()
    local dep, arr, active, legs, progress, total = "XXXX", "XXXX", false, 0, 0, 0

    local get_current_fpln = rawget(_G, "FMGS_get_current_fpln")
    local get_next_leg_id = rawget(_G, "FMGS_get_next_leg_id")
    local get_pred_trip_dist = rawget(_G, "FMGS_perf_get_pred_trip_dist")

    local fpln = nil
    if get_current_fpln then
        local ok, result = pcall(get_current_fpln)
        if ok then fpln = result end
    end

    if fpln and fpln.apts then
        if fpln.apts.dep and fpln.apts.dep.id then dep = tostring(fpln.apts.dep.id) end
        if fpln.apts.arr and fpln.apts.arr.id then arr = tostring(fpln.apts.arr.id) end
        if fpln.apts.dep or fpln.apts.arr then active = true end
        if fpln.legs then legs = #fpln.legs end
        if get_next_leg_id and legs > 1 then
            local ok2, nl = pcall(get_next_leg_id)
            if ok2 and nl then progress = math.max(0, math.min(1, (nl-1)/(legs-1))) end
        end
    end

    if get_pred_trip_dist then
        local ok3, tot = pcall(get_pred_trip_dist)
        if ok3 and tot then total = tot end
    end

    return dep, arr, active, legs, progress, total
end

-- ---------- Time ----------
local function fmt_time()
    local t = os.date("*t")
    return string.format("%02d:%02d", t.hour, t.min)
end

-- ---------- Update ----------
function EFB_home_update()
    local t = get(TIME)
    local dt = t - EFB_LAST_TIME
    if dt < 0 then
        EFB_BATTERY = 100
        efb_batt_save()
    elseif dt > 0 then
        EFB_BATTERY = EFB_BATTERY - dt*0.04
        if EFB_BATTERY < 0 then EFB_BATTERY = 0 end
    end
    EFB_LAST_TIME = t

    EFB_FACT_TIMER = EFB_FACT_TIMER + (dt > 0 and dt or 0)
    if EFB_FACT_TIMER > 6 then
        EFB_FACT_TIMER = 0
        EFB_FACT_IDX = (EFB_FACT_IDX % #FACTS) + 1
    end
    if math.floor(t) % 60 == 0 then efb_batt_save() end
end

-- ---------- Buttons ----------
function EFB_home_buttons()
    local cx, cy = EFB_CURSOR_X, EFB_CURSOR_Y
    local W_local = W

    -- Dock apps
    local dock_y = 735
    local dock_h = 55
    local cxmin = W/5
    if cy >= dock_y and cy <= dock_y + 55 then
        local app = math.floor(cx/cxmin) + 1
        if app >= 1 and app <= 5 then EFB_DOCK_APP = app end
    end

    -- TOGA button (top-right area)
    local toga_x = W - 150
    local toga_y = 12
    local toga_w = 120
    local toga_h = 48
    local toga_r = 12
    if cx >= toga_x and cx <= toga_x + toga_w and cy >= toga_y and cy <= toga_y + toga_h then
        TOGA_PRESSED = true
    end

    if TOGA_PRESSED then
        if get(Cockpit_throttle_lever_L) < 0.95 or get(Cockpit_throttle_lever_R) < 0.95 then
            set(Cockpit_throttle_lever_L, 1.0)
            set(Cockpit_throttle_lever_R, 1.0)
        end
    end
end

function EFB_home_on_mouse_up()
    TOGA_PRESSED = false
end

-- ---------- Draw ----------
local function drawClockPanel(x, y, w, h)
    glassCard(x, y, w, h, 16, C.glass_card, C.glass_highlight, C.glass_shadow)
    textc(x + w/2, y + 24, "LOCAL TIME", 14, C.text_muted)
    textc(x + w/2, y + 62, fmt_time(), 44, C.blue)
    textc(x + w/2, y + 112, os.date("%A, %d %b"), 15, C.text_muted)
    local bat_txt = string.format("BATTERY %d%%", math.floor(EFB_BATTERY))
    textc(x + w/2, y + 145, bat_txt, 16, (EFB_BATTERY > 20 and C.green or C.red))
    local bw = math.max(0, 120*(EFB_BATTERY/100))
    roundRect(x + w/2 - 60, y + 168, 120, 10, 5, {0.05,0.05,0.07,0.9})
    roundRect(x + w/2 - 60, y + 168, math.max(0, 120*(EFB_BATTERY/100)), 10, 5, (EFB_BATTERY > 20 and C.green or C.red))
end

local function drawFactPanel(x, y, w, h)
    glassCard(x, y, w, h, 16, C.glass_card, C.glass_highlight, C.glass_shadow)
    textc(x + w/2, y + 24, "PLANE FACT", 14, C.text_muted)
    textc(x + w/2, y + 60, FACTS[EFB_FACT_IDX], 17, C.text_main, TEXT_ALIGN_CENTER)
    textc(x + w/2, y + h - 22, "Tap to refresh", 12, C.text_dim)
end

local function drawChecklistPanel(x, y, w, h)
    glassCard(x, y, w, h, 16, C.glass_card, C.glass_highlight, C.glass_shadow)
    textc(x + w/2, y + 24, "CHECKLISTS", 14, C.text_muted)
    local lists = {
        {name="BEFORE START", tbl=Before_start_checklist},
        {name="PUSH/ START",  tbl=Push_start_checklist},
        {name="BEFORE T/O",   tbl=Before_takeoff_checklist},
        {name="AFTER T/O",    tbl=After_takeoff_checklist},
        {name="DESCENT",      tbl=Descent_checklist},
        {name="LANDING",      tbl=Landing_checklist},
        {name="SHUTDOWN",     tbl=Shutdown_checklist},
    }
    local yy = y + 52
    local shown = 0
    for _, l in ipairs(lists) do
        if type(l.tbl) == "table" and #l.tbl > 0 then
            text(x + 24, yy, l.name, 13, C.blue)
            yy = yy + 18
            local items = 0
            for _, it in ipairs(l.tbl) do
                if it.Type == CHECKLIST_ITEM and items < 3 then
                    local mark = it.Checked and "[X]" or "( )"
                    text(x + 40, yy, mark.."  "..tostring(it.Name), 12, C.text_main)
                    yy = yy + 16
                    items = items + 1
                end
            end
            shown = shown + 1
            yy = yy + 10
        end
        if shown >= 4 then break end
    end
    if shown == 0 then
        textc(x + w/2, y + h/2, "Checklists not loaded", 15, C.text_muted)
    end
end

-- ============================================================
-- NEW LIVE DATA WIDGETS
-- ============================================================

-- Fuel widget: Total fuel, FOB, fuel flow L/R
local function drawFuelWidget(x, y, w, h)
    glassCard(x, y, w, h, 16, C.glass_card, C.glass_highlight, C.glass_shadow)
    textc(x + w/2, y + 20, "FUEL", 14, C.text_muted)

    local FQ = rawget(_G, "Fuel_quantity")
    local fuel_l = FQ and safeGet(FQ[1], 0) or 0
    local fuel_r = FQ and safeGet(FQ[2], 0) or 0
    local fuel_c = FQ and safeGet(FQ[0], 0) or 0
    local fob = fuel_l + fuel_r + fuel_c

    local ff_l = 0
    local ff_r = 0
    local eng_dyn = rawget(_G, "ENG.dyn")
    if eng_dyn and eng_dyn[1] then
        ff_l = eng_dyn[1].ff or 0
        ff_r = eng_dyn[2].ff or 0
    end

    local ff_total = (ff_l + ff_r) * 3600 -- kg/hr

    local row_y = y + 55
    local label_x = x + 24
    local val_x = x + w - 24

    text(label_x, row_y, "TOTAL", 13, C.text_muted)
    textr(val_x, row_y, fmtNum(fob, "%.0f kg", "---"), 18, C.blue)

    row_y = row_y + 28
    text(label_x, row_y, "FOB", 13, C.text_muted)
    textr(val_x, row_y, fmtNum(fob, "%.0f kg", "---"), 18, C.text_main)

    row_y = row_y + 28
    text(label_x, row_y, "FF L / R", 13, C.text_muted)
    textr(val_x, row_y, string.format("%.0f / %.0f kg/h", ff_l * 3600, ff_r * 3600), 16, C.text_main)

    row_y = row_y + 28
    text(label_x, row_y, "FF TOTAL", 13, C.text_muted)
    textr(val_x, row_y, fmtNum(ff_total, "%.0f kg/h", "---"), 16, C.blue)

    -- Fuel bars
    local bar_y = y + h - 45
    local bar_w = w - 48
    local bar_h = 8
    local max_fuel = 24000 -- approximate max for A321neo

    -- Left tank
    local l_ratio = math.min(1, fuel_l / 12000)
    roundRect(x + 24, bar_y, bar_w * 0.3, bar_h, 4, {0.05,0.05,0.07,0.9})
    roundRect(x + 24, bar_y, math.max(0, bar_w * 0.3 * l_ratio), bar_h, 4, C.blue)
    text(x + 24, bar_y - 18, "L", 11, C.text_dim)

    -- Center tank
    local c_ratio = math.min(1, fuel_c / 11000)
    roundRect(x + 24 + bar_w * 0.35, bar_y, bar_w * 0.3, bar_h, 4, {0.05,0.05,0.07,0.9})
    roundRect(x + 24 + bar_w * 0.35, bar_y, math.max(0, bar_w * 0.3 * c_ratio), bar_h, 4, C.amber)
    text(x + 24 + bar_w * 0.35, bar_y - 18, "C", 11, C.text_dim)

    -- Right tank
    local r_ratio = math.min(1, fuel_r / 12000)
    roundRect(x + 24 + bar_w * 0.7, bar_y, bar_w * 0.3, bar_h, 4, {0.05,0.05,0.07,0.9})
    roundRect(x + 24 + bar_w * 0.7, bar_y, math.max(0, bar_w * 0.3 * r_ratio), bar_h, 4, C.blue)
    text(x + 24 + bar_w * 0.7 + bar_w * 0.3 - 10, bar_y - 18, "R", 11, C.text_dim)
end

-- Engines widget: N1%, N2%, EGT, FF, oil temp/pressure for both engines
local function drawEnginesWidget(x, y, w, h)
    glassCard(x, y, w, h, 16, C.glass_card, C.glass_highlight, C.glass_shadow)
    textc(x + w/2, y + 20, "ENGINES", 14, C.text_muted)

    local eng_dyn = rawget(_G, "ENG.dyn")
    if not eng_dyn then
        textc(x + w/2, y + h/2, "Engine data unavailable", 14, C.text_muted)
        return
    end

    local col_w = (w - 60) / 2
    for i = 1, 2 do
        local eng = eng_dyn[i]
        local cx = x + 24 + (i-1) * (col_w + 12)
        local row_y = y + 48

        -- Engine label
        textc(cx + col_w/2, row_y, "ENG " .. i, 15, C.blue)
        row_y = row_y + 22

        local avail = eng.is_avail
        local n1 = eng.n1 or 0
        local n2 = eng.n2 or 0
        local egt = eng.egt or 0
        local ff = (eng.ff or 0) * 3600
        local oil_temp = eng.oil_temp or 0
        local oil_press = eng.oil_press or 0
        local n1_idle = eng.n1_idle or 0

        local n1_col = avail and C.green or C.red
        text(cx, row_y, "N1", 12, C.text_muted)
        textr(cx + col_w, row_y, fmtNum(n1, "%.1f%%", "---"), 16, n1_col)
        row_y = row_y + 20

        text(cx, row_y, "N2", 12, C.text_muted)
        textr(cx + col_w, row_y, fmtNum(n2, "%.1f%%", "---"), 16, C.text_main)
        row_y = row_y + 20

        local egt_col = egt > 900 and C.red or (egt > 800 and C.amber or C.green)
        text(cx, row_y, "EGT", 12, C.text_muted)
        textr(cx + col_w, row_y, fmtNum(egt, "%.0f°C", "---"), 16, egt_col)
        row_y = row_y + 20

        text(cx, row_y, "FF", 12, C.text_muted)
        textr(cx + col_w, row_y, fmtNum(ff, "%.0f kg/h", "---"), 16, C.text_main)
        row_y = row_y + 20

        local oil_t_col = oil_temp > 130 and C.red or (oil_temp > 100 and C.amber or C.green)
        text(cx, row_y, "OIL T", 12, C.text_muted)
        textr(cx + col_w, row_y, fmtNum(oil_temp, "%.0f°C", "---"), 16, oil_t_col)
        row_y = row_y + 20

        local oil_p_col = oil_press < 30 and C.red or (oil_press < 50 and C.amber or C.green)
        text(cx, row_y, "OIL P", 12, C.text_muted)
        textr(cx + col_w, row_y, fmtNum(oil_press, "%.0f PSI", "---"), 16, oil_p_col)

        -- N1 idle reference line
        if n1_idle > 0 then
            text(cx, row_y + 20, "IDLE N1: " .. fmtNum(n1_idle, "%.1f%%"), 11, C.text_dim)
        end
    end
end

-- Navigation widget: Current position (lat/lon), altitude, ground speed, wind
local function drawNavWidget(x, y, w, h)
    glassCard(x, y, w, h, 16, C.glass_card, C.glass_highlight, C.glass_shadow)
    textc(x + w/2, y + 20, "NAVIGATION", 14, C.text_muted)

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

    local row_y = y + 50
    local label_x = x + 24
    local val_x = x + w - 24

    text(label_x, row_y, "POSITION", 13, C.text_muted)
    row_y = row_y + 20
    text(label_x, row_y, "LAT", 12, C.text_dim)
    textr(val_x, row_y, lat_str, 14, C.text_main)
    row_y = row_y + 18
    text(label_x, row_y, "LON", 12, C.text_dim)
    textr(val_x, row_y, lon_str, 14, C.text_main)

    row_y = row_y + 24
    text(label_x, row_y, "ALTITUDE", 13, C.text_muted)
    row_y = row_y + 20
    textr(val_x, row_y, fmtNum(alt, "%.0f ft", "---"), 22, C.blue)

    row_y = row_y + 28
    text(label_x, row_y, "GROUND SPD", 13, C.text_muted)
    textr(val_x, row_y, fmtNum(gs, "%.0f kt", "---"), 18, C.text_main)

    row_y = row_y + 22
    text(label_x, row_y, "TRACK", 13, C.text_muted)
    textr(val_x, row_y, fmtNum(track, "%.0f°", "---"), 18, C.text_main)

    -- Wind (placeholder - would need wind dataref)
    row_y = row_y + 22
    text(label_x, row_y, "WIND", 13, C.text_muted)
    textr(val_x, row_y, "---", 16, C.text_dim)
end

-- Systems widget: Hydraulic pressure (G/B/Y), electrical (battery voltage, gen status), pneumatic (bleed)
local function drawSystemsWidget(x, y, w, h)
    glassCard(x, y, w, h, 16, C.glass_card, C.glass_highlight, C.glass_shadow)
    textc(x + w/2, y + 20, "SYSTEMS", 14, C.text_muted)

    local row_y = y + 48
    local label_x = x + 24
    local val_x = x + w - 24
    local col_gap = 120

    -- HYDRAULICS
    textc(x + w/2, row_y, "HYDRAULIC PRESSURE", 12, C.text_muted)
    row_y = row_y + 22

    local hyd_g = safeGet(rawget(_G, "Hydraulic_G_press"), 0)
    local hyd_b = safeGet(rawget(_G, "Hydraulic_B_press"), 0)
    local hyd_y = safeGet(rawget(_G, "Hydraulic_Y_press"), 0)

    local function hydColor(p)
        return p >= 1450 and C.green or C.red
    end

text(label_x, row_y, "GREEN", 12, C.text_dim)
    textr(label_x + col_gap, row_y, fmtInt(hyd_g) .. " PSI", 14, hydColor(hyd_g))
    row_y = row_y + 18
 
    text(label_x, row_y, "BLUE", 12, C.text_dim)
    textr(label_x + col_gap, row_y, fmtInt(hyd_b) .. " PSI", 14, hydColor(hyd_b))
    row_y = row_y + 18
 
    text(label_x, row_y, "YELLOW", 12, C.text_dim)
    textr(label_x + col_gap, row_y, fmtInt(hyd_y) .. " PSI", 14, hydColor(hyd_y))

    row_y = row_y + 28
    -- ELECTRICAL
    textc(x + w/2, row_y, "ELECTRICAL", 12, C.text_muted)
    row_y = row_y + 22

    local bat1_v = safeGet(rawget(_G, "Elec_bat_1_V"), 0)
    local bat2_v = safeGet(rawget(_G, "Elec_bat_2_V"), 0)
    local gen1 = safeGet(rawget(_G, "Gen_1_line_active"), 0)
    local gen2 = safeGet(rawget(_G, "Gen_2_pwr"), 0)
    local apu_gen = safeGet(rawget(_G, "Ecam_apu_gen_state"), 0)
    local ext_pwr = safeGet(rawget(_G, "Gen_EXT_pwr"), 0)

text(label_x, row_y, "BAT 1", 12, C.text_dim)
    local bat1_col = bat1_v >= 25 and C.green or (bat1_v > 0 and C.amber or C.red)
    textr(label_x + col_gap, row_y, fmtNum(bat1_v, "%.1f V"), 14, bat1_col)
    row_y = row_y + 18
 
    text(label_x, row_y, "BAT 2", 12, C.text_dim)
    local bat2_col = bat2_v >= 25 and C.green or (bat2_v > 0 and C.amber or C.red)
    textr(label_x + col_gap, row_y, fmtNum(bat2_v, "%.1f V"), 14, bat2_col)
    row_y = row_y + 18
 
    text(label_x, row_y, "GEN 1", 12, C.text_dim)
    textr(label_x + col_gap, row_y, gen1 == 1 and "ON" or "OFF", 14, gen1 == 1 and C.green or C.red)
    row_y = row_y + 18
 
    text(label_x, row_y, "GEN 2", 12, C.text_dim)
    textr(label_x + col_gap, row_y, gen2 == 1 and "ON" or "OFF", 14, gen2 == 1 and C.green or C.red)
    row_y = row_y + 18
 
    text(label_x, row_y, "APU GEN", 12, C.text_dim)
    local apu_txt = apu_gen == 2 and "ON" or (apu_gen == 3 and "FAIL" or "OFF")
    local apu_col = apu_gen == 2 and C.green or (apu_gen == 3 and C.red or C.text_dim)
    textr(label_x + col_gap, row_y, apu_txt, 14, apu_col)

    row_y = row_y + 28
    -- PNEUMATIC / BLEED
    textc(x + w/2, row_y, "PNEUMATIC", 12, C.text_muted)
    row_y = row_y + 22

    local l_bleed = safeGet(rawget(_G, "L_bleed_press"), 0)
    local r_bleed = safeGet(rawget(_G, "R_bleed_press"), 0)
    local apu_bleed = safeGet(rawget(_G, "APU_bleed_switch_pos"), 0)
    local xbleed = safeGet(rawget(_G, "Ecam_bleed_xbleed_valve"), 0)

text(label_x, row_y, "ENG 1 BLEED", 12, C.text_dim)
    local l_col = l_bleed > 30 and C.green or C.red
    textr(label_x + col_gap, row_y, fmtNum(l_bleed, "%.0f PSI"), 14, l_col)
    row_y = row_y + 18
 
    text(label_x, row_y, "ENG 2 BLEED", 12, C.text_dim)
    local r_col = r_bleed > 30 and C.green or C.red
    textr(label_x + col_gap, row_y, fmtNum(r_bleed, "%.0f PSI"), 14, r_col)
    row_y = row_y + 18
 
    text(label_x, row_y, "APU BLEED", 12, C.text_dim)
    textr(label_x + col_gap, row_y, apu_bleed == 1 and "ON" or "OFF", 14, apu_bleed == 1 and C.green or C.text_dim)
    row_y = row_y + 18
 
    text(label_x, row_y, "X-BLEED", 12, C.text_dim)
    local xb_txt = xbleed == 2 and "OPEN" or "CLOSED"
    local xb_col = xbleed == 2 and C.green or C.text_dim
    textr(label_x + col_gap, row_y, xb_txt, 14, xb_col)
end

-- Flight Controls widget: Flap position, spoiler position, gear position, trim
local function drawFltCtlWidget(x, y, w, h)
    glassCard(x, y, w, h, 16, C.glass_card, C.glass_highlight, C.glass_shadow)
    textc(x + w/2, y + 20, "FLIGHT CONTROLS", 14, C.text_muted)

    local flap_pos = safeGet(rawget(_G, "Flaps_handle_position"), 0)
    local flap_ratio = safeGet(rawget(_G, "Flaps_handle_ratio"), 0)
    local spdbrk_ratio = safeGet(rawget(_G, "SPDBRK_HANDLE_RATIO"), 0)
    local gear_handle = safeGet(rawget(_G, "Gear_handle"), 0)
    local nose_gear = safeGet(rawget(_G, "Front_gear_deployment"), 0)
    local left_gear = safeGet(rawget(_G, "Left_gear_deployment"), 0)
    local right_gear = safeGet(rawget(_G, "Right_gear_deployment"), 0)
    local rudder_trim = safeGet(rawget(_G, "Rudder_trim_knob_pos"), 0)

    local flap_labels = {"0", "1", "1+F", "2", "3", "FULL"}
    local flap_label = flap_labels[flap_pos + 1] or tostring(flap_pos)

    local row_y = y + 50
    local label_x = x + 24
    local val_x = x + w - 24

    -- FLAPS
    text(label_x, row_y, "FLAPS", 13, C.text_muted)
    textr(val_x, row_y, flap_label, 18, C.blue)
    -- Flap position bar
    local bar_w = w - 48
    local bar_h = 8
    local bar_y = row_y + 22
    roundRect(label_x, bar_y, bar_w, bar_h, 4, {0.05,0.05,0.07,0.9})
    local flap_fill = math.min(1, flap_ratio) * bar_w
    roundRect(label_x, bar_y, flap_fill, bar_h, 4, C.blue)
    row_y = bar_y + 20

    -- SPOILERS
    text(label_x, row_y, "SPOILERS", 13, C.text_muted)
    local spdbrk_txt = spdbrk_ratio < 0.1 and "RET" or (spdbrk_ratio < 0.3 and "ARMED" or "EXT")
    local spdbrk_col = spdbrk_ratio < 0.1 and C.green or (spdbrk_ratio < 0.3 and C.amber or C.blue)
    textr(val_x, row_y, spdbrk_txt, 16, spdbrk_col)
    bar_y = row_y + 22
    roundRect(label_x, bar_y, bar_w, bar_h, 4, {0.05,0.05,0.07,0.9})
    local spdbrk_fill = math.min(1, math.max(0, spdbrk_ratio)) * bar_w
    roundRect(label_x, bar_y, spdbrk_fill, bar_h, 4, spdbrk_col)
    row_y = bar_y + 20

    -- GEAR
    text(label_x, row_y, "GEAR", 13, C.text_muted)
    local gear_txt = gear_handle == 1 and "DOWN" or "UP"
    local gear_col = gear_handle == 1 and C.green or C.blue
    textr(val_x, row_y, gear_txt, 16, gear_col)
    row_y = row_y + 22
    -- Gear indicators
    local gx = label_x
    local gy = row_y
    local gs = 14
    local gap = 6
    -- Nose
    local nose_col = nose_gear >= 0.95 and C.green or (nose_gear > 0.05 and C.amber or C.red)
    roundRect(gx, gy, gs, gs, 3, nose_col)
    text(gx + gs + 4, gy + 2, "N", 11, C.text_dim)
    -- Left
    local left_col = left_gear >= 0.95 and C.green or (left_gear > 0.05 and C.amber or C.red)
    roundRect(gx + gs + gap + 30, gy, gs, gs, 3, left_col)
    text(gx + gs + gap + 30 + gs + 4, gy + 2, "L", 11, C.text_dim)
    -- Right
    local right_col = right_gear >= 0.95 and C.green or (right_gear > 0.05 and C.amber or C.red)
    roundRect(gx + 2*(gs + gap + 30), gy, gs, gs, 3, right_col)
    text(gx + 2*(gs + gap + 30) + gs + 4, gy + 2, "R", 11, C.text_dim)
    row_y = gy + gs + 14

    -- TRIM
    text(label_x, row_y, "RUDDER TRIM", 13, C.text_muted)
    local trim_val = rudder_trim * 100 -- convert to percent
    local trim_col = trim_val ~= 0 and C.amber or C.green
    textr(val_x, row_y, fmtNum(trim_val, "%.0f%%", "0%"), 16, trim_col)
    bar_y = row_y + 22
    roundRect(label_x, bar_y, bar_w, bar_h, 4, {0.05,0.05,0.07,0.9})
    local trim_fill = (trim_val + 100) / 200 * bar_w -- -100 to +100 -> 0 to 1
    local trim_center = label_x + bar_w / 2
    if trim_val >= 0 then
        roundRect(trim_center, bar_y, trim_fill, bar_h, 4, C.amber)
    else
        roundRect(trim_center - math.abs(trim_fill), bar_y, math.abs(trim_fill), bar_h, 4, C.amber)
    end
    -- Center line
    rect(trim_center, bar_y, 1, bar_h, {1,1,1,0.3})
end

local function drawHomeGrid()
    local gw, gh = 350, 220
    local gx, gy = 30, 225
    local gap = 20
    -- Row 1
    drawFuelWidget(gx, gy, gw, gh)
    drawEnginesWidget(gx + gw + gap, gy, gw, gh)
    drawNavWidget(gx + 2*(gw + gap), gy, gw, gh)
    -- Row 2
    drawSystemsWidget(gx, gy + gh + gap, gw, gh)
    drawFltCtlWidget(gx + gw + gap, gy + gh + gap, gw, gh)
    drawChecklistPanel(gx + 2*(gw + gap), gy + gh + gap, gw, gh)
    -- Row 3
    drawChecklistPanel(gx, gy + 2*(gh + gap), gw, gh)
end

-- Fenix-style progress bar (text only, no aircraft icon)
local function drawFplnBar()
    local dep, arr, active, legs, progress, total = efb_fpln()
    local label = (dep ~= "XXXX" and arr ~= "XXXX") and (dep.."-"..arr) or "XXXX-XXXX"
    local bx, by, bw, bh = (W-700)/2, 115, 700, 95
    glassCard(bx, by, bw, bh, 16, C.glass_card, C.glass_highlight, C.glass_shadow)
    textc(bx + bw/2, by + 18, "FLIGHT", 12, C.text_muted)
    textc(bx + bw/2, by + 44, label, 28, (active and C.blue_bright or C.text_muted), TEXT_ALIGN_CENTER)

    -- Progress bar (text labels only)
    local bar_x, bar_y, bar_w, bar_h = bx + 40, by + 70, bw - 80, 12
    local r = 6
    roundRect(bar_x, bar_y, bar_w, bar_h, r, {0.05,0.05,0.07,0.9})
    local fill_w = math.max(0, bar_w * progress)
    if fill_w > 0 then
        roundRect(bar_x, bar_y, fill_w, bar_h, r, {0.12,0.58,0.95,1.0})
    end
    textc(bx + bw/2, by + 86, string.format("FLIGHT PROGRESS  %d%%   %d LEGS", math.floor(progress*100), legs), 12, C.text_muted)
end

function EFB_home_draw()
    -- Full-screen frosted glass background
    rect(0, 0, W, H, {0.04, 0.04, 0.05, 1.0})
    -- Subtle vignette
    for i = 1, 3 do
        roundRect(-i*W*0.5, -i*H*0.5, W+i*W, H+i*H, 0, {0,0,0,0.02})
    end

    -- Header glass bar
    glassCard(0, 0, W, 100, 0, {0.06,0.06,0.08,0.95}, {1,1,1,0.12}, {0,0,0,0.25})
    rect(0, 98, W, 1, {0,0,0,0.15})
    text(30, 32, "HMW A321neo", 24, C.text_main)
    text(30, 60, "A32X   HoldMyWire   Lukas Koledic", 15, C.text_muted)
    textr(W - 30, 34, fmt_time(), 20, C.text_main)
    local bat_col = (EFB_BATTERY > 20 and C.text_muted or C.red)
    textr(W - 30, 62, string.format("BATTERY %d%%", math.floor(EFB_BATTERY)), 14, bat_col)

    -- TOGA button (top-right, glossy plastic)
    local toga_x = W - 150
    local toga_y = 12
    local toga_w = 120
    local toga_h = 48
    local toga_r = 12
    plasticTogaButton(toga_x, toga_y, toga_w, toga_h, toga_r, TOGA_PRESSED)

    -- Fenix-style flight progress bar
    drawFplnBar()

    -- Content area
    if EFB_DOCK_APP == 0 then
        drawHomeGrid()
    elseif EFB_DOCK_APP == 5 then
        drawClockPanel(30, 120, W - 60, 560)
    else
        local titles = { [1]="AviTab", [2]="ChartFox", [3]="Browser", [4]="Clock", [6]="Checklist" }
        glassCard(30, 225, W - 60, 480, 16, C.glass_card, C.glass_highlight, C.glass_shadow)
        text(50, 250, titles[EFB_DOCK_APP] or "App", 20, C.text_main)
        text(50, 280, "Real browser / sync not available in SASL - mock view", 13, C.text_muted)
        if EFB_DOCK_APP == 6 then
            drawChecklistPanel(50, 310, W - 110, 380)
        end
    end

    -- Bottom dock (liquid glass, text labels only)
    local dock_y = 735
    local dock_h = 55
    glassCard(0, dock_y, W, dock_h, 0, C.dock_bg, {1,1,1,0.1}, {0,0,0,0.3})
    local apps = {"AviTab", "ChartFox", "Browser", "Clock", "Checklist"}
    local cxmin = W/5
    for i = 1, 5 do
        local x = (i-1)*cxmin
        local sel = (EFB_DOCK_APP == i)
        roundRect(x + 5, dock_y + 5, cxmin - 10, dock_h - 10, 6, sel and C.dock_active or {0.1,0.1,0.12,0.6})
        textc(x + cxmin/2, dock_y + 28, apps[i], 13, (sel and C.white or C.text_muted))
    end

    -- Dead state overlay
    if EFB_BATTERY <= 0 then
        rect(0, 0, W, H, {0.02, 0.02, 0.03, 0.95})
        textc(W/2, H/2 - 10, "EFB DEAD - BATTERY DEPLETED", 22, C.red, TEXT_ALIGN_CENTER)
        textc(W/2, H/2 + 22, "Recharge on new flight", 15, {1,1,1,0.8}, TEXT_ALIGN_CENTER)
    end
end

-- Expose mouse up handler
function EFB_home_on_mouse_up()
    TOGA_PRESSED = false
end
