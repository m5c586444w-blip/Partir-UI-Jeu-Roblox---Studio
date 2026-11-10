# S2 Plateau de cendres / centre-nord (08/11/2026) - terrain, ruisseau, sentiers, lieux 6/11/23/14 : fait, a valider visuellement

## Fait (place Partie)
- Terrain voxel 4 studs : boite A X -1000..1400 / Z -4000..-200 et boite B X 1400..1500 / Z -4000..-2500 (au nord de S3). Reecrit la bande Z -600..-200 de S4 (marge nord provisoire de S4 supprimee).
- Code : `ServerStorage/TerrainBuilder/{S2Donnees, S2Terrain}` (copies locales `terrain/S2Donnees.lua`, `terrain/S2Terrain.lua`). `S2Terrain.NettoyerBoite(b)`, `Construire(b,cx,cz)` (b=1 : cx 0..9, cz 0..14 ; b=2 : cx 0, cz 0..5), `Raccord()` (2 bandes de S3). **Ordre : NettoyerBoite d'abord** (une cellule d'eau ne s'ecrit pas sur un voxel deja occupe). Rebuild complet ~15 s. Piege : cloner `TerrainBuilder` en UN seul `TEMP_S2_TB` (supprimer les anciens, sinon `ServerStorage.TEMP_S2_TB` renvoie le plus vieux).
- Relief : H globale + flanc du volcan 14 (bonus jusqu'a +200 au bord nord, masque X en fondu 600 : nul a X=-1000 et X=1500) ; relief max 692 au nord, min ~111. Materiaux : `MelangeMateriaux` + cendre locale (Slate/Sand/Basalt/Rock + taches de Grass) dans S2Terrain.

## Lieux
- **6 Plateau de cendres** : centre (1100,-2600) (nominal 1200 : decale de 100 vers l'ouest pour finir avant X=1400), ellipse 440x380 plate a Y=412 (ondulation +-5) + fondu 90, cendre : Slate 46 %, Sand 21 %, Basalt 15 %, Rock 6 %, Grass (fleurs) 6 %. Il se detache comme une table (flancs raides ~60-100 studs au sud). Marqueur `Lieu_06_PlateauCendres`, `MANQUANT_FleursSauvages_Plateau`.
- **11 Tour de guet** : recentree sur la crete locale **(150,-1600)** (nominal (0,-1600)), pad plat 30x30 Y=368. Clone `TourGuet_11` (de `Assets/Structures/TourGuet_24`) dans `S2_Plateau/Assets` : 29x50x28, 146 parties toutes Anchored, posee sur le sol (bas 370, haut 420). **Echelle : non verifiee** (modele sans TrussPart ; a controler a l'ecran). `MANQUANT_Sapins_Tour`. Radio/extraction : plus tard.
- **23 Station meteo** : **(350,-2200)** (point haut local dans 150 studs autour du nominal deduit (500,-2200)), pad 20x20 Y=408, pente d'acces ~0,6. `MANQUANT_StationMeteo` (6x12x6). A valider.
- **14 Volcan** : seulement le flanc en pente (Z < -3200, cendre/roche) ; marqueur `Lieu_14_Volcan` (250,-3990). Pas de sommet ni de cratere (hors carte).
- Marqueurs dans `Workspace/Carte/S2_Plateau/{Terrain_Notes,Routes,Eau,Lieux,Assets}` (Numero/Nom/Secteur="S2").

## Ruisseau principal
- De la source (1220,-2490) (sur le plateau) a la source de l'affluent de S4 (1250,-250) : 2276 studs, puis chaine de S4. Largeur d'eau 19 -> 16 (cuvette 3,5), 3 cascades `Eau/Cascade_01..03` (chutes 8, 7, 6 ; vers (1228,-2240), (1090,-1610), (1180,-1000)).
- Niveau d'eau mesure sur voxels (115 points) : 376,0 a la source -> 227,7 en (1213,-201) ; 0 hausse, 0 trou. Jonction identique a S4 (lit 228,5, S4 `rim`/`bedC` repris ; difference S2/S4 mesuree sur Z -202/-198 : 0,00 sur toute la largeur X -1000..1396).
- Limite : dans S4, entre Z -160 et -50 l'eau de S4 a des trous (cellules d'eau minces avalees par la methode de S4) ; a corriger cote S4 avec la regle « derniere cellule solide sous l'eau -> eau » de `S2Terrain.ecrire`.

## Sentiers (Ground, 4,4 de large, axe 100 % Ground/Mud/Grass-d'aire en lecture voxel ; 94 % en raycast a cause du decalage de rendu)
- `Sentier_S4_vers_Tour` : bout du Sentier_Nord de S4 (-340,-560) -> tour (150,-1600), 97 points.
- `Sentier_Tour_vers_Plateau` : tour -> plateau (1090,-2580), 111 points ; `Sentier_vers_StationMeteo` : branche en (480,-1900) -> station, 26 points.
- Pathfinding (Edit, agent joueur 5x2, hops < 400) : S4->tour 3/3, tour->plateau 3/3, camp->fin sentier S4 4/4, branche station : tous les hops Success sauf le dernier de 8 studs (bloc gris sur le point d'arrivee). Agent creature 10x4 : echecs seulement aux hops dont le but/depart est dans la tour.

## Raccords (mesures)
- S4 (Z=-200) : exact (0,00). Sentier nord de S4 reecrit identique.
- S3 (X=1400) : la marge nord de S4 prolongee dans S3 (X 1400..1700, Z -1000..-500) est annulee (bande reecrite) : saut <= 1,1 ; marge nord de S3 (Z -2500..-2400) annulee sur X 1400..1500 : saut <= 2,1 a X=1400. **Reste a faire hors de mon perimetre : la meme marge nord de S3 existe encore a X >= 1500, Z -2500..-2400 (dip de 45) ; a X=1500 elle cree une marche (ex. Z -2480 : 332 cote S2 / 305 cote S3).** `D.Corr3` peut etre etendu (bande {1500,-2500,1700,-2400}).
- S8 (X=1500, coin nord-est) : bord est = H pur, sans marge ; apres correction, sauts X 1492/1504 : <= 5 sur Z -3900..-2700 (+11 en Z -2520, pente locale de S8).
- Ouest (X=-1000, S1) : marge descendante de 45 sur 100 studs (X -1000..-900), effacee entre Z -900 et -600 (S4 est pur au sud). A reprendre/fondre par S1 (qui doit retomber sur H pur a X=-1000, comme S8 l'a demande a S2).

## Limites / a faire
- Validation visuelle par Gabriel (1 capture ; la 2e a expire). Pas de vegetation ni d'eclairage final ; sapins, station, fleurs = blocs gris `MANQUANT_`.
- Plateau en « table » un peu abrupt ; flanc nord a 51 % de Rock (pentes).
- Station sur forte pente ; echelle de la tour a verifier.
- Un serveur `python -m http.server 8765` (dossier `terrain/`, 127.0.0.1) lance pour un test d'import (refuse par Studio) reste actif : a arreter.
