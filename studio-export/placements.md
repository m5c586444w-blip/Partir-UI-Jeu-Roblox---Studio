# Placements des modèles dans la place Partie (Studio, relevé du 10/11/2026)

Source : Studio, place « Partie » (placeId 103506696801797), mode Edit, lecture du pivot (`GetPivot().Position`) de chaque modèle,
coordonnées MONDE en studs (X = x − 4000, Z = y − 4000 ; nord = −Z). Relevé en lecture seule. Nombre de modèles placés : 27.
Tous sont des clones de modèles importés depuis des AssetId de `uploaded_assets.json` (compte Roblox 4566808450), sauf `Workspace/Model`
(pont de Lava Canyon remis par Gabriel) et `Workspace/TEST_Rock09` (test d'import, AssetId 85416985004708, Poly Haven CC0).

| Nom | Chemin (Studio) | Position X, Y, Z |
| --- | --- | --- |
| SacADos_01 | Workspace/Carte/S4_Centre/Assets/SacADos_01 | -813, 230, 594 |
| SacADos_02 | Workspace/Carte/S4_Centre/Assets/SacADos_02 | -810, 230, 590 |
| SacADos_03 | Workspace/Carte/S4_Centre/Assets/SacADos_03 | -806, 230, 587 |
| Glaciere_09 | Workspace/Carte/S4_Centre/Assets/Glaciere_09 | -782, 230, 598 |
| Tente_01 | Workspace/Carte/S4_Centre/Assets/Tente_01 | -821, 230, 595 |
| Tente_02 | Workspace/Carte/S4_Centre/Assets/Tente_02 | -818, 230, 588 |
| Tente_03 | Workspace/Carte/S4_Centre/Assets/Tente_03 | -813, 230, 583 |
| Rechaud_09 | Workspace/Carte/S4_Centre/Assets/Rechaud_09 | -800, 230, 626 |
| Radio_17 | Workspace/Carte/S4_Centre/Assets/Radio_17 | 207, 202, 1497 |
| TourGuet_24 | Workspace/Carte/S3_NordEst/Assets/TourGuet_24 | 3360, 238, 1130 |
| EntreeMine_15 | Workspace/Carte/S3_NordEst/Assets/EntreeMine_15 | 3300, 264, -71 |
| Rails_01 | Workspace/Carte/S3_NordEst/Assets/Rails_01 | 3300, 270, -66 |
| Rails_02 | Workspace/Carte/S3_NordEst/Assets/Rails_02 | 3300, 270, -78 |
| Rails_03 | Workspace/Carte/S3_NordEst/Assets/Rails_03 | 3300, 270, -90 |
| Rails_04 | Workspace/Carte/S3_NordEst/Assets/Rails_04 | 3300, 270, -102 |
| TourGuet_26 | Workspace/Carte/S5_Ouest/Assets/TourGuet_26 | -2610, 236, 100 |
| TourGuet_25 | Workspace/Carte/S1_ZoneInterdite/Assets/TourGuet_25 | -2070, 346, -3500 |
| BarriereRoute_18 | Workspace/Carte/S1_ZoneInterdite/Assets/BarriereRoute_18 | -1105, 334, -740 |
| Panneau_AreaClosed_1 | Workspace/Carte/S1_ZoneInterdite/Assets/Panneau_AreaClosed_1 | -1112, 343, -732 |
| Panneau_AreaClosed_2 | Workspace/Carte/S1_ZoneInterdite/Assets/Panneau_AreaClosed_2 | -1094, 338, -741 |
| TourGuet_11 | Workspace/Carte/S2_Plateau/Assets/TourGuet_11 | 150, 370, -1600 |
| PileBuches_1 | Workspace/Carte/S6_SudOuest/Assets/PileBuches_1 | -1500, 75, 3345 |
| PileBuches_2 | Workspace/Carte/S6_SudOuest/Assets/PileBuches_2 | -1285, 83, 3360 |
| PileBuches_3 | Workspace/Carte/S6_SudOuest/Assets/PileBuches_3 | -1255, 94, 3250 |
| PileBuches_4 | Workspace/Carte/S6_SudOuest/Assets/PileBuches_4 | -1480, 109, 3185 |
| Model (pont de Lava Canyon, remis par Gabriel) | Workspace/Model | 3167, 88, 2019 |
| TEST_Rock09 (test d'import) | Workspace/TEST_Rock09 | 2790, 15, 3140 |

## Modèles maîtres rangés (non placés tels quels) : `ServerStorage/Assets/`
| Nom | Chemin |
| --- | --- |
| BarriereRoute | ServerStorage/Assets/Props/BarriereRoute |
| Radio | ServerStorage/Assets/Props/Radio |
| Panneau_ApeCanyonTrail | ServerStorage/Assets/Props/Panneau_ApeCanyonTrail |
| CameraVintage | ServerStorage/Assets/Props/CameraVintage |
| PileBuches | ServerStorage/Assets/Props/PileBuches |
| PontSuspendu | ServerStorage/Assets/Structures/PontSuspendu |
| Rails_01 | ServerStorage/Assets/Structures/Rails_01 |
| EntreeMine | ServerStorage/Assets/Structures/EntreeMine |
| TourGuet_24 | ServerStorage/Assets/Structures/TourGuet_24 |
| FusilChasse | ServerStorage/Assets/Weapons/FusilChasse |
| FusilRigby | ServerStorage/Assets/Weapons/FusilRigby |
| Glaciere | ServerStorage/Assets/Camp/Glaciere |
| SacADos_01 | ServerStorage/Assets/Camp/SacADos_01 |
| Rechaud | ServerStorage/Assets/Camp/Rechaud |
| Tente_01 | ServerStorage/Assets/Camp/Tente_01 |

## Remarques
- Le panneau « Ape Canyon Trail » du parking (lieu 1) n'est pas placé (bloc gris `MANQUANT_PanneauApeCanyonTrail` conservé en S7).
- Le pont suspendu (maître `PontSuspendu`) n'a pas été placé par nous : Gabriel a posé son propre pont (`Workspace/Model`).
- La barrière du lieu 18 est désormais à l'entrée de la zone interdite (S1), plus en S7.
- Les positions de poste 17, mine 15, tours 24, 25, 26 et 11 sont déduites (à valider).
- Les clones sont des packages : les corrections d'échelle, de pivot et d'ancrage n'existent que sur les copies insérées.
- Crédits CC BY : `assets/sketchfab/CREDITS.md` (copie du fichier de Gabriel).
