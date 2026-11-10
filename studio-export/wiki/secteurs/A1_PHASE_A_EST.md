# A1 phase A : alignement de la region EST (S7, S3, S8) sur la bible 3.2 (10/11/2026)

## Methode
- `ServerStorage/TerrainSectors/Alignement_EST` : champ `Delta(X,Z)` (moyenne ponderee normalisee de noyaux gaussiens centres sur les ancres des lieux + plateaux exacts par lieu, nul pour X <= 1500 par fondu multiplicatif).
- `HauteurEST` : proxy de `HauteurGlobale` (H et Basse + Delta). S7/S3/S8 `Donnees` l'utilisent a la place de `HauteurGlobale` (non modifie) : lits, lahar, plateformes, routes, sentiers se recalculent sur le relief aligne.
- Terrain : `NettoyerChunk` borne a la boite (S7Terrain n'a plus `Terrain:Clear()`), socle Slate sous la bande ecrite (y -40 pour S7/S3, y 100 pour S8) car la hauteur monte de +100/+175 par endroits. Reconstruction S7 -> S3 -> S8 M -> S8 O (121 + 187 + 70 + 10 chunks, ~35 s).
- Copies `.lua` exactes dans `Partir-UI-Jeu-Roblox---Studio/studio-export/terrain/` (Alignement_EST, HauteurEST, S7/S3/S8 Donnees et Terrain ; taille et hash verifies identiques a Studio). Pas de commit.

## Deplacements de cours d'eau (decisions DEFAUT PROPOSE)
1. **R2** (bible 3.5) : (3067,-1600) -> ... -> (3733,4000), largeur 8 -> 16 -> 22. La bezier de la bible passe a ~157 studs a l'ouest de P16 et ~230 de P03 : le trace est force par P16 (3467,1600) et P03 (3200,2200) (le tableau 3.2 prime). Points de passage : voir `S7Donnees.Cfg.PtsR2`. Chaine complete dans `S7Donnees.R2` (S3 applique sa partie nord).
2. **Ruisseau d'Ape Canyon** (ancien trace source (2690,-1950) -> jonction (2550,1500) -> S7) : conserve comme **affluent** : fonte S8 -> gorge (P05s, P05) -> (2550,1500) -> bras est (2850,1520),(3150,1450) -> confluence avec R2 en (3380,1330). R2 prend donc sa source seule en (3067,-1600) (pied de falaise) : pas de liaison avec le ruisseau de fonte.
3. Lit R2 : eau 100 a P16 (bed 100.5), lit du fond de P03 a 41.5 (sol mesure 37.8), sortie 20 ; 10 cascades (`S7Donnees.Cfg.Cascades`). Lit d'Ape : absolu entre P05s (sol 331) et P05 (sol 250), rapides (pente jusqu'a 30 %).
4. Pont de Gabriel `Workspace.Model` : deplace/oriente seulement (pivot 3467, 133.6, 1600, rotation -30.4 deg). Gorge a P16 dimensionnee sur sa longueur (106). Bloc `MANQUANT_PontSuspendu` (cree par nous) supprime.

## Parametres DEFAUT PROPOSE (aucun appui chiffre dans la bible)
Alignement : Sigma 450, FondAmbiant 0.15, Xb 1500 / Wb 450 (fondu nul->plein sur 450), Pas 16, RMin 20, FonduMin 90, rayons plein P01 80, P15 50, P24 50, P23 40, P05c 30. Axe du lahar : Delta lineaire en Z entre +102 (sud) et +136 (nord).
Cibles : P02 sud lit 110 (ancre 120 -> NiveauLahar 105.9..109.6), P05c corniche 300 (pad), P15 pad 390 (mur nord 40, entree vers le sud), P24 pad 300, P23 pad 560 (S8). Gorge Ape : Prof 170 max, raccord de gorge 120 studs, bord 400. Gorge Lava : Z 1380..2450 pleine, Dg 44 -> 58, floor hw 36 a P16. P05s : floor 9 de large (hw 4.5, eau 6). Pentes : routes 8 %, sentiers 15 % (`D.Graduer`, deblai/remblai), largeurs RD1 18, T1 6, T4 4. Gues : (3225,-520) R2 et (2725,-300) Ape.
Sentiers : T1 = ancien trace (X ~ 2470-2550) et non la polyligne exacte de la bible ; T4 = P16 (rive est) -> P15 (rive est de R2) -> gue R2 -> gue Ape -> T1 -> ruine. Spur RD1 -> rive ouest du pont ajoute. Tour est P24 (3800,667) reliee a T4 par 332 studs.

## Limites connues
- P05 : bord 400 mesure 399.6 mais la ruine P05c est a 300 a 112 studs : escarpement de ~45 degres entre les deux (incoherence interne de la bible) ; T1 entre dans la corniche en pente 27 % sur ~40 studs.
- Pathfinding creature 10x4 : echoue sur 3-4 etapes du T1 nord (sentier de 6 < agent de 8) ; joueur 5x2 : tous les trajets passent.
- RD1 croise R2 vers (3640,3450) sans pont : l'eau disparait sur ~40 studs sous l'asphalte. A traiter.
- Ruisseau R2 amont (3067,-1600) -> P16 : rapides jusqu'a 14 % de pente de lit.
- S2.Corr3 (S2Donnees) ajoute encore ses deux corrections de bande : elles sont maintenant integrees dans `S3Donnees.Colonne` ; une reconstruction de S2 les doublerait (a retirer de S2).
- `Lieu_22_Epave` / `MANQUANT_EpaveVoiture` (dossier S7 a (2600,3000)) : P22 officiel (533,3733) est en S6 : non touches. Ancien `MANQUANT_StationMeteo` / `Lieu_23` de S2 (~350,-2200) non touches (nettoyage a faire en S2).

## Écart R2 par rapport à la bible (décision coordinatrice 10/11 : accepté, marqué DÉFAUT)
- Le tracé de R2 est forcé par P16 (3467, 1600) et P03 (3200, 2200) : la courbe de Bézier de la bible 3.5 passe à environ 157 studs de P16 et 230 studs de P03. Le tableau 3.2 (positions et altitudes des lieux) prime sur la courbe.
- Largeurs d'eau de la bible : 8, 16, 22 (la consigne antérieure de rivières « larges » n'est plus appliquée).
- Affluent d'Ape Canyon → R2 : confluence vers (3380, 1330) (DÉFAUT PROPOSÉ de la phase A) ; R2 prend sa source seule en (3067, −1600).
