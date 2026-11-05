## 3. Carte de la partie : coordonnées et génération

La carte fait 8 000 × 8 000 studs, soit 2,24 km de côté, puisque 1 stud = 28 cm selon la [doc Roblox](https://create.roblox.com/docs/physics/units). Elle compresse d'environ 4,5 fois le vrai secteur sud-est du volcan : le sentier réel d'Ape Canyon monte de 1 300 pieds sur 4,8 miles ([The Columbian](https://columbian.com/news/2013/jul/10/ape-canyon-trail-mount-hiking)), et il en garde l'ordre des lieux et des altitudes.

Les positions reprennent exactement celles du [document Carte validé](https://claude.ai/artifact/3kbHEGv6jw9Lsbfc1wDSsT). Seule la notation change, pour coller au repère de Roblox.

### 3.1 Repère

- Centre de la carte = origine du monde `(0, 0, 0)`. X va vers l'est, Z vers le sud, **le nord est −Z**.
- Zone jouable : X et Z de −4 000 à +4 000. Bande décorative non jouable jusqu'à ±4 600.
- Conversion depuis l'ancien document (origine au coin nord-ouest) : `X = x − 4000`, `Z = y − 4000`.
- Altitude Y : 0 = point le plus bas (sortie du ruisseau principal au sud-ouest). Point jouable le plus haut : Y = 560 (station météo). Compression verticale choisie ≈ 4 fois, comme l'horizontale.
- Vitesses du jeu (section 7) : marche 12 studs/s, course 20 studs/s. Un côté de carte = 11 min de marche, 6 min 40 s de course continue.

&#91;embedded content: carte 8 000 × 8 000 studs · coordonnées monde · 26 lieux, F01, T5\]

Chaque carré de la grille fait 2 000 studs. Les positions exactes sont dans les tableaux ci-dessous ; en cas d'écart, le tableau gagne.

### 3.2 Lieux (Y = altitude du sol)

| Code | Lieu | Statut | X | Z | Y | Rayon (studs) | Fonction |
| --- | --- | --- | --- | --- | --- | --- | --- |
| P01 | Parking du sentier d'Ape Canyon | Réel, déplacé | 2 800 | 3 200 | 120 | 60 | Départ S1, van, extraction E1 |
| P02 | Coulée de lahar | Réel | 1 800 → 2 400 | −1 500 → 3 600 | 110 (sud) → 380 (nord) | couloir 600 de large | Axe rapide mais à découvert |
| P03 | Lava Canyon (fond de gorge) | Réel | 3 200 | 2 200 | bord 110, fond 40 | 120 | Gorge sonore, cascades |
| P04 | Forêt ancienne | Réel (type de forêt) | 507 → 1 800 | −507 → 2 507 | 150 → 330 | zone | Exploration, traque |
| P05 | Ape Canyon | Réel | 2 600 | −1 400 | bord 400, fond 250 | 300 | Acte 2, le siège |
| P05c | Ruine de la cabane de 1924 | Lieu réel, emplacement fictif | 2 550 | −1 300 | 300 (corniche) | 25 | Barricade du siège |
| P05s | « Étroit » du canyon | Réel : la gorge se resserre jusqu'à 8 pieds ([Wikipedia](https://en.wikipedia.org/wiki/Ape_Canyon)) | 2 700 | −1 650 | 330 | 9 de large | Passage étroit, piège |
| P06 | Plateau de cendres | Réel (Plains of Abraham) | 1 200 | −2 600 | 480 | 900 | Vue sur le volcan, à découvert |
| P07a | Ape Cave, entrée principale | Réel | −2 507 | 2 400 | 60 (sol du tube Y = 5) | 20 | Entrée du réseau |
| P07b | Salle du repaire | Fiction | −2 900 | 1 700 | 30 (souterrain) | 45 | Repaire, corps de Whitcombe, femelle |
| P07c | Sortie basse bouchée par le lahar | Réel (bouchon) + fiction (sortie) | −2 300 | 3 600 | 20 | 6 | Extraction E4 (fin secrète) |
| P08 | Zone interdite (forêt soufflée) | Fiction greffée sur 1980 | −3 707 → −507 | −3 707 → −800 | 300 → 430 | zone | Terrain de chasse, raccourci |
| P09 | Camp des géologues | Fiction | −800 | 600 | 230 | 50 | Départ S3, indices, corps |
| P10 | Chantier forestier abandonné | Fiction | −1 400 | 3 307 | 70 | 80 | Départ S2, bulldozer, extraction E3 |
| P11 | Tour de guet centrale | Fiction | 0 | −1 600 | 420 (cabine +60) | 15 | Radio, extraction E2 |
| P12 | Prairie et clairières | Fiction | −2 200 | 200 | 200 | 350 | Respiration, visible de loin |
| P13 | Cascade et bassin | Fiction | −1 800 | 1 200 | haut 210, bassin 150 | 40 | Bruit d'eau, lieu de la mort du juvénile |
| P14 | Volcan (décor) | Réel, hors limites | −500 | −10 000 | sommet 2 600 | — | Repère visuel |
| P15 | Mine abandonnée | Fiction | 3 333 | −667 | 390 | 30 | Corps d'Ito, munitions possibles |
| P16 | Pont sur le ruisseau de Lava Canyon | Un pont existe sur ce sentier ([The Columbian](https://columbian.com/news/2012/jul/10/lots-hike-lava-canyon)), emplacement fictif | 3 467 | 1 600 | tablier 150, eau 100 | 30 de long | Passage obligé, grince |
| P17 | Poste des rangers fermé | Fiction | 800 | 3 067 | 110 | 25 | Radio, carte murale, pièces |
| P18 | Barrière de la zone interdite | Fiction | −400 | −667 | 300 | 10 | Panneaux « Area closed » |
| P19 | Charnier de wapitis | Fiction | −2 933 | −2 667 | 380 | 40 | Preuve de classe B |
| P20 | Lac aux troncs flottants | Clin d'œil au lac Spirit | −1 667 | −1 733 | eau 330 | 600 × 320 (demi-axes X, Z) | Restes de Castillo |
| P21 | Tunnel effondré (puits) | Fiction | −3 200 | 933 | 140 (tube Y = 85) | 15 | Second accès au réseau |
| P22 | Épave de voiture | Fiction | 533 | 3 733 | 100 | 10 | Batterie, cric |
| P23 | Station météo | Fiction | 2 400 | −3 467 | 560 | 12 | Point haut, enregistrement DOC\_14 |
| P24 | Tour est | Fiction | 3 800 | 667 | 300 (cabine +60) | 12 | Vue sur la gorge et la mine |
| P25 | Tour nord | Fiction | −200 | −3 067 | 470 (cabine +60) | 12 | Vue sur le lac et le charnier |
| P26 | Tour ouest | Fiction | −3 600 | −667 | 260 (cabine +60) | 12 | Vue sur la prairie et Ape Cave |
| F01 | Falaise de la Crête (**nouveau**) | Fiction | −507 → 1 800 | −800 | marche de 40 | 40 de haut | Ferme le nord sauf par les lacets de P11 (passage X = −100 à +100) |

### 3.3 Départs, extractions, zones de la créature

| Code | Type | Position (X, Y, Z) | Détail |
| --- | --- | --- | --- |
| S1 | Départ | 2 780, 120, 3 220 | Autour du van ; 10 points espacés de 6 studs |
| S2 | Départ | −1 380, 70, 3 290 | Autour du bulldozer |
| S3 | Départ | −820, 230, 640 | Dans le camp, corps visibles |
| E1 | Extraction van | 2 800, 120, 3 200 | Clés + pneu réparé, puis sortir par la route 83 vers X = 4 000 |
| E2 | Extraction hélicoptère | aire de 60 × 60 en −150, 425, −1 750 | Radio de P11 réparée, tenir 180 s |
| E3 | Extraction bulldozer | barrière en −1 400, 70, 3 950 | Carburant + relais, forcer la barrière |
| E4 | Extraction tunnels | P07c | Carte DOC\_07, dégager le bouchon (60 s d'action) |
| B1 | Zone créature : siège | P05 | Pierres depuis le bord du canyon sur la cabane |
| B2 | Zone créature : repaire | P07a–P07c | Famille, femelle |
| B3 | Zone créature : chasse | P08 | Chasse à découvert, carcasses |
| B4 | Zone créature : traque | P04 | Observation, filature |
| B5 | Zone créature : embuscade | P02 | Attaque pendant les traversées |
| B6 | Zone créature : mise en scène | P09 | Corps déplacés entre deux passages |

### 3.4 Points tirés au hasard

Chaque partie tire 6 points d'indice sur 12, et un emplacement par objet clé. Graine aléatoire = `os.time()` au lancement du serveur, écrite dans la console pour rejouer un bug.

| Code | Lieu | X, Y, Z | Peut contenir |
| --- | --- | --- | --- |
| C01 | Camp, tente nord | −780, 232, 560 | DOC\_03, DOC\_04 |
| C02 | Camp, glacière | −840, 230, 640 | DOC\_03, DOC\_04 |
| C03 | Prairie, souche | −2 150, 200, 260 | DOC\_03, DOC\_04, DOC\_06 |
| C04 | Cascade, rocher | −1 760, 152, 1 240 | DOC\_03, DOC\_04, DOC\_06 |
| C05 | Forêt, arbre creux | 1 100, 240, 900 | DOC\_04, DOC\_05, DOC\_06 |
| C06 | Épave, boîte à gants | 533, 100, 3 733 | DOC\_04, DOC\_05, DOC\_06 |
| C07 | Poste des rangers, bureau | 800, 112, 3 067 | DOC\_05, DOC\_06 |
| C08 | Mine, entrée | 3 300, 390, −640 | DOC\_05, DOC\_06 |
| C09 | Pied de la tour P11 | 20, 420, −1 580 | piles, bandages |
| C10 | Lahar, gros bloc | 2 100, 260, 400 | piles, fusée |
| C11 | Pont, culée | 3 440, 150, 1 620 | bandages, corde |
| C12 | Tour ouest, cabine | −3 580, 320, −650 | piles, attelle |
| K1–K3 | Clés du van (1 tirée) | −760, 230, 610 · −900, 229, 700 · −1 500, 215, 420 | Clés |
| A1–A5 | Boîte de munitions (1 tirée) | P17 (820, 112, 3 050) · P15 (3 360, 390, −700) · P26 cabine · P10 cabane (−1 380, 72, 3 280) · P19 (−2 800, 380, −2 550) | 5 balles de fusil + 6 de rev. + 4 cartouches |
| J1–J2 | Cric (1 tiré) | P22 coffre · P17 garage | Cric |
| R1–R2 | Câble d'antenne (1 tiré) | P23 · P17 | Câble coaxial |
| R3 | Batterie | P22, fixe | Batterie de voiture (lourde) |
| R4–R6 | Jerrican (1 tiré) | P17 · P22 · P15 | Carburant |
| R7 | Relais de démarreur | P17, fixe | Pièce du bulldozer |

### 3.5 Eau, routes et sentiers (polylignes)

Les points sont des (X, Z) ; Y suit le terrain. Les courbes sont des Béziers cubiques (départ, contrôle 1, contrôle 2, arrivée).

| Code | Type | Tracé | Largeur (studs) |
| --- | --- | --- | --- |
| R1 | Ruisseau principal | (533, −3 067) → c(−133, −1 600) → c(−1 067, −267) → **P13** (−1 800, 1 200) → c(−2 200, 2 133) → c(−2 800, 3 067) → (−3 067, 4 000) | 6 à la source, 14 au milieu, 24 sous la cascade, 30 à la sortie |
| R2 | Ruisseau de Lava Canyon | (3 067, −1 600) → c(3 467, 0) → c(3 067, 1 200) → (3 467, 2 400) → c(3 667, 3 067) → c(3 600, 3 600) → (3 733, 4 000) | 8 → 16 → 22 ; rapides dans la gorge |
| R3 | Exutoire du lac | (−1 067, −1 733) → c(−667, −1 067) → c(−533, −533) → rejoint R1 vers (−700, −100) | 5 → 8 |
| RD1 | Route forestière 83 (réelle) | (4 000, 3 467) → P01 → P03 (3 200, 2 200) | 18, asphalte usé |
| RD2 | Piste du chantier (fictive) | (−1 400, 4 000) → P10 → P07a | 14, gravier et boue |
| T1 | Sentier d'Ape Canyon (réel, n° 234) | P01 → (2 400, 1 867) → (2 200, 267) → P05 → P06 | 6 |
| T2 | Sentier de la forêt | P01 → c(933, 2 400) → c(0, 1 200) → P09 → P12 → P07a | 5 |
| T3 | Sentier de la tour | P09 → passage F01 (0, −800) → lacets → P11 → P06 | 5 |
| T4 | Sentier de la gorge | P16 → P15 → P05 | 4 |
| T5 | Piste des wapitis (non balisée) | P12 → (−1 500, −1 000) → (−900, −2 300) → P25 → P06 | aucune, herbe couchée |

Raccourci par la zone interdite : de P12 à P06, T5 fait environ 5 300 studs contre 6 700 par T2 et T3 (lacets de F01 compris). À 12 studs/s, le gain réel est donc d'environ **2 min**, et non 3 min comme écrit dans l'ancien document : correction.

### 3.6 Biomes et végétation

| Biome | Où | Sol (matériau Roblox) | Arbres pour 10 000 studs² | Sous-bois |
| --- | --- | --- | --- | --- |
| Forêt ancienne | P04, abords de T2 | LeafyGrass + Ground, mousse | 9 (sapins de Douglas, pruches) | Fougères denses, troncs couchés |
| Forêt mixte | Tout le reste du sud | Grass + Ground | 6 | Fougères, buissons |
| Prairie | P12 | Grass haute | 0,3 (arbres isolés) | Herbe animée par le vent |
| Lahar | P02 | Pebble + Rock | 0 | Blocs, galets |
| Gorges | P03, P05 | Basalt + Rock | 1 sur les bords | Mousse, éboulis |
| Plateau | P06, P23 | Sand recoloré gris cendre (#7A7670) + Pebble | 0,2 (pins rabougris) | Fleurs rares |
| Zone interdite | P08 | Sand cendre + Ground | 0 vivant ; 4 chicots + 6 troncs couchés orientés nord-sud | Carcasses, aucun sous-bois |

Plafond global : 20 000 modèles de végétation et rochers. Au-delà de 700 studs, les arbres passent en maillage simplifié (`Model.LevelOfDetail = StreamingMesh`).

### 3.7 Génération procédurale (en mode Edit, une seule fois)

Le terrain est généré par un script d'édition, `TerrainBuilder`, avec la graine fixe **1924**, pour que la carte soit identique à chaque régénération.

1. **Relief de base :** somme de collines gaussiennes centrées sur les ancres ci-dessous, plus une pente douce qui monte du sud (Y ≈ 40) vers le nord (Y ≈ 420).
2. **Bruit :** bruit fractal à 5 octaves, période de base 1 600 studs, amplitude 60, chaque octave à fréquence double et amplitude moitié. Bruit en crêtes d'amplitude 40 sur les crêtes.
3. **Rivières :** pour chaque polyligne, creuser un lit de profondeur 0,35 × largeur + 4, raccordé au terrain sur 3 × la largeur. Le fond doit toujours descendre vers l'aval.
4. **Gorges :** Ape Canyon (150 de profondeur, de (2 300, −600) à (3 000, −2 200)) et Lava Canyon (70 de profondeur, le long de R2 entre Z = 1 600 et 2 600), parois en Basalt.
5. **Aplanir** chaque lieu sur son rayon, raccordé sur 1,5 fois le rayon.
6. **Routes et sentiers :** pente maximale 8 % pour les routes, 15 % pour les sentiers (sinon lacets).
7. **Matériaux :** pente > 40° = Rock ou Basalt ; puis les matériaux des biomes ; textures Poly Haven via `MaterialVariant`.
8. **Eau :** eau du terrain pour R1, R2, R3 et le lac P20.
9. **Végétation :** répartition aléatoire avec distance minimale entre arbres (11 studs en forêt ancienne), rotation libre, échelle ±15 %, rangée dans `Workspace/Vegetation/Chunk_X_Z` (blocs de 512 studs).

| Ancre | X, Z | Hauteur visée | Rayon |
| --- | --- | --- | --- |
| Dôme du plateau | 1 200, −2 733 | 520 | 1 470 × 800 (ellipse) |
| Crête de la tour | 200, −1 573 | 430 | 800 × 373 |
| Crête est | 3 200, −800 | 400 | 667 × 933 |
| Colline ouest | −3 067, 1 200 | 220 | 733 × 533 |
| Cuvette du lac | −1 667, −1 733 | 320 (creux) | 700 × 420 |

### 3.8 Limites et décor lointain

- **Nord :** pentes d'éboulis infranchissables qui montent vers le volcan. Le volcan est un maillage lointain (P14), pas du terrain, vu depuis le sud : on n'y voit pas la brèche du cratère, qui s'ouvre au nord ([Wikipedia](https://en.wikipedia.org/wiki/Mount_St._Helens)).
- **Sud :** au-delà de Z = 4 600, un plan d'eau décoratif évoque le réservoir Swift, situé directement au sud du sommet ([Wikipedia](https://en.wikipedia.org/wiki/Mount_St._Helens)).
- **Est et ouest :** collines boisées noyées dans le brouillard.
- À ±3 900, message « Tu t'éloignes trop du groupe » ; mur invisible à ±4 000, caché par des obstacles naturels (troncs, rochers, pentes).

