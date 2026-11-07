"""13.4 / 12 : ciel d'édition. HDRI Poly Haven CC0 (overcast_soil_puresky) -> 6 faces PNG 1024 pour Lighting/Sky.
Usage : python tools/terrain/make_sky.py   (sortie : assets/sky/sky_<Face>.png ; aucune dépendance autre que numpy et Pillow)"""
import json, os, urllib.request
import numpy as np
from PIL import Image

ASSET = "overcast_soil_puresky"
RES = "2k"
FACE = 1024
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "assets", "sky")
HEADERS = {"User-Agent": "PisteFroide-asset-script/1.0"}


def get(url):
    return urllib.request.urlopen(urllib.request.Request(url, headers=HEADERS), timeout=120).read()


def read_hdr(data):
    """Décodeur Radiance RGBE (RLE nouveau format)."""
    pos = 0
    while True:
        end = data.index(b"\n", pos)
        line = data[pos:end]
        pos = end + 1
        if line.strip() == b"":
            break
    end = data.index(b"\n", pos)
    parts = data[pos:end].split()
    pos = end + 1
    h, w = int(parts[1]), int(parts[3])
    img = np.zeros((h, w, 4), dtype=np.uint8)
    for y in range(h):
        if data[pos] == 2 and data[pos + 1] == 2 and (data[pos + 2] << 8 | data[pos + 3]) == w:
            pos += 4
            for c in range(4):
                x = 0
                while x < w:
                    n = data[pos]
                    pos += 1
                    if n > 128:
                        n -= 128
                        img[y, x : x + n, c] = data[pos]
                        pos += 1
                    else:
                        img[y, x : x + n, c] = np.frombuffer(data[pos : pos + n], dtype=np.uint8)
                        pos += n
                    x += n
        else:
            raise ValueError("HDR non compressé non géré")
    e = img[..., 3].astype(np.float32)
    scale = np.where(e > 0, 2.0 ** (e - 136), 0.0)
    return img[..., :3].astype(np.float32) * scale[..., None]


def main():
    files = json.loads(get(f"https://api.polyhaven.com/files/{ASSET}"))
    url = files["hdri"][RES]["hdr"]["url"]
    hdr = read_hdr(get(url))
    h, w, _ = hdr.shape
    lum = hdr @ np.array([0.2126, 0.7152, 0.0722], dtype=np.float32)
    hdr = hdr * (0.45 / max(float(np.median(lum)), 1e-6))  # exposition : luminance médiane 0,45
    ldr = hdr / (1.0 + hdr)
    ldr = np.clip(ldr, 0, 1) ** (1 / 2.2)
    # faces : Ft = −Z, Bk = +Z, Lf = −X, Rt = +X, Up = +Y, Dn = −Y
    g = (np.arange(FACE) + 0.5) / FACE * 2 - 1
    u, v = np.meshgrid(g, -g)  # u vers la droite, v vers le haut
    faces = {
        "Ft": (u, v, -np.ones_like(u), "x", "y", "z"),
        "Bk": (-u, v, np.ones_like(u), "x", "y", "z"),
        "Lf": (-np.ones_like(u), v, -u, "x", "y", "z"),
        "Rt": (np.ones_like(u), v, u, "x", "y", "z"),
        "Up": (u, np.ones_like(u), -v, "x", "y", "z"),
        "Dn": (u, -np.ones_like(u), v, "x", "y", "z"),
    }
    os.makedirs(OUT, exist_ok=True)
    for name, (x, y, z, *_r) in faces.items():
        n = np.sqrt(x * x + y * y + z * z)
        x, y, z = x / n, y / n, z / n
        lon = np.arctan2(x, -z)
        lat = np.arcsin(np.clip(y, -1, 1))
        px = ((lon / (2 * np.pi) + 0.5) * w).astype(int) % w
        py = np.clip(((0.5 - lat / np.pi) * h).astype(int), 0, h - 1)
        Image.fromarray((ldr[py, px] * 255).astype(np.uint8)).save(os.path.join(OUT, f"sky_{name}.png"))
        print("face", name)


if __name__ == "__main__":
    main()
