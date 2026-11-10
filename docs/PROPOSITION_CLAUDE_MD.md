# Proposition de mise à jour de `CLAUDE.md` (ticket C1, 2026-11-10)

Proposition seulement : `CLAUDE.md` n'est pas modifié. Chaque ajout s'appuie sur la bible (section citée)
ou sur un constat de `docs/RECONCILIATION.md`. Les points marqués « à trancher » attendent Gabriel.

## 1. Tableau « Synchronisation cloud ↔ Studio » : ajouter une ligne

| Fichier | Écrit par | Contenu |
|---|---|---|
| `studio-export/` | Session Studio, à la fin | Copie en lecture seule de ce qui n'existe que dans Studio : modules de terrain (`terrain/*.lua`), relevé des placements (`placements.md`), wiki de la session Studio (`wiki/`) |

Règle proposée (18.1 ter, règle 4, étendue du dossier `ui-export/` au terrain et aux placements) :
- `studio-export/` est écrit **seulement** par la session Studio ; la session cloud le lit et ne le modifie
  jamais. Rojo ne le synchronise pas (il n'est dans aucun `.project.json`).
- Chaque fin de session Studio réexporte les modules de terrain modifiés et refait `placements.md`.
- En cas d'écart entre `studio-export/wiki/` et la bible, la bible gagne (section 0) ; l'écart est noté
  dans `SUIVI.md` (voir `docs/RECONCILIATION.md`).

## 2. Section « Projet Rojo » : nom du module de terrain

Texte actuel : « `tools/terrain/TerrainBuilder.luau` = `ServerStorage/TerrainBuilder` de la Partie (script
d'édition, 3.7). »

Proposition (à trancher, question 3 de `RECONCILIATION.md`) :
- La bible (3.7, 18) nomme `TerrainBuilder`. Dans Studio, `ServerStorage/TerrainBuilder` est devenu un
  dossier de 18 modules, renommé `TerrainSectors` (compte rendu S0). Deux options :
  - A. Garder le nom de la bible : le dossier Studio redevient `ServerStorage/TerrainBuilder`, et
    `tools/terrain/TerrainBuilder.luau` est renommé ou rangé à part (ex. `TerrainBuilder_3_7`) ;
  - B. Adopter `TerrainSectors` : la bible doit l'écrire (règle 1 de la section 0), puis `CLAUDE.md` dit
    « `ServerStorage/TerrainSectors` (dossier, copie dans `studio-export/terrain/`) ; `ServerStorage/TerrainBuilder`
    (dépôt, 3.7) n'est plus lancé dans la Partie ».
- Dans les deux cas, ajouter : « Ne jamais lancer `TerrainBuilder.Build()` ni `Terrain:Clear()` dans une
  place qui contient le terrain des secteurs. »

## 3. Noms des secteurs

Ajouter une sous-section « Secteurs de terrain (Studio) » avec le tableau de
`studio-export/wiki/secteurs/decoupage.md` (boîtes monde), et une règle de nommage :

| Code | Nom actuel | Proposition (à trancher) | Boîte monde |
| --- | --- | --- | --- |
| S1 | `S1_ZoneInterdite` | inchangé | X −4000..−1000, Z −4000..−500 |
| S2 | `S2_Plateau` | inchangé | X −1000..1500, Z −4000..−500 |
| S3 | `S3_NordEst` | `S3_Est` | X 1400..4000, Z −2500..1700 |
| S4 | `S4_Centre` | inchangé | X −1100..1400, Z −600..2500 |
| S5 | `S5_Ouest` | inchangé | X −4000..−1000, Z −500..2500 |
| S6 | `S6_SudOuest` | `S6_Sud` (la boîte va jusqu'à X 1500) | X −4000..1500, Z 2500..4000 |
| S7 | `S7_SudEst` | inchangé | X 1400..4000, Z 1400..4000 |
| S8 | `S8_NordEst` | inchangé (seul vrai coin nord-est) | X 1500..4000, Z −4000..−2500 |

Les secteurs n'existent pas dans la bible : ils restent une organisation de travail de Studio, sans effet
sur les lieux `Pxx` (3.2), qui gardent leurs codes et leurs positions.

## 4. Rappel à ajouter dans « Règles absolues »

« Positions : le tableau 3.2 prime sur tout placement fait dans Studio (décision de Gabriel du
2026-11-10). Tout lieu à plus de ±5 studs (`MapConfig.Terrain.PlaceTolerance`) est corrigé dans Studio
par ticket. »
