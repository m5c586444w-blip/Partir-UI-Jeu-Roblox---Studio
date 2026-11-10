# Assets
Source de vérité : `ASSETS.md` (racine). Ici : état d'avancement seulement.

## Règles
Poly Haven = CC0. Sketchfab : lire la licence de la page avant usage, noter le crédit. Jamais le Marketplace. Absent → bloc gris `MANQUANT_<nom>`. Import FBX/GLB : Gabriel (importeur 3D de Studio).

## État
- Dossier `assets/` : vide (08/11). Aucun modèle téléchargé trouvé dans Téléchargements.
- Blender 4.2 et 5.0 installés. Serveur Blender MCP : non installé / non vérifié.
- `MANQUANT_` posés : aucun.

## Connus manquants
Neige, pruche (Free3D à vérifier), Bigfoot (licence whitehair19 à confirmer), carte murale et documents du musée (textures à créer), écume (particules).

## Import d'assets : méthode et état (08/11/2026)
- **Méthode trouvée** : `open_cloud_invoke` (Studio MCP) `POST /assets/v1/assets` avec `files` (GLB/FBX/PNG...), sans clé API (jeton OAuth du MCP, scopes asset:read + asset:write déjà accordés : sonde 200). Compte créateur de l'expérience : users/4566808450 (= utilisateur Studio). Puis `insert_asset` par ID. Skill Studio : `rbx-import-asset`.
- **Bloquant actuel** : le dossier `assets/export` n'est pas dans les dossiers d'upload approuvés (Assistant Settings → MCP Permissions). À approuver par Gabriel.
- `AssetImportService` n'est pas accessible depuis `execute_luau` (service nil).
- Les uploads sont permanents (Open Cloud ne peut pas supprimer les Models/Images ; Creator Dashboard seulement).
- **Test Rock 09** (Poly Haven, CC0, Jenelle van Heerden) : téléchargé en glTF 1K (`assets/polyhaven/modeles/rock_09/`, 1,96 Mo), réduit dans Blender 5.0 en ligne de commande de 12 416 à 8 000 triangles, exporté `assets/export/rock_09_reduit.glb` (1,87 Mo). Pas encore envoyé.
- Limite triangles par mesh Roblox : à vérifier dans la doc avant les gros modèles.

## IDs d'assets envoyés sur le compte (insérables sans restriction)
- Textures terrain Poly Haven (1K, CC0), images : voir `MaterialService/PolyHaven` (ColorMap/NormalMap/RoughnessMap de chaque variante PH_*).
- Modèles : aucun pour l'instant.

## Test d'import Rock 09 : RÉUSSI (08/11/2026)
- Chaîne validée : Poly Haven (CC0) → Blender 5.0 en ligne de commande (12 416 → 8 000 triangles) → GLB → `open_cloud_invoke POST /assets/v1/assets` (dossier `assets/export` approuvé dans MCP Permissions) → modération Approved → `insert_asset` → vérification.
- **Asset Model : 85416985004708** (`PF_Rock09_PolyHaven_CC0`, compte users/4566808450). Importeur : 1 MeshPart `rock_09_LOD0`, SurfaceAppearance (ColorMap + NormalMap créés automatiquement : images 107765176028827 et 123499952462408), non ancré par défaut.
- **Échelle** : GLB en mètres arrive à 1 m = 1 stud (taille 0,12×0,03×0,16 studs). Correction : `ScaleTo(échelle / 0,28)` → ~0,44 stud (c'est un petit caillou de ~12 cm). Les gros rochers (Boulder 01...) suivront la même règle (÷0,28).
- Placement : `TEST_Rock09` posé près du parking S7 (2790, 15,5, 3140), ancré, au sol (à supprimer quand Gabriel a vu). L'insertion arrive à une position arbitraire (ici près de (2572,282,-1713)) : toujours repositionner.
- Package : `isPackage=true` ; les corrections d'échelle/ancrage ne vivent que sur la copie insérée.
- Rappel : upload permanent (suppression seulement via Creator Dashboard).

## Règle d'import (08/11/2026, vérifiée sur les 15 modèles)
- Les 15 modèles sont insérés (15 insertions, aucun doublon) puis rangés dans `ServerStorage/Assets/<Props|Structures|Weapons|Camp>` : ce sont des MAÎTRES corrigés (ancrés, pivot au sol au centre de la base, yaw normalisé, échelle réelle). Les placements dans `Workspace/Carte/<S>/Assets` sont des clones. Tous insérés comme packages : corrections valables sur la copie seulement.
- Chaque insertion arrive avec une rotation Y arbitraire (-21,8 deg) : retirer le yaw du plus gros MeshPart, puis `WorldPivot` = centre bas de la boîte englobante (étendue des 8 coins de chaque part, pas `GetBoundingBox` d'un pivot tourné).
- L'échelle d'import varie d'un modèle à l'autre (unités Sketchfab différentes) : ne PAS appliquer un facteur fixe 1/0,28. Mesurer, puis `ScaleTo(cible / taille mesurée)` avec la taille réelle voulue (avatar = 5 studs, 1 m ~ 2,9 studs). Facteurs finaux : voir colonne Placé.
- Textures : SurfaceAppearance/TextureID présents sur tout sauf Tour de guet, Glacière, Réchaud (gris Plastic par défaut, source sans texture). Tour peinte gris acier + Metal ; Glacière et Réchaud laissés gris (à repeindre).
- Modèles à dalle : la tour contenait 2 grosses dalles de neige/sol (283 x 40 x 283) supprimées de la copie.
- Collision : `Default` donne une enveloppe convexe pleine. Mine : cadre rendu non solide (CanCollide/CanQuery faux) + 3 parts invisibles `Collision_*` (montants, linteau) ; ouverture libre mesurée par rayons : 16 de large x 20 de haut.
- Captures Studio : fiables à moins de ~50 studs du sol ; blanches ou en timeout dans la gorge de Lava Canyon (pont).
- Placement : raycast descendant sur `workspace.Terrain` (le rendu voxel peut décaler visuellement d'environ 2 studs).

## Assets Sketchfab envoyés par Gabriel sur son compte (AssetIds, 08/11/2026)
Tous CC BY (crédits dans `assets/sketchfab/CREDITS.md`). Ecran Crédits obligatoire avant publication (decisions.md).
| Modèle | AssetId | Usage prévu | Rangé dans ServerStorage/Assets | Placé / anomalies |
| --- | --- | --- | --- | --- |
| Wooden Sign | 71803035309466 | panneaux | Props/Panneau_ApeCanyonTrail (échelle 2,66, 3,8 studs, texturé OK) | Non placé : panneau du parking (lieu 1) laissé à `MANQUANT_PanneauApeCanyonTrail` ; clone Area closed retiré de S7 (lieu 18 va en S1). Pas de texte. |
| Fire lookout tower | 99120838331356 | tours 11, 24, 25, 26 | Structures/TourGuet_24 (x0,2445, 50 de haut) | Placé S3 `Assets/TourGuet_24` (3360, 238, 1130), position à valider. Sans texture (peint). ANOMALIE : pathfinding n'atteint que y=247 sur 238 (escaliers non confirmés praticables, même en PreciseConvexDecomposition) : à tester à la main. Tours 11/25/26 : non placées. |
| Road Gate Barrier | 82756730972814 | barrière (18) | Props/BarriereRoute (x1,18, 14 de long) | Retiré de S7 (décision Gabriel) ; à poser par l'agent S1 à l'entrée de la zone interdite. |
| Hunting Rifle | 93090548304566 | fusil léger | Weapons/FusilChasse (x4,375, 3,5 long) | Non placé (jalon armes) |
| Rigby Hunting Rifle | 89935441257174 | fusil détaillé | Weapons/FusilRigby (x18, 3,6 long) | Non placé (jalon armes) ; 1 mesh sur 12 sans texture |
| Radio | 135634267393894 | poste des rangers (17) | Props/Radio (x0,31, 1,5) | Placé S4 `Assets/Radio_17` au sol (207,202,1497), texturé OK. Poste (position déduite) à valider. |
| Mine entrance | 131851940881655 | mine (15) | Structures/EntreeMine (x0,23, 64 x 49 x 31,5) | Placé S3 `Assets/EntreeMine_15` (3300, z -71), dos au mur, ouverture au nord, praticable (pathfinding Success). Position à valider. |
| Suspension Bridge | 119362607520258 | pont (16) | Structures/PontSuspendu (x6,8, 110 de long, tablier 13,6 de large, bombé 4 studs) | NON placé : Gabriel gère le pont ; bloc `MANQUANT_PontSuspendu` laissé. Maître prêt (tablier/culées en PreciseConvexDecomposition). |
| Log pile | 135629014237316 | chantier (10) | Props/PileBuches (x1, 5,5 x 1,3 x 4,7) | Non placé (S6) |
| Vintage Camera | 112541740094592 | objet de preuve | Props/CameraVintage (x0,0189, 0,7 max) | Non placé (jalon objets) |
| Cooler | 81678585475499 | camp (9) | Camp/Glaciere (x15, 1,8) | Placé S4 `Assets/Glaciere_09` ; sans texture (gris) |
| Portable gas stove | 77994982361404 | camp (9) | Camp/Rechaud (x0,075, 1,0) | Placé S4 `Assets/Rechaud_09` ; sans texture (gris) |
| Backpack | 96695437341577 | sacs | Camp/SacADos_01 (x0,75, 1,5) | Placé S4 `Assets/SacADos_01..03` (3 clones) ; textures réduites, aspect correct |
| Modern Camping Tent | 133821101214636 | camp (9) | Camp/Tente_01 (x5,11, 9 de large) | Placé S4 `Assets/Tente_01..03` en arc face au centre (-800,600), texturé OK |
| Rail track straight | 79236002350923 | rails, mine (15) | Structures/Rails_01 (x0,475, 12 de long, écartement ~3) | Placé S3 `Assets/Rails_01..04` depuis la mine vers le nord (z -60 à -108), posés au sol |
Poly Haven : Rock 09 = 85416985004708 (test, CC0).
Blocs MANQUANT_ remplacés puis supprimés : Tentes, Rechaud, Glaciere, SacsADos, Radio, TourGuet, EntreeMine, Rails, PanneauAreaClosed, BarriereRoute. Restent : PanneauApeCanyonTrail, PontSuspendu (Gabriel), CabaneRangers, VanVW, EpaveVoiture, Sapins*, ParoisRock, CabaneRuine1924, Wagonnet.
