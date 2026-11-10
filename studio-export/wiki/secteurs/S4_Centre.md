# S4 Centre (08/11/2026) - terrain, ruisseau, sentiers, lieux 9/4/17 : fait, a valider visuellement

## Fait (place Partie, cloud)
- Terrain voxel 4 studs, X -1100..1400 / Z -600..2500 (S4 + 100 de marge douce nord/ouest ; bord sud : leger fondu Z 2400..2500 absent pour X>1350). Jonction est avec S7 a X=1400 : meme fonction `H`, meme sentier (voir plus bas) ; saut max mesure 2.6 studs / 4 studs (pente naturelle) sur X 1380..1620 pour 8 valeurs de Z (1410..2490) : aucune marche. Le lahar (X>=1640 apres fondu) ne touche pas S4.
- Code : `ServerStorage/TerrainBuilder/{S4Donnees, S4Terrain}` (+ `MelangeMateriaux`, partage). `S4Terrain.Construire(cx,cz)` : cx 0..9, cz 0..12 (chunks 256, `NbX`, `NbZ`), `Nettoyer()`. Reconstruction complete : ~130 appels, ~10 s. Copies locales : `terrain/S4Donnees.lua`, `terrain/MelangeMateriaux.lua`, `terrain/HauteurGlobale.lua`.
- Piege : `require` d'un module modifie renvoie l'ancienne version (cache). Toujours cloner `TerrainBuilder` puis `require` le clone (le cache peut meme etre plus ancien que la Source : H(2550,1500) valait 63 en cache, 99 en Source fraiche).
- Camp des geologues (9) : aire plate 80x80 centree (-800,600), hauteur 230 (multiple de 4, mesuree plate a +-0.01), fondu 45. Depart `Workspace/Departs/S3` (SpawnLocation, attribut Depart="S3", tag `Depart`). Test : joueur pose sur S3, vivant, HRP 3.9 au-dessus du sol.
- Poste des rangers (17) : plateforme 40x40 en (200,1500) (position deduite, a valider), hauteur 202, plate. Piste d'acces (spur) depuis le sentier.
- Foret ancienne (4) : partie X 500..1400 ; marqueur `Lieu_04_ForetAncienne` (950,1000). Sol sous-bois dense (couvert 0.92) : LeafyGrass ~60 %, Ground ~29 %, Rock ~8 % (mesure sur 1200 colonnes, aucun materiau > 70 %).
- Zones Bigfoot : `Zones/B4` (950,1000, Rayon 250), `Zones/B6` (-800,600, Rayon 120) : Part ancre invisible.
- Ruisseau (affluent NE -> SO) : de (1250,-250) a la sortie (-1110,2260), largeur d'eau 16 -> 22, cuvette 3.5, 2 petites cascades (s 900 chute 4, s 1900 chute 5 ; `Eau/Cascade_01..02`). Niveau d'eau mesure par voxels : 0 hausse. Niveau du lit a la sortie : ~79.4 (eau ~78.9), **S5 doit continuer depuis (-1110,2260) a ce niveau, monotone decroissant**. NB : le terrain naturel descend vers le sud-ouest (Z 1900+, X -1800 : ~74), pas vers la cascade 13 supposee en (-1800,1200) (relief ~135-150) : S5 devra soit descendre la riviere plus au sud, soit deplacer la cascade 13. Marqueur `Eau/Sortie_Ruisseau` (attributs NiveauEau, Largeur).
- Sentiers (Ground, 4.4 de large + bords irreguliers, coeur continu) : camp -> poste -> est jusqu'a (1660,1600) (bord ouest du lahar ; le troncon X>1300 est aussi applique par S7 via `S4Donnees.AppliquerSentierEst`) ; sentier nord camp -> (-340,-560) (bord nord, vers la tour de S2) ; piste du poste. Marqueurs dans `S4_Centre/Routes`. Le sentier traverse le ruisseau a gue vers (-170,1105).
- Blocs gris (assets absents) : `MANQUANT_Tentes`, `MANQUANT_SacsADos`, `MANQUANT_Rechaud`, `MANQUANT_Glaciere` (camp), `MANQUANT_CabaneRangers`, `MANQUANT_Radio` (poste), `MANQUANT_Sapins_Camp/_Poste/_ForetAncienne` (un temoin par clairiere-cle) dans `S4_Centre/Lieux`.
- Marqueurs : `Workspace/Carte/S4_Centre/{Terrain_Notes, Routes, Eau, Lieux}` ; `Lieu_09_Camp`, `Lieu_04_ForetAncienne`, `Lieu_17_PosteRangers` (Numero/Nom/Secteur="S4").

## Parametres (S4Donnees.Cfg)
Camp/Poste (Demi, Fondu), Cuvette, PenteRuisseau .004, Cascades, Sentier (Demi 2.2, Fondu 12), PtsRuisseau/PtsSentierEst/PtsSentierNord/PtsSpur, Marge/ChuteMarge (nord/ouest), SudFondu/SudChute. Couvert forestier : `D.Couvert(X,Z)` (clairieres autour du camp et du poste). Relief : altRoche 330 (roche au-dessus). Terrain max 380 (nord-ouest), min 29.

## Verifie (play test)
- Joueur sur S3 : pose sur le sol. Pathfinding : camp -> poste en 2 etapes (< 1000 studs) Success ; la requete directe de 1345 studs donne NoPath (limite de recherche de PathfindingService, pas un obstacle : chaque sous-trajet reussit) ; poste -> (1000,1600) -> (1660,1600) -> traversee du lahar (2450,1700) -> (2520,2400) -> fin route 83 (3090,2400) -> parking : tous Success, pas max 29 (zones ouvertes).
- Console : aucune erreur du projet (plugin roblox-path-plugin-main et assets de textures de Gabriel "content representation is being generated").

## Limites / a faire
- Validation visuelle par Gabriel ; captures Studio peu fiables. Pas de vegetation (arbres Poly Haven a importer), pas d'eclairage final.
- Rendu des materiaux : le terrain en voxel de 4 studs rend les materiaux par cellule ; l'alignement visible est decale de ~2 studs (mesure : l'asphalte d'une cellule apparait sur ~8 studs). Les coeurs de routes/sentiers sont donc elargis d'une demi-cellule pour rester continus.
- Le poste (17) est a valider (position deduite). Bord sud de S4 : Z>2500 non construit (S5/S6).
- Bord nord/ouest : marge descendante de 45 (S3/S2/S5 reprendront H pur ; la marge est une coupe provisoire).

## Materiaux (module partage `MelangeMateriaux`)
Bruit fractal (3 octaves, deformation de domaine) par colonne ; entrees : genre, pente, altitude, humidite (proximite d'eau), couvert forestier, sable. Genres : route (Asphalt strict), route_bord, sentier(_bord), aire, lahar/laharbord, berge, gorge (Basalt/Rock/Slate en 3D), fond de ruisseau (Cobblestone/Sand/Mud). API : `Sol`, `Voxel`, `Lit`, `Bord`. Graine globale `M.Graine`. Utilise par S4Terrain et S7Terrain ; reutilisable pour S1-S6 (passer c.couvert/c.altRoche par secteur).
