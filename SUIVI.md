# SUIVI — PISTE FROIDE

Tenu par les deux sessions (cloud et Studio), section 18.1 ter. Chaque session ajoute une
entrée au journal : date, ce qui est fait, ce qui reste ouvert.

Règle de la section 0 : une question qui ne touche ni un texte affiché aux joueurs, ni une
valeur de gameplay, ni un asset est tranchée par Claude Code et marquée **DÉFAUT**. Les autres
restent des `TODO(BIBLE)`. Une valeur marquée **PROVISOIRE** est une valeur de gameplay mise
seulement pour que le code tourne : elle attend la bible.

## État de reprise (à lire en premier)

- Session cloud du 2026-11-05 (2) : bible 19.6 appliquée (plus aucun `TODO(BIBLE)` ni PROVISOIRE dans le code),
  bible découpée dans `docs/bible/`, `.claude/settings.json`, étape 0 « Remise à zéro » dans `HANDOFF.md`.
- **Phase A terminée. 0a, vérification des écrans, publication (Lobby v12, Partie v13) et 0b faites (RESET_OK, 2026-11-07).**
  Prochaine étape : phase B1, étape 8 de `HANDOFF.md` (`TerrainBuilder.Build()` dans la Partie). Les fenêtres Studio
  contiennent désormais le seul exemplaire du terrain et des Part posées : ne jamais les fermer sans demander à Gabriel.
- Lobby : le build n'a pas de nœud `Lighting` ; Studio ajoute `ColorGrading` et `Bloom` par défaut (à régler en B2).
- Outils de relecture : `stylua --check src tools/terrain`, `selene src tools/terrain`,
  `python3 tools/check_values.py` (0 nombre hors Config), `python3 tools/ui/check_ui.py --previews`
  (chemins, débordements, chevauchements, aperçus dans `previews/`), puis `rojo build` des deux places.

## Journal des sessions

### 2026-11-10 (3) — session cloud, ticket C2 : crédits des textures (branche `integration/2026-11-10`, depuis `c734cb5`, rebasé sur `bdcac1b`)
- `Credits.luau` : 10 textures Poly Haven appliquées dans Studio ajoutées (preuve : `studio-export/wiki/hot.md`,
  ligne 31) : forrest_ground_01 (Grass), forest_floor (LeafyGrass), forest_ground_04 (Ground), brown_mud_03 (Mud),
  river_small_rocks (Slate), rock_wall_02 (Rock), dry_riverbed_rock (Basalt), asphalt_02 (Asphalt),
  gravel_ground_01 (Sand), large_pebbles (Cobblestone). Titre et auteur de 3 d'entre elles repris du `Credits.luau`
  de `cb37b12` (écrit par l'API) ; les 7 autres : `name` = identifiant, auteur « non confirmé (à relever sur la
  fiche) » (polyhaven.com bloqué depuis le cloud). Les 8 textures d'origine sont conservées, commentées « plus
  appliquées dans Studio » (hot.md lignes 2 et 31). Fichier formaté par StyLua (plus aucun écart).
- `tools/terrain/download_polyhaven.py` : `write_credits` fusionne par url (entrées et commentaires existants
  conservés, ajout avant l'accolade fermante, StyLua à relancer ensuite). Testé sur une copie, sans réseau :
  34 url avant, 35 après, 0 perdue ; 2e passage sans changement.
- Relecture : StyLua 0 écart, selene 0/0, 0 nombre hors Config, `rojo build` des deux places vers un dossier
  temporaire. Aucun test en jeu possible.
- Laissé ouvert : auteurs et titres des 7 textures (à relever sur polyhaven.com) ; identifiant `forest_ground_04`
  (la fiche s'écrit peut-être `forrest_ground_04`) ; `ash_gray` (couleur recolorée en local, pas une fiche Poly
  Haven) et les 6 matériaux `PF_` générés par IA (hot.md ligne 25) non crédités ; question 4 de `RECONCILIATION.md`
  (les 10 textures remplacent-elles les 8 ?) à confirmer par Gabriel.

### 2026-11-10 (2) — session cloud, ticket C3 (branche `integration/2026-11-10`, depuis `c734cb5`)
- VENT01 (`5c65548`) : diffs Codex appliqués tels quels (`git apply --check` OK). `WeatherService` : compteur
  `weatherRevision`, une rafale programmée avant un changement de météo est ignorée et ne rétablit pas l'ancien vent.
  `TreeWindController` : sans vent, les os des arbres actifs reviennent au repos.
- Bible 13.5 (`f8e4d35`) : ligne « Aucune image… IA générative » remplacée par la décision de Gabriel du 9 nov. 2026
  (images IA sous 5 conditions, dépôt `assets/images-ia/`). `docs/bible/` régénéré, reconstitution identique.
- Vérifications : selene 0/0/0, `check_values` 0, `check_ui` 0, `rojo build` des deux places OK (vers un dossier
  temporaire, `builds/` non touché). `stylua --check` échoue sur `src/shared/Credits.luau` seul (lignes longues,
  héritées de C1 `fe7697d`) ; les deux fichiers modifiés passent.
- Laissé ouvert : formatage stylua de `Credits.luau` (hors ticket) ; dossier `assets/images-ia/` non créé (aucune image déposée).

### 2026-11-10 — session cloud, tickets C1, T02B, T04B (branche `integration/2026-11-10`, depuis `d86b4ec`)
- C1 : `docs/RECONCILIATION.md` (SUIVI contre `studio-export/wiki`, Config contre 3.2/3.7/12.4/17.3, stockage 16.4,
  placements contre 3.2 : seul P09 en place, 9 lieux équipés hors ±5 (P10, P11, P15, P16, P17, P18, P24, P25, P26) ; `HauteurGlobale` contre 3.7 : graine 7.31
  contre 1924, pas d'ancres ni de bruit fractal ; noms `TerrainSectors`, `S3_NordEst`/`S8_NordEst`, 13.3) ;
  `Credits.luau` : 15 modèles Sketchfab « CC BY (version à relever) » + Rock 09 (CC0) ;
  `docs/PROPOSITION_CLAUDE_MD.md` (CLAUDE.md non modifié).
- T02B : `TreeWindController` (Partie, client) : os des arbres `Tree_*` de `Workspace/Vegetation`, portée du
  préréglage (Élevé 120 = `TreeWindRange`, Ultra 200, 17.3), réglage TreeWind (17.2), aucun sur mobile (17.1),
  `workspace.GlobalWind` ; arbre sans os ignoré. `AmbienceConfig.TreeWind` : 5 valeurs **DÉFAUT PROPOSÉ**
  (préfixe, 3°, 0,25 Hz, 40 arbres, 0,5 s). `SettingsController.Apply` pousse Enabled et Preset.
- T04B : `docs/ECARTS_INTERACTIFS.md` ; aucun changement de gameplay. Tronçonneuse absente de la bible 8 ;
  aucune réaction physique aux impacts décrite.
- Relecture : selene 0/0, 0 nombre hors Config, `check_ui.py` 0, `rojo build` des deux places vers un dossier
  temporaire (pas `builds/`). StyLua : seul `Credits.luau` en écart (déjà le cas à `d86b4ec` : format sur une
  ligne du générateur, conservé). Aucun test en jeu possible.
- Laissé ouvert : questions de `RECONCILIATION.md` (D02, terrain de référence, nom du dossier de terrain,
  10 textures non créditées, version CC BY, appareil photo EricKos/Ledger9o9) et de `ECARTS_INTERACTIFS.md`
  (soins d'un coéquipier, objet lancé au sol, tronçonneuse, débris de 17.1). `HANDOFF.md` non modifié (hors ticket).

### 2026-11-07 (3) — session Studio, B1
- Fait : plugin `roblox-path-plugin-main` déplacé dans `Plugins/_ancien/` (Gabriel : Team Create = son compte TheDarkArtist02). `TerrainBuilder` : écriture par tranches de `MapConfig.Terrain.WriteSlab` (512, DÉFAUT technique) après « Region is too large ». Objets au sol générés par script (voir DÉFAUT 2026-11-07).
- B1, étape 8–9 (2026-11-07) : `TerrainBuilder.Build()` terminé dans la Partie. Contrôle du sol à ±5 studs du tableau 3.2 (rayon vertical sur le terrain) : 18 lieux conformes ; 8 écarts : P01 70 (attendu 120, asphalte), P03 98 (40), P05 358 (250, rebord au lieu du fond), P05c 254 (300), P05s 254 (330), P07a 94 (60), P07b 166 (30, sous terre), P11 382 (420). La plupart sont des gorges, grottes ou tours où le rayon touche le dessus : à vérifier à l'œil puis retoucher à la main ; P01 et P11 sont les plus probables à corriger.
### 2026-11-07 (2) — session Studio, publication et 0b
- **RESET_OK** : Gabriel a publié `builds/Lobby.rbxlx` (v12) et `builds/Partie.rbxlx` (v13) en Overwrite depuis des fenêtres neuves ; places rouvertes depuis Roblox et comparées à `builds/` : aucun résidu (détail dans `RESET_INVENTAIRE.md`). DataStore existant : `PisteFroide_Profils_v1` seulement (pas de conflit avec `PisteFroide_v1`). Tableau Creator Dashboard : toujours à remplir par Gabriel (non bloquant).
### 2026-11-06 — session Studio, étape 0a
- Fait : outils installés (Rokit 1.2.0, Rojo 7.7.1 en tête du PATH — l'ancien Rojo 7.7.0 renommé `Documents
ojo_ancien` —, StyLua 2.6.0, selene 0.31.0, plugin Rojo). Hygiène git : `.codegraph/`, `.mcp.json`, `.claude/CLAUDE.md`, `.claude/settings.local.json` ignorés. Inventaire 0a du Lobby et de la Partie dans `RESET_INVENTAIRE.md`.
- Constat : les deux places publiées contiennent l'ancien projet (Lobby 17 scripts, Partie 24, terrain vide, aucune UI/son/package). Anciens noms de stockage : DataStore `PisteFroide_Progression_v1`, MemoryStore `PisteFroide_DonneesPartie` ; aucun ne coïncide avec `PisteFroide_v1`, `Parties`, `Launch_*`.
- Laissé ouvert : tableau « Creator Dashboard » de `RESET_INVENTAIRE.md` (Gabriel le remplira plus tard) ; liste réelle des DataStores après publication et accès aux API (HANDOFF, étape 0). Push GitHub impossible pour l'instant : commits locaux seulement.
- Écrans, Lobby (`builds/Lobby.rbxlx`, 2026-11-07) : émulateur piloté par `StudioDeviceSimulatorService` (`CreateDeviceAsync({Name, Width, Height, PixelDensity (72–10000), IsTouchEnabled})` puis `SetDeviceAsync(nom)`) : viewports obtenus 843×369 (tactile) et 1279×700. Contrôle numérique (`execute_luau`, hors `ScrollingFrame`) : 0 débordement réel aux deux tailles, 0 texte hors boîte (les textes sont en `TextScaled`). Faux positif connu : les 6 boutons de `PartyGui` sont empilés dans le fichier, le contrôleur n'en montre que 4 (sans groupe) ou 2 (en groupe). `screen_capture` rend l'UI en Edit (une seule `ScreenGui` à la fois) : vérifiés `SettingsGui`, `PartyGui`, `RoleSelectGui`, `EvidenceBoardGui` à 843×369 ; RAS, portraits vides (images attendues en B3). Reste : captures des 10 autres écrans du Lobby, puis la Partie (`builds/Partie.rbxlx`). Les modifs de `Visible`/`Enabled` faites dans la fenêtre Studio ne doivent jamais être enregistrées.
- Écrans, bilan (2026-11-07) : Lobby (14 écrans) et Partie (13) vus à 843×369 (une capture par écran ; `NotificationGui`, `CinematicGui`, `SettingsGui` sont communs, vus une fois) et contrôle par calcul à 843×369 et 1279×700 : 0 débordement réel, 0 texte coupé (textes en `TextScaled`). Rien à corriger dans les sources, donc aucun rebuild : `builds/*.rbxlx` inchangés (23:26, 2026-11-06). Boutons tactiles : grille de 3 colonnes, 62×66 px ; avec 6 boutons au plus elle reste sur 2 rangées (y 109 à 251 sur 369), coins bas libres. Sac ouvert (x 168–617) sans chevauchement avec `RadioGui` (x ≥ 663) ni les boutons tactiles (x ≥ 625). `Util.prepareGui` / `ScreenInsets = CoreUISafeInsets` : les marges de zone sûre ne sont pas simulées en Edit (écrans collés au bord dans les captures), à confirmer sur appareil réel (J15). Portraits, icônes et images vides : attendus avant B3. Fenêtres Studio de contrôle fermées sans enregistrer (processus arrêté), fenêtres neuves de `builds/Lobby.rbxlx` et `builds/Partie.rbxlx` ouvertes pour la publication par Gabriel.
- Outils : `python3` renvoie au raccourci du Microsoft Store sous Windows ; utiliser `python`.

### 2026-11-05 (2) — session cloud, bible 19.6

Fait (un commit par étape, puis push) :
1. **19.6 dans le code** : C1 (peur en voyant un corps ou la créature, en ligne de vue), C3 (à terre : la
   créature tue, pierre ou tir allié −10 s), C4, C5 (45 de sang), C8 (2 fusées), C9 (poids), C11 (piège à
   bruit), C14 (brûlure), C16 (hache 7, machette 6), C17 (quantités, `GroundItem`), C18, C26 (van 1 500 studs,
   attaque autorisée), C29 (une attaque lancée bloque aussi la régénération), C30 (recul 40 + 15), C31
   (fréquence ×1,5), C32 (catalogue « bas » et règles propres), C33 (distances tirées), C43 (palette du bonnet,
   couleur suivante à chaque « Équiper »), textes des verrous et 4 interprétations validés.
2. **Bible découpée** : `docs/bible/NN_titre.md` + `INDEX.md` (`tools/split_bible.py`, reconstitution
   identique vérifiée) ; `CLAUDE.md` pointe vers l'index (142 lignes).
3. **`.claude/settings.json`** : modèle, conseiller, effort, taille de flux ; autorisations rojo, git (push forcé
   refusé), selene, stylua, outils UI, MCP Roblox Studio.
4. **Remise à zéro** : étape 0 de `HANDOFF.md`, `RESET_INVENTAIRE.md`, `tools/studio/` (inventaire et chemins
   en lecture seule, comparaison avec `builds/`).
5. Relecture : StyLua, selene, 0 nombre hors Config, `check_ui.py` à 0, build des deux places.
   Corrections après relecture : un coéquipier à terre ne perd 10 s qu'une fois par tir de fusil à pompe
   (pas une fois par plomb) ; les corps des géologues (`Body_*`) portent le tag `Corpse` (C1) ; les outils
   d'inventaire impriment par paquets de 100 lignes.

Laissé ouvert : rien dans la bible ; l'inventaire et la remise à zéro attendent la session Studio.

### 2026-11-05 — session cloud, bible 19.5 et 15.7

Fait, dans l'ordre demandé (un commit par étape, puis push) :
1. **19.5 dans le code** : profil Moderate (C35) ; C6 portage d'un blessé (`HealthService` : Porter 2 s,
   Poser 1 s, compte à rebours ×0,5, pas de relèvement porté, +0,5 au score de cible, ni arme à feu ni lampe
   en main) ; C7 `HiddenClueService` + `HiddenClueController` (HC1 repère de la boîte de munitions, HC2 vide
   sanitaire invisible à la vue, HC3 gué ×0,4, HC4 puits sans corde) ; C15 machette fixe en P10 ; C38
   accessoires (données, déblocages, équipement) ; C42 lacets et C40 gorges en trapèze (`TerrainBuilder`) ;
   J12 attaque imposée (`TensionDirector:ForcedAttack`) ; valeurs C2, C10, C12, C13, C20/C34, C23 ;
   textes C19 (objectifs séquentiels, phrase de CS_07), C24 (messages radio), C25 (fins, statuts), C36 (sources).
2. **15.7 dans `tools/ui/build_ui.py`** : `Layout_Desktop` / `Layout_Touch` pour chaque écran (zones sûres
   1280 × 662 et 750 × 311), boutons tactiles en icônes (12, au plus 6 visibles), HUD en haut à gauche sur
   téléphone, icônes devant les jauges, 6 silhouettes, verrous opaques avec condition, fenêtres opaques avec
   voile, sac avec Fermer, lignes de 36 px, cartes de rôle réduites + panneau `Detail`, notifications par place.
3. **`tools/ui/check_ui.py`** : moteur de mise en page aux deux tailles ; **371 signalements avant (UI d'avant
   15.7 : 45 PC, 326 téléphone), 0 après** ; aperçus PNG dans `previews/` (28 contextes × 2 tailles).
4. **RaycastParams** : `Shared/TaggedSet` ; Perception, EvidenceService, ATK_Throw, CreatureBrain,
   WeaponService, lancer, GoreController ; `GetTagged` répétés remplacés (FearService, comportements, contrôleurs).
5. Relecture : StyLua, selene (0/0), 0 nombre hors Config, 0 `Instance.new` d'UI, build des deux places.

Laissé ouvert : les questions du tableau ci-dessous (19.5 n'y répond pas), les couleurs du bonnet (C38),
le placement des Part `CrawlSpace` et `Ford` (B1), l'import des nouvelles icônes.

### 2026-11-04 (3) — session cloud, réponses B1–B4 puis phases A3 → A8

Réponses de la bible appliquées (commit `39d62eb`) : libellés 15.6 dans les interfaces,
images 13.5 (`Img_FearVignette` et 41 icônes `Icon_<ID>`, dessinées par script dans
`assets/ui/`), départ équiprobable (4.4), votes par défaut et égalités (5.4),
`MSG_LaunchConfigMissing` (4.6), `Portrait` en `ViewportFrame`.

**Phase A3 (J6, J7, J8)** — fait :
- Config : `PlayerConfig` (section 7 complète), `ItemConfig` (8, 8.1, 8.3, 8.4),
  `WeaponConfig` (8.2), `MapConfig` (section 3 complète : lieux, départs, extractions, zones,
  points tirés, tracés, biomes, génération), `ActConfig` (section 5), `AmbienceConfig` (12.1–12.4),
  `AudioConfig` (12.5, 12.6, 13.7 ; identifiants vides), `LoreConfig.Documents` (2.7).
- Serveur (Partie) : `NoiseService`, `InteractionService` (invites Custom, durées par rôle, ping),
  `CharacterService` (rôle, skin ou mannequin `MANQUANT_CHR_<ROLE>_Skin_<n>`, copie des ScreenGui),
  `SpawnService`, `HealthService` (6 membres, sang, hémorragies, à terre, relever, mort, ragdoll,
  sac au sol), `StaminaService` (postures, vitesses, endurance, bruits de pas), `FearService`
  (peur, cri involontaire, ordre du Meneur), `InventoryService` (emplacements, sac 12 kg, objets
  lourds, lampes et piles, soins, fusée, feu de camp, lancers, bombe anti-ours, capacités),
  `ItemSpawnService` (tirage 6 indices sur 12, objets clés, objets fixes, graine en console),
  `WeaponService` (validation, cadence, munitions, plombs, tir allié, mêlée, rechargement
  interruptible), `EvidenceService` (A/B/C, vidéo à 60 % visible, sauvegarde à l'extraction),
  `DocumentService` (journal, tablette des géologues, carnet), `TabletService` (DÉFAUT, voir plus bas).
- Client : `ClientBootstrap` (DÉFAUT) et les contrôleurs `InputController`, `CameraController`,
  `HUDController`, `InventoryController`, `InteractController`, `TabletController`,
  `DocumentController`, `DownedController`, `SpectatorController`, `RadioController`,
  `LightController`, `FearFXController` (Partie) et `NotificationController` (les deux).
- Relecture : StyLua et selene sans erreur ; `tools/check_values.py` : 0 nombre hors Config ;
  chemins d'UI tous présents ; `rojo build` des deux places réussi.

**Phase A4 (J9)** — fait :
- Config : `CinematicConfig` (section 6, textes des 17 cinématiques), `LaunchConfig.Votes`,
  `LoreConfig.Endings` et `LoreConfig.Status`.
- Partie (serveur) : `GameStateService` (actes 0–4, horloge 5.1 avec saut de 10 s, objectifs,
  siège : barricades, 6 min, silence 20 s, page 2 du carnet ; voie d'extraction tirée ; aube ;
  fins 5.3 et récompenses ; fin à 06 h 00), `ExtractionService` (E1–E4), `CinematicService`
  (portée, invulnérabilité + 3 s, vote pour passer), `WeatherService` (12.3, vent 12.4).
- Partie (client) : `ObjectiveController` ; les deux places : `CinematicController` (plans
  `CS_xx_Shot_n`, bandes, sous-titres, CS_00 à la première connexion), `AmbienceController`
  (lumière 12.1 interpolée sur l'heure, brouillard 12.2 par zone, réverbération 12.5).
- Lobby (serveur) : `RoleService`, `WeaponBoardService` (armes selon la taille, fusil au Pisteur,
  Opératrice sans arme, vote de conflit en 15 s), `VoteService` (5.4 : défauts et égalités) ;
  `PartyService` : rôle obligatoire avant « Prêt », CS_01 avant la téléportation.
- Lobby (client) : `PartyController`, `RoleController` (portraits en ViewportFrame),
  `WeaponBoardController`, `VoteController`, `ResultsController`, `TeleportController`.
- `Lighting.Technology = Future` dans le projet Partie (12.1).
- Relecture : StyLua et selene sans erreur ; 0 nombre hors Config ; build des deux places réussi.

**Phase A5 (J10, J11, J12)** — fait :
- Config : `CreatureConfig` (section 9 complète), `DirectorConfig` (9.12 et catalogue 10.2).
- `ServerScriptService/AI` (16.1) : `NavGraph` (nœuds tous les 200 studs + un par lieu, A*),
  `Perception` (vue, cône, périphérie, vigilance, ouïe et atténuations, odorat selon le vent, lumière,
  visibilité 7.6), `CreatureBrain` (corps ou capsule `MANQUANT_<ID>` de 10/8/9 studs, simulation à
  distance au-delà de 600 studs, PathfindingService avec les coûts de 9.11, allures et sprint,
  régénération, choix par utilité avec ×1,25 et durées minimales), 16 comportements `Behaviors/BHV_*`,
  7 attaques `Attacks/ATK_*` (signal sonore avant les dégâts, × difficulté), `FamilyBrain`
  (présence selon 5.5, femelle au repaire, personnalité de l'Alpha, cible 9.7 toutes les 2 s, échelle
  d'intimidation 9.6, coordination, lisibilité ≤ 2 créatures visibles, parades, empreintes, capacité
  du Pisteur), `TensionDirector` (T, intensité, montée, pic, règles des actes 1 à 4), `EventDirector`
  (EVT_01–22, règles de 10.1), `MimicService` (sons préenregistrés, repérage par l'Opératrice),
  `CreatureDebug` (Studio, F8) ; `Bootstrap` charge le dossier AI après les services.
- Client : `CreatureDebugController` (F8 ; empreintes fraîches en surbrillance pour le Pisteur).
- Objets `Animation` vides de la section 14 (56 joueur, 41 créature) : `tools/animations/build_animations.py`.
- Relecture : StyLua et selene sans erreur ; 0 nombre hors Config ; build réussi.

**Phase A6 (J13, J14 scripts)** — fait :
- `GoreConfig` (section 11 : deux profils, démembrement, flaques, plafonds 17.3), `GoreService`
  (DÉFAUT, démembrement en Restricted, variantes des corps des géologues), `GoreController`
  (jet court, flaques par rayon, plafond selon le préréglage, option « Gore réduit », noir de la mise à mort).
- Lobby : `LobbyPrompts` (DÉFAUT : invites du ranger, des 8 panneaux, du magasin, du diner, du tableau
  des preuves), `DialogueService` + `DialogueController` (4.2), `MuseumService` + `MuseumController`
  (4.3, 5 XP la première lecture), `SkinService` + `SkinShopController` (7.1 : A, B après 5 parties,
  C après 1 survie ; aperçu en ViewportFrame), `RecordsService` + `RecordsController` (4.5),
  `EvidenceBoardController` (preuves personnelles et pages du carnet).
- Réglages : `ProgressionConfig.Settings` (17.2, défauts PC / mobile) et `Presets` (17.3),
  `SettingsController` (les deux places), remote `RE_SaveSettings` (DÉFAUT), validation par `DataService`.
- Textes recopiés : dialogue du ranger (4.2), 8 panneaux du musée (4.3), plan du lobby (4.1, `MapConfig.Lobby`).
- Relecture : StyLua et selene sans erreur ; 0 nombre hors Config ; build réussi.

**Phase A7 (préparation de J2)** — fait :
- `tools/terrain/TerrainBuilder.luau` (→ `ServerStorage/TerrainBuilder` de la Partie) : les 9 étapes de
  3.7 avec la graine 1924 (relief gaussien + pente, bruit fractal 5 octaves et crêtes, gorges, rivières à
  fond descendant, lieux aplanis, routes et sentiers à pente bornée, F01, lac P20 et réservoir Swift,
  matériaux par pente et biome, eau), un bloc gris par lieu (`Workspace/Places/Pxx_<Nom>`), murs
  invisibles à ±4 000 ; `Vegetation()` séparé (modèles de 13.3 à importer d'abord).
- `BoundaryController` : message de 3.8 à ±3 900.
- Textures Poly Haven de 13.4 téléchargées en 1k (couleur, normale, rugosité) dans `assets/terrain/` par
  `tools/terrain/download_polyhaven.py` ; crédits dans `ReplicatedStorage/Credits` (`src/shared/Credits.luau`).
- Non exécuté ici : TerrainBuilder ne tourne que dans Studio (phase B1).
- Relecture : StyLua et selene sans erreur ; 0 nombre hors Config ; build réussi.

**Phase A8** — fait : relecture complète (StyLua, selene : 0 erreur, 0 avertissement ; 0 nombre hors
Config ; aucun `Instance.new` d'UI ; `require`, services et remotes vérifiés ; 268 chemins d'UI), `rojo build`
des deux places et des deux projets de synchronisation, `HANDOFF.md` réécrit avec la liste ordonnée de ce
qui reste à faire dans Studio. Bilan : environ 15 600 lignes de Luau, 42 `TODO(BIBLE)`, 117 marques `DÉFAUT`.

Non fait en A3 (bloqué par la bible) : porter un blessé (7.2, 7.7 : l'interaction n'est pas
décrite), indices « cachés » de la Descendante (8 studs : aucun indice n'est désigné comme
caché), voix comme bruit (7.8 : chat vocal non décidé, 19.4), sons (13.7 : à fournir).
`TreeWindController` (12.4) est laissé au jalon J3/J4 : il anime les os des arbres, qui ne
sont pas encore importés.

### 2026-11-04 (2) — session cloud, réponses de Gabriel + phase A2 (jalon J5)

- Bible Markdown ; réponses Q1–Q20 appliquées ; messages 4.6 ; 24 ScreenGui de la section 15
  et 2 BillboardGui générés par `tools/ui/build_ui.py` ; `UI_MAP.md` ; projets `*.serve.project.json`.

### 2026-11-04 (1) — session cloud, phase A1 (jalon J1)

- Dépôt Git, projet Rojo 7.7.1, `CLAUDE.md`, `SUIVI.md`, `HANDOFF.md`, arborescence 16.1,
  Config, Shared, 28 RemoteEvents, `DataService`, groupe, lancement, retour.

## Phases

| Phase | Où | Jalons | Contenu | État |
|---|---|---|---|---|
| A1 | Cloud | J1 | Arborescence Rojo, Config, Shared, remotes, DataService, téléportation Lobby ↔ Partie | Fait (code) — à tester en B |
| A2 | Cloud | J5 | Toutes les UI en fichiers d'instances, noms de la section 15, `UI_MAP.md` | Fait — à tester en B |
| A3 | Cloud | J6, J7, J8 | Joueur, objets, inventaire, tablette, documents, preuves, armes | Fait (code) — à tester en B |
| A4 | Cloud | J9 | Actes, horloge, extractions, fins, cinématiques (scripts), lobby (scripts) | Fait (code) — à tester en B |
| A5 | Cloud | J10, J11, J12 | IA complète de la famille, directeur de tension, événements inexpliqués | Fait (code) — à tester et régler en B |
| A6 | Cloud | J13, J14 (scripts) | Gore (deux profils), musée, dialogues, skins, records | Fait (code) — à tester en B |
| A7 | Cloud | J2 (préparation) | Script `TerrainBuilder` complet, téléchargement des textures Poly Haven | Fait — à lancer en B1 |
| A8 | Cloud | — | `rojo build` des deux places, liste de ce qui reste à faire dans Studio | Fait |
| B1 | Studio | J2, J3 | Lancer `TerrainBuilder`, vérifier les positions, poser la végétation | À faire |
| B2 | Studio | J4 | Lumière, brouillard, météo, sons : réglage à l'œil, captures | À faire |
| B3 | Studio | J0, J15 | Import des modèles 3D et animations, tests en jeu, mobile, équilibrage | À faire |

## Critères d'acceptation (18.2)

En phase A rien ne se teste en jeu : « code » = écrit et relu, pas vérifié dans Roblox.

- J1 : [ ] groupe de 2 part et revient (code) · [ ] données sauvegardées (code) · [ ] zéro erreur console (non vérifiable ; zéro erreur de syntaxe)
- J5 : [x] aucun `Instance.new` d'UI · [x] `check_ui.py` : 0 débordement, 0 chevauchement à 1280 × 720 et 844 × 390 · [ ] affichage correct PC et mobile dans l'émulateur de Studio (15.7, 8)
- J6 : [ ] chaque valeur de la section 7 vérifiable dans `CreatureDebug` ou la console — les valeurs sont toutes dans `PlayerConfig` et lisibles en attributs du joueur ; `CreatureDebug` vient en A5
- J7 : [ ] 6 indices sur 12 tirés (code) · [ ] graine affichée (code : console de `ItemSpawnService`) · [ ] preuves sauvegardées après extraction (code : `EvidenceService:CommitForSurvivor`, appelé par l'extraction en A4)
- J8 : [ ] tir impossible sans munitions (code) · [ ] cadence respectée (code) · [ ] tir allié seulement en Difficile et Cauchemar (code)
- J10 : [ ] elle suit un joueur bruyant (code : ouïe + cible) · [ ] perd un joueur couché dans les fougères (code : visibilité ×0,1, invisible au-delà de 10 studs) · [ ] grimpe par les `ClimbPoint` (non fait : escalade à brancher quand les falaises et les points existeront, phase B1)
- J11 : [ ] chaque comportement observé au moins une fois en test (16 comportements écrits) · [ ] aucune attaque sans signal (code : chaque ATK_ attend son signal)
- J12 : [ ] aucun mort en acte 1 hors exceptions (code : `TensionDirector:AllowAttack`) · [ ] au moins un temps fort par acte (code : CS_03 et 2 signes garantis en acte 1 ; acte 3 : attaque imposée après 10 min si moins de 2 tentatives, 19.5)
- J13 : [ ] bascule Restricted / Moderate sans erreur (code : `GoreConfig.Profile`) · [ ] limites fixes respectées (11.3 : aucun organe, aucun gros plan, aucun ralenti, aucune torture — rien de tel n'est codé)
- J14 : [ ] les 8 panneaux lisibles avec sources (textes et sources recopiés, 19.5 C36) · [ ] déblocages corrects (code)
- J9 : [ ] une partie complète jouable sans créature, de CS_02 à l'écran de résultats (code ; plans de caméra à poser dans Studio, sinon bandes et texte seuls)

## Questions encore ouvertes (TODO(BIBLE))

**Aucune.** La bible 19.5 et 19.6 répond à C1–C43 ; le code ne contient plus aucun `TODO(BIBLE)` ni PROVISOIRE.
Les textes des verrous et les quatre interprétations ci-dessous sont validés (19.6) :
« bruit des 10 dernières secondes » (9.7) = le bruit le plus fort émis pendant ces 10 s ; « la Médecin soigne
×2 » = deux fois plus vite ; un acte ne s'achève pas avant sa durée minimale (5.1) ; « conditions d'extraction
réunies » = voie principale préparée, extraction à l'acte 4.

Interprétation nouvelle, à confirmer (non bloquante) : 19.6 (C9) ne pèse pas les photos (créature, charnier) ;
elles restent à 0 kg.

## Décisions DÉFAUT (section 0)
### DÉFAUT 2026-11-07 — relief, textures, éclairage (B1 étapes 8–10, B2 début)
- Lecture de la colonne Y du tableau 3.2 (Gabriel) : sans précision = sol au point X,Z ; « fond de gorge » = point au fond, bord autour (bord = fond + profondeur de la gorge) ; souterrain = sol de la salle. `TerrainBuilder.Measure()` : 26 lieux à ±5 studs (P07b vérifié sur le sol de la salle après `Caves`).
- Incohérence des coordonnées de la bible : P05 est à 46 studs et P05s à 59 studs de l'axe droit d'Ape Canyon (2 300, −600 → 3 000, −2 200) ; P03 est à ~200 studs du tracé de R2. DÉFAUT : la gorge passe par P05 et P05s (`ApeCanyon.via`), le fond de P03 est une cuvette (`Terrain.GorgeBasins`, 240 en haut, 60 au fond, profondeur 70).
- Routes et sentiers : profil de hauteur épinglé aux Y des lieux traversés à moins de `RoadPinRadius` (60) avec pente limitée ; les lieux sont aplanis avant (sauf fonds de gorge). Le terrain écrit descend au moins à `BedrockY` (−20, DÉFAUT) pour que les sols de grotte existent.
- Textures (13.4) : 18 images Poly Haven CC0 de `assets/terrain/` (1 024 px : couleur, normale, rugosité) envoyées par `upload_image` ; `MaterialVariant` PF_Ground, PF_LeafyGrass, PF_Grass (DÉFAUT : Forest Floor, aucune texture listée pour Grass), PF_Mud, PF_MuddyTracks (disponible, ne remplace pas Mud), PF_Rock (Rock et Basalt), PF_Sand (Brown Mud 03, teinte cendre par `SetMaterialColor`) ; `StudsPerTile` 30 (DÉFAUT). Remise en place : `tools/studio/ApplyTerrainMaterials.luau` (identifiants dedans).
- Éclairage (12.1, 12.2) : `tools/studio/ApplyLighting.luau` pose, depuis `AmbienceConfig`, le moment « Arrivée », `ColorCorrection`, `Bloom` et l'`Atmosphere` de forêt. `Lighting.Technology = Future` ne se règle pas par script de plugin : à poser dans les propriétés de Lighting (Gabriel) — à noter dans la liste de fin de phase.
- Synchro Studio : Rojo ne poussait rien malgré le patch accepté ; repli par `multi_edit` (fichiers modifiés seulement) décidé par Gabriel le 2026-11-07. Le dépôt reste la référence ; `TerrainBuilder` de la fenêtre contient encore `buildRoadsOld` et `buildGorgesOld` (anciennes versions inutilisées).

### DÉFAUT 2026-11-07 — Ape Cave creusée en voxels (réponse de Gabriel)
- `TerrainBuilder.Caves()` (appelée par `Build()` après l'écriture du terrain, relançable seule) creuse P21 → P07b → P07a → P07c selon `MapConfig.ApeCave` : sols aux Y du tableau 3.2 (P21 85, P07b 30, P07a 5, P07c 20 ; pentes 6,7 % / 3,1 % / 1,2 %, aucune contradiction), arche à sol plat de 30 de haut et 36 de large (partie basse), 13 de large et accidentée (partie haute, P21 → P07b), 3 éboulements de 4 studs (le saut du jeu n'est pas réglé : défaut Roblox 7,2 studs), salle P07b de rayon 45, puits P21 vertical de rayon 15 (descente à la corde `ITM_Rope`), bouchon de sédiments (`Mud`, 12 studs) au bout vers P07c, tranchée d'entrée à P07a montant de 35 % vers la piste RD2 (DÉFAUT : direction P10) jusqu'à la surface. Profondeur 55 studs sous la surface en P07a et P21. Les modèles scannés `Cave_LavaTube_A/B` serviront seulement d'habillage en B3, licence validée d'abord.
- Limite : la sortie derrière le bouchon (P07c, extraction E4) n'est pas creusée ; l'extraction se déclenche par script (bible 3.3), à confirmer en test.

### DÉFAUT 2026-11-07 — objets au sol (réponse de Gabriel, remplace le TODO(BIBLE) sur les `GroundItem`)
- Plus de Part `GroundItem` posées à la main. `ItemSpawnService` génère branches et pierres au lancement de la partie (graine de la partie), par blocs de 512 studs comme la végétation ; pas de réapparition. Valeurs dans `MapConfig.GroundItems` : `ITM_Branch` 10 par bloc en forêt ancienne et mixte, 2 par bloc dans P08, jamais à moins de 4 studs d'un tronc (4 = DÉFAUT) ; `ITM_Stone` 6 par bloc sauf eau et routes ; garanti à moins de 20 studs de P05c, P09 et P17 : 3 branches et 6 pierres.
- Limites DÉFAUT : « routes » = matériau `Asphalt` seulement (gravier et sentiers partagent leur matériau avec le lahar et le sol de forêt) ; « forêt » = matériaux `LeafyGrass`, `Grass`, `Ground` de `MapConfig.Biomes` ; « cabane P05 » = P05c. Coût : jusqu'à ~5 000 objets au sol créés au lancement, à mesurer en J15 (budget mobile, section 17).


Lancement et données (A1) :
- Carte de hachage MemoryStore « Launch » ; 3 essais de téléportation à 5 s ; file rapide et code limités au serveur du lobby ; seul le groupe privé a un code ; demande ignorée si le joueur a déjà un groupe ; le plus ancien membre remplace le créateur ; `MSG_Countdown` envoyé une fois au début ; partie de test sans configuration dans Studio (Normal, aléatoire, S1, rôles dans l'ordre) ; `{player}` = `DisplayName` ; état du groupe en attributs ; verrou dans les métadonnées DataStore ; graine tirée au départ du groupe ; résultats dans les données de téléportation (affichage seulement) ; limite 16.3 par joueur et par remote.

Interfaces (A2) :
- Positions, tailles, `DisplayOrder` (notifications 50, cinématiques 60, réglages 70, chargement 100) ; couleur « Hurt » = rouge à moitié transparent ; menus cachés au départ ; éléments décoratifs ajoutés (titres « Difficulté », « Météo », nom de l'arme, étiquettes des réglages) ; pages et lignes de `SettingsGui` ; cartes et tenues en `TextButton` ; grille des rôles défilante ; lignes de listes à hauteur calculée depuis la largeur ; boutons mobiles au-dessus du saut ; bandes 2.35:1 calculées pour un écran 16:9 ; `PingMarker` et `NameTag` ; libellés courts hors 15.6 : « Groupe », « Petite », « Grande », et les invites (« Ramasser », « Relever », « Barricader », « Réparer », « Changer la roue », « Appeler », « Conduire », « Dégager le bouchon », « Ouvrir »).

Joueur, objets, armes (A3) :
- `TabletService` ajouté (16.2 ne nomme pas le service de `RE_TabletAction`) ; `ClientBootstrap` charge les contrôleurs ; état partagé dans `ReplicatedStorage/MatchState` (attributs : journal, preuves, repères, couche tunnels, carnet).
- Numéros d'emplacement : 1..N rapides, N+1.. sac ; `RE_UseItem(0)` = capacité du rôle.
- Inventaire publié en attribut JSON `inventory` ; munitions de réserve rangées en objets `AMMO_<arme>` (pile de 99) ; preuves = objets `EVD_*` et `ITM_SDCard`.
- Objet lourd porté = mains prises, même s'il n'est pas sélectionné ; il reste en main.
- Lampe torche et lampe puissante : allumées seulement en main ; frontale : partout.
- Fusée posée aux pieds ; feu de camp posé devant le joueur ; lancer dans la direction du personnage.
- Pluie : le facteur 0,6 est appliqué une seule fois, par la perception (12.3 et 9.4 décrivent le même effet).
- Tirage des indices : les 4 documents tirés reçoivent chacun un point compatible distinct, les 2 autres points sont pris parmi C09–C12 ; appareil photo de C03–C06 posé sur un de ces points s'il est tiré.
- Points de départ alignés d'ouest en est ; `Workspace/SpawnPoints` et `Workspace/CluePoints` (Part nommées comme les codes) remplacent les coordonnées si Gabriel en pose.
- Touches : Maj courir, C accroupi, X couché, Q/E se pencher (= A/E en AZERTY, 7.2), T lampe, R recharger, Tab tablette, G signaler, B sac, V capacité, F interagir, 1–4 emplacements ; manette : L3, B, R2, L2, Y, X.
- Durée de maintien propre au joueur : attribut `hold_<UserId>` sur l'invite, vérifié par le serveur (marge 0,3 s).
- Personnage absent : mannequin Roblox neutre (`HumanoidDescription` vide) nommé `MANQUANT_CHR_<ROLE>_Skin_<n>`.
- Tablette : « sommet » de P11 / P23 = dans le rayon et au niveau de la cabine ; le Géologue est le seul à voir son point dans les tunnels.
- Valeurs d'affichage et techniques regroupées dans `PlayerConfig.Interface`, `PlayerConfig.Technical`, `PlayerConfig.Keys`, `ItemConfig` (bloc gris, placement, visuels du feu).

Actes, extractions, lobby (A4) :
- Une extraction termine la partie pour tout le monde : les joueurs dans la zone sont extraits, les autres restent (disparus ou morts) ; tous morts → fin immédiate (Silence).
- Zones d'extraction : E1 = rayon de P01 (60) ; E2 = aire de 60 × 60 ; E3 = portée d'interaction du bulldozer à l'arrivée ; E4 = portée d'interaction de la sortie P07c.
- E2 : les objets demandés peuvent être portés par le joueur ou par un coéquipier tout près ; ils sont consommés à la réparation. L'appel ne se fait qu'à l'acte 4.
- Ancres d'interaction : Part de `Workspace/Places` (`E1_Van`, `E2_Radio`, `E3_Bulldozer`, `E4_Plug`, `P05c/Door`, `Window`, `RoofHole`) si posées à la main, sinon ancres invisibles aux coordonnées de la bible ; une planche par ouverture.
- La Mécanicienne répare ×2 plus vite sur E2 et E3 (7.7) ; 10 s pour la roue (5.2) ; sans caisse à outils, ×2 plus long (8.1).
- XP : partie jouée 50 pour tous, survie 200 pour les extraits, preuves selon 8.4 ; fins, Cauchemar débloqué et pages du carnet enregistrés pour tous les participants.
- Lobby : `PartyFrame` visible dès l'arrivée ; grille des rôles ouverte à l'entrée dans un groupe, fermée par Confirmer ; armes et votes visibles ensuite ; nombre de votes affiché dans le texte des boutons (« Normal (2) ») ; disposition : armes en haut à gauche, votes en bas à gauche.
- Cauchemar : seul un joueur qui l'a débloqué peut voter pour.
- CS_00 joue tant que le joueur n'a joué aucune partie (`plays = 0`) ; compteurs `xp`, `plays`, `survivals`, `nightmareUnlocked` publiés en attributs.
- Formats : heure « 19 h 00 », XP « +250 XP », preuve « A · Carte mémoire · Theo » ; statuts « Extrait », « Mort », « Disparu » (5.1).

IA (A5) :
- Scores des comportements (`baseScore`) : la bible donne les conditions, pas les valeurs ; score = `baseScore` quand la condition est pleinement remplie (à régler en B3). Retreat, Siege, Guard et Avoid interrompent le comportement en cours.
- Famille au départ au repaire (P07a ; femelle en P07b) ; éclaireurs : jamais dans les tunnels.
- Un bruit entendu fait tourner la tête (vigilance ≥ 0,3) ; un coup de feu → 1,0 (9.4) ; l'odorat donne la position (≥ 0,7).
- « À découvert » (7.6) = P02, P06, P08, P12 ; ailleurs, forêt.
- Les coefficients météo de 7.6 (visibilité du joueur) et de 9.4 (portée) sont appliqués tous les deux, comme écrits.
- Échelle 9.6 : un cran par activation de BHV_Intimidate ; plus de 5 min après le cran précédent, l'échelle repart du bas ; fausse charge 60 % sans lampe, sinon vraie charge.
- Lisibilité : au-delà de 2 créatures visibles, les plus lointaines reculent brièvement.
- Pisteur : direction de la créature la plus proche en attribut `trackerDirection` (degrés depuis le nord) ; Opératrice : `mimicDirection` (pas d'élément d'UI prévu en 15 pour les afficher).
- Empreintes : plaques grises (décalque à créer), une tous les 6 studs, retirées après 300 s.
- Simulation à distance : déplacement en ligne sur le graphe ; le corps réapparaît quand aucun joueur ne regarde le point.

Gore, lobby, réglages (A6) :
- `GoreService` ajouté (16.2 ne nomme pas de service pour le gore) ; corps des géologues : enfants « Restricted » et « Moderate » des modèles `Body_*`, posés dans Studio ; flaques et taches en plaques rouge sombre tant que `Decal_Blood_Pool` manque.
- En Moderate, pas de mise à mort : BHV_Drag emporte le joueur à terre (11.2).
- Invites du lobby : `LobbyPrompts` (ajouté) ; ancres taguées `RangerHollis`, `MuseumPanel` (attribut `panelId`), `SkinShop`, `RecordsBoard`, `EvidenceBoard`, sinon ancres invisibles aux positions 4.1 ; libellés « Tenues », « Records », « Preuves » ; les fenêtres se ferment en s'éloignant.
- Records « du serveur » = joueurs présents sur ce serveur du lobby, une ligne par joueur.
- Réglages : touche P ; option choisie marquée « • » dans son texte ; valeur des curseurs dans `Value` ; seules les valeurs changées sont enregistrées ; volumes appliqués aux `SoundGroup` nommés Ambience, Voice, Music, Effects (à créer dans Studio).
- Données publiées en attributs JSON pour l'interface : `settingsJson`, `evidenceJson`, `notebookPagesJson`, `museumReadJson`, `skinsJson`, `equippedJson`, `endingsJson`.

Terrain (A7) :
- Colline gaussienne : `exp(−(dx² / rx² + dz² / rz²))`, rayon de l'ancre = écart de la gaussienne ; crêtes = ancres dont le nom contient « Crête ».
- Maille de calcul 8 studs, écriture par blocs de 256 studs ; F01 = marche de 40 sur la bande juste au sud de Z = −800 ; lieux souterrains (P07b) non aplanis.
- Végétation : un seul biome par bloc de 512 studs (celui du centre) ; modèles cherchés par préfixe (`Tree_DouglasFir` → `Tree_DouglasFir_A`…).

Bible 19.5 et 15.7 (2026-11-05) :
- C21, C27 : les rafales gardent la direction du vent (l'odorat ne lit que la direction) → valeurs d'ambiance :
  cycle de la pluie 12 s, rafale 1 s, rafales de neige toutes les 8 à 15 s.
- C22 : `RadioGui/Talking` reste caché tant que le chat vocal (19.4) n'est pas décidé. C28 : arbres à pierres =
  Part taguées `StoneTree` posées en B1. C37 : sensibilité 0,1 à 3. C39 : flaque 4 / tache 1,5 studs (visuel).
  C41 : réservoir Swift à Y = 40 (décor).
- C6 : Porter / Poser sur une touche à part (G, manette Y) pour ne pas se confondre avec Relever (F) ;
  sur écran tactile, un appui bref sur l'invite passe à l'invite suivante ; joueur porté soudé sur l'épaule
  (décalage 0 ; 1,5 ; 0,5), sans masse ni collision ; invites « Porter », « Poser », « Descendre » (mots de 19.5 et 8.1).
- C7 : service à part `HiddenClueService` ; découverte quand la Descendante passe à 8 studs ; Part
  `CrawlSpace` (sous P05c) et `Ford` (gué) posées à la main, sinon le point de la marque ; le gué réduit
  seulement les bruits de pas et de saut ; HC2 s'ouvre avec l'invite « Ouvrir » ; descente du puits P21
  avec une corde (8.1) ou l'anneau.
- C10 : lancer joueur = simulation balistique avec la gravité du moteur, direction de la caméra ; la portée
  horizontale est bornée à 60 studs. Pierres : erreur tirée dans un disque de rayon 3 % de la distance.
- C12 : `magazine` (1 fusée chargée) et `startReserve` (2) dans `WeaponConfig` ; munition `AMMO_WPN_FlareGun`
  nommée « Fusées ».
- C19 : « Fouiller le camp » est fait quand le camp est atteint et qu'un indice ou la tablette y est trouvé ;
  « Barricader » passe à « Tenir » quand les 3 ouvertures sont clouées ou que le siège commence ; objets de
  l'acte 3 comptés dès qu'un joueur du groupe les porte ; la ligne facultative E4 s'affiche sous l'objectif.
- C20 : impacts cosmétiques sur le toit quand aucune ouverture n'est clouée ; essais de bras seulement de 3:20 à 5:00.
- C23 : CS_05 dans la page Journal de la tablette (Title = horodatage, Body = réplique puis texte d'écran).
- C24 : le message radio passe par `NotificationGui` (clé = identifiant de la cinématique).
- C38 : champs de données `evidenceBOut`, `accessories`, `equippedAccessories` ; `RE_EquipSkin(rôle, accessoire)`
  porte ou retire ; textes des verrous sur le modèle de 15.7 (« Verrouillé — 3 parties jouées »,
  « Verrouillé — 10 parties jouées », « Verrouillé — 1 preuve de classe B », Cauchemar « Verrouillé — 1 survie »).
- J12 : toutes les créatures (sauf la femelle) attaquent leur meilleure cible tant que l'acte 3 a passé
  10 min avec moins de 2 tentatives, dans les limites de `AllowAttack`.
- 15.7 : zones sûres de référence 1280 × 662 et 750 × 311 ; `Util.prepareGui` choisit la disposition et
  lie chaque `Veil` aux fenêtres de son attribut `veilFor` ; ordre de priorité des boutons tactiles
  (Utiliser, Tirer, Viser, Recharger, Courir, Accroupi, Couché, Pencher ×2 si accroupi, Lampe, Tablette,
  Signaler), tous cachés quand le sac, la tablette ou un document est ouvert ; toucher l'emplacement déjà
  choisi ouvre le sac ; `NotificationGui` propre à chaque place, 2 messages au plus ; sous-titres longs
  montrés phrase par phrase ; disposition du lobby sur téléphone : armes et votes à gauche, groupe à droite,
  notifications en bas à gauche.
- `check_ui.py` : barre de Roblox 58 px, encoche 47 px, barre d'accueil 21 px (téléphone en paysage) ;
  polices de mesure dans `tools/ui/fonts` (Apache 2.0, OFL 1.1 ; outil seulement).
- `Shared/TaggedSet` (budget 17) : listes taguées et RaycastParams mis à jour par les signaux de tag.

Bible 19.6 (2026-11-05, soir) :
- C1 : « voir » = cible devant le joueur (demi-espace de son regard) et rayon libre depuis sa tête ; les
  feuillages `Foliage` ne cachent pas (comme pour la vue de la créature) ; RaycastParams par personnage.
- C3 : un coup de pierre ou un tir allié laisse au moins un pas de calcul (0,5 s) au compte à rebours ; la
  brûlure du lance-fusées fait partie du tir allié et ne retire rien de plus.
- C11 : déclenchement à 4 studs ; le poseur ne déclenche pas son propre piège ; bruit réémis toutes les 0,5 s
  pendant 3 s ; piège en bloc gris (`MANQUANT_NoiseTrap`).
- C17 : branches et pierres au sol = Part taguées `GroundItem` (attribut `itemId`) posées en B1, une unité par Part.
- C26 : l'attaque est autorisée pour les joueurs dans le rayon de P01 après le démarrage (`vanStartedAt`),
  malgré une pause du directeur.
- C32 : un événement hors catalogue « bas » avec des lieux est tenté quand le joueur y est ; sans lieu, une
  fois par acte ; EVT_08 par BHV_Mimic ; cadences de 10.1 respectées.
- C43 : « Équiper » sur le bonnet passe à la couleur suivante, puis le retire.
- `.claude/settings.json` : clés `advisorModel`, `effortLevel`, `workflowSizeGuideline` écrites comme demandé
  (non vérifiées dans la documentation de Claude Code) ; les refus de push forcé à joker au milieu peuvent ne
  pas s'appliquer : les formes en préfixe sont celles qui comptent.
- Remise à zéro : outils en lecture seule ; objets créés par le moteur ignorés par `reset_diff.py` (liste
  `ENGINE_DEFAULTS`), contenu des phases B listé à part (`STUDIO_OWNED`).

## Assets MANQUANT_

Aucun bloc `MANQUANT_<ID>` n'est posé à la main ; les scripts en créent quand le modèle manque :
- `MANQUANT_CHR_<ROLE>_Skin_<n>` (mannequin) par `CharacterService` ;
- `MANQUANT_Item_<Nom>` (bloc gris 1 × 1 × 1) par `ItemSpawnService` pour chaque objet du monde.

| ID (13.3) | Contenu | Utilisé par |
|---|---|---|
| `CHR_<ROLE>_Skin_A–C` | 10 humains réalistes avec squelette, découpés en 6 | `CharacterService`, `RoleSelectGui/Portrait` |
| `WPN_Revolver`, `WPN_Shotgun`, `WPN_FlareGun`, `MEL_Axe`, `MEL_Machete` | Armes | `ItemSpawnService` |
| `Item_Tablet`, `Item_Camcorder`, `Item_Jerrycan`, `Item_CarBattery`, `Item_Jack`, `Item_ToolBox`, `Item_BearSpray`, `Item_Headlamp`, `Item_Flare`, `Item_Bandage`, `Item_Medkit` | Objets | `ItemSpawnService` |

Ajoutés le 2026-11-05 : marques de mineurs `MANQUANT_HiddenMark` (décalque, C7) ; modèles des accessoires
(bonnet en 3 couleurs #7A2E24, #4F6B45, #3A3A3A, frontale ambre, sac « Cold Trail », C38, C43) ;
piège à bruit `MANQUANT_NoiseTrap` (C11) ; branches et pierres au sol à poser (`GroundItem`, C17).

Images et sons : `assets/ui/png` (vignettage, icônes d'objets, 12 icônes `Icon_Ctrl_*`, `Icon_Stamina`,
`Icon_Battery`, 6 silhouettes `Img_Body_*`) à importer dans Studio ; `Img_TabletMap`,
couche tunnels, `Img_DOC06`, `Img_DOC16`, `Img_Museum_M1–M8`, `Img_News_CS14` à créer (13.5) ;
tous les sons de 13.7 à fournir.
