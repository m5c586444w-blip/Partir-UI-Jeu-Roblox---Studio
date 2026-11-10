#!/usr/bin/env python3
"""Section 13.4 et 18.1 bis : télécharge les textures de terrain Poly Haven (CC0, sans compte) en 1 024
(13.2 : 1 024 × 1 024 au plus) et ajoute les crédits manquants à src/shared/Credits.luau
(ReplicatedStorage/Credits), sans retirer
les entrées existantes (fusion par url).

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


CREDITS_PATH = os.path.join(ROOT, "src", "shared", "Credits.luau")
HEADER = [
    "-- ReplicatedStorage/Credits",
    "-- Section 0, règle 4 : chaque asset importé est inscrit ici (nom, auteur, URL, licence).",
    "-- Généré par tools/terrain/download_polyhaven.py ; compléter à chaque import (phase B).",
]


def credit_line(name, authors, url, license_, material):
    return (
        f'\t{{ name = "{name}", author = "{authors}", url = "{url}", license = "{license_}", '
        f'usage = "Texture de terrain : {material}" }},'
    )


def write_credits(credits):
    """Fusion par url (ticket C2) : les entrées et commentaires déjà présents dans Credits.luau sont
    conservés tels quels ; seules les textures dont l'url n'y figure pas encore sont ajoutées, juste
    avant l'accolade fermante. Lancer StyLua ensuite (stylua src/shared/Credits.luau)."""
    if os.path.exists(CREDITS_PATH):
        with open(CREDITS_PATH, encoding="utf-8") as f:
            text = f.read()
    else:
        text = "\n".join(HEADER + ["return {", "}"]) + "\n"
    closing = text.rstrip().rfind("}")
    if closing < 0:
        raise SystemExit(f"accolade fermante introuvable dans {CREDITS_PATH} : fichier laissé tel quel")
    added = []
    for name, authors, url, license_, material in credits:
        # une url déjà citée (entre guillemets) garde son entrée existante, même modifiée à la main
        if f'"{url}"' in text or url in added:
            print(f"  déjà crédité, conservé : {url}")
            continue
        added.append(credit_line(name, authors, url, license_, material))
    if not added:
        print("Credits.luau inchangé")
        return
    head = text[:closing].rstrip("\n\t ")
    text = head + "\n" + "\n".join(added) + "\n" + text[closing:]
    with open(CREDITS_PATH, "w", encoding="utf-8") as f:
        f.write(text if text.endswith("\n") else text + "\n")
    print(f"Credits.luau : {len(added)} entrée(s) ajoutée(s)")


if __name__ == "__main__":
    main()
