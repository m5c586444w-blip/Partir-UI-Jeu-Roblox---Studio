# S3 Nord-est (08/11/2026) - terrain, ruisseau, gorge d'Ape Canyon, lahar nord, sentiers, lieux 5/15/24/2 : fait, a valider visuellement

## Fait (place Partie, cloud)
- Terrain voxel 4 studs, X 1400..4000 / Z -2500..1700. La bande Z 1400..1700 **reecrit le bord nord de S7** (raccord, voir plus bas). Bord nord (Z -2500) : marge descendante de 45 sur 100 studs ; bord est X=4000 = bord de carte.
- Code : `ServerStorage/TerrainBuilder/{S3Donnees, S3Terrain}` (+ `MelangeMateriaux`, `HauteurGlobale` partages). `S3Terrain.Construire(cx,cz)` : cx 0..10, cz 0..16 (chunks 256, `NbX`=11, `NbZ`=17), `NettoyerChunk(cx,cz)`, `Nettoyer()` : **ne vide que la boite de S3** (jamais `Terrain:Clear`, qui effacerait S4 et S7). Reconstruction complete ~10 s. Copie locale : `terrain/S3Donnees.lua` (S3Terrain = S4Terrain adapte, non copie en local comme S4Terrain/S7Terrain).
- Piege : cloner `TerrainBuilder` (nom `TEMP_TB`) puis `require` le clone (cache de require). Le clone a ete supprime en fin de session.
- `S3Donnees` requiert `S4Donnees` et `S7Donnees` (via `script.Parent`) ; `proche()` est accelere (index grossier 1 sommet sur 8) : 20 000 colonnes en 0,14 s.

## Raccords (mesures sur voxels)
- Sud (S7) : la chaine du ruisseau de S3 est **prolongee par celle de S7** (meme `bedC` 112, largeur 20, `rim` a la jonction (2550,1500)) ; de Z 1580 a 1700 fondu vers `S7.Colonne` (poids Lisse), au-dela S3 = S7 exactement. Plus de coupe franche. Saut max sur Z 1380..1520 : 4,0 studs (X=2550, bord de la cuvette, un voxel), <= 2,4 ailleurs (X 1500/2000/2300/2750/3000/3600).
- Ouest (S4) : S4 s'arrete a X=1400 : S3 commence a X=1400 et ajoute la contribution de S4 (ruisseau, marge nord) fondue sur 300 studs (X 1400..1700). Saut max sur X 1380..1520 : 2,8 (Z -590), <= 2,0 sur Z -400/-300/0/500/800/1000/1500/1650. Au nord de Z=-600 (S2/S5 pas faits) la marge de S4 s'efface sur 300 studs : coupe provisoire a X=1400.
- **Coin nord-est de la carte (x 5500..8000, y 0..1500 = monde X 1500..4000, Z -4000..-2500) non construit** : dans aucun secteur du decoupage (S3 = y 1500..5500 seulement). A attribuer (S2 ? nouveau secteur ?). Le bord nord de S3 est donc une marge provisoire, pas la limite de la carte.

## Ruisseau (amont de Lava Canyon) et gorge d'Ape Canyon
- Chaine de la source (2690,-1950) (pied de falaise) a la jonction (2550,1500), 171 points + chaine de S7. Largeur d'eau 12 -> 20 (meme valeur que S7 a la jonction), meandres nuls a la source et pres de la jonction.
- Lit construit **depuis la jonction vers l'amont** (monotone par construction : pente entre 0,0045 et 0,07), 2 cascades (`Eau/Cascade_01` chute 10 vers (2681,-1450) dans la gorge ; `Cascade_02` chute 5 vers (2719,402)). Niveau d'eau mesure par voxels (196 points, source 244,4 -> jonction 111,4 -> S7 111,5) : **0 hausse**, aucun trou.
- Gorge d'Ape Canyon (Z -1900 a ~-700 pleine, s'ouvre ensuite) : profondeur 55-60, paroi de ~3 studs (mesure Z=-1400 : rebord 283 -> fond 223 en une colonne), fond ~24-44 de large, genre `gorge` (Basalt/Rock/Slate en 3D). Non gravissable. Les sentiers restent sur le rebord ouest, jamais dans la gorge.
- Gues : les deux sentiers vers la mine/tour traversent le ruisseau a (2720,70) et (2576,1200) ; cuvette reduite a 1,4 (eau de ~1 stud), `Gues` dans `S3Donnees.Cfg`. Hors gue, la cuvette fait 7 (eau profonde) : le pathfinding ne passe pas a pied ailleurs.

## Lahar nord (2) et B5
- Meme fonction que S7 (X 1800..2400 +-40, fondu 120, `S7.NiveauLahar(Z)` globale de Z) prolongee de Z 1400 a -1500 ; efface vers le nord entre Z -1200 et -1500 (`LaharNord`), il s'arrete en fondu vers le terrain naturel (la gorge est a 300-400 studs a l'est, X~2690). Materiaux : Slate 60 %, Basalt 22 %, Rock 17 %.
- `Zones/B5` (2100,-200) Rayon 200, attributs Rayon/Secteur="S3". Marqueur `Lieu_02_Lahar_Nord` (2100,-800).

## Sentiers (Ground, axe 100 % Ground/Mud sauf gues)
- Sentier d'Ape Canyon (largeur 4,8) : prolonge celui de S7 depuis (2300,1600) (hauteur raccordee a la fin de `S7.Sentier`) le long du bord est du lahar jusqu'a la ruine (2615,-1400) ; 3040 studs, 251/251 points de l'axe en Ground/Mud.
- Fictifs (largeur 3,8) : carrefour (2470,0) -> mine (gue (2720,70)) ; mine -> tour ; tour -> sentier d'Ape (gue (2576,1200)). Marqueurs `Routes/Sentier_*` (attributs Vers/Largeur/Materiau).

## Lieux
- **5 Ape Canyon / ruine 1924** : replat plat 50x50 a Y=280 (mesure plate) a (2615,-1400), a ~70 studs a l'ouest de la gorge (rebord 283). `MANQUANT_CabaneRuine1924` (14x5x10) sur le replat, `MANQUANT_ParoisRock` (6x30x60) sur le rebord est. `Zones/B1` (2645,-1400) Rayon 220.
- **15 Mine** : position nominale (3200,0) non favorable (cuvette entouree de collines) ; site choisi par recherche de pente : **(3300,-75)**, entree vers le nord, pad 40x40 a Y=268 (plat), mur vertical de 40 studs au sud (rebord a ~307). `MANQUANT_EntreeMine` (10x8x3) contre le mur, `MANQUANT_Rails` (3x0,4x26), `MANQUANT_Wagonnet`. Position a valider.
- **24 Tour est** : recentree sur la crete locale **(3360,1130)** (nominal (3300,1000), +-150) ; pad 30x30 plat a Y=236. `MANQUANT_TourGuet` (7x28x7). Position a valider.
- Marqueurs `Workspace/Carte/S3_NordEst/{Terrain_Notes,Routes,Eau,Lieux}` : `Lieu_05_ApeCanyon`, `Lieu_15_Mine`, `Lieu_24_TourEst`, `Lieu_02_Lahar_Nord` (Numero/Nom/Secteur="S3"), `Eau/{Cascade_01..02, Source_Ruisseau, Jonction_S7}` (attributs NiveauEau/Largeur/Chute).

## Materiaux (MelangeMateriaux, c.altRoche = 330 -> 420 vers le nord via `D.AltRoche(Z)`, couvert 0,85 -> 0,45 vers le nord)
- Hors lahar/gorge (3112 colonnes) : LeafyGrass 42 %, Ground 39 %, Grass 11 %, Rock 6 % ; zone sud (Z 0..1390) LeafyGrass 68 % (le plus haut, < 70 %), nord Ground 48 %.

## Verifie (play test)
- Joueur pose sur `Departs/S1` : vivant, HRP 4 studs au-dessus du sol. Pathfinding par etapes (< 1000 studs), tous **Success** : parking -> (2300,1600) (4 etapes) ; sentier d'Ape (2300,1600) -> ruine (2615,-1400) (6 etapes) ; carrefour -> mine (5 etapes, gue compris) ; mine -> tour (6) ; tour -> sentier d'Ape (4, gue compris) ; traversee du lahar (2300,1600) -> (2100,-800) (4).
- Console : seulement les erreurs du plugin `roblox-path-plugin-main` et un avertissement de chat ; aucune erreur du projet.

## Limites / a faire
- Validation visuelle par Gabriel (captures Studio peu fiables : une capture de la zone de la gorge n'a pas montre la gorge, a verifier a l'ecran).
- Assets absents (blocs `MANQUANT_`) : cabane de ruine 1924, parois rocheuses, entree de mine, rails, wagonnet, tour de guet ; pas de vegetation ni d'eclairage final.
- Le relief nord de S3 monte a 330-450 studs ; la marge nord (45 studs) est provisoire jusqu'a S2.
- Gorge : sa source (2690,-1950) est une impasse (pied de falaise) ; le rebord est (X>2700) n'est pas relie a la ruine sauf par un franchissement impossible (voulu).
