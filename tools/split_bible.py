#!/usr/bin/env python3
"""Découpe BIBLE_PISTE_FROIDE.md en docs/bible/NN_titre.md (une section « ## » par fichier, contenu
identique) et écrit docs/bible/INDEX.md. À relancer à chaque nouvelle version de la bible.

Usage (depuis la racine du dépôt) : python3 tools/split_bible.py
Contrôle : l'en-tête de la bible suivi des fichiers dans l'ordre redonne exactement la bible.
"""
import os
import re
import sys
import unicodedata

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SOURCE = os.path.join(ROOT, "BIBLE_PISTE_FROIDE.md")
OUT = os.path.join(ROOT, "docs", "bible")


def slug(title):
    text = unicodedata.normalize("NFKD", title).encode("ascii", "ignore").decode("ascii").lower()
    text = re.sub(r"[^a-z0-9]+", "_", text).strip("_")
    return text[:48].rstrip("_")


def main():
    with open(SOURCE, encoding="utf-8") as f:
        source = f.read()
    starts = [m.start() for m in re.finditer(r"(?m)^## \d+\. ", source)]
    if not starts:
        sys.exit("aucune section « ## N. » trouvée")
    header = source[: starts[0]]
    if os.path.isdir(OUT):
        for name in os.listdir(OUT):
            if name.endswith(".md"):
                os.remove(os.path.join(OUT, name))
    os.makedirs(OUT, exist_ok=True)
    rows = []
    rebuilt = header
    for i, start in enumerate(starts):
        end = starts[i + 1] if i + 1 < len(starts) else len(source)
        chunk = source[start:end]
        first = chunk.split("\n", 1)[0]
        m = re.match(r"## (\d+)\. (.*)", first)
        number, title = int(m.group(1)), m.group(2).strip()
        name = f"{number:02d}_{slug(title)}.md"
        with open(os.path.join(OUT, name), "w", encoding="utf-8") as f:
            f.write(chunk)
        subsections = re.findall(r"(?m)^### (.+)$", chunk)
        rows.append((number, title, name, subsections))
        rebuilt += chunk
    if rebuilt != source:
        sys.exit("le découpage ne redonne pas la bible à l'identique")
    lines = [
        "# Bible PISTE FROIDE — index",
        "",
        "Source unique : `BIBLE_PISTE_FROIDE.md` (écrite par Gabriel). Les fichiers de ce dossier en sont",
        "le découpage exact, une section par fichier, produit par `python3 tools/split_bible.py` ;",
        "en cas de doute, la bible entière fait foi. Ne pas modifier ces fichiers à la main.",
        "",
        "En-tête de la bible : " + " ".join(header.split()),
        "",
        "| § | Section | Fichier | Sous-sections |",
        "| --- | --- | --- | --- |",
    ]
    for number, title, name, subsections in rows:
        subs = " ; ".join(subsections) if subsections else "—"
        lines.append(f"| {number} | {title} | [`{name}`]({name}) | {subs} |")
    lines += [
        "",
        "Lecture conseillée en début de session (section 0) : `00_*`, `16_*`, puis la section du jalon.",
        "",
    ]
    with open(os.path.join(OUT, "INDEX.md"), "w", encoding="utf-8") as f:
        f.write("\n".join(lines))
    print(f"{len(rows)} sections écrites dans docs/bible/ ; reconstitution identique")


if __name__ == "__main__":
    main()
