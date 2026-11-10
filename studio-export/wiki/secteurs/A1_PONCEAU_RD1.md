# A1 phase B, tache 3 : ponceau RD1 x R2 (vers (3640, 3450)) - 10/11/2026

## Probleme constate
La route RD1 (profil lisse, pente 8 %) passe a ~84-87 studs de haut ; le lit de R2 est a ~17 (eau a ~23). Les voxels montrent un remblai plein de ~104 studs de long (Z 3396..3500) qui coupe le ruisseau : l'eau disparaissait (26 echantillons sans eau sur l'axe, Z 3398..3498). Defaut en plus : sur 5 cellules (X 3632..3648) la surface de la chaussee etait en Cobblestone/Ground, car `S7Terrain` peint le lit (`Mix.Lit`) dans les 8 studs du haut des colonnes qui portent l'eau de R2, meme sous la route (axe a 96,1 % Asphalt seulement).

## Methode
Module `ServerStorage/TerrainSectors/Ponceau_RD1` (copie exacte : `studio-export/terrain/Ponceau_RD1.lua`, 11518 octets, sha256 `8a3ade71...aeab4b`, somme d'octets 867848). Il ne modifie ni S7Donnees ni S7Terrain ni les autres modules ; il lit `S7Donnees` (R2, Proche, Surface0, Colonne).
`Appliquer()` lit par tranches de 48 studs (`ReadVoxels`, grille 4) la zone X 3580..3700, Z 3360..3544, Y 0..112 et, colonne par colonne, a partir des DONNEES (pas du contenu voxel) :
- colonnes a <= 16 studs de l'axe de R2 portant un remblai (Colonne - Surface0 > 2) : sol d'origine du lit (Surface0 : meme niveau d'eau que le ruisseau naturel, galets `Mix.Lit`), eau, air jusqu'au plafond = ceil((niveau d'eau + 6)/4)*4 = 32, puis voute en marches (+8 pour d <= 8, +4 pour d <= 12, +0 jusqu'a 16) ; au-dessus, 8 studs de Concrete (voute). Si le remblai est trop bas pour une voute : tranchee ouverte (portail) jusqu'au dessus du remblai et au moins jusqu'au niveau de l'eau ;
- colonnes entre 16 et 24 studs de l'axe : cellules pleines en Rock (parois / ailes de portail) jusqu'a la voute + 8 ;
- colonnes `route` portant l'eau : les 8 studs du haut redeviennent Asphalt (occupations conservees).
Pas de `Terrain:Clear`, aucun asset, la chaussee n'est pas deplacee. Piege decouvert : `WriteVoxels` ignore l'eau ecrite dans une cellule qui garde une occupation residuelle (1/256) ; le module vide d'abord les cellules modifiees (Air), ecrit, puis ecrit les valeurs finales.
Idempotent : tout est deduit des donnees ; une cellule vide reste vide quel que soit son materiau. Mesure : passe 1 = 58 cellules (apres les passes precedentes d'essai), passe suivante = 0.

## Parametres (DEFAUTS PROPOSES)
`Cfg.DemiLargeur` 16 ; `LibreMin` 6 ; `Voute` {{8,8},{12,4},{16,0}} ; `Paroi` 8 ; `EpaisseurMin` 2 ; `MatVoute` Concrete ; `MatParoi` Rock ; `Zone` X 3580..3700 / Z 3360..3544 ; `YMax` 112 ; `PasZ` 48. Boite autorisee : X 3390..3890, Z 3200..3700 (rien n'est ecrit hors de la zone, elle-meme dans la boite).

## Ordre d'application (DEFAUT PROPOSE)
Apres toute reconstruction de S7 qui touche les chunks (8,7) et (8,8) (`S7Terrain.Construire`, X 3448..3704, Z 3200..3704), car elle efface le ponceau ; relancer `Ponceau_RD1.Appliquer()` ensuite. Raccords_EST (frontieres X~1400 et Z~-2440, loin de la boite) : l'ordre est sans effet, avant ou apres convient. Mettre le ponceau APRES Alignement/S7 et AVANT le polissage final. Cache `require` : cloner le module sous un autre nom avant de le recharger.

## Mesures (Studio, mode Edit)
| Mesure | Avant | Apres |
| --- | --- | --- |
| Echantillons d'eau sur l'axe R2 (tous les 4 studs, Z 3202..3698, dans les voxels) | 125 dont 26 sans eau (Z 3398..3498) | 125, 0 trou |
| Niveau d'eau (haut de la cellule) | 24,30 (Z3202) -> 21,81 (Z3698) | identique aux extremites ; 0 hausse sur 125 (tunnel : 23,34 a 22,84) |
| Largeur d'eau en cellules (Z 3340..3556) | - | 12 a 16 studs partout, tunnel compris |
| Hauteur libre au-dessus de l'eau (toutes colonnes d'eau, Z 3200..3700) | remblai plein | minimum 16,75 (Z 3412), >= 6 requis |
| Surface de RD1 sur l'axe (127 echantillons tous les 4 studs dans la boite) | 96,1 % Asphalt (5 cellules Cobblestone/Ground) | 100,0 % Asphalt |
| Pente de RD1 (donnees `D.Route.Y`) | 8,00 % max | 8,00 % (inchange) |
| Pente de RD1 (voxels, entre centres de cellules, fenetre de 12 studs) | 8,07 % max | 8,07 % (inchange ; ecart = quantification) |
| Saut de surface aux 4 bords de la boite (cellule dedans / cellule dehors) | O 2,2 ; E 1,0 ; N 0,8 ; S 1,1 | identique (aucune cellule modifiee a moins de 100 studs d'un bord) |
| Cellules modifiees hors de la zone | - | 0 (comparaison par empreinte de 256 blocs de 32x32 studs, Y 0..128 : 9 blocs differents, tous dans X 3580..3676, Z 3392..3520) |
| Pathfinding RD1, joueur (AgentRadius 2, AgentHeight 5) : x3400->3600, 3680->3880, 3560->3720 (traversee du ponceau), 3400->3880 | - | Success x4 (53 / 52 / 42 / 124 waypoints), 0 saut, pas vertical max 1,1, waypoints a 3,5 studs max sous l'axe de la route |
| Pathfinding RD1, creature (AgentRadius 5, AgentHeight 10) : memes 4 trajets | - | Success x4, memes chiffres |
Coupe a Z=3448 (materiaux) : eau et lit au fond, voute en marches en Concrete, parois Rock, chaussee Asphalt au-dessus (84-88).

## Limites / non teste
- Pente de RD1 : 8,00 % dans les donnees (limite exacte) et 8,07 % en voxels ; defaut ANTERIEUR, non modifie ici (hors perimetre).
- Pas de verification visuelle (captures non faites) ; le ponceau est un passage a section en marches de 4 studs (resolution du terrain), long de ~104 studs sous un remblai de ~60 studs.
- La route reste un remblai haut de ~60 studs au-dessus du lit ; seule l'eau est rendue. Pas teste : vehicules, ni gameplay du tunnel (eau peu profonde, berges praticables a pied).
- Pathfinding teste en Edit, pas en Play.
