"""Promote image.png -> app_icon (+ launcher with navy fill for Android)."""
from PIL import Image

src = r"c:\Users\QBS\Downloads\solar_clean\solar_clean\assets\icons\image.png"
out_icon = r"c:\Users\QBS\Downloads\solar_clean\solar_clean\assets\icons\app_icon.png"
out_launcher = (
    r"c:\Users\QBS\Downloads\solar_clean\solar_clean\assets\icons\app_icon_launcher.png"
)

im = Image.open(src).convert("RGBA")
px = im.load()
w, h = im.size

# Only wipe near-white that is almost fully opaque AND has neighbors mostly empty
# (leftover canvas). Keep bright sparkles (they sit next to colored pixels).
for y in range(h):
    for x in range(w):
        r, g, b, a = px[x, y]
        if a == 0:
            continue
        if a < 20:
            px[x, y] = (0, 0, 0, 0)
            continue
        if r >= 248 and g >= 248 and b >= 248 and a >= 250:
            # check if surrounded by transparency -> canvas leftover
            empty = 0
            for dy in (-2, 0, 2):
                for dx in (-2, 0, 2):
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < w and 0 <= ny < h and px[nx, ny][3] < 30:
                        empty += 1
            if empty >= 6:
                px[x, y] = (0, 0, 0, 0)

bbox = im.getbbox()
cropped = im.crop(bbox)
cw, ch = cropped.size
side = max(cw, ch)
pad = max(16, int(side * 0.06))
side = side + pad * 2
transparent = Image.new("RGBA", (side, side), (0, 0, 0, 0))
ox = (side - cw) // 2
oy = (side - ch) // 2
transparent.paste(cropped, (ox, oy), cropped)
transparent.save(out_icon, optimize=True)

# Launcher: navy plate + artwork (no holes on older Android launchers)
navy = (8, 40, 110, 255)
launcher = Image.new("RGBA", (side, side), navy)
launcher.paste(transparent, (0, 0), transparent)
launcher.convert("RGB").save(out_launcher, optimize=True)

print(f"app_icon {transparent.size} transparent")
print(f"launcher {launcher.size} navy+art")
