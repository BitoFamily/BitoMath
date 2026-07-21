"""
Generates the master app icon files for issue #5, from the existing
transparent Coco cutout (assets/images/coco.png), which already has a
clean alpha-transparent background - no background removal needed.

Outputs (into icon_source/, not bundled as a runtime Flutter asset -
these are only consumed by flutter_launcher_icons at generation time):
  - icon_source/coco_icon_foreground.png  (1024x1024, transparent bg,
    Coco centered in the ~66% "safe zone" - for Android adaptive icons)
  - icon_source/coco_icon_flat.png        (1024x1024, solid Bito Cyan
    #22D3EE background, Coco centered - for iOS/web/general master icon,
    since iOS icons must be fully opaque)
"""

from PIL import Image
import os

BITO_CYAN = (0x22, 0xD3, 0xEE, 0xFF)
CANVAS = 1024
SAFE_ZONE_FRACTION = 0.66  # Android adaptive-icon safe-zone convention

SRC = "assets/images/coco.png"
OUT_DIR = "icon_source"

os.makedirs(OUT_DIR, exist_ok=True)

coco = Image.open(SRC).convert("RGBA")
bbox = coco.getbbox()
coco_cropped = coco.crop(bbox)

# Scale Coco to fit within the safe zone, preserving aspect ratio.
target = int(CANVAS * SAFE_ZONE_FRACTION)
w, h = coco_cropped.size
scale = min(target / w, target / h)
new_w, new_h = int(w * scale), int(h * scale)
coco_resized = coco_cropped.resize((new_w, new_h), Image.LANCZOS)

paste_x = (CANVAS - new_w) // 2
paste_y = (CANVAS - new_h) // 2

# 1. Transparent foreground (Android adaptive icon)
foreground = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
foreground.paste(coco_resized, (paste_x, paste_y), coco_resized)
foreground.save(os.path.join(OUT_DIR, "coco_icon_foreground.png"))

# 2. Flat opaque version on Bito Cyan (iOS/web/general master icon)
flat = Image.new("RGBA", (CANVAS, CANVAS), BITO_CYAN)
flat.paste(coco_resized, (paste_x, paste_y), coco_resized)
flat = flat.convert("RGB")  # drop alpha entirely - iOS requires fully opaque
flat.save(os.path.join(OUT_DIR, "coco_icon_flat.png"))

print("Generated:")
print(" -", os.path.join(OUT_DIR, "coco_icon_foreground.png"), foreground.size)
print(" -", os.path.join(OUT_DIR, "coco_icon_flat.png"), flat.size)
