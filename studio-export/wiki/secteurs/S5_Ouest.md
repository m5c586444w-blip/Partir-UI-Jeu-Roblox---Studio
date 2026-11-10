# S5 Ouest (08/11/2026) - terrain, ruisseau, cascade 13, Ape Cave 7, tunnel 21, prairie 12, tour 26, sentiers : fait, a valider visuellement

## JONCTION SUD AVEC S6 (a lire en premier)
- **Ruisseau principal** : traverse Z = 2500 en **X = -1599.6** (axe), plein sud. **Lit bedC = 40.7, surface de l'eau = 40.2**, **largeur d'eau 32.7** (hw = sw/2+3), cuvette ~6 studs, berges (rim) ~ bedC + 14 = 55. L'axe continue au sud par (-1603,2520), (-1606,2560) (niveau decroissant, bed 40.0 en Z 2560). S6 continue depuis (-1600,2500) a ce niveau, niveau monotone decroissant. Marqueur `Eau/Sortie_Ruisseau`.
- Terrain au bord sud : **H pur** (pas de fondu sud sauf coin sud-est X -1300..-1000, fondu vers S4 : S4 a un fondu sud de 30 studs en Z 2400..2500).
- **Aucun sentier ne traverse Z = 2500** (sentiers de S5 : Z <= 2345). Ape Cave reste au nord de Z 2345.

## Code (ServerStorage/TerrainBuilder, copies dans terrain/)
- `S5Donnees` / `S5Terrain` : boite X -4000..-790, Z -600..2500, chunks 256 (NbX 13, NbZ 13), `Construire(cx,cz)`, `Nettoyer()` (FillBlock Air de la seule boite S5). Reconstruction complete ~5 s. **Reconstruire S5 APRES S4** (S4 remet sa marge ouest X -1100..-1000). Piege : cloner TerrainBuilder (`TEMP_S5_TB`) avant `require` (cache) ; le cache de `HauteurGlobale` peut etre ancien (H(-2440,2338) = 78.9 en cache, **123.4 en Source fraiche = la verite**, verifie par raycast sur S4).
- Bande X -1000..-790 : `S4Donnees.Colonne` + sentier du camp (reecriture identique a S4 + sentier). X < -1000 : surface propre (meme H, **memes points de ruisseau que S4 copies** `D4.Ruisseau.P/S/F` queue de 25 pts + prolongement). Marge nord Z -600..-500 : meme formule que S4 (45 studs).
- Tubes creuses dans la meme passe que le terrain (occupation = min(terrain, cavite), Basalt a < 6 studs de la cavite, eboulis en Rock).

## Raccord est (S4), mesures raycast
- Saut max entre points espaces de 8 studs sur X -1180..-1020 : 3.0 (Z -450), 4.2 (Z 0), 3.2 (300), 3.9 (800), 2.9 (1200), 3.2 (1500), 2.5 (1900), **5.8 (Z 2150, bord de la cuvette du ruisseau)**, 0.9 (2300), 2.8 (2450). Pas de marche visible, un saut de 5.8 d'un voxel au bord du lit.
- Ruisseau : meme niveau/largeur a la jonction (-1110,2260) : bed 79.4, largeur 22, `Eau/Jonction_S4`.

## Ruisseau, cascade 13 (position DEPLACEE)
- Nominal (-1800,1200) : relief 150-210, au-dessus du lit de sortie de S4 (79) : impossible. Le ruisseau coupe la crete N-S (X -1400..-1250, crete ~137-145 : gorge d'environ 60 de profondeur) et tombe de **22 studs** (bed 76.2 -> 54) a **(-1425, 2215)** dans la cuvette ouest : `Lieu_13_Cascade` + `Eau/Cascade_13` (Bruit=true, Rayon 150). Bassin ~60x60 en (-1480,2207) (niveau 51.5, `Eau/Bassin_13`, berges rocheuses : genre gorge, Mud/Cobblestone au bord de l'eau), 2e petite chute de 8 vers (-1545,2208) (`Cascade_13b`), puis le ruisseau tourne au sud-sud-ouest dans le couloir X ~-1600 jusqu'a la sortie Z 2500.
- Niveau d'eau mesure par raycast le long de l'axe (X < -1000) : monotone decroissant (une seule inversion de 0.8, arrondi voxel), 78.7 -> 77.0 -> 50.9 -> 42.0 -> 39.2. Largeur : 22 -> 33 (49 au bassin). Lit sous le terrain partout (construit depuis le profil du lit).
- Creux ferme sec au nord du bassin (hors axe), sans piege : le pathfinding le contourne (pas de sentier dedans).

## Ape Cave (7) : entree DEPLACEE (-2500,2400) -> (-2440,2345)
- Entree en rampe d'effondrement (comme la vraie Ape Cave) : aire plate ~24x24 a Y=120 en (-2440,2345), le plancher descend de 17 studs sur 78 (pente 0.22) puis remonte de 0.02/stud ; la voute depasse du sol sur ~30 studs (tranchee d'entree) puis passe sous roche. Largeur 20-22 (demi-largeur 11), voute 18-20 au centre (~13-15 de hauteur libre mesuree au raycast apres quantification 4 studs), **tube de 340 studs** (~290 apres l'entree) vers l'ouest puis le nord-ouest jusqu'a (-2745,2245), cul-de-sac arrondi (a prolonger plus tard), sol et parois Basalt. Couverture de roche minimale 6 studs (zone de transition de la rampe), ~28-35 ailleurs.
- Navigation (Edit, PathfindingService, par tronçons) : joueur 5x2, Bigfoot 10x2 et 10x4 : **21/21 tronçons Success** sur l'axe ; agent de hauteur 10 ne passe qu'avec une voute >= 18 (la quantification des voxels de 4 mange ~4-5 studs).
- `Lieu_07_ApeCave`, `Zones/B2` (-2560,2335, Rayon 150). Bloc `MANQUANT_TubeLave` (22x14x6) pres de l'entree (-2425,2372) : modele scan a importer.

## Tunnel effondre (21) : position DEDUITE (-2800,1800) -> portail (-2900,1800)
- Portail bas (hauteur ~8) face a l'est au pied d'une pente de 30 degres, aire plate a Y=84, galerie de ~60 studs vers l'ouest (axe jusqu'a (-2988,1792)), eboulis Rock de s 40 a 72 avec un couloir lateral libre (section nominale 8-9 de large x 7 de haut) et une poche libre au bout. `MANQUANT_ParoisRock` au-dessus du portail. Pathfinding joueur et 10x2/10x4 : 6/6 (le couloir est la limite : section reelle apres voxels non verifiee a l'oeil, a controler). `Lieu_21_TunnelEffondre`.
- Le couloir de 5x3 du brief n'est pas representable fiablement en voxels de 4 : 8x7 retenu.

## Prairie 12, tour 26
- Prairie (-2200,200) : relief adouci (collines/detail x0.2) sur ~430 studs de rayon, couvert 0.3 : surface Grass 69 % / Ground 30 % (mesure sur la prairie).
- Tour 26 : crete la plus haute dans 150 studs autour de (-2500,0) -> **(-2610,100)**, pad 30x30 a Y=236 ; clone de `ServerStorage/Assets/Structures/TourGuet_24` (29x50x28) renomme `TourGuet_26` dans `Carte/S5_Ouest/Assets`, pose sur le pad (base Y=236). Position deduite, a valider.

## Sentiers (Ground, largeur 4.6-4.8, bords irreguliers)
- Camp (-800,600) -> prairie (-2200,200) ; prairie -> tour ; prairie -> vallee N-S (X ~-2200) -> belvedere de la cascade (-1500,2135) ; embranchement (-2180,2080) -> Ape Cave ; embranchement (-2250,1780) -> portail 21. Aucun sentier ne croise le ruisseau (pas de gue).
- Axe Ground/Mud (rayon vertical) : Camp 352/354, Cascade 616/630, Cave 97/102, Spur21 151/156 (reste = rampes en Basalt), Tour 93/102 (9 points en Grass dans la prairie, a ameliorer).
- Pathfinding joueur 5x2 par troncons : camp->prairie 8/8, prairie->cascade 13/13, ->grotte 5/5, spur 5/5, prairie -> pied de la tour : Success (la cible a l'interieur du modele de tour : NoPath, normal).

## Materiaux (MelangeMateriaux, altRoche 330, couvert 0.8 -> 0.73 vers l'ouest)
- Toute la boite hors tunnel : LeafyGrass 46 %, Ground 45 %, Grass 6 %, Rock 3 % (aucun > 70 %). Ouest forestier : Ground 45 %, LeafyGrass 48 %.

## Blocs et marqueurs (Workspace/Carte/S5_Ouest/{Terrain_Notes,Routes,Eau,Lieux,Assets})
`Lieu_12_Prairie`, `Lieu_13_Cascade` (Bruit), `Lieu_26_TourOuest`, `Lieu_07_ApeCave`, `Lieu_21_TunnelEffondre` (Numero/Nom/Secteur="S5"), `Eau/{Cascade_13, Cascade_13b, Bassin_13, Jonction_S4, Sortie_Ruisseau}`, `Routes/Sentier_*`, `Zones/B2`. Blocs gris : `MANQUANT_TubeLave`, `MANQUANT_ParoisRock`, `MANQUANT_Sapins_Prairie/_Tour/_ApeCave` (si le terrain est reconstruit, reposer les blocs au sol).

## Limites / a faire
- Altitude min du terrain 32.8 ; aucun point < 0.
- Validation visuelle par Gabriel (2 captures prises : cascade et rampe d'Ape Cave, correctes). Pas de vegetation, pas de modele de grotte (scan), pas d'eclairage.
- Prolonger le tube d'Ape Cave plus tard (cul-de-sac a (-2745,2245)), relier eventuellement le tunnel 21.
- Marge nord Z -600..-500 (meme que S4) : S1 doit la reecrire si besoin.
