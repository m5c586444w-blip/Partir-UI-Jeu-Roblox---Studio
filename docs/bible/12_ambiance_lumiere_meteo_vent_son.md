## 12. Ambiance : lumière, météo, vent, son

La nuit doit être vraiment noire entre minuit et 4 h, et le son doit porter la moitié de la peur. Valeurs dans `Config/AmbienceConfig` ; un module client `AmbienceController` interpole entre les réglages selon l'heure et la zone.

### 12.1 Lumière par moment

`Lighting.Technology = Future`. Couleurs en RGB 0–255.

| Moment | ClockTime | Brightness | OutdoorAmbient | Ambient | ExposureCompensation |
| --- | --- | --- | --- | --- | --- |
| Arrivée | 18,5 → 19 | 1,2 | 60, 65, 80 | 40, 45, 55 | 0 |
| Fin d'enquête | 21 | 0,15 | 20, 24, 32 | 12, 14, 18 | 0 |
| Siège | 22 → 0 | 0,05 | 12, 14, 20 | 8, 9, 12 | −0,1 |
| Nuit noire | 0 → 4 | 0 | 8, 9, 14 | 5, 6, 9 | −0,3 |
| Aube | 5 → 6 | 0,6 | 45, 55, 75 | 25, 30, 40 | 0 |

- `ColorCorrectionEffect` : Saturation −0,25, Contrast 0,1, TintColor 220, 230, 255.
- `BloomEffect` intensité 0,3 ; `DepthOfFieldEffect` FarIntensity 0,15 (réglage Élevé seulement).
- Lune par nuit claire : les nuages s'ouvrent 20 s toutes les 3 à 5 min, assez pour voir une silhouette à 80 studs.
- Lampes : `SpotLight` avec ombres, angle 45°, portée de la section 8 ; sous 15 % de pile, clignotement aléatoire.

### 12.2 Brouillard par zone (`Atmosphere`)

| Zone | Density | Haze | Color |
| --- | --- | --- | --- |
| Forêt | 0,35 | 1,5 | 190, 200, 215 |
| Gorges P03, P05 | 0,45 | 2,0 | 180, 190, 205 |
| Zone interdite P08 | 0,20 | 0,5 + particules de cendre | 170, 170, 175 |
| Plateau P06 | 0,25 | 1,0 | 200, 205, 215 |
| Tunnels P07 | Atmosphere désactivée, noir total | — | — |

### 12.3 Météo (tirée à chaque partie, sauf vote « fixe »)

| Météo | Probabilité | Effets |
| --- | --- | --- |
| Nuit claire | 30 % | Lune, froid ; aucune pénalité de vue |
| Brouillard | 30 % | Density ×1,7 ; vue de la créature ×0,5, celle des joueurs aussi |
| Pluie | 25 % | Particules près de la caméra ; bruits ×0,6 pour tous ; sol mouillé |
| Première neige | 15 % | Neige au-dessus de Y = 350 ; empreintes visibles 300 s ; endurance ×0,85 |

Pendant l'acte 2, une nuit claire ou un brouillard passe en pluie (ou en neige au-dessus de Y = 350, ce qui est le cas de la cabane).

### 12.4 Vent

`workspace.GlobalWind` fait bouger l'herbe du terrain, les nuages et les particules qui ont `WindAffectsDrag` ([doc Roblox](https://create.roblox.com/docs/environment/global-wind)). Il ne fait pas bouger les maillages : les arbres sont donc animés par leurs os, côté client, seulement à moins de 120 studs et en réglage Élevé.

| Météo | Vent de base (X, Y, Z) | Rafales |
| --- | --- | --- |
| Nuit claire | 6, 0, −3 | +10, toutes les 8 à 15 s |
| Brouillard | 2, 0, −1 | aucune |
| Pluie | 14, 0, −6 | +20, cycle en sinus comme l'exemple de la doc |
| Neige | 10, 0, −8 | +12 |

Le vent sert aussi à l'odorat de la créature (9.4) : un joueur attentif peut se placer sous le vent.

### 12.5 Sons d'ambiance

| ID | Couche | Où | Règle |
| --- | --- | --- | --- |
| AMB\_Birds | Oiseaux | Forêt, actes 0 et 4 | Se tait autour de la créature (EVT\_01) |
| AMB\_Insects\_Owls | Insectes, chouettes | Forêt, actes 1 à 3 | Idem |
| AMB\_Wind\_Pines | Vent dans les pins | Partout dehors | Volume selon la force du vent |
| AMB\_River | Ruisseau | Émetteurs tous les 60 studs le long de R1, R2, R3 | Masque les bruits (9.4) |
| AMB\_Waterfall | Cascade | P13 | Masquage fort |
| AMB\_CanyonWind | Vent qui siffle | P03, P05 | — |
| AMB\_AshEmpty | Vent à vide, sans faune | P08 | Aucun animal, jamais |
| AMB\_TunnelDrips | Gouttes, souffle | P07 | — |

**Réverbération par zone** (`SoundService.AmbientReverb` mis à jour par zone) : forêt `Forest`, gorges `Mountains`, tunnels `Cave`, cabane et bâtiments `Room`, plateau et zone interdite `Plain`.

**Pas des joueurs :** un jeu de 4 variantes par matériau : Grass, LeafyGrass, Ground, Mud, Pebble, Rock, Basalt, Sand (cendre), Snow, Water, bois (cabane, pont), métal (escaliers des tours).

### 12.6 Musique

| ID | Quand | Style |
| --- | --- | --- |
| MUS\_Lobby | Lobby | Guitare sèche lente, très discrète |
| MUS\_Siege | Acte 2, pendant le bombardement | Bourdon grave continu |
| MUS\_Chase | La créature attaque ou charge le joueur local à moins de 60 studs | Percussions graves et cordes ; coupure nette quand elle perd sa cible |
| MUS\_Dawn | Cinématiques d'extraction | Cordes, une note tenue |
| — | Tout le reste | **Pas de musique** |

