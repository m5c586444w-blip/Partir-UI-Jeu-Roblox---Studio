# Ticket A1, phase A : alignement de la région EST sur la bible 3.2 (brief de l'agent d'exécution)

Contexte : ticket A1 de la coordinatrice (10/11/2026), décisions de Gabriel : (1) positions ET altitudes du tableau 3.2 de la bible priment ; (2) on garde les 8 secteurs (pas de `TerrainBuilder.Build()`) ; (3) `ServerStorage/TerrainSectors` conservé. Sauvegarde faite : `Documents\Roblox, jeu bigfoot, projet hagrahh\Sauvegardes\Partie_2026-11-10.rbxl` (16:26). Studio : place « Partie » (placeId 103506696801797).
Région EST = secteurs S7 (X 1400..4000, Z 1400..4000), S3 (X 1400..4000, Z −2500..1700), S8 (X 1500..4000, Z −4000..−2440). **Aucun travail hors de ces boîtes** ; frontières avec CENTRE (S4 : X<1400, S2 : X<1500) et OUEST/Sud (S6) : continuité (saut ≤ 4 studs) à mesurer avant et après.
Un seul agent à la fois : tu es cet agent. Tu es la seule session qui écrit dans Studio. Aucune publication, aucun rojo build, pas de `src/`, `builds/`, `docs/bible/`. N'écris pas dans MaterialService. Ne modifie pas `hot.md`, `decisions.md`, `assets.md`, CLAUDE.md (le coordinateur le fait).

## Lire d'abord
`wiki/BRIEF_SECTEUR_COMMUN.md` (outils, pièges), `wiki/secteurs/S7_SudEst.md`, `S3_NordEst.md`, `S8_NordEst.md`, et la BIBLE : `C:\Users\gbest\Partir-UI-Jeu-Roblox---Studio\BIBLE_PISTE_FROIDE.md` sections 3.2 (lignes ~220–250), 3.3 (~256), 3.5 (polylignes R2, RD1, T1, T4) et 3.7 (génération : gorges, aplanir, pentes). **La bible fait foi, les chiffres ci-dessous sont recopiés.**
Code existant (ServerStorage/TerrainSectors, copies exactes dans `C:\Users\gbest\Partir-UI-Jeu-Roblox---Studio\studio-export\terrain\`) : HauteurGlobale, MelangeMateriaux, S7Donnees/S7Terrain, S3Donnees/S3Terrain, S8Donnees/S8Terrain (zones M et O). Repère monde : X = x − 4000, Z = y − 4000, nord = −Z.

## Cibles bible 3.2 / 3.3 (région EST), X, Z, Y du sol, rayon
| Lieu | X | Z | Y (bible) | Rayon | Mesuré AVANT (sol, raycast terrain) | Écart Y |
| --- | --- | --- | --- | --- | --- | --- |
| P01 parking + départ S1 (2780, 120, 3220), E1 van (2800,120,3200) | 2800 | 3200 | 120 | 60 | 14 | −106 |
| P02 lahar, sud | 2100 (couloir X 1800..2400) | 3500 | 110 | couloir 600 | 10 | −100 |
| P02 lahar, nord | 2100 | −1500 | 380 | — | 205 | −175 |
| P03 Lava Canyon (fond de gorge) | 3200 | 2200 | bord 110, fond 40 | 120 | fond ≈50, bord ≈77 (profil Z=2200 : 56 61 65 70 73 76 77 77 77 | 52 50 | 72 70 67 64 63 62 de X 3040 à 3360) | bord −33, fond +10 |
| P05 Ape Canyon | 2600 | −1400 | bord 400, fond 250 | 300 | 282 | −118 (bord) |
| P05c ruine cabane 1924 | 2550 | −1300 | 300 (corniche) | 25 | 279 | −21 |
| P05s « Étroit » (9 de large) | 2700 | −1650 | 330 | 9 | 236 | −94 |
| P15 mine | 3333 | −667 | 390 | 30 | 238 | −152 |
| P16 pont | 3467 | 1600 | tablier 150, eau 100 | 30 de long | sol 175, pas de gorge ni d'eau là | pont à déplacer |
| P23 station météo | 2400 | −3467 | 560 | 12 | 604 | +44 |
| P24 tour est | 3800 | 667 | 300 (cabine +60) | 12 | 191 | −109 |
**P22 (533, 3733) est dans S6 (hors EST) : NE LE TOUCHE PAS**, signale-le seulement. Départ S1 actuel : (2800, 14, 3225).
Objets actuels (mesurés) : Lieu_01_Parking (2800,16,3230), Lieu_03_LavaCanyon (3200,78,2200), Lieu_16_Pont (3163,107,2017), pont de Gabriel `Workspace.Model` (3167,88,2019) ; S3 : Lieu_05_ApeCanyon (2615,284,−1400), ruine (2610,282,−1400), Lieu_15_Mine (3300,271,−75), EntreeMine_15 (3300,264,−71), Rails_01..04 (3300,270,−66..−102), Lieu_24_TourEst + TourGuet_24 (3360,238,1130) ; S8 : Source_Fonte (2800,439,−3420), crête panoramique (2800,387,−3000). Relève les autres toi-même (marqueurs `Lieu_*`, `Assets`, `Routes`, `Eau`, `Zones/B1`, `B5`, `Departs/S1`).
Bible 3.5 / 3.7 à respecter pour l'EST (adapte si tu déplaces des cours d'eau) : R2 = ruisseau de Lava Canyon (3067,−1600) → c(3467,0) → c(3067,1200) → (3467,2400) → c(3667,3067) → c(3600,3600) → (3733,4000), largeur 8 → 16 → 22, rapides dans la gorge ; RD1 route 83 (4000,3467) → P01 → P03, 18 de large, asphalte usé ; T1 sentier d'Ape Canyon P01 → (2400,1867) → (2200,267) → P05 → P06 ; T4 sentier de la gorge P16 → P15 → P05. Gorges : Ape Canyon profondeur 150 de (2300,−600) à (3000,−2200) ; Lava Canyon profondeur 70 le long de R2 entre Z=1600 et 2600 ; parois Basalt. Relief : pente douce du sud (Y≈40) au nord (≈420) + ancres (dôme du plateau (1200,−2733) 520 ; crête est (3200,−800) 400, rayon 667×933). Aplanir chaque lieu sur son rayon, raccorder sur 1,5× le rayon ; routes ≤ 8 %, sentiers ≤ 15 %.
Le **pont de Gabriel** (`Workspace.Model`, pont de Lava Canyon remis par Gabriel) suit P16 (décision G5) : déplace-le à (3467, tablier 150, 1600), orienté pour franchir le ruisseau (eau à 100), sans le modifier autrement ; le bloc `MANQUANT_PontSuspendu` de S7 (créé par nous) est à supprimer ou déplacer en conséquence.

## Méthode attendue
1. **Mesure avant** (déjà faite ci-dessus ; complète : X, Z, Y du sol pour chaque lieu, frontières, pente max des sentiers, niveaux d'eau). 
2. Introduis un champ de correction de hauteur **dans les modules S7/S3/S8** (pas dans `HauteurGlobale`, qui est partagé avec les autres régions) : module `Alignement_EST` (`Delta(X,Z)`, lisse : ancres de correction aux lieux, plateaux aplatis sur le rayon, raccord ≥ 1,5× le rayon, décroissance vers 0 aux frontières avec CENTRE : X=1400/1500) appliqué dans `Colonne` des trois secteurs (sol, gorges, niveaux d'eau, routes, sentiers) puis reconstruction dans l'ordre S7 → S3 → S8 (M) → S8 (O, couloir déjà dans S3). Tu peux déplacer rivières, gorges, cascades, routes et sentiers dans `S*Donnees` pour atteindre les cibles (P16 impose un ruisseau avec eau à 100 à (3467,1600) et un tablier à 150 ; P03 un bord à 110 et un fond à 40) ; explique chaque déplacement. Évite d'écraser le travail de S4/S2 (`Nettoyer` ne vide que ta boîte).
3. Déplace objets, marqueurs et clones d'assets du lieu à la position de la bible (rends les Y au sol par raycast), départ S1 et zones B1/B5 compris si leurs lieux bougent. Le marqueur et le bloc gris `MANQUANT_StationMeteo` de P23 : crée-les en S8 à (2400, 560, −3467) ; l'ancien (S2, (350,−2200)) est hors région : ne le touche pas, signale-le.
4. Continuité : rivières, lahar, sentiers (axe 100 % continu), eau monotone décroissante vers l'aval (mesure sur voxels), jonctions inchangées aux frontières (saut ≤ 4 ; mesure avant/après : S7↔S4 en X≈1400 Z 1400..2500 ; S3↔S4 X≈1400 Z −600..1700 ; S3/S8↔S2 X≈1500 Z −4000..−200 ; S7↔S6 Z≈2500 X≈1400).
5. Pathfinding Edit (joueur 5×2, créature 10×4, étapes < 1000 studs) : P01→P03, P01→P16, P16→P15 ; plus P05↔P15 (T4). Pentes : sentiers ≤ 15 % (sinon lacets), < 45° dans tous les cas, routes ≤ 8 %.
6. Toute valeur chiffrée choisie par toi (largeur de raccord, pente, profondeur, rayon de fondu) = **DÉFAUT PROPOSÉ**, à lister.
7. TEMP_ : préfixe `TEMP_A1A_` (attributs et dossiers), nettoie tout à la fin. Studio est occupé : captures peu fiables (caméra ≥ 60 studs au-dessus du sol, réessaie) ; un seul play test si indispensable (arrête-le).

## Livrables et rapport
- Modules : `Alignement_EST` et `S7/S3/S8Donnees|Terrain` modifiés, dans `ServerStorage/TerrainSectors` ; copies `.lua` exactes (taille + somme vérifiées) dans `C:\Users\gbest\Partir-UI-Jeu-Roblox---Studio\studio-export\terrain\` (**sans commit git : le coordinateur commite**).
- `wiki/secteurs/A1_PHASE_A_EST.md` (dans mon wiki local) : déplacements, paramètres, DÉFAUTS PROPOSÉS, limites.
- Rapport : tableau par lieu `X, Z, Y attendus (bible) | mesurés avant | mesurés après | écart (marge ±5)` ; sauts aux frontières avant/après ; pathfinding des 4 trajets ; nombre de voxels réécrits si connu ; ce qui reste hors tolérance (avec la raison chiffrée) ; problèmes ; décisions nécessaires.
