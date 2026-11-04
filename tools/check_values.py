#!/usr/bin/env python3
"""Relecture de fin de phase (bible 18.1 bis) : signale les nombres écrits en dur hors des modules Config.

Usage : python3 tools/check_values.py
Ignorés : commentaires, chaînes, petits nombres d'usage courant (0, 1, 2, 0,5, 10 dans « 10 ^ n », 100 des
pourcentages, seuils 0,1 / 0,01 de « presque zéro »), et les lignes marquées « -- constante » (unité ou limite
du moteur). Tout autre nombre est listé : il doit venir de ReplicatedStorage/Config.
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ALLOWED = {"0", "1", "2", "0.5", "100", "10", "0.1", "0.01"}
NUMBER = re.compile(r"(?<![\w.])(\d+\.\d+|\d+)(?![\w.])")


def strip(line):
    out, quote, i = [], None, 0
    while i < len(line):
        c = line[i]
        if quote:
            if c == "\\":
                i += 2
                continue
            if c == quote:
                quote = None
            i += 1
            continue
        if c in "\"'":
            quote = c
            i += 1
            continue
        if line.startswith("--", i):
            break
        out.append(c)
        i += 1
    return "".join(out)


def main():
    found = []
    for base in ("src/server", "src/client", "src/shared/Shared", "tools/terrain"):
        folder = os.path.join(ROOT, base)
        for dirpath, _, files in os.walk(folder):
            for name in files:
                if not name.endswith(".luau"):
                    continue
                path = os.path.join(dirpath, name)
                for number, line in enumerate(open(path, encoding="utf-8"), start=1):
                    if "-- constante" in line:
                        continue  # unité ou limite du moteur, pas une valeur de jeu
                    code = strip(line)
                    for match in NUMBER.findall(code):
                        if match not in ALLOWED:
                            found.append(f"{os.path.relpath(path, ROOT)}:{number}: {match} : {code.strip()}")
    for item in found:
        print(item)
    print(f"{len(found)} nombre(s) hors Config")
    return 1 if found else 0


if __name__ == "__main__":
    sys.exit(main())
