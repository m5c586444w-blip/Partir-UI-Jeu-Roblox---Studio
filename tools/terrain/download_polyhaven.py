#!/usr/bin/env python3
"""Section 13.4 et 18.1 bis : télécharge les textures de terrain Poly Haven (CC0, sans compte) en 1 024
(13.2 : 1 024 × 1 024 au plus) et écrit la liste des crédits (src/shared/Credits.luau, ReplicatedStorage/Credits).

Usage : python3 tools/terrain/download_polyhaven.py
Sortie : assets/terrain/<id>/<id>_<carte>_1k.<ext> (couleur, normale GL, rugosité).
"""
import json
import os
import urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUT = os.path.join(ROOT, "assets", "terrain")
API = "https://api.polyhaven.com"

# 13.4 : matériau Roblox → texture Poly Haven (identifiants de l'API)
TEXTURES = [
    ("LeafyGrass (sol de forêt : aiguilles et feuilles)", "Forest Ground 03", "forrest_ground_03"),
    ("Grass (prairie)", "Leafy Grass", "leafy_grass"),
    ("Ground (terre)", "Brown Mud Dry", "brown_mud_dry"),
    ("Mud", "Mud Forest", "mud_forest"),
    ("Mud (pistes)", "Muddy Tracks", "muddy_tracks"),
    ("Rock", "Rock Pitted Mossy", "rock_pitted_mossy"),
    ("Basalt (sombre)", "Dark Rock", "dark_rock"),
    ("Sand (cendre)", "Burned Ground 01 (recoloré gris)", "burned_ground_01"),
]
MAPS = {"Diffuse": "color", "nor_gl": "normal", "Rough": "roughness"}
RESOLUTION = "1k"


# Poly Haven refuse les requêtes sans en-tête User-Agent explicite
HEADERS = {"User-Agent": "PisteFroide-asset-script/1.0"}


def fetch_json(url):
    with urllib.request.urlopen(urllib.request.Request(url, headers=HEADERS), timeout=60) as response:
        return json.load(response)


def download(url, path):
    with urllib.request.urlopen(urllib.request.Request(url, headers=HEADERS), timeout=120) as response:
        with open(path, "wb") as f:
            f.write(response.read())


def main():
    credits = []
    for material, name, asset_id in TEXTURES:
        info = fetch_json(f"{API}/info/{asset_id}")
        files = fetch_json(f"{API}/files/{asset_id}")
        folder = os.path.join(OUT, asset_id)
        os.makedirs(folder, exist_ok=True)
        for map_key, label in MAPS.items():
            entry = files.get(map_key, {}).get(RESOLUTION, {})
            chosen = entry.get("png") or entry.get("jpg")
            if chosen is None:
                print(f"  carte absente : {asset_id} {map_key}")
                continue
            ext = os.path.splitext(chosen["url"])[1]
            path = os.path.join(folder, f"{asset_id}_{label}_{RESOLUTION}{ext}")
            download(chosen["url"], path)
        authors = ", ".join(info.get("authors", {}).keys())
        credits.append((name, authors, f"https://polyhaven.com/a/{asset_id}", "CC0", material))
        print(f"{name} ({asset_id}) : téléchargé")
    write_credits(credits)


def write_credits(credits):
    lines = [
        "-- ReplicatedStorage/Credits",
        "-- Section 0, règle 4 : chaque asset importé est inscrit ici (nom, auteur, URL, licence).",
        "-- Généré par tools/terrain/download_polyhaven.py ; compléter à chaque import (phase B).",
        "return {",
    ]
    for name, authors, url, license_, material in credits:
        lines.append(
            f'\t{{ name = "{name}", author = "{authors}", url = "{url}", license = "{license_}", usage = "Texture de terrain : {material}" }},'
        )
    lines.append("}")
    with open(os.path.join(ROOT, "src", "shared", "Credits.luau"), "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")


if __name__ == "__main__":
    main()
