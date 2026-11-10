# S8 Nord-est (08/11/2026) - flanc du volcan, X 1500..4000 / Z -4000..-2440 + couloir "O" dans S3 : fait, trou d'eau de 20 studs a la jonction a corriger (rebuild "O")

## Fait (place Partie, cloud)
- Zone "M" montagne X 1500..4000 / Z -4000..-2440 (70 chunks, ~4 s) ; zone "O" = couloir X 2440..2900 / Z -2440..-1380 dans la boite de S3 (colonnes S3 identiques sauf sentier + ruisseau), 2x5 chunks. Aucun lieu numerote, aucune zone Bigfoot.
- Code `ServerStorage/TerrainBuilder/{S8Donnees, S8Terrain}` (pas de copie locale .lua). `S8Terrain.Nettoyer(zone)` et `Construire(zone,cx,cz)` ; ne vident que "M" et "O". Piege : cloner TerrainBuilder (`TEMP_S8NE_TB`) avant `require`.
- Historique des permissions : la premiere tentative d'ecrire "O" (par le sous-agent) a ete refusee par le classifieur (reecriture de S3 hors de la bande -2560..-2440) ; Gabriel l'a autorise dans le chat principal et le coordinateur a lance `Nettoyer("O")` + `Construire("O")` via un clone temporaire.

## Relief et materiaux
- `H.H` + surelevation 160 sur Z -2500 -> -4000 (fondue vers H pur sur X 1500..1750), falaises en gradins (3 seuils, 45 de haut, transition ~4 studs, non gravissables, masquees a < 70 du sentier / 40 du ruisseau), ravins secs, eboulis de cendre (genres lahar/laharbord de `MelangeMateriaux`). Surface mesuree 246..796.
- Materiaux sur 8 928 colonnes de "M" : Rock 33 %, Slate 30 %, Ground 21 %, Basalt 9 %, LeafyGrass 3 % ; aucun > 70 %.
- Couture S3 (Z -2438/-2446, toute la largeur, pas 12) : saut max 11,5 (pente naturelle de montagne) ; le mur de 55-60 du ravin a disparu. Bords du couloir "O" (X 2436/2444, 2896/2904, Z -1376/-1384) : saut max 4,9 (X=2436, Z=-2052, pente de falaise) ; <= 4 ailleurs non releve en detail.

## Ruisseau de fonte
- Chaine de la jonction (2690,-1950) a la source (2800,-3420), 1 500 studs, 6 cascades (`Eau/Cascade_01..06`), gue (2625,-2660), ravin ~70 de profondeur sauf gue/source, largeur 12 -> 18 -> 12.
- Mesure voxels (jonction -> source, 68 points d'eau sur 73) : niveaux 244 (Z -1950) -> 250 (-2083) -> 267 -> 291 -> 303 -> 328 (-2500) -> ... -> 434 (-3390) : **0 inversion**, monotone croissant vers l'amont.
- **Defaut constate** : sur l'axe X=2690, l'eau est a 244,4 jusqu'a Z=-1952 puis **absente de Z=-1956 a -1976** (20 studs) et reprend a 248,2 (Z=-1980) : fondu `wm` du ruisseau S8 trop long. **Corrige dans le source `S8Donnees`** (seuil Z < -1952, `wm = Lisse((-1952-Z)/10)`), mais le couloir n'a pas ete reecrit : relancer `S8Terrain.Nettoyer("O")` puis `Construire("O",cx,cz)` (cx 0..1, cz 0..4) depuis un clone frais de TerrainBuilder, puis verifier l'eau sur l'axe Z -1940..-2000.

## Sentier
- Ruine (2615,-1400) -> zigzags a l'ouest du ravin -> gue (2625,-2660) -> crete (2800,-3000) (sol ~385) + boucle de crete (510 studs). Longueur 1 709, pente du profil <= 0,33, demi-largeur 2,2 (+ bords irreguliers). Axe Ground/Mud 63/68 points (hors : point de depart sur la ruine = SmoothPlastic de S3, 1 point Slate pres du gue, 3 Rock sur les pentes raides de la crete). Profil du sol sous l'axe : 285, 285, 277, 264, 281, 331, 381, 398, 377, 378, 390, 385 (pas de marche).
- Pathfinding (mode Edit, agent rayon 2 / hauteur 5, saut autorise) ruine -> crete en 4 etapes < 500 studs : **4/4 Success**.

## Couture S2 (mesure seule, S2 non touche)
- Apres correction par S2 : X1492/1504/1516 : Z-3900 490/485/482, -3700 482/478/477, -3500 448/451/457, -3300 493/492/492, -3100 389/387/386, -2900 341/342/345, -2700 359/360/359 : saut <= 5.

## Marqueurs
- `Workspace/Carte/S8_NordEst/{Terrain_Notes, Routes, Eau, Lieux}` : `Lieux/Point_Crete_Panoramique`, `Routes/Sentier_Crete_Depart`, `Routes/Sentier_Crete_Boucle`, `Eau/{Source_Fonte, Jonction_S3, Gue_Fonte, Cascade_01..06}`, `Terrain_Notes/Note_S8`.

## Limites
- Pas de `MANQUANT_Sapins` : aucune lisiere basse dans S8 (tout est au-dessus de la limite des arbres). Pas de vegetation ni d'eclairage, aucune capture.
- Positions a valider visuellement : crete (2800,-3000), gue, source (2800,-3420).
