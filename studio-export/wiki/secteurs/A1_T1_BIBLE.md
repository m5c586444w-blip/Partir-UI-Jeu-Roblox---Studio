# A1 phase B (agent B4) : T1 selon la bible 3.5 + route de la creature P15 <-> P05 (10/11/2026)

Tous les parametres ci-dessous sont des DEFAUTS PROPOSES (aucun appui chiffre dans la bible en dehors des points P01, (2400,1867), (2200,267), P05, P06 et des largeurs).

## Trace T1 (6 de large, Ground, axe continu)
- S7 (`S7Donnees.Cfg.PtsSentier`) : (2800,3172) (2750,3125) (2660,3090) (2560,3030) (2480,2930) (2420,2800) (2400,2500) (2395,2200) (2400,1867) (2330,1590). Le long du bord est du lahar. Jonction (2330,1590) identique a `S3.PtsApe[1]`.
- S3 (`S3Donnees.Cfg.PtsApe`) : (2330,1590) (2290,1300) (2270,1000) (2240,650) (2200,267) (2210,-100) (2260,-300) (2320,-480) (2330,-800) (2350,-1100) (2400,-1300) (2450,-1370) (2290,-1420) (2090,-1540) (2010,-1620) (1940,-1730) (1910,-1820) (1790,-1860) (1770,-1960) (1700,-2040) (1650,-2080) (1560,-2160) (1500,-2240).
- Points de la bible respectes : (2400,1867) et (2200,267) exacts. P05 : T1 passe a ~160 studs (dans le rayon 300) ; P05 est desservi par une branche. P06 : hors region (ticket CENTRE).
- **Point de sortie en X=1500 : (1500, -2240), hauteur 322,4 (plan) / 324,4 (voxel).** La suite vers P06 (1200,-2600) est du ticket CENTRE. Ces 200 derniers studs (X 1500..1700) sont dans la bande de couture de B1 : `Raccords_EST` doit conserver la bande de T1 (ou etre relance puis T1 re-verifie).
- Pente : plan 14 % (`S7.PenteT1`, marge sous les 15 %). Lacets naturels dans le coin NO du lahar (X 1650..1950), recherche A* puis RDP (coupe max 17 studs, moyenne 2,2).
- Ancien trace (X ~2470-2550) supprime : les tuiles ont ete reconstruites, sol redevenu foret/lahar (Ground 38-48 % seulement sur l'ancien axe).

## Branches
- `S3.PtsP05` (6 de large) : de T1 (2450,-1370) a P05 (2600,-1400), arrivee a 399,6 (plan), 401,6 mesure. Derniere montee sur le flanc ouest du bord, a >= 35 studs du sentier de crete S8, croisement vers (2563,-1668) (hauteurs alignees dans `S8Donnees`).
- `S3.PtsRuine` : premier troncon du sentier de crete de S8 (ruine -> crete). S8 ne construit que Z < -1380, le mur de la corniche n'etait pose par personne (marche de 29 studs a Z=-1380 avant). Maintenant pose par S3 apres la corniche, hauteurs reprises par S8. Acces a la ruine = branche P05 -> croisement -> sentier de crete vers le sud. Zone de la ruine : pente mesuree jusqu'a 37 % sur 24 studs (plan 33 % = `S8.Cfg.Sentier.PenteMax`, inchange) : au-dessus des 26,6 % acceptes, impossible a reduire sans allonger le trace (montee de 64 studs sur ~220).
- T4 : seule sa tete change : attache sur T1 en (2320,-480) (au lieu de (2490,-450)) ; PtsMine = (2320,-480) (2420,-460) (2510,-430) (2600,-380) ... Profil de T4 inchange. Marqueur `Sentier_Carrefour_Mine` deplace.

## Modifications de code
- `S7Donnees` : PtsSentier, `D.PenteT1 = 0.14`.
- `S3Donnees` : PtsApe, PtsP05, PtsRuine, SentierRuine, PtsMine (tete) ; `D.P05`, `D.Ruine` ; fonction `base()` (sol avant sentiers = lahar + ruisseau) pour les profils de T1/P05/Ruine ; T1 + P05 + bande S7 REAPPLIQUES apres le ruisseau (son fondu deformait l'axe de ~10 studs) ; gate de T4 `X > 2250` ; T1 ne finit plus a la ruine.
- `S8Donnees` : hauteurs du sentier de crete alignees sur S3.Ruine (debut) et sur S3.P05 (croisement).
- `S7Terrain`, `S3Terrain`, `S8Terrain` : NON modifies.

## Chunks reconstruits (mode "boites" de 64x64, pas de chunk entier)
Constructeur temporaire (copie conforme de `Construire`, borne a une boite alignee sur la grille 4 studs, vide la boite avant d'ecrire). Grille de tuiles : origine X 2440, Z 1700, pas 64. Tuiles = trace ancien + nouveau de T1, branche P05, ruine, T4 (S7 sentier ancien/nouveau, S3.Ape ancien/nouveau, SMine), dilates de 30 studs : 417 tuiles (97 en S7 Z>=1700, 320 en S3), puis zone O de S8 sur 27 sous-boites (X 2440..2900, Z -2440..-1380) apres S3. Puis 51 tuiles T4 (profil T4 remis). Seul impact hors trace : les voxels souterrains a plus de 48 studs sous la surface de la tuile sont du Slate.
## Ordre d'application conseille
S7 -> S3 -> S8 "O" (reconstruction des chunks), puis `Raccords_EST` (B1), puis `Ponceau_RD1` (B3), puis relire T1 dans X 1500..1700. Cloner `TerrainSectors` avant tout `require` apres modification.

## Limites
- T4 (non modifie) mesure 110 % de pente sur 12 studs au gue d'Ape (2759,-292) : remblai de ~160 studs coupe par le lit ; c'est l'etat de la phase A (profil Graduer pince par le point de depart), pas une regression. Correction = lacets (~2000 studs), non faite.
- Branche P05 : 20 % sur 24 studs au lacet (2588,-1678) ; P05 monte de +2 (401,6 mesure pour 399,6).
- Parking : 6 echantillons d'Asphalt au depart de T1 (aire du parking).
- Mud rare (0,3 %) sur l'axe : regle de `MelangeMateriaux` (sentier, fbm < -0,75), module non modifie.
- Pathfinding P01 -> P05 par T1 : 69 % des waypoints a <= 5 studs de l'axe (les coins sont coupes par le pathfinder).
