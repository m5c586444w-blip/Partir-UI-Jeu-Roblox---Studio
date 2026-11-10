# S7 Sud-est (08/11/2026) - terrain, ruisseau, routes, lieux : fait, a valider visuellement

## Fait (dans la place Partie, cloud)
- Terrain voxel 4 studs, X 1400..4000 / Z 1400..4000 (S7 + 100 studs de marge nord/ouest en pente douce : le sol y descend de 45 studs sur 100). Reste jusqu'au bord de carte (X=4000, Z=4000).
- Code : `ServerStorage/TerrainBuilder/{HauteurGlobale, S7Donnees, S7Terrain}` (ModuleScripts, pas de script de jeu). `S7Terrain.Construire(cx,cz)` (cx,cz = 0..10, chunks 256x256) ecrit le terrain, `Nettoyer()` le vide. Reconstruction complete : ~121 appels, quelques secondes au total. Copie locale de HauteurGlobale : `terrain/HauteurGlobale.lua` (S7Donnees et S7Terrain existent seulement dans Studio).
- Piege : `require` d'un module modifie renvoie l'ancienne version (cache) -> cloner `TerrainBuilder` puis `require` le clone.
- Ruisseau de Lava Canyon : axe NO -> SE (de (2550,1500) a la sortie sud ~(3880,4000)), meandres, largeur d'eau 8 -> 12 (gorge) -> 38. Niveau d'eau mesure par lecture de voxels : monotone decroissant (24 points, 0 hausse, 110 -> -59). 5 cascades (chutes de 5 a 9 studs, abscisses 650/760/900/1020/1120), marqueurs `Eau/Cascade_01..05` (attributs Chute, Abscisse).
- Gorge de Lava Canyon : s~600..1150 (de ~(3000,1900) a ~(3350,2600)), profondeur ~55-80, fond 44-76 de large, parois quasi verticales (marche de 4 studs, rugosite par bruit), bandes Basalt/Rock. Apres la gorge : talus doux (la gorge s'ouvre en vallee).
- Lahar (2) : lit plat gravier/galets (Slate, Rock, Basalt), X 1800..2400 (bords bruites +-40), Z 1400..3500, creux de 6 studs, niveau decroissant vers le sud, finit en fondu vers Z 3500-3650.
- Route 83 (14 de large, Asphalt + accotements Ground) : bord sud (2950,4150) -> parking (2800,3260) -> fin pres de la gorge (3090,2400). Sentier d'Ape Canyon (4.8, Ground) : parking -> (2300,1600) le long du lahar. Aire du parking (70x57) arasee. Routes en pente douce suivant le terrain, arasement progressif sur les cotes. Pas de bombage (invisible a 4 studs).
- Lieux (`Workspace/Carte/S7_SudEst/Lieux`, attributs Numero/Nom/Secteur="S7") : Lieu_01_Parking, 02_Lahar, 03_LavaCanyon, 16_Pont, 18_Barriere, 22_Epave. Depart : `Workspace/Departs/S1` (SpawnLocation, tag `Depart`).
- Blocs gris poses (assets absents) : MANQUANT_PontSuspendu (8 x 1.5 x 90, y~75, perpendiculaire au ruisseau), MANQUANT_VanVW, MANQUANT_PanneauApeCanyonTrail, MANQUANT_EpaveVoiture, MANQUANT_BarriereRoute, MANQUANT_PanneauAreaClosed, MANQUANT_Sapins (un seul bloc temoin).

## HauteurGlobale (parametres, `Config`)
Graine 7.31 ; HSud 20 (Z=4000) -> HNord 400 (Z=-3500) ; AmpVallees 110 / LongVallees 1250 ; AmpCollines 100 / LongCollines 350 ; AmpDetail 8 / LongDetail 60 ; ReliefSud 0.6 -> ReliefNord 1.4 (multiplicateur) ; Plancher 12 (adoucit sous 12). Fonctions : `H`, `Basse` (sans collines, sert aux lits de riviere), `Tendance`, `Lisse`, `Arase`, `CreuserGorge`. H seule ne contient ni riviere, ni lahar, ni route.
Parametres S7 (S7Donnees.Cfg) : lahar, cuvette 7, pente mini du lit 0.004, cascades, routes, parking, marge.

## Verifie (play test)
- Joueur sur S1 : pose sur le sol (HRP ~3 au-dessus du terrain/aire), aucune chute. Ecart raycast / calcul de hauteur : ~2 studs (arrondi voxel).
- Pathfinding parking -> fin de route (3090,2400) : Success, 234 waypoints, pas max 4 studs.
- Console : aucune erreur venant du projet (seulement les erreurs du plugin roblox-path-plugin-main).

## Reste a faire / limites / bugs
- VALIDATION VISUELLE par Gabriel : les captures de Studio sont peu fiables (le viewport d'edition n'affiche qu'une partie du terrain, "vide" sous les falaises, timeouts frequents). Ne pas juger la gorge sur ces captures ; ouvrir la place et regarder.
- Vallee en aval de la gorge profonde (lit a ~-55, terrain alentour ~40-50) : relief a revoir apres S4/S3 (le bas de la carte descend jusqu'a y<0).
- Pas de materiaux PBR du projet (generate_material non utilise) : materiaux de terrain natifs. Sol "Rock" sur pentes > 35 degres et au-dessus de y=230.
- Eclairage temporaire pour voir : ClockTime=14, Atmosphere Density 0.15 / Haze 0, FogEnd 100000 (a refaire au jalon ambiance).
- Marge nord/ouest : le lahar continue vers S3 (coupe franche au bord Z=1400, sans fondu).
- Le pont est impossible a traverser ailleurs (gorge verticale) mais le bloc MANQUANT_PontSuspendu doit etre remplace par l'asset (Suspension Bridge de coffeecat112, a importer par Gabriel). Rives du pont non raccordees (extremites eventuellement 1-3 studs au-dessus du sol).
- A importer (Gabriel) : Fir/Pine (Poly Haven), VW van, epave Renafox, barriere + panneaux, Suspension Bridge, rochers/parois basalte pour Lava Canyon.
- Captures prises (dans le dossier tool-results de la session) : S7_ensemble_2/3, S7_gorge_1/6, S7_parking, S7_gorge_pont2 (les 3 angles demandes, de qualite moyenne).


## Retouches du 08/11 (apres la premiere construction) - a valider visuellement
- Relief : `Plancher` 16 avec plancher asymptotique (PlancherK 8) dans `HauteurGlobale` : le terrain ne descend jamais sous y~9 (min mesure 9.5, 0/4225 points < 0). Copie locale mise a jour.
- Ruisseau : lit impose par morceaux (`Cfg.Lit` : 112 -> 86 (s600) -> 64 (s1146) -> 56 (s2969), hors cascades 34) au lieu d'un minimum glissant : plus de vallee enfoncee a -55. Aval : lit ~30 -> 22, vallee de ~12 studs de profondeur ; gorge : profondeur ~40 en amont, decroit vers l'aval (le terrain autour de la gorge est releve de 20-30 si besoin). Niveau d'eau mesure par voxels : 0 hausse. Largeur d'eau elargie : 20 -> 24 (gorge) -> 65 (aval). Cascades re-positionnees (marqueurs `Eau/Cascade_01..05`).
- Pont (16) : deux plates-formes de rive arasees a y=104 (multiple de 4, mesure ~105.7) hors de la gorge (`D.Pont`) ; `MANQUANT_PontSuspendu` redimensionne (8 x 2 x 106) pose a plat sur les deux rives (aucun ecart). La gorge n'est pas franchissable ailleurs (plateformes seulement a d > hw+ww+5).
- Parking : hauteur unique (multiple de 4) ; mesure plate a +-0.02 ; route et sentier se raccordent a elle. Aire etendue en Asphalt jusqu'a 2 studs hors du rectangle.
- Marges nord/ouest supprimees (ChuteMarge = 0) : S4 (ouest) et S3 (nord) prolongent la meme fonction ; bord nord (Z=1400) = coupe franche provisoire.
- Lahar : `NiveauLahar(Z)` est maintenant une fonction GLOBALE de Z (origine Z=-1500, monotone) : S3 l'utilisera telle quelle, pas de raccord a faire (a la place d'un fondu). A l'ouest le lahar s'efface vers X~1640 : se raccorde a S4 sans marche.
- Route 83 : materiau Asphalt a 100 % sur l'axe et a +-3 / +-5 studs (mesure raycast tous les 5 studs, 391 echantillons) ; priorite route/parking sur le sentier ; commence au bord de carte Z=4000 (PtsRoute demarre a Z=4150, hors carte, c'est voulu) et va jusqu'a (3090,2400) : materiau Asphalt aussi en bout. Pathfinding sans interruption (par etapes < 1000 studs).
- Sentier d'Ape Canyon : coeur Ground continu ; le sentier de S4 (camp -> poste) est prolonge dans S7 jusqu'a (1660,1600).
- Materiaux : repeints par `MelangeMateriaux` (bruit fractal), repartition mesuree variee (Ground 43 %, LeafyGrass 39 %, Slate 5 %, Grass 6 %).
