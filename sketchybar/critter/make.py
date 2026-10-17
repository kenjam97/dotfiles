# Render the Zebar pixel critter to PNGs with only the stdlib: python3 make.py [outdir]
# The canvas is the whole pill: sketchybar left-aligns icon images, so centring is baked in.
# Critter coordinates are on its own 16x12 grid (pixels span cols 1-14 / rows 2-10); OX/OY
# place that grid in the canvas with equal margins. Extras (notes, dots, marks) use canvas coords.
import struct, sys, zlib, pathlib
OUT = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else pathlib.Path(__file__).parent)
W, H, OX, OY, SCALE = 30, 21, 7, 4, 4
ORANGE, EYE = (0xd9, 0x77, 0x57, 255), (0x11, 0x11, 0x1b, 255)
PINK, BLUE, PEACH, GREEN = (0xf5, 0xc2, 0xe7, 255), (0x89, 0xb4, 0xfa, 255), (0xfa, 0xb3, 0x87, 255), (0xa6, 0xe3, 0xa1, 255)

BODY = (3, 2, 10, 6)
EYES = {"open": [(5, 4, 1, 2), (10, 4, 1, 2)], "left": [(4, 4, 1, 2), (9, 4, 1, 2)],
        "right": [(6, 4, 1, 2), (11, 4, 1, 2)], "happy": [(5, 4, 1, 1), (10, 4, 1, 1)]}
ARM_L = {"out": (1, 4, 2, 2), "up": (1, 2, 2, 2), "down": (1, 6, 2, 2)}
ARM_R = {"out": (13, 4, 2, 2), "up": (13, 2, 2, 2), "down": (13, 6, 2, 2), "high": (13, 0, 2, 3)}
leg = lambda x, h: (x, 8, 1, h)
LEGS = {"stand": [leg(4, 3), leg(6, 3), leg(9, 3), leg(11, 3)],
        "a": [leg(4, 2), leg(6, 3), leg(9, 2), leg(11, 3)],   # legs a (4, 9) lifted
        "b": [leg(4, 3), leg(6, 2), leg(9, 3), leg(11, 2)]}   # legs b (6, 11) lifted

# extras, in canvas coords; keep them at row 3+, since the image top sits on the pill's edge
def note(x, y): return [(x + 1, y, 2, 1), (x + 1, y + 1, 1, 1), (x, y + 2, 2, 2)]  # eighth note
def dots(n): return [(OX + 4 + 3 * i, OY - 1, 1, 1) for i in range(n)]            # "thinking..."
BANG = [(5, OY + 1, 1, 3), (5, OY + 5, 1, 1)]                                          # "!" left of the critter
CHECK = [(21, 5, 1, 1), (22, 6, 1, 1), (23, 5, 1, 1), (24, 4, 1, 1), (25, 3, 1, 1)]

FRAMES = {
    # idle / music (media_state)
    "idle":   dict(arms=("out", "out"), legs="stand", eyes="open"),
    "dance1": dict(arms=("up", "up"), legs="a", eyes="open", extra=[(note(OX + 15, OY - 1), PINK)]),
    "dance2": dict(arms=("down", "down"), legs="b", eyes="open", extra=[(note(OX - 3, OY - 1), PINK)]),
    # Claude working: glancing around, dots counting up
    "think1": dict(arms=("out", "out"), legs="stand", eyes="left", extra=[(dots(1), BLUE)]),
    "think2": dict(arms=("out", "out"), legs="stand", eyes="open", extra=[(dots(2), BLUE)]),
    "think3": dict(arms=("out", "out"), legs="stand", eyes="right", extra=[(dots(3), BLUE)]),
    # Claude needs you: waving with a "!"
    "wave1":  dict(arms=("out", "high"), legs="stand", eyes="open", extra=[(BANG, PEACH)]),
    "wave2":  dict(arms=("out", "up"), legs="stand", eyes="open", extra=[(BANG, PEACH)]),
    # Claude finished its turn: happy, with a check
    "done":   dict(arms=("up", "up"), legs="stand", eyes="happy", extra=[(CHECK, GREEN)]),
}

def render(arms, legs, eyes, extra=()):
    px = [[(0, 0, 0, 0)] * W for _ in range(H)]
    def fill(rects, color, ox=0, oy=0):
        for x, y, w, h in rects:
            for j in range(y, y + h):
                for i in range(x, x + w): px[oy + j][ox + i] = color
    fill([ARM_L[arms[0]], ARM_R[arms[1]], *LEGS[legs], BODY], ORANGE, OX, OY)
    fill(EYES[eyes], EYE, OX, OY)
    for rects, color in extra: fill(rects, color)
    return px

def png(path, px):
    rows = b"".join(b"\0" + b"".join(bytes(c) for c in row for _ in range(SCALE))
                    for row in px for _ in range(SCALE))
    chunk = lambda t, d: struct.pack(">I", len(d)) + t + d + struct.pack(">I", zlib.crc32(t + d))
    ihdr = struct.pack(">IIBBBBB", W * SCALE, H * SCALE, 8, 6, 0, 0, 0)
    path.write_bytes(b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", ihdr) + chunk(b"IDAT", zlib.compress(rows, 9)) + chunk(b"IEND", b""))

for name, spec in FRAMES.items():
    png(OUT / f"{name}.png", render(**spec))
