#!/usr/bin/env python3
"""Generate a plane-inspired installer background PNG (pure stdlib, no PIL).

Renders a dusk aviation scene: deep navy-to-warm-amber vertical sky gradient,
a soft horizon glow band, a subtle star field in the upper sky, and a
stylised twin-engine airliner silhouette climbing across the frame.
"""
import math
import struct
import sys
import zlib

W = 1280
H = 800


def lerp(a, b, t):
    return a + (b - a) * t


def mix(c1, c2, t):
    return tuple(int(round(lerp(c1[i], c2[i], t))) for i in range(3))


# Palette
ZENITH = (11, 18, 38)      # deep navy at the top
UPPER = (26, 38, 78)       # dusk blue
MID = (58, 74, 130)        # transition
HORIZON = (196, 122, 96)   # warm amber near the horizon
GLOW = (247, 196, 140)     # bright horizon glow
GROUND = (16, 18, 30)      # dark ground below the horizon

HORIZON_Y = int(H * 0.68)


def sky_color(y):
    """Vertical sky gradient with a warm glow band at the horizon."""
    if y < HORIZON_Y:
        t = y / HORIZON_Y
        if t < 0.42:
            return mix(ZENITH, UPPER, t / 0.42)
        if t < 0.78:
            return mix(UPPER, MID, (t - 0.42) / 0.36)
        return mix(MID, HORIZON, (t - 0.78) / 0.22)
    t = (y - HORIZON_Y) / max(1, (H - HORIZON_Y))
    dim = tuple(int(c * 0.55) for c in HORIZON)
    return mix(dim, GROUND, min(1.0, t * 2.2))


def glow_factor(y):
    """Intensity of the warm glow band around the horizon."""
    d = abs(y - HORIZON_Y)
    return max(0.0, 1.0 - d / 150.0) ** 2.2


# ---------------------------------------------------------------------------
# Airliner silhouette (top-down-ish side profile, climbing to the right)
# ---------------------------------------------------------------------------
PLANE_CX = 880.0
PLANE_CY = 300.0
PLANE_SCALE = 1.0
PLANE_ANGLE = math.radians(-14.0)


def plane_local(px, py):
    """Transform a point into the plane's local frame (origin at fuselage mid)."""
    dx = px - PLANE_CX
    dy = py - PLANE_CY
    c, s = math.cos(-PLANE_ANGLE), math.sin(-PLANE_ANGLE)
    lx = (dx * c - dy * s) * PLANE_SCALE
    ly = (dx * s + dy * c) * PLANE_SCALE
    return lx, ly


def inside_plane(px, py):
    """True if the pixel falls inside the airliner silhouette."""
    lx, ly = plane_local(px, py)

    # Fuselage: tapered capsule running along local X
    if -230.0 <= lx <= 230.0:
        # nose taper
        if lx > 150.0:
            half = 15.0 * (230.0 - lx) / 80.0
        elif lx < -190.0:
            half = 15.0 * (lx + 230.0) / 40.0
        else:
            half = 15.0
        if abs(ly) <= half:
            return True

    # Vertical tail fin
    if -230.0 <= lx <= -175.0:
        t = (lx + 230.0) / 55.0
        if 12.0 <= ly <= 12.0 + 78.0 * t:
            return True

    # Horizontal stabiliser
    if -215.0 <= lx <= -155.0 and abs(ly) <= 46.0 and ly >= 6.0:
        return True

    # Main wings (swept back from root)
    if -30.0 <= lx <= 120.0:
        span = abs(ly)
        if 12.0 <= span <= 175.0:
            # leading edge sweeps back, trailing edge roughly straight
            lead = 120.0 - (span - 12.0) * 0.42
            trail = 20.0 + (span - 12.0) * 0.05
            if trail <= lx <= lead:
                return True

    # Engines
    for ex in (30.0, 75.0):
        ex2 = ex
        for ey in (-62.0, 62.0):
            ddx = (lx - ex2) / 30.0
            ddy = (ly - ey) / 11.0
            if ddx * ddx + ddy * ddy <= 1.0:
                return True

    return False


def plane_shade(px, py):
    """Simple lighting for the silhouette so it reads as a 3D shape."""
    lx, ly = plane_local(px, py)
    # Lighter along the top of the fuselage, darker underneath
    if abs(lx) > 150.0:
        base = 0.30
    else:
        base = 0.22 + 0.10 * (1.0 - min(1.0, abs(ly) / 15.0))
    # Slight rim brightening on the sunward (upper) edge
    if ly < -4.0:
        base += 0.16
    return base


# ---------------------------------------------------------------------------
# Stars
# ---------------------------------------------------------------------------
def star_field():
    stars = []
    seed = 20251022
    for _ in range(320):
        seed = (seed * 1103515245 + 12345) & 0x7FFFFFFF
        x = seed % W
        seed = (seed * 1103515245 + 12345) & 0x7FFFFFFF
        y = seed % int(HORIZON_Y * 0.72)
        seed = (seed * 1103515245 + 12345) & 0x7FFFFFFF
        b = (seed % 100) / 100.0
        if y < 40:
            b *= y / 40.0
        stars.append((x, y, b))
    return stars


STARS = star_field()


def render():
    rows = []
    plane_px = []
    for y in range(H):
        row = bytearray()
        base = sky_color(y)
        gf = glow_factor(y)
        for x in range(W):
            r, g, b = base
            # horizon glow
            if gf > 0.0:
                r = min(255, int(r + GLOW[0] * gf * 0.55))
                g = min(255, int(g + GLOW[1] * gf * 0.50))
                b = min(255, int(b + GLOW[2] * gf * 0.38))
            row.append(r)
            row.append(g)
            row.append(b)
        rows.append(row)

    # Stars
    for (sx, sy, sb) in STARS:
        v = int(120 + 135 * sb)
        r = rows[sy]
        r[sx * 3] = min(255, r[sx * 3] + v)
        r[sx * 3 + 1] = min(255, r[sx * 3 + 1] + v)
        r[sx * 3 + 2] = min(255, r[sx * 3 + 2] + int(v * 1.05))

    # Airliner silhouette (drawn with a 1px soft edge)
    for y in range(max(0, int(PLANE_CY - 230)), min(H, int(PLANE_CY + 230))):
        for x in range(max(0, int(PLANE_CX - 300)), min(W, int(PLANE_CX + 300))):
            if inside_plane(x + 0.5, y + 0.5):
                s = plane_shade(x + 0.5, y + 0.5)
                r = rows[y]
                r[x * 3] = int(r[x * 3] * (1.0 - s))
                r[x * 3 + 1] = int(r[x * 3 + 1] * (1.0 - s))
                r[x * 3 + 2] = int(r[x * 3 + 2] * (1.0 - s))

    # Navigation light on the wingtip (red) and belly strobe
    tip_x, tip_y = int(PLANE_CX + 118 * math.cos(PLANE_ANGLE)), \
                    int(PLANE_CY + 118 * math.sin(PLANE_ANGLE))
    for dx in range(-4, 5):
        for dy in range(-4, 5):
            d = math.hypot(dx, dy)
            if d <= 4.0:
                a = 1.0 - d / 4.0
                px, py = tip_x + dx, tip_y + dy
                if 0 <= px < W and 0 <= py < H:
                    r = rows[py]
                    r[px * 3] = min(255, int(r[px * 3] + 210 * a))
                    r[px * 3 + 1] = int(r[px * 3 + 1] * (1.0 - 0.6 * a))
                    r[px * 3 + 2] = int(r[px * 3 + 2] * (1.0 - 0.6 * a))

    return rows


def write_png(path, rows):
    raw = bytearray()
    for row in rows:
        raw.append(0)          # filter type 0 (None)
        raw.extend(row)

    def chunk(tag, data):
        c = struct.pack('>I', len(data)) + tag + data
        return c + struct.pack('>I', zlib.crc32(tag + data) & 0xFFFFFFFF)

    png = b'\x89PNG\r\n\x1a\n'
    png += chunk(b'IHDR', struct.pack('>IIBBBBB', W, H, 8, 2, 0, 0, 0))
    png += chunk(b'IDAT', zlib.compress(bytes(raw), 9))
    png += chunk(b'IEND', b'')
    with open(path, 'wb') as f:
        f.write(png)
    print('Wrote %s (%dx%d, %d bytes)' % (path, W, H, len(png)))


if __name__ == '__main__':
    out = sys.argv[1] if len(sys.argv) > 1 else 'background.png'
    write_png(out, render())
