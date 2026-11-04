#!/usr/bin/env python3
"""Images d'interface de la section 13.5 (ajout), dessinées par script — aucune IA générative.

- Img_FearVignette : dégradé radial noir, transparent au centre, 1 024 × 1 024 (PNG, Pillow).
- Icon_<ID> : icônes simples à traits blancs, écrites en SVG (assets/ui/svg) puis exportées en
  PNG 256 × 256 (assets/ui/png) avec Chromium (Playwright), fond transparent.

Usage : python3 tools/images/make_images.py   (puis : node tools/images/rasterize.js)
Les PNG sont à importer dans Studio (Asset Manager) ; leurs identifiants vont dans
Config/ItemConfig.Icons et Config/WeaponConfig.Icons (voir HANDOFF.md).
"""
import math
import os

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUT = os.path.join(ROOT, "assets", "ui")
SVG_DIR = os.path.join(OUT, "svg")
PNG_DIR = os.path.join(OUT, "png")


def fear_vignette():
    size = 1024
    img = Image.new("RGBA", (size, size))
    px = img.load()
    c = (size - 1) / 2
    for y in range(size):
        for x in range(size):
            d = math.hypot(x - c, y - c) / (c * math.sqrt(2))  # 0 au centre, 1 dans les coins
            t = min(1.0, max(0.0, (d - 0.35) / 0.65))  # transparent jusqu'à 35 % du rayon
            px[x, y] = (0, 0, 0, int(255 * t * t))
    img.save(os.path.join(PNG_DIR, "Img_FearVignette.png"))


# Pictogrammes : éléments SVG dans un carré 0..100, trait blanc.
L = '<line x1="{}" y1="{}" x2="{}" y2="{}"/>'
R = '<rect x="{}" y="{}" width="{}" height="{}" rx="{}"/>'
C = '<circle cx="{}" cy="{}" r="{}"/>'
P = '<path d="{}"/>'

ICONS = {
    # 8.1 objets
    "ITM_Flashlight": [R.format(18, 40, 46, 20, 3), P.format("M64 36 L82 28 L82 72 L64 64 Z")],
    "ITM_Headlamp": [P.format("M15 55 Q50 20 85 55"), R.format(38, 46, 24, 16, 4), L.format(50, 66, 50, 80)],
    "ITM_PowerLight": [R.format(14, 38, 40, 24, 4), P.format("M54 32 L80 20 L80 80 L54 68 Z"), L.format(24, 62, 24, 76)],
    "ITM_Battery": [R.format(30, 22, 40, 62, 4), R.format(42, 14, 16, 8, 1), L.format(50, 40, 50, 60), L.format(40, 50, 60, 50)],
    "ITM_Bandage": [R.format(14, 34, 72, 32, 14), L.format(40, 34, 40, 66), L.format(60, 34, 60, 66)],
    "ITM_Splint": [R.format(28, 12, 12, 76, 3), R.format(60, 12, 12, 76, 3), L.format(22, 35, 78, 35), L.format(22, 65, 78, 65)],
    "ITM_Medkit": [R.format(16, 28, 68, 52, 5), R.format(38, 18, 24, 10, 2), L.format(50, 42, 50, 66), L.format(38, 54, 62, 54)],
    "ITM_Flare": [R.format(40, 34, 20, 54, 3), P.format("M50 30 Q40 18 50 8 Q60 18 50 30")],
    "ITM_Matches": [R.format(22, 44, 56, 34, 3), L.format(36, 44, 48, 16), C.format(49, 13, 4)],
    "ITM_Branch": [L.format(14, 82, 86, 22), L.format(46, 55, 40, 30), L.format(64, 40, 78, 44)],
    "ITM_Stone": [P.format("M20 62 Q18 36 42 30 Q70 22 80 48 Q86 72 58 76 Q30 80 20 62 Z")],
    "ITM_Rope": [C.format(50, 50, 30), C.format(50, 50, 18), C.format(50, 50, 6)],
    "ITM_Plank": [R.format(10, 38, 80, 24, 2), C.format(20, 50, 2), C.format(80, 50, 2)],
    "ITM_BearSpray": [R.format(34, 30, 32, 58, 6), R.format(42, 16, 16, 14, 2), L.format(58, 22, 74, 18)],
    "ITM_ToolBox": [R.format(14, 40, 72, 40, 4), P.format("M36 40 L36 28 L64 28 L64 40"), L.format(14, 56, 86, 56)],
    "ITM_Compass": [C.format(50, 50, 34), P.format("M50 22 L58 50 L50 78 L42 50 Z")],
    "ITM_RadioScanner": [R.format(28, 30, 44, 58, 5), L.format(62, 30, 72, 10), R.format(36, 40, 28, 16, 2), C.format(42, 72, 4), C.format(58, 72, 4)],
    "ITM_Walkie": [R.format(32, 28, 36, 62, 6), L.format(40, 28, 40, 8), L.format(40, 44, 60, 44), L.format(40, 54, 60, 54), L.format(40, 64, 60, 64)],
    "ITM_TinCan": [R.format(30, 26, 40, 54, 6), L.format(30, 38, 70, 38), L.format(30, 68, 70, 68)],
    "ITM_DuctTape": [C.format(46, 50, 28), C.format(46, 50, 12), L.format(74, 50, 88, 50)],
    "ITM_Notebook": [R.format(26, 16, 48, 68, 3), L.format(34, 16, 34, 84), L.format(42, 34, 66, 34), L.format(42, 46, 66, 46)],
    "ITM_Keys": [C.format(32, 50, 14), L.format(46, 50, 84, 50), L.format(72, 50, 72, 62), L.format(80, 50, 80, 60)],
    "ITM_Jack": [P.format("M20 80 L80 80 L66 62 L34 62 Z"), L.format(50, 62, 50, 24), R.format(36, 16, 28, 8, 2)],
    "ITM_CoaxCable": [P.format("M14 70 Q30 20 50 50 T86 30"), C.format(14, 70, 5), C.format(86, 30, 5)],
    "ITM_CarBattery": [R.format(14, 32, 72, 50, 4), R.format(24, 24, 12, 8, 1), R.format(64, 24, 12, 8, 1), L.format(26, 52, 38, 52), L.format(62, 52, 74, 52), L.format(68, 46, 68, 58)],
    "ITM_Jerrycan": [P.format("M24 30 L60 30 L76 46 L76 86 L24 86 Z"), R.format(30, 18, 20, 12, 3), L.format(34, 50, 64, 76), L.format(64, 50, 34, 76)],
    "ITM_StarterRelay": [R.format(24, 34, 52, 34, 4), L.format(34, 68, 34, 84), L.format(50, 68, 50, 84), L.format(66, 68, 66, 84)],
    "ITM_PlasterKit": [P.format("M26 30 L74 30 L66 84 L34 84 Z"), P.format("M40 50 Q50 42 60 50 Q58 66 50 70 Q42 66 40 50")],
    "ITM_AudioRecorder": [R.format(30, 14, 40, 72, 6), C.format(50, 34, 10), L.format(40, 60, 60, 60), L.format(40, 70, 60, 70)],
    "ITM_SampleBag": [R.format(26, 22, 48, 62, 3), L.format(26, 34, 74, 34), P.format("M40 50 Q50 60 44 72"), P.format("M54 50 Q62 60 56 72")],
    "ITM_Camcorder": [R.format(14, 34, 52, 34, 4), P.format("M66 42 L86 32 L86 70 L66 60 Z"), C.format(30, 51, 8)],
    "ITM_PhotoCamera": [R.format(14, 32, 72, 48, 5), C.format(50, 56, 14), R.format(24, 24, 16, 8, 2)],
    "ITM_TabletField": [R.format(22, 14, 56, 72, 5), R.format(28, 22, 44, 52, 2), C.format(50, 80, 2)],
    "ITM_TabletGeo": [R.format(22, 14, 56, 72, 5), R.format(28, 22, 44, 52, 2), P.format("M34 60 L44 40 L54 52 L66 32")],
    "ITM_SDCard": [P.format("M30 14 L62 14 L72 24 L72 86 L30 86 Z"), L.format(40, 24, 40, 36), L.format(50, 24, 50, 36), L.format(60, 24, 60, 36)],
    # 8.2 armes
    "WPN_Rifle": [L.format(8, 46, 70, 46), P.format("M50 46 L50 58 L92 64 L92 50 L70 46"), L.format(36, 40, 50, 40), L.format(56, 46, 60, 54)],
    "WPN_Revolver": [R.format(14, 34, 46, 12, 2), C.format(56, 46, 8), P.format("M54 52 L66 80 L80 76 L70 48")],
    "WPN_Shotgun": [L.format(8, 44, 72, 44), L.format(8, 50, 72, 50), R.format(36, 52, 18, 8, 2), P.format("M72 42 L92 50 L92 64 L72 54 Z")],
    "WPN_FlareGun": [R.format(16, 36, 50, 18, 4), P.format("M44 54 L50 82 L64 82 L60 54"), C.format(24, 45, 4)],
    "MEL_Axe": [L.format(30, 86, 62, 18), P.format("M56 16 Q80 10 86 30 L64 34 Z")],
    "MEL_Machete": [L.format(18, 82, 30, 70), P.format("M30 70 L80 18 Q90 22 84 34 L38 78 Z")],
}


def svg(elements):
    body = "".join(elements)
    return (
        '<svg xmlns="http://www.w3.org/2000/svg" width="256" height="256" viewBox="0 0 100 100">'
        '<g fill="none" stroke="#FFFFFF" stroke-width="5" stroke-linecap="round" stroke-linejoin="round">'
        f"{body}</g></svg>\n"
    )


def main():
    os.makedirs(SVG_DIR, exist_ok=True)
    os.makedirs(PNG_DIR, exist_ok=True)
    fear_vignette()
    for icon_id, elements in ICONS.items():
        with open(os.path.join(SVG_DIR, f"Icon_{icon_id}.svg"), "w", encoding="utf-8") as f:
            f.write(svg(elements))
    print(f"Img_FearVignette + {len(ICONS)} icônes SVG")


if __name__ == "__main__":
    main()
