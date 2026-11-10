# A1 phase B : fusion des secteurs de la région EST (10/11/2026)

Statut : phase B acceptée par la coordinatrice. Région EST = S7, S3, S8. Trois agents en parallèle sur ordre de Gabriel (le ticket disait « un agent à la fois » : écart signalé à la coordinatrice). Sauvegarde de départ : `Sauvegardes\Partie_apres_A1_A.rbxl`.

## Modules (ServerStorage/TerrainSectors, copies exactes dans studio-export/terrain/)
| Module | Rôle | Pages détaillées |
| --- | --- | --- |
| `Raccords_EST` | coutures côté EST (bande X 1400..1640 pour Z −2400..4000 ; X 1500..1700 pour Z −2560..−2400) : `Appliquer()`, `AppliquerOuest()`, `AppliquerNord()`, `CalibrerProfil()`, `Delta(X,Z)`, `Mesurer()` ; idempotent ; toujours en DERNIER | rapport B1 |
| `Ponceau_RD1` | passage voxel de l'eau de R2 sous RD1 vers (3640, 3450) : `Appliquer()`, `Mesurer()` ; boîte (3390..3890, 3200..3700) ; idempotent | `A1_PONCEAU_RD1.md` |
| `S7Donnees`, `S3Donnees`, `S8Donnees` | T1 selon la bible (+ `S3.PtsRuine`, branche P05 `PtsP05`, `D.PenteT1`), tête de T4 | `A1_T1_BIBLE.md` |

## Mesures (voir aussi les pages ci-dessus) [rapports d'agents ; recoupées par le coordinateur Studio là où c'est indiqué]
- Cibles bible 3.2 (recoupées, raycast terrain) : P01 122,0 ; P02 sud 109,6 ; P02 nord 382,5 ; P03 fond 37,8 ; P05 401,6 ; P05c 302,0 ; P05s 331,7 ; P15 392,0 ; P23 562,0 ; P24 302,0 : toutes à ±5 (P05 +2 à cause de la branche P05).
- Ponceau (agent B3 ; `Appliquer()` relancé : 0 cellule modifiée) : 0 trou d'eau sur 125 échantillons de l'axe de R2, eau monotone, hauteur libre min 16,75, chaussée 100 % Asphalt, pente RD1 8,00 % (données) / 8,07 % (voxels, accepté).
- Coutures (agent B1, saut = écart à la pente) : médiane 0,1 à 0,5 stud, max 0,9 à 2,5 ; saut brut à ±4 jusqu'à 7,5 (S3↔S4) : c'est de la pente naturelle ; X=1500 contre S2 : 26,9 → 5,8 max. Côté S2 : ticket CENTRE. Marge nord de S3 à X > 1700 : chute de 45 conservée (provisoire).
- T1 (agent B4) : 1 540 échantillons, 99,4 % Ground, 0 saut > 4 ; sortie en X=1500 à (1500, −2240), Y 322 ; branche P05 : 162 échantillons, 99,4 % Ground.
- Route créature 10×4 P15↔P05 : pathfinding réussi dans les deux sens (9 étapes), en grande partie sur le tracé de T4 ; couloir strictement hors T4 non testé.
- Pathfinding joueur : P01→P05 par T1, P15→P05, T4, RD1 de bout en bout (4 trajets, joueur et créature), spur→pont, P16→P15 : réussis ; P01→P16 franchissement du pont de Gabriel de bout en bout : non testé.

## Non conformités connues (décidées par la coordinatrice : corrigées en début de phase C par des lacets locaux)
- T4 : pente 110 % sur 12 studs au gué d'Ape (2759, −292), 91–92 % de Ground sur l'axe.
- Accès à la ruine (P05c, doit rester accessible) : 36,6 % mesuré sur 24 studs (plan 33 %).
- Branche P05 : 20,2 % sur 24 studs au lacet (2588, −1678).
- Lahar : bord est +11 par endroits (ancien déblai de T1 rendu) ; cœur inchangé.

## DÉFAUTS PROPOSÉS (tous sans appui dans la bible ; Gabriel/coordinatrice)
Raccords_EST : `Fondu` 240, `Pas` 8, `Lissage` 2, `Recul` 10, `Biais` 2,0, `MaxCorr` 30, `Nord` {X0 1500, Fondu 200, Z −2560..−2400}. Ponceau : `DemiLargeur` 16, `LibreMin` 6, voûte à 8 au centre, Concrete pour la voûte, Rock pour les parois (VALIDÉS par la coordinatrice). T1 : `PenteT1` 0,14.

## Ordre d'application (EST)
S7 → S3 → S8 (zone M puis O) → T1/branches (via `S*Donnees`) → `Ponceau_RD1.Appliquer()` → `Raccords_EST.Appliquer()` (en dernier) → mesures. Détail global : `studio-export/wiki/ORDRE_RECONSTRUCTION.md`.
