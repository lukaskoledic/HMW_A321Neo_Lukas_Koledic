# HMW A321neo — EFB Layout Audit

**Assessment Date:** 2026-10-21
**Project Directory:** `/Users/lukas/X-Plane 12/Aircraft/HMW_A321Neo_AppleSilicon_Dev/`
**Screen Dimensions:** W=1143, H=800

---

## Spacing Standard

**Minimum padding:** 5 pixels between UI content and screen edges, borders, divider lines, and neighbouring elements.

---

## Page-by-Page Audit

### Page 1 — Home (`efb_home_widgets.lua`)

| Element | Position/Size | Padding Check | Status |
|---------|--------------|---------------|--------|
| Header glass bar | glassCard(0, 0, W, 100, ...) | Top edge: 0px (screen edge) | **OK** (intentional full-width) |
| Header divider line | rect(0, 98, W, 1) | Bottom of header: 98px, divider at y=98 | **OK** |
| Header title text | text(30, 32, ...) | Left margin: 30px ✓ | **OK** |
| Header time | textr(W-30, 34, ...) | Right margin: 30px ✓ | **OK** |
| TOGA button | W-150 to W, y=12 to 60 | Right margin: 30px, below header divider (y=98) | **OK** |
| FPLN bar | y=115 to y=210 (bh=95) | Below header divider (y=98): 17px gap ✓ | **OK** |
| FPLN progress bar | bar_y=by+70, bar_h=12 | Inside card ✓ | **OK** |
| Content panel (mock apps) | glassCard(30, 120, W-60, 560) | **OVERLAP** with FPLN bar (ends y=210) | **ISSUE** |
| Home grid widgets | y=225, gw=350, gh=220, gap=20 | Below FPLN bar (y=210): 15px gap ✓ | **OK** |
| Widget inter-gap | gap=20 | Between widgets: 20px ✓ | **OK** |
| Bottom dock | glassCard(0, 735, W, 55) | Bottom edge: 800-735-55=0px (screen edge) | **OK** (intentional full-width) |
| Dock items | x margins: 4px, cxmin-8 width | Inside dock bounds ✓ | **OK** |
| Dock text | textc at dock_y+28 | Centered in 55px dock ✓ | **OK** |
| Dead state overlay | rect(0,0,W,H) | Full screen overlay (intentional) | **OK** |

**Issue Found:** Mock app panel at y=120 overlaps FPLN bar ending at y=210. Fix: move mock panel to y=225 to match home grid start.

---

### Pages 2-9 — MCDU / Performance / Fuel / Systems / Manuals

| Page | File | Status | Notes |
|------|------|--------|-------|
| 2 | MCDU main | Untested | Uses EFB common buttons |
| 3 | Performance | Untested | Has subpages for config |
| 4 | Fuel/Payload | Untested | Has sliders |
| 5 | Systems | Untested | Has text input |
| 6-9 | Placeholder | Untested | Minimal content |

**Note:** Pages 2-9 were not modified in this session and were previously assessed as working. Detailed spacing audit requires sim testing.

---

## Issues Found

### 1. Page 1 Mock Panel Overlap (Confirmed)
**Location:** `efb_home_widgets.lua:865` — `glassCard(30, 120, W - 60, 560, ...)` overlaps FPLN bar (y=115-210).
**Fix:** Change y from 120 to 225 to align with home grid start.

### 2. Page 1 Dock Hitbox
**Location:** `efb_home_widgets.lua:877-885` — Dock items use `roundRect(x + 4, dock_y + 4, cxmin - 8, dock_h - 8, ...)` with 4px padding inside dock.
**Status:** 4px padding is slightly below the 5px minimum standard. Fix: increase to 5px.

### 3. Page 1 Header Divider
**Location:** Line 840 — `rect(0, 98, W, 1, ...)` at y=98.
**Status:** Divider is at bottom edge of header card (y=100). 2px gap between divider text and divider line. Acceptable but tight.

---

## Files Modified This Session

| File | Change |
|------|--------|
| `efb_home_widgets.lua` | Removed `frostedIcon()` function, removed `fenixProgressBar()` aircraft icon, replaced dock icons with text labels + selection background, simplified `drawFplnBar()` |

---

## Remaining Tasks

- [ ] Fix mock panel overlap (y=120 → y=225)
- [ ] Increase dock item padding from 4px to 5px
- [ ] Sim test all EFB pages for spacing/overlap
- [ ] Create automated intersection checks (optional)
- [ ] Review pages 2-9 for spacing compliance
