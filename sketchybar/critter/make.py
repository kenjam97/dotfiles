# Render the Zebar pixel critter (16x12 grid) to PNGs with only the stdlib.
import struct, sys, zlib, pathlib
OUT = pathlib.Path(sys.argv[1]); SCALE = 4
ORANGE, EYE = (0xd9, 0x77, 0x57, 255), (0x11, 0x11, 0x1b, 255)
BODY = (3, 2, 10, 6); EYES = [(5, 4, 1, 2), (10, 4, 1, 2)]
def frame(arms, legs):
    px = [[(0, 0, 0, 0)] * 16 for _ in range(12)]
    for x, y, w, h in arms + legs + [BODY]:
        for j in range(y, y + h):
            for i in range(x, x + w): px[j][i] = ORANGE
    for x, y, w, h in EYES:
        for j in range(y, y + h):
            for i in range(x, x + w): px[j][i] = EYE
    return px
def png(path, px):
    rows = b"".join(b"\0" + b"".join(bytes(c) for c in row for _ in range(SCALE))
                    for row in px for _ in range(SCALE))
    chunk = lambda t, d: struct.pack(">I", len(d)) + t + d + struct.pack(">I", zlib.crc32(t + d))
    ihdr = struct.pack(">IIBBBBB", 16 * SCALE, 12 * SCALE, 8, 6, 0, 0, 0)
    path.write_bytes(b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", ihdr) + chunk(b"IDAT", zlib.compress(rows, 9)) + chunk(b"IEND", b""))
leg = lambda x, h: (x, 8, 1, h)
# idle: arms out, legs down | dance1: arms up, legs a (4, 9) lifted | dance2: arms down, legs b (6, 11) lifted
png(OUT / "idle.png",   frame([(1, 4, 2, 2), (13, 4, 2, 2)], [leg(4, 3), leg(6, 3), leg(9, 3), leg(11, 3)]))
png(OUT / "dance1.png", frame([(1, 2, 2, 2), (13, 2, 2, 2)], [leg(4, 2), leg(6, 3), leg(9, 2), leg(11, 3)]))
png(OUT / "dance2.png", frame([(1, 6, 2, 2), (13, 6, 2, 2)], [leg(4, 3), leg(6, 2), leg(9, 3), leg(11, 2)]))
