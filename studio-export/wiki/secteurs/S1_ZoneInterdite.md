# S1 Zone interdite (08/11/2026) - terrain, lac, affluent, sentiers, lieux 8/18/19/20/25 : fait, a valider visuellement

## Fait (place Partie, cloud)
- Terrain voxel 4 studs, **X -4000..-1000 / Z -4000..-500** (168 chunks 256, ~1 min). Bord ouest et nord = bords de carte (H pur, le terrain monte vers le nord, 130..575). Bord est X=-1000 : H pur (raccord S2/S4). **Bord sud Z=-500 : la bande Z -600..-500 (marge provisoire de S5, chute de 45) est REECRITE en H pur** : sans cela, falaise de 45 studs a Z=-600.
- Code : `ServerStorage/TerrainBuilder/{S1Donnees, S1Terrain}` (+ `MelangeMateriaux`, `HauteurGlobale`). Copies : `terrain/S1Donnees.lua`, `terrain/S1Terrain.lua`. `Construire(cx,cz)` cx 0..11, cz 0..13 ; `Nettoyer()` ne vide que la boite de S1. Cloner `TerrainBuilder` avant `require` (cache).
- **Ordre de reconstruction** : S1 APRES S4/S5. Si S5 est relance, sa bande Z -600..-500 reintroduit la chute de 45 : refaire `S1Terrain.Construire(cx,13)` pour cx 0..11 (constate : S5 avait deja reecrit la bande une fois, refaite).
- Relief de la zone : `D.Soft` = Basse + (H - Basse) x 0,2 (adouci de 80 %, fondu 250 aux bords ; a l'est fondu vers H pur a X=-1000). Terrain ouvert, sans couvert, pas de vegetation.
- Sol de cendre (`D.Cendre`, mesure sur 1500 colonnes) : Slate 27 %, Ground 27 %, Basalt 22 %, Sand 20 %, Mud 1 %, eau 2 % (aucun > 70 %). Sentiers/berges/fond via `MelangeMateriaux` (Sol, Lit). Pas de genre « cendre » dans le module partage : melange propre dans S1Donnees (bruit `Mix.Bord`).

## Lieux
- **20 Lac Spirit** (-2500,-1800) (position deduite, conservee) : ellipse 350 x 250 (rive irreguliere par bruit), **niveau d'eau constant 336**, profondeur 12 au centre (mesure : eau a 336,0 sur 5 points), rives en pente douce (Mud/Sand/Ground, `berge`), terrasse de rive a +5 puis fondu vers le relief (q 1,5 -> 2,6).
- **Affluent du lac** : sort de l'ellipse a (-2380,-1760), 1 503 studs, 73 points, vers le SE puis le sud, **fin a (-1730,-500) = frontiere sud**. Largeur d'eau 16 -> 24, cuvette 7 (assure au moins une cellule d'eau de 4 studs sur l'axe). Niveau d'eau mesure par voxels : 336 -> 252 (0 hausse >1,5 ; 3 points sur 73 sans cellule d'eau, au depart dans le lac et a la fin). **S5 doit continuer a partir de `Eau/Sortie_Affluent` : niveau d'eau 252,5, largeur 24, X=-1730**, monotone decroissant (S5 n'a aucun ruisseau dans cette zone). Couture a Z=-500 : saut du sol 2,6 sur l'axe ; max 14,9 sur la largeur (bruit de H sur 8 studs).
- **19 Charnier** (-2150,-2280) (deduite (-2200,-2200), deplacee de ~85 studs pour eloigner la cuvette de l'anneau du lac) : cuvette plate ~60x60, sol mesure 310 (plat a +-1), 4 sous le terrain voisin. `MANQUANT_SquelettesCerf` (5 blocs gris 6x1.4x2.6).
- **25 Tour d'observation nord** : crete la plus haute (moyenne locale) dans un rayon de 130 autour de (-2200,-3500) => **(-2070,-3500)**, sol plat 346 (mesure aux 4 coins +-14 : 345,4..346). Clone `TourGuet_25` (de `TourGuet_24`, 29x50x28, pivot au pied) pose a Y=346 dans `Assets`. **Position corrigee par rapport a decoupage.md** : la tour est au bord NORD de la zone (Z -3500), pas a l'ancienne position de decoupage.md ; position = deduite (carte (1930,500)), a valider.
- **8 Zone interdite** : marqueur `Lieu_08_ZoneInterdite` (-2100,-2250) (centre de la partie construite).
- **18 Barriere (point de non-retour)** : `Lieu_18_Barriere` (-1105,-740), Deduite=true, sur le sentier d'acces au bord sud-est de la zone (Z -800 = limite sud de la zone, ~60 studs avant). `BarriereRoute_18` (clone de `Props/BarriereRoute`, 14 studs, en travers du sentier, perpendiculaire, pose au sol) ; 2 clones de `Panneau_ApeCanyonTrail` (`Panneau_AreaClosed_1/2`, a 10 studs de chaque cote, texte a faire plus tard). Terrain ouvert des deux cotes : contournement libre (pathfinding avant -> apres Success), la barriere pourra pivoter/s'ouvrir plus tard. Pas de bloc `MANQUANT_PanneauAreaClosed` (le modele existe).
- **B3** `Workspace/Zones/B3` : (-2150,-2280), Rayon 300, Secteur S1 (Part invisible ancre).

## Sentiers (Ground, 100 % de l'axe en Ground/Mud : 346/346 points ; largeur 6,0 ; tour 5,2 ; pente max 0,52 a l'entree du charnier)
- `Sentier_Acces` : bord est (-1000,-560) -> barriere (-1105,-740) -> (-1240,-1000) -> (-1420,-1520) -> jonction J (-1720,-2150). **Raccord a creer cote est : (-1000,-560) doit etre relie au sentier nord de S4 (fin (-340,-560)) par S2/S4** (X>-1000 non ecrit ; la bande Z -600..-500 de X>-1000 a encore la chute de 45 de S4/S5 jusqu'a ce que S2/S4 la reprenne).
- `Sentier_Charnier` : J -> charnier. `Sentier_Tour` : charnier -> (-2110,-2550) -> (-2120,-2850) -> (-2150,-3150) -> tour. `Sentier_Est` : J -> (-1500,-2250) -> (-1250,-2350) -> **(-1000,-2420)** (sortie vers S2, a continuer ; sol 413 = H de S2 a +-1). Marqueurs `Routes/Sentier_*` et `_Fin` (attributs Vers, Largeur, Materiau, RaccordEst).
- Le sentier ne traverse ni le lac ni l'affluent (pas de gue). Le « raccourci risque » est la traversee par le charnier et la sortie est ; jamais obligatoire.
- Pathfinding (agent joueur 5x2 et creature 10x4, etapes < 1000 studs) : entree -> J -> charnier -> tour (10 etapes) **toutes Success**, sortie est Success. (Fin de l'etape tour testee a 25 studs de la tour : le pad est occupe par le modele.)

## Blocs gris (assets absents) dans `Lieux`
- `MANQUANT_TroncsCouches_Entree/_Lac/_Charnier/_Tour` (6 troncs 2,6x2,6x14-24 par groupe, orientes vers le sud), `MANQUANT_Chicots_<meme zones>` (5 par groupe, 9-15 de haut), `MANQUANT_SquelettesCerf`.

## Parametres (S1Donnees.Cfg)
Zone (X0/X1/Z0/Z1, Fondu 250, Adoucit 0,8), Lac (A 175, B 125, Niveau 336, Prof 12, RingPlein 1,5, RingFin 2,6, Terrasse 5), Charnier (Demi 30, Fondu 45, Creux 4), TourRecherche, Cuvette 7, PenteRuisseau .004, Sentier (Demi 3, Fondu 12), PtsRuisseau/PtsPasse/PtsCharnier/PtsEst/PtsTourBase.

## Limites / a faire
- Validation visuelle par Gabriel (1 capture : lac visible, rendu en deux lobes a verifier a l'ecran ; sol brun fonce sous le ciel gris). Pas de vegetation, pas d'eclairage final.
- Voxels de 4 studs : le sol rendu est decale d'environ +2 par rapport a la hauteur logique (tour, charnier : sol mesure = cote + 2) ; les objets sont poses par raycast.
- Couture est a X=-1000 : S2 n'etait pas ecrit (rien a X>-1000 pour Z<-600) ; bande Z -600..-500 a l'est encore en chute de 45 (saut 46 a Z=-580 en X=-1004/-996).
- Le lac et la zone sont des positions deduites (voir CARTE.md) ; le charnier est deplace de ~85 studs.
- Dans la boite S1 aucun point sous y=130 (min H 130).
