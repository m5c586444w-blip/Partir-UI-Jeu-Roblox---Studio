# S6 Sud-ouest + sud-centre (08/11/2026) - terrain, ruisseau, chantier 10, depart S2, piste, sentiers : fait, a valider visuellement

## Mise a jour (autorisation de Gabriel) : dip supprime, sentiers prolonges
- **Dip de S5 supprime** : `SudChute` mis a 0 dans `S5Donnees` (Studio + copie locale). Bande Z 2400..2500, X -1300..1400 reecrite par `S6Terrain.ReecrireBandeS4(i)` i=0..10 (rabais de S4 retire ; S4Donnees NON modifie : sa `SudChute` reste 30, donc **relancer la bande apres toute reconstruction de S4**), puis S6 reconstruit (RabaisNord=0). Mesure raycast : X -1250..1000, Z 2380..2620 suivent H a +-2 ; saut de couture max 3.9 (X=216, au croisement du sentier), bord X=-1300 : 0.4. Jonction ruisseau re-mesuree : S5 40.28 / S6 40.20, largeur 32.7 inchangee.
- **Sentier Ape Cave prolonge dans S5** : bande X -2480..-2400, Z 2380..2500 (`S6Terrain.EcrireSentierCave`), profil epingle sur `Aire7Y` ; marche laterale max 1.9. Reste ~35 studs (Z 2345..2380, aire fondue de S5) non ecrits : l axe y est a 19/23 en Ground, jonction avec l aire plate.
- **Sentier du poste 17 prolonge dans S4** : axe seul, X 176..256, Z 1480..2400 (`S6Terrain.EcrireSentierPoste(0..3)`) + Z 2400..2500 dans la bande ; `D.SentierPoste` (points `PtsSentierEstSuite`, fin (212,1510) epinglee sur `PosteY`). Axe **158/158 Ground/Mud**, pente max 0.26, marche laterale max 2.0.
- Navigation (Edit, etapes < 1000) joueur 5x2 et creature 10x4 : S2 -> gue -> (-2440,2350) et S2 -> poste (212,1510) de bout en bout : tous Success.
- Points 1 a 3 ci-dessous : **resolus** (sauf les 35 studs de l aire d Ape Cave).

## A lire en premier (points ouverts pour le coordinateur)
1. **Bande sud de S4 reecrite** : S4 avait un rabais PROVISOIRE de 30 studs en Z 2400..2500 (X -790..1400 ; "S5/S6 reprendront H pur"). Sans correction S6 aurait du creuser une tranchee de 28 studs le long de la couture. J'ai reecrit UNIQUEMENT les cellules Z 2400..2500, X -792..1400 (`S6Terrain.ReecrireBandeS4`, memes materiaux que S4Terrain, rabais retire de 0 % a X=-790 a 100 % a X=-590). Mesure : X 0..1300 suit H a +-3 studs, pas de marche. **A relancer apres toute reconstruction de S4** (`for i=0,9 do S6Terrain.ReecrireBandeS4(i)`).
2. **Dip residuel au coin sud-est de S5 (X -1300..-590, Z 2400..2560)** : S5 (fini) a garde son fondu de 30 studs (X -1300..-790) ; une tentative de reecriture de ce coin a ete refusee par l'outil, je n'y ai donc pas touche. Resultat : creux de ~28 studs a Z=2500, X -1100..-900, qui remonte vers H sur 200 studs au sud (pente max ~25 degres). Correction simple : retirer le fondu sud de S5 (`SudChute`) et relancer `ReecrireBandeS4` avec `w=1` partout, puis reconstruire S6.
3. **Sentiers non raccordes aux extremites voisines** (ni S4 ni S5 n'ont d'extremite au bord Z=2500) :
   - Chantier -> Ape Cave : S6 ecrit le sentier jusqu'a (-2440,2500). La suite (Z 2500 -> 2345, aire d'entree de S5 `D5.Aire7`) est dans la boite de S5 : **a appliquer par S5** avec `S6Donnees.AppliquerSentierCave(h, genre, X, Z)` (export, profil deja epingle sur `Aire7Y`). Sans cela le sentier s'arrete a 155 studs de l'entree (foret, jouable).
   - Chantier -> S4 : le sentier sort a (230,2500) (vers le poste 17). La suite dans S4 (~1000 studs, NON construite) : `S6Donnees.Cfg.PtsSentierEstSuite` = (230,2500) (225,2300) (215,2100) (205,1900) (205,1700) (220,1560) (215,1488 = piste du poste). Le trajet croise aucun ruisseau de S4 (le ruisseau de S4 est a l'ouest).
4. **S5_Ouest.md relu** : jonction du ruisseau conforme (voir ci-dessous).

## Fait (place Partie)
- Terrain voxel 4 studs, **X -4000..1400 / Z 2500..4000** (bords de carte ouest et sud). Raccord est : meme H que S7 a X=1400, ecart au gradient de H max 0.2 stud (mesure raycast X 1394 vs 1406, Z 2510..3990). Raccord nord : ecart au gradient de H max 3.6 (au bord du lit du ruisseau, X=-1540). Grille 9000 points raycast : 0 trou, altitude min 9.8, max 164.5.
- Code : `ServerStorage/TerrainBuilder/{S6Donnees, S6Terrain}` ; copies `terrain/S6Donnees.lua`, `terrain/S6Terrain.lua`. `S6Terrain.Construire(cx,cz)` cx 0..21, cz 0..5 (5 s pour tout) ; `Nettoyer()` = FillBlock Air de la boite S6 seule. S6Donnees depend de `S5Donnees` (queue du ruisseau copiee) : reconstruire S6 apres tout changement du ruisseau de S5.
- **Ruisseau principal** (continuation de S5) : traverse Z=2500 en X~-1600, plein sud puis leger decalage ouest (X -1860 vers Z 3300, sortie bord sud ~(-1950,4000)). Jonction : S5 (-1600,2494) niveau d'eau 40.28 / S6 (-1603,2506) 40.20, largeur 32.7 identique (queue de 150 studs de S5 recopiee). Niveau d'eau mesure par raycast tous les ~70 studs : **0 hausse**, 42.2 -> 40.1 (Z 2540) -> 38.0 (Z 3040..3340, plat) -> 34.9 -> 29.8 -> 23.9 -> 18.3 -> 10.0 (plat de Z 3700 a la sortie). Largeur 32.7 -> 48 en sortie, cuvette 6 -> 4. Lit plancher y=10 (jamais sous 9.8).
- **Gue** du sentier de la grotte en ~(-1697,2844) : berges abaissees a bed+4.5, cuvette reduite de 80 % ; marqueur `Eau/Gue_Sentier_Cave`. Pente max 0.71 (35 degres) a (-1717,2827) juste au nord du gue (relief naturel, < 45).
- **Chantier (10)** `Lieu_10_Chantier` (-1400,3300) : coupe rase ellipse 300x250 (bord bruite +-16 %), relief adouci a 20 % (collines retirees), sol "aire" (Ground/Mud/Grass en taches) ; **aire d'engins arasee** 120x90 a **Y=88** centre (-1390,3300), fondu 45. Depart `Workspace/Departs/S2` (SpawnLocation, tag `Depart`, attribut Depart="S2") en (-1440, 90.5, 3335) sur l'aire plate. Le pavage de la coupe penche encore du sud-est (~77) vers le nord-ouest (~111).
- Blocs gris dans `Carte/S6_SudOuest/Lieux` : `MANQUANT_Bulldozer` (12x9x20 en (-1330,3285)), `MANQUANT_CabaneChantier` (16x10x12 en (-1468,3232)), `MANQUANT_Souches` (1 bloc temoin, attribut Quantite=40, zone = la coupe), `MANQUANT_Sapins_Chantier/_Ouest/_Est/_Sud/_Gue` (un par clairiere cle : (-1565,3195), (-2500,3350), (-300,3250), (-950,3720), (-1640,2795)).
- **Grumes** : 4 clones de `ServerStorage/Assets/Props/PileBuches` (`Assets/PileBuches_1..4`) : le modele source fait 4.6x1.3x3.5 (trop petit) -> **ScaleTo(3)** = 14x4x10 ; 4 parts ancrees chacun ; poses par raycast (bas du bbox + 0.3) a (-1500,3345) (-1285,3360) (-1255,3250) (-1480,3185). Positions a valider visuellement.
- **Piste forestiere** fictive (demi-largeur 5, fondu 14, Ground compacte) : bord sud (-1000,4000) -> (-1090,3780) -> (-1290,3560) -> aire d'engins. Axe : **126/126 = 100 % Ground** (raycast tous les 5 studs), pente max 0.26. `Routes/Piste_Depart_BordSud`.
- **Sentier vers Ape Cave** (demi 2.2, bords irreguliers) : chantier -> NO -> gue -> O -> (-2440,2500) : 209/211 Ground/Mud (les 2 hors-axe sont au gue : Cobblestone/Rock de berge). **Sentier vers S4/poste 17** : chantier -> E/NE -> (230,2500) : 282/283. Pente max 0.37.
- Forêt dense (couvert 0.85, 0.92 a X>500) avec 4 clairieres (Ouest, Est, Sud, Gue) + chantier ; 50 affleurements rocheux (bosses raides hors chemins/ruisseau, deviennent Rock par la pente) ; materiaux par `MelangeMateriaux` (altRoche 330).
- Marqueurs : `Eau/Jonction_S5`, `Eau/Sortie_Sud_Ruisseau`, `Eau/Gue_Sentier_Cave`, `Routes/Sentier_Cave_FinNord`, `Routes/Sentier_Est_FinNord`.

## Navigation (Edit, PathfindingService par etapes < 1000)
Joueur (r2 h5) et creature (r5 h10) : S2 <-> bord sud (4/4), S2 -> gue -> (-2440,2500) (5/5), S2 -> (230,2500) (5/5) : **tous Success**.

## Parametres (S6Donnees.Cfg)
Coupe (RX 150, RZ 125, Adoucit 0.8), Pad, RampeNord 200 / RabaisNord 30, Cuvette 4, PenteRuisseau 0.004, FondMin 10, LargeurSortie 48, ExtRuisseau (waypoints), PtsPiste/PtsSentierCave/PtsSentierEst, Clairieres.

## Limites
- Pas de vegetation, pas d'asset, captures non prises (aucune capture dans cette session). Validation visuelle par Gabriel.
- Le ruisseau reste plat sur ~300 studs a Z 3040..3340 (38.0) puis tombe vite (rapides) : relief du sud ; a retoucher si on veut des cascades nettes.
- Dip residuel S5 (voir point 2) et sentiers de S4/S5 a prolonger (point 3).
