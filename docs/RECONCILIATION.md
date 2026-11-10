# Réconciliation dépôt ↔ export Studio (ticket C1, 2026-11-10)

Session cloud, lecture seule de `studio-export/` (commit `d86b4ec`, branche `studio/local-2026-11-07`).
Rien n'est corrigé ici : ce fichier liste les écarts. La bible (`BIBLE_PISTE_FROIDE.md`, découpée dans
`docs/bible/`) fait foi (section 0) ; décision de Gabriel du 2026-11-10 16:11 (registre de coordination) :
la bible 3.2 prime sur le placement fait dans Studio.

Repères : bible 3.1 = origine au centre, `X = x − 4000`, `Z = y − 4000` depuis l'ancien document.
`CARTE.md` (dossier projet) = bible + 4 000 sur X et Z. `studio-export/placements.md` est déjà en
coordonnées monde (bible).

## 1. `SUIVI.md` (dépôt) contre `studio-export/wiki/` (hot.md, decisions.md, secteurs/)

| # | `SUIVI.md` dit | `studio-export/wiki` dit | Écart |
| --- | --- | --- | --- |
| 1 | 2026-11-07 (2) : Overwrite publié (Lobby v12, Partie v13), places rouvertes et comparées à `builds/`, **RESET_OK** | `hot.md` (08/11) : place Partie 103506696801797 **vidée le 08/11** (1 654 éléments : « ancien projet » scripts, StarterGui, 8 matériaux PF_, Places, terrain effacé) ; il reste Camera, Terrain vide, Lighting | Contradiction ouverte (D02). Si v13 était le code du dépôt, `hot.md` n'aurait pas trouvé « l'ancien projet ». Compte rendu S0 du 10/11 (coordination) : place vide de code. |
| 2 | 2026-11-07 (3) : `TerrainBuilder.Build()` terminé dans la Partie (graine et relief de `MapConfig.Terrain`, 3.7) ; 18 lieux à ±5, 8 écarts | `hot.md` : terrain effacé le 08/11 puis reconstruit **par secteurs** (S1–S8) avec `HauteurGlobale` (graine 7.31) et des modules `SxDonnees`/`SxTerrain` | Le terrain actuel de Studio ne vient pas de `tools/terrain/TerrainBuilder.luau`. Voir la partie 5. |
| 3 | « État de reprise » : phase A terminée, code complet (Config, services, IA, 24 ScreenGui) | `hot.md` : « le squelette du jalon 1 (22/10) n'existait plus : à reconstruire (Config, Shared, Demarrage) » | Le wiki Studio ignore la phase A du dépôt. Les noms `Demarrage` et `Shared/Carte` (decisions.md) n'existent pas dans le dépôt (`Bootstrap`, `ReplicatedStorage/Shared`). |
| 4 | `Credits.luau` : 8 textures Poly Haven (forrest_ground_03, leafy_grass, brown_mud_dry, mud_forest, muddy_tracks, rock_pitted_mossy, dark_rock, burned_ground_01) | `hot.md` (« Textures Poly Haven appliquées ») : 10 autres textures en override (forrest_ground_01, forest_floor, forest_ground_04, brown_mud_03, river_small_rocks, rock_wall_02, dry_riverbed_rock, asphalt_02, gravel_ground_01, large_pebbles) | Les 10 textures de Studio ne sont pas dans `Credits` (règle 4 de la section 0). Non ajoutées par ce ticket : auteurs à relever. |
| 5 | DÉFAUT 2026-11-07 : teintes `MapConfig.Terrain.Tints`, MaterialVariant de 13.4 | `hot.md` : 6 matériaux PF_ générés par IA, puis remplacés par les textures du point 4 ; Asphalt/Slate/Cobblestone surchargés | Jeux de matériaux différents ; `Pebble` cité puis corrigé (pas un matériau de terrain). |
| 6 | Crédits : `ReplicatedStorage/Credits` (section 0, règle 4) | `decisions.md` : écran « Crédits » qui affiche `assets/sketchfab/CREDITS.md` | Deux sources de crédits. Le ticket C1 recopie les 15 modèles et Rock 09 dans `Credits.luau`. |
| 7 | Lieux de 3.2 : coordonnées de tous les lieux P01–P26 dans `MapConfig.Places` | `decisions.md` : « Lieux 15 à 26 : coordonnées absentes de CARTE.md → positions déduites (`secteurs/decoupage.md`), à valider » | Cause de la plupart des écarts de position (partie 4) : la bible 3.2 donne ces coordonnées. |
| 8 | Découpage : aucun (terrain d'un seul tenant, 3.7) | `decoupage.md` : 8 secteurs (S1 Zone interdite … S8 Coin nord-est) | Notion absente de la bible. |
| 9 | Lieu P18 : (−400, −667), bible 3.2 | `decisions.md` (08/11) : barrière déplacée à l'entrée de la zone interdite (S1), « décision Gabriel », position à valider | Position Studio (−1105, −740) : 709 studs de la bible. Décision du 10/11 : la bible prime. |
| 10 | Pas de plugin de chemin, Team Create avec TheDarkArtist02 | `hot.md` : même collaborateur | Concordant. |

## 2. Valeurs `Config` contre la bible (contrôle limité)

Contrôle automatique (script de lecture, 2026-11-10) de `MapConfig.Places` contre le tableau 3.2 : **X et Z
identiques pour les 26 lieux à position ponctuelle** ; P03 (3200, 40, 2200) et P16 (3467, 150, 1600)
vérifiés à la main. Y : la Config garde le **fond** pour P05 (250, bord 400 dans `rimY`) et P03 (40), le
bassin pour P13 (150), conformément aux commentaires de `MapConfig` (DÉFAUT de lecture du tableau).
`MapConfig.Terrain` : graine 1924, pente 40 → 420, bruit 5 octaves / 1 600 / 60 / crêtes 40, rivières
0,35 × largeur + 4 sur 3 × la largeur, gorges (150 et 70), aplanissement × 1,5, pentes 8 % et 15 %,
Rock/Basalt au-delà de 40°, 5 ancres : conformes à 3.7.
`AmbienceConfig.Wind` et `TreeWindRange = 120` : conformes à 12.4 ; `ProgressionConfig.Presets`
(`animatedTrees` 0/0/120/200) : conformes à 17.3.

Hors contrôle dans ce ticket : les autres modules Config (Player, Item, Weapon, Creature, Director…).
Ils ont été relus contre la bible en phase A (SUIVI 2026-11-05) ; aucune relecture refaite ici.

## 3. DataStore et MemoryStore (16.4 contre `SUIVI.md`)

| Nom | Bible 16.4 | Code du dépôt | `SUIVI.md` / `RESET_INVENTAIRE.md` |
| --- | --- | --- | --- |
| DataStore `PisteFroide_v1`, clé `player_<UserId>` | oui | `ProgressionConfig.DataStoreName` | Absent de la place au 07/11 (jamais utilisé) |
| MemoryStore `Parties` (carte triée, 900 s) | oui | `LaunchConfig` : `PartiesMapName = "Parties"`, `PartiesTTL = 900`, `GetSortedMap` | — |
| MemoryStore `Launch_<PrivateServerId>` (600 s) | oui | Carte de hachage `Launch` (DÉFAUT) contenant les clés `Launch_<id>`, TTL 600 | — |
| DataStore `PisteFroide_Profils_v1` | non | non | Seul DataStore listé le 07/11, origine inconnue, laissé intact |
| DataStore `PisteFroide_Progression_v1`, MemoryStore `PisteFroide_DonneesPartie` | non | non | Anciens scripts (inventaire 0a, 06/11) |

Écart unique avec la bible : `Launch_<id>` est une **clé** dans une carte de hachage nommée `Launch`, pas
un MemoryStore nommé `Launch_<id>` (DÉFAUT technique de la phase A1). Le wiki Studio ne cite aucun nom
de stockage.

## 4. `studio-export/placements.md` contre le tableau 3.2 (marge ±5 studs)

Distance horizontale entre le pivot du modèle et le centre du lieu ; Y = pivot du modèle (pas forcément
le sol). « dans le rayon » = hors des ±5 mais à l'intérieur du rayon du lieu (objets répartis dans un camp).

| Modèle | Lieu | Studio X, Y, Z | Bible X, Y, Z | ΔX / ΔY / ΔZ | Dist. | Rayon | À ±5 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| SacADos_01 | P09 | -813, 230, 594 | -800, 230, 600 | -13 / +0 / -6 | 14 | 50 | dans le rayon |
| SacADos_02 | P09 | -810, 230, 590 | -800, 230, 600 | -10 / +0 / -10 | 14 | 50 | dans le rayon |
| SacADos_03 | P09 | -806, 230, 587 | -800, 230, 600 | -6 / +0 / -13 | 14 | 50 | dans le rayon |
| Glaciere_09 | P09 | -782, 230, 598 | -800, 230, 600 | +18 / +0 / -2 | 18 | 50 | dans le rayon |
| Tente_01 | P09 | -821, 230, 595 | -800, 230, 600 | -21 / +0 / -5 | 22 | 50 | dans le rayon |
| Tente_02 | P09 | -818, 230, 588 | -800, 230, 600 | -18 / +0 / -12 | 22 | 50 | dans le rayon |
| Tente_03 | P09 | -813, 230, 583 | -800, 230, 600 | -13 / +0 / -17 | 21 | 50 | dans le rayon |
| Rechaud_09 | P09 | -800, 230, 626 | -800, 230, 600 | +0 / +0 / +26 | 26 | 50 | dans le rayon |
| Radio_17 | P17 | 207, 202, 1497 | 800, 110, 3067 | -593 / +92 / -1570 | 1678 | 25 | **NON** |
| TourGuet_24 | P24 | 3360, 238, 1130 | 3800, 300, 667 | -440 / -62 / +463 | 639 | 12 | **NON** |
| EntreeMine_15 | P15 | 3300, 264, -71 | 3333, 390, -667 | -33 / -126 / +596 | 597 | 30 | **NON** |
| Rails_01 … Rails_04 | P15 | 3300, 270, -66 … -102 | 3333, 390, -667 | ≈ -33 / -120 / +565…+601 | 566–602 | 30 | **NON** |
| TourGuet_26 | P26 | -2610, 236, 100 | -3600, 260, -667 | +990 / -24 / +767 | 1252 | 12 | **NON** |
| TourGuet_25 | P25 | -2070, 346, -3500 | -200, 470, -3067 | -1870 / -124 / -433 | 1919 | 12 | **NON** |
| BarriereRoute_18 | P18 | -1105, 334, -740 | -400, 300, -667 | -705 / +34 / -73 | 709 | 10 | **NON** |
| Panneau_AreaClosed_1 | P18 | -1112, 343, -732 | -400, 300, -667 | -712 / +43 / -65 | 715 | 10 | **NON** |
| Panneau_AreaClosed_2 | P18 | -1094, 338, -741 | -400, 300, -667 | -694 / +38 / -74 | 698 | 10 | **NON** |
| TourGuet_11 | P11 | 150, 370, -1600 | 0, 420, -1600 | +150 / -50 / +0 | 150 | 15 | **NON** |
| PileBuches_1 | P10 | -1500, 75, 3345 | -1400, 70, 3307 | -100 / +5 / +38 | 107 | 80 | **NON** |
| PileBuches_2 | P10 | -1285, 83, 3360 | -1400, 70, 3307 | +115 / +13 / +53 | 127 | 80 | **NON** |
| PileBuches_3 | P10 | -1255, 94, 3250 | -1400, 70, 3307 | +145 / +24 / -57 | 156 | 80 | **NON** |
| PileBuches_4 | P10 | -1480, 109, 3185 | -1400, 70, 3307 | -80 / +39 / -122 | 146 | 80 | **NON** |
| Model (pont, Gabriel) | P16 | 3167, 88, 2019 | 3467, 150 (tablier), 1600 | -300 / -62 / +419 | 515 | 30 de long | **NON** |
| TEST_Rock09 | (près de P01) | 2790, 15, 3140 | 2800, 120, 3200 | -10 / -105 / -60 | 61 | 60 | sans objet (test) |

Seul le camp P09 est en place (8 modèles dans le rayon de 50, au sol à 230). Tous les autres lieux
équipés sont hors marge. Lieux dont les wiki de secteurs donnent une position ou une altitude différente
de 3.2 (sans modèle placé) :

| Lieu | Wiki Studio | Bible 3.2 |
| --- | --- | --- |
| P05 / P05c | gorge 55–60 de profondeur, rebord 283 ; ruine à (2615, −1400), Y 280 | bord 400, fond 250 (gorge 150, 3.7) ; ruine (2550, −1300), Y 300 |
| P06 | centre (1100, −2600), Y 412 | (1200, −2600), Y 480 |
| P07a | entrée (−2440, 2345), Y 120 | (−2507, 2400), Y 60 |
| P10 | aire d'engins Y 88 | Y 70 |
| P19 | (−2150, −2280), Y 310 | (−2933, −2667), Y 380 |
| P20 | (−2500, −1800), ellipse 350 × 250, eau 336 | (−1667, −1733), 600 × 320, eau 330 |
| P23 | (350, −2200), Y 408 | (2400, −3467), Y 560 |

## 5. `studio-export/terrain/HauteurGlobale.lua` contre la bible 3.7 (sans correction)

| Point | Bible 3.7 (et `MapConfig.Terrain`) | `HauteurGlobale.lua` |
| --- | --- | --- |
| Graine | **1924** | `Graine = 7.31` (3e coordonnée de `math.noise`) |
| Pente de base | sud Y ≈ 40 → nord Y ≈ 420 | `HSud = 20` à Z = 4000 → `HNord = 400` à Z = −3500, prolongée jusqu'à 1,2 × (au-delà de 400 au nord) |
| Relief de base | somme de collines gaussiennes sur 5 ancres (dôme 520, crête de la tour 430, crête est 400, colline ouest 220, cuvette du lac 320) | **aucune ancre** |
| Bruit | fractal 5 octaves, période 1 600, amplitude 60, fréquence × 2 et amplitude ÷ 2 par octave | 5 couches de `math.noise` non fractales : vallées 110 / 1 250, 38,5 / 600, collines 100 / 350, 40 / 150, détail 8 / 60 |
| Bruit en crêtes | amplitude 40 sur les crêtes | absent |
| Modulation | aucune | relief × 0,6 au sud → × 1,4 au nord (`ReliefSud`, `ReliefNord`) |
| Plancher | Y = 0 au point le plus bas (3.1) | plancher doux 16, asymptote 8 (`Plancher`, `PlancherK`) |
| Gorges | Ape Canyon 150 de profondeur de (2300, −600) à (3000, −2200), Lava Canyon 70 ; parois Basalt | fonction générique `CreuserGorge(d, fond, rebord, demiLargeur, paroi)` ; paramètres par secteur (S3 : 55–60) |
| Aplanir les lieux | rayon, raccord 1,5 × le rayon | `Arase(h, cible, d, rayonPlein, rayonFondu)`, paramètres par secteur |
| Graine de la végétation, rivières, routes | 3.7 points 3, 6, 9 | hors de ce module (`SxDonnees`) |

Conséquence : le relief de Studio ne peut pas reproduire les altitudes de 3.2 sans retouche par lieu ;
`tools/terrain/TerrainBuilder.luau` (dépôt) suit 3.7 mais n'est plus ce qui tourne dans Studio.

## 6. Noms qui diffèrent de la bible

| Bible / dépôt | Studio | Remarque |
| --- | --- | --- |
| `ServerStorage/TerrainBuilder` = un ModuleScript unique (`tools/terrain/TerrainBuilder.luau`, 3.7, 18) | `ServerStorage/TerrainBuilder` = un **dossier** de 18 modules (HauteurGlobale, MelangeMateriaux, S1–S8 Donnees/Terrain) ; renommé **`TerrainSectors`** dans Studio (compte rendu S0 du 10/11) | Le renommage n'apparaît dans aucun fichier du commit `d86b4ec` ; les wiki disent encore `TerrainBuilder`. Même nom, deux contenus. |
| — | `S3_NordEst` (X 1400..4000, Z −2500..1700 : l'est de la carte) et `S8_NordEst` (X 1500..4000, Z −4000..−2500 : le vrai coin nord-est) | Deux secteurs portent « NordEst ». `decoupage.md` appelle S8 « Coin nord-est ». |
| Lieux `Pxx_Nom` (section 0) | `Lieu_02_Lahar_Nord`, `Lieu_08_ZoneInterdite`, `Lieu_10_Chantier`, `Lieu_18_Barriere`, `TourGuet_24`, `EntreeMine_15`… | Convention `Pxx` non suivie. |
| Assets `Catégorie_Nom_Variante` (13.3, ex. `Prop_…`, `Tree_…`) | `SacADos_01`, `Glaciere`, `Rechaud`, `FusilChasse`, `FusilRigby`, `PontSuspendu`… (français, sans catégorie) | Noms de 13.3 non utilisés. |
| `Shared/…`, `Bootstrap` | `Shared/Carte`, `Demarrage` (`decisions.md`, `hot.md`) | Noms de l'ancien projet. |
| Matériaux 13.4 (`MaterialVariant` Poly Haven nommés dans `MapConfig`) | `MaterialService/PolyHaven`, `AssistantMaterials/PF_*` | Voir partie 1, point 4. |

## 7. Modèles importés contre la bible 13.3 (auteurs et noms)

Les 15 modèles de `Credits.luau` (liste de la coordinatrice) comparés au tableau 13.3. La plupart des
écarts d'auteur sont sans doute un nom affiché contre un identifiant Sketchfab : **non confirmé**.

| Modèle (Credits) | Auteur (Credits) | Bible 13.3 : nom attendu, auteur | Rangement Studio | Écart |
| --- | --- | --- | --- | --- |
| Fire lookout tower | k1llreal | `Tower_Lookout_A`, k1llreal (P11, P24, P25, P26) | `Structures/TourGuet_24` | nom seulement |
| Mine entrance | almarudjord | `Mine_Entrance_A`, « almarudjord ou jsabbott » | `Structures/EntreeMine` | nom |
| Rail track straight | Unreal Nick | `Mine_Rail_A`, lastnickleft | `Structures/Rails_01` | nom, auteur |
| Suspension Bridge | coffeecat | `Bridge_Suspension_A`, coffeecat112 | `Structures/PontSuspendu` | nom, auteur |
| Road Gate Barrier | ngooiwong | `Gate_Road_A`, ngooi1397 | `Props/BarriereRoute` | nom, auteur |
| Wooden Sign | Carlos | `Sign_Wood_A`, carlossamuelariza | `Props/Panneau_ApeCanyonTrail` | nom, auteur |
| Portable gas stove / Cooler | manamsudheer / MrPuppet | `Camp_Stove_A`, `Camp_Cooler_A` | `Camp/Rechaud`, `Camp/Glaciere` | nom |
| Backpack | MadeByYeshe | `Camp_Backpack_A` | `Camp/SacADos_01` | nom |
| Log pile | 00amza | `Prop_LogPile_A` | `Props/PileBuches` | nom |
| Radio | 3DSKETCH1550 | `Prop_Radio_Old` (P17, P11) | `Props/Radio` | nom |
| Vintage  Camera | EricKos | `Item_PhotoCamera`, « Vintage Camera, **Ledger9o9** » | `Props/CameraVintage` | **autre modèle que celui de la bible** (à confirmer) |
| Hunting Rifle / Rigby | Ryan_Nein / Martijn | `WPN_Rifle` (modèle) : Ryan_Nein (mobile), Rigby de MartijnVaes (PC) | `Weapons/FusilChasse`, `Weapons/FusilRigby` | nom, auteur (Martijn / MartijnVaes) |
| Modern Camping Tent | Guy in a Poncho | `Camp_Tent_A`, ponchoguy (P09) | `Camp/Tente_01` | nom, auteur |

Le code cherche les objets dans `ReplicatedStorage/Items/Item_<Nom>` (`ItemConfig.ModelsFolder`,
`ItemSpawnService`) : aucun modèle de Studio n'y est rangé ; tous les objets restent des blocs gris
`MANQUANT_`. Détail dans `docs/ECARTS_INTERACTIFS.md`.

## Questions pour Gabriel (aucune n'est tranchée ici)

1. D02 : la place Partie publiée contient-elle encore le code du dépôt (v13) ? S0 dit non.
2. Le terrain de référence est-il celui des secteurs (HauteurGlobale, graine 7.31) ou celui de 3.7
   (TerrainBuilder, graine 1924) ? La bible ne connaît que le second.
3. Nom définitif du dossier de terrain dans ServerStorage : `TerrainBuilder` ou `TerrainSectors` ?
4. Les 10 textures appliquées dans Studio (partie 1, point 4) remplacent-elles celles de `Credits` ?
5. Version de la licence CC BY de chaque modèle Sketchfab (3.0 ou 4.0).
6. L'appareil photo d'EricKos remplace-t-il celui de Ledger9o9 (13.3) ?
