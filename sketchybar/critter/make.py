# Render the Zebar pixel critter to PNGs with only the stdlib: python3 make.py <outdir>
# The canvas is the whole pill: sketchybar left-aligns icon images, so centring is baked in.
# The critter's pixels span grid cols 1-14 / rows 2-10; OX/OY leave equal margins around them.
import struct, sys, zlib, pathlib
OUT = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else pathlib.Path(__file__).parent)
W, H, OX, OY, SCALE = 30, 21, 7, 4, 4
ORANGE, EYE, PINK = (0xd9, 0x77, 0x57, 255), (0x11, 0x11, 0x1b, 255), (0xf5, 0xc2, 0xe7, 255)
BODY = (3, 2, 10, 6); EYES = [(5, 4, 1, 2), (10, 4, 1, 2)]
# eighth note, 3x4: flag top-right, stem, 2x2 head bottom-left
NOTE = [(1, 0, 2, 1), (1, 1, 1, 1), (0, 2, 2, 2)]

def frame(arms, legs, note_at=None):
    px = [[(0, 0, 0, 0)] * W for _ in range(H)]
    def fill(rects, color, ox, oy):
        for x, y, w, h in rects:
            for j in range(y, y + h):
                for i in range(x, x + w): px[oy + j][ox + i] = color
    fill(arms + legs + [BODY], ORANGE, OX, OY)
    fill(EYES, EYE, OX, OY)
    if note_at: fill(NOTE, PINK, *note_at)
    return px

def png(path, px):
    rows = b"".join(b"\0" + b"".join(bytes(c) for c in row for _ in range(SCALE))
                    for row in px for _ in range(SCALE))
    chunk = lambda t, d: struct.pack(">I", len(d)) + t + d + struct.pack(">I", zlib.crc32(t + d))
    ihdr = struct.pack(">IIBBBBB", W * SCALE, H * SCALE, 8, 6, 0, 0, 0)
    path.write_bytes(b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", ihdr) + chunk(b"IDAT", zlib.compress(rows, 9)) + chunk(b"IEND", b""))

leg = lambda x, h: (x, 8, 1, h)
# idle: arms out, legs down | dance1: arms up, legs a (4, 9) lifted, note top-right
# dance2: arms down, legs b (6, 11) lifted, note top-left
png(OUT / "idle.png",   frame([(1, 4, 2, 2), (13, 4, 2, 2)], [leg(4, 3), leg(6, 3), leg(9, 3), leg(11, 3)]))
png(OUT / "dance1.png", frame([(1, 2, 2, 2), (13, 2, 2, 2)], [leg(4, 2), leg(6, 3), leg(9, 2), leg(11, 3)], (OX + 15, OY - 1)))
png(OUT / "dance2.png", frame([(1, 6, 2, 2), (13, 6, 2, 2)], [leg(4, 3), leg(6, 2), leg(9, 3), leg(11, 2)], (OX - 3, OY - 1)))
