#!/usr/bin/env python3
"""Remise à zéro (HANDOFF, étape 0b) : compare les chemins imprimés par tools/studio/ResetPaths.luau dans
la place publiée avec la place assemblée par Rojo (builds/<Place>.rbxlx).

Usage : python3 tools/studio/reset_diff.py <chemins.txt> Lobby|Partie
Affiche les résidus (présents dans la place, absents du build), hors objets créés par le moteur
(ENGINE_DEFAULTS) et hors contenu ajouté dans Studio par les phases B (STUDIO_OWNED), à vérifier à part.
"""
import fnmatch
import os
import sys
import xml.etree.ElementTree as ET

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# objets créés par Roblox Studio ou par le moteur dans toute place (DÉFAUT, à compléter si besoin)
ENGINE_DEFAULTS = [
    "Workspace/Camera", "Workspace/Camera/*", "Workspace/Terrain", "Workspace/Terrain/*",
    "Workspace/Baseplate", "Workspace/SpawnLocation", "Workspace/SpawnLocation/*",
    "Lighting/Sky", "Lighting/Atmosphere", "Lighting/Bloom", "Lighting/DepthOfField", "Lighting/SunRays",
    "TextChatService/*", "Chat/*", "StarterPlayer/StarterPlayerScripts", "StarterPlayer/StarterCharacterScripts",
    "SoundService/*Reverb*",
]
# contenu que les phases B ajoutent dans Studio (terrain, végétation, modèles, sons) : pas des résidus
STUDIO_OWNED = [
    "Workspace/Vegetation*", "Workspace/Places*", "Workspace/SpawnPoints*", "Workspace/ClimbPoints*",
    "Workspace/CluePoints*", "Workspace/Cinematics*", "Workspace/Navigation*", "MaterialService/*",
    "ServerStorage/Vegetation*", "ServerStorage/Creatures*", "ServerStorage/Props*",
    "ReplicatedStorage/Characters*", "ReplicatedStorage/Items*", "SoundService/*",
]


def build_paths(place):
    root = ET.parse(os.path.join(ROOT, "builds", f"{place}.rbxlx")).getroot()
    out = set()

    def visit(item, path):
        name = item.find("Properties/string[@name='Name']").text
        full = f"{path}/{name}" if path else name
        out.add(full)
        for child in item.findall("Item"):
            visit(child, full)

    for item in root.findall("Item"):
        visit(item, "")
    return out


def main():
    if len(sys.argv) != 3 or sys.argv[2] not in ("Lobby", "Partie"):
        sys.exit(__doc__)
    reference = build_paths(sys.argv[2])
    with open(sys.argv[1], encoding="utf-8") as f:
        present = [line.strip() for line in f if line.strip()]
    residues, owned = [], []
    for path in present:
        if path in reference or path.split("/")[0] == path:
            continue
        if any(fnmatch.fnmatch(path, p) for p in ENGINE_DEFAULTS):
            continue
        (owned if any(fnmatch.fnmatch(path, p) for p in STUDIO_OWNED) else residues).append(path)
    print(f"{len(residues)} résidu(s) à supprimer :")
    for path in residues:
        print("  " + path)
    print(f"{len(owned)} élément(s) des phases B (terrain, modèles, sons) : à vérifier un par un")
    return 1 if residues else 0


if __name__ == "__main__":
    sys.exit(main())
