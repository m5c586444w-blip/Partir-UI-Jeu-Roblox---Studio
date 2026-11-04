# SUIVI — PISTE FROIDE

Tenu par les deux sessions (cloud et Studio), section 18.1 ter. Chaque session ajoute une
entrée au journal : date, ce qui est fait, ce qui reste ouvert.

Règle de la section 0 : une question qui ne touche ni un texte affiché aux joueurs, ni une
valeur de gameplay, ni un asset est tranchée par Claude Code et marquée **DÉFAUT**. Les autres
restent des `TODO(BIBLE)`. Une valeur marquée **PROVISOIRE** est une valeur de gameplay mise
seulement pour que le code tourne : elle attend la bible.

## État de reprise (à lire en premier)

- Session cloud du 2026-11-04 (3) : Gabriel a demandé d'enchaîner A3 → A8 sans s'arrêter.
- Phases terminées dans cette session : **A3, A4, A5, A6**. En cours : A7. Reste : A8.
- Outils de relecture de fin de phase : `stylua --check src`, `selene src`,
  `python3 tools/check_values.py` (0 nombre hors Config), `python3 tools/ui/check_ui.py`,
  puis `rojo build` des deux places.

## Journal des sessions

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
| A7 | Cloud | J2 (préparation) | Script `TerrainBuilder` complet, téléchargement des textures Poly Haven | En cours |
| A8 | Cloud | — | `rojo build` des deux places, liste de ce qui reste à faire dans Studio | À faire |
| B1 | Studio | J2, J3 | Lancer `TerrainBuilder`, vérifier les positions, poser la végétation | À faire |
| B2 | Studio | J4 | Lumière, brouillard, météo, sons : réglage à l'œil, captures | À faire |
| B3 | Studio | J0, J15 | Import des modèles 3D et animations, tests en jeu, mobile, équilibrage | À faire |

## Critères d'acceptation (18.2)

En phase A rien ne se teste en jeu : « code » = écrit et relu, pas vérifié dans Roblox.

- J1 : [ ] groupe de 2 part et revient (code) · [ ] données sauvegardées (code) · [ ] zéro erreur console (non vérifiable ; zéro erreur de syntaxe)
- J5 : [x] aucun `Instance.new` d'UI · [ ] affichage correct PC et mobile (à vérifier dans l'émulateur)
- J6 : [ ] chaque valeur de la section 7 vérifiable dans `CreatureDebug` ou la console — les valeurs sont toutes dans `PlayerConfig` et lisibles en attributs du joueur ; `CreatureDebug` vient en A5
- J7 : [ ] 6 indices sur 12 tirés (code) · [ ] graine affichée (code : console de `ItemSpawnService`) · [ ] preuves sauvegardées après extraction (code : `EvidenceService:CommitForSurvivor`, appelé par l'extraction en A4)
- J8 : [ ] tir impossible sans munitions (code) · [ ] cadence respectée (code) · [ ] tir allié seulement en Difficile et Cauchemar (code)
- J10 : [ ] elle suit un joueur bruyant (code : ouïe + cible) · [ ] perd un joueur couché dans les fougères (code : visibilité ×0,1, invisible au-delà de 10 studs) · [ ] grimpe par les `ClimbPoint` (non fait : escalade à brancher quand les falaises et les points existeront, phase B1)
- J11 : [ ] chaque comportement observé au moins une fois en test (16 comportements écrits) · [ ] aucune attaque sans signal (code : chaque ATK_ attend son signal)
- J12 : [ ] aucun mort en acte 1 hors exceptions (code : `TensionDirector:AllowAttack`) · [ ] au moins un temps fort par acte (code partiel : CS_03 et 2 signes garantis en acte 1 ; acte 3 « au moins 2 tentatives » compté mais pas forcé)
- J13 : [ ] bascule Restricted / Moderate sans erreur (code : `GoreConfig.Profile`) · [ ] limites fixes respectées (11.3 : aucun organe, aucun gros plan, aucun ralenti, aucune torture — rien de tel n'est codé)
- J14 : [ ] les 8 panneaux lisibles avec sources (textes recopiés ; adresses sources manquantes, C36) · [ ] déblocages corrects (code)
- J9 : [ ] une partie complète jouable sans créature, de CS_02 à l'écran de résultats (code ; plans de caméra à poser dans Studio, sinon bandes et texte seuls)

## Questions encore ouvertes (TODO(BIBLE))

Chaque ligne correspond à un marqueur `TODO(BIBLE)` dans le code. Rien ne bloque la suite des
phases A ; ces points bloquent le réglage final.

| # | Question | Où | En attendant |
|---|---|---|---|
| C1 | Distance à laquelle un joueur « voit » un corps (+15 peur) et la créature (+20 à +35). | `PlayerConfig.Fear` | Hausses non appliquées |
| C2 | Qu'est-ce qui déclenche une hémorragie légère ou grave (seuil de dégâts, attaque) ? | `PlayerConfig.BleedOnDamage` | Seules les attaques qui le précisent font saigner |
| C3 | Un coup reçu à terre tue-t-il ? | `PlayerConfig.Technical.DownedDamageKills` | PROVISOIRE : oui |
| C4 | Sur quel membre agissent le bandage et la trousse ? | `PlayerConfig.HealTarget` | PROVISOIRE : le plus abîmé |
| C5 | Sang rendu au joueur relevé après être tombé faute de sang. | `PlayerConfig.ReviveBlood` | PROVISOIRE : 20 |
| C6 | Porter un blessé : comment le prendre et le poser (7.2, 7.7) ? | — | Non fait (vitesses prêtes dans `PlayerConfig`) |
| C7 | Quels indices sont « cachés » (visibles par la Descendante à 8 studs) ? | — | Non fait |
| C8 | Nombre de fusées à main du Pyrotechnicien au départ. | `ItemConfig.StartingItems` | PROVISOIRE : 1 |
| C9 | Poids des preuves et des munitions. | `ItemConfig.Items` | PROVISOIRE : 0 kg |
| C10 | Distance et vitesse d'un lancer (pierre, branche). | `ItemConfig.Throw` | PROVISOIRE : 40 studs/s, 1 s |
| C11 | Bruit du piège à bruit du Pyrotechnicien. | `ItemConfig.NoiseTrapRadius` | Piège désactivé |
| C12 | Munitions au départ (chargeur plein ? réserve ?). | `InventoryService` | PROVISOIRE : chargeur plein, réserve 0 |
| C13 | Fusil à pompe : forme de la baisse entre 15 et 40 studs, portée au-delà, écart des plombs. | `WeaponConfig` | PROVISOIRE : linéaire, plombs dans l'axe |
| C14 | Pistolet lance-fusées : cadence et brûlure sur un coéquipier ; munitions de réserve. | `WeaponConfig` | Cadence = rechargement (2 s) |
| C15 | Qui porte la machette au départ, ou où est-elle ? | `WeaponConfig` | Personne |
| C16 | Portée des armes de mêlée. | `WeaponConfig.MeleeRange` | PROVISOIRE : 7 (portée du coup de la créature) |
| C17 | Quantité de chaque objet sur C09–C12 et aux lieux fixes de 8.1. | `MapConfig` | PROVISOIRE : 1 |
| C18 | 12.3 « endurance ×0,85 » par neige : sur le maximum, la dépense ou la récupération ? | `StaminaService` | PROVISOIRE : récupération |
| C19 | Textes d'objectif des actes 3 et 4 pour E1, E3, E4 (CS_07 ne donne que l'exemple de E2). | `ActConfig.Objectives` | Vides |
| C20 | Cadence des pierres pendant le siège. | `ActConfig.Siege.StoneInterval` | Réglée avec l'IA (A5) |
| C21 | Période du cycle en sinus des rafales de pluie ; intervalle des rafales de neige. | `AmbienceConfig` | — |
| C22 | Ce qui allume l'indicateur `RadioGui/Talking` (dépend du chat vocal, 19.4). | `RadioController` | Caché |
| C23 | CS_05 dure 25 s, mais « en partie, elles durent 12 s au plus » (6) : exception pour la vidéo ? | `CinematicConfig` | 25 s |
| C24 | Texte du « message radio » entendu hors du rayon d'une cinématique de lieu (6.1). | `CinematicConfig` | Rien |
| C25 | Textes de fin pour `ResultsGui > EndingText` (seul Silence en a un). | `LoreConfig.Endings` | Vides |
| C26 | Rayon du bruit du démarrage du van (E1, « démarrage bruyant »). | `ActConfig.Routes.E1` | Pas de bruit |
| C27 | Durée d'une rafale de vent. | `AmbienceConfig.GustDuration` | PROVISOIRE : 1 s |
| C28 | Position des 3 « arbres à pierres » fixes (9.1). | `CreatureConfig.StoneTreeTag` | Part taguées `StoneTree` à poser |
| C29 | « Hors combat » (régénération) : combien de secondes sans dégâts ? | `CreatureConfig.OutOfCombatAfter` | PROVISOIRE : 10 s |
| C30 | Vitesse d'une pierre lancée, force du recul de ATK_Strike. | `CreatureConfig` | PROVISOIRE : 80 studs/s, 40 |
| C31 | « Lance plus » après 2 tirs reçus (9.8) : de combien ? | `CreatureConfig.Memory.ThrowMoreFactor` | PROVISOIRE : ×1,5 |
| C32 | Catalogue « bas » du directeur (10) : quels événements ? | `DirectorConfig.LowCatalog` | PROVISOIRE : tous |
| C33 | Distances « au loin » et « tout près » des événements. | `DirectorConfig` | PROVISOIRE : 150 et 15 studs |
| C34 | Cadence des pierres du siège (= C20). | `ActConfig.Siege.StoneInterval` | PROVISOIRE : 4 s par créature |
| C35 | **19.4 bloquant** : profil publié, Restricted (18+ vérifié) ou Moderate ? | `GoreConfig.Profile` | PROVISOIRE : Moderate |
| C36 | Adresse « Source » de chaque panneau du musée (4.3). | `LoreConfig.Museum` | Vides |
| C37 | Plage de la sensibilité (17.2 : « — »). | `ProgressionConfig.Settings.Sensitivity` | PROVISOIRE : 0,1 à 3 |
| C38 | Déblocage des accessoires (bonnet, frontale colorée, sac, 7.1). | `ProgressionConfig.SkinUnlocks` | Non fait |
| C39 | Taille d'une flaque et d'une petite tache de sang. | `GoreConfig.PoolSize` | PROVISOIRE : 4 et 1,5 studs |

Interprétations à confirmer (non bloquantes) : « bruit des 10 dernières secondes » (9.7) = le
bruit le plus fort émis pendant ces 10 s ; « la Médecin soigne ×2 » = deux fois plus vite ;
un acte ne s'achève pas avant sa durée minimale même si sa condition est remplie (5.1) ;
« conditions d'extraction réunies » (fin de l'acte 3) = la voie principale est préparée
(roue changée, radio réparée, bulldozer réparé) ; l'extraction se déclenche à l'acte 4.

## Décisions DÉFAUT (section 0)

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

## Assets MANQUANT_

Aucun bloc `MANQUANT_<ID>` n'est posé à la main ; les scripts en créent quand le modèle manque :
- `MANQUANT_CHR_<ROLE>_Skin_<n>` (mannequin) par `CharacterService` ;
- `MANQUANT_Item_<Nom>` (bloc gris 1 × 1 × 1) par `ItemSpawnService` pour chaque objet du monde.

| ID (13.3) | Contenu | Utilisé par |
|---|---|---|
| `CHR_<ROLE>_Skin_A–C` | 10 humains réalistes avec squelette, découpés en 6 | `CharacterService`, `RoleSelectGui/Portrait` |
| `WPN_Revolver`, `WPN_Shotgun`, `WPN_FlareGun`, `MEL_Axe`, `MEL_Machete` | Armes | `ItemSpawnService` |
| `Item_Tablet`, `Item_Camcorder`, `Item_Jerrycan`, `Item_CarBattery`, `Item_Jack`, `Item_ToolBox`, `Item_BearSpray`, `Item_Headlamp`, `Item_Flare`, `Item_Bandage`, `Item_Medkit` | Objets | `ItemSpawnService` |

Images et sons : `assets/ui/png` (vignettage, icônes) à importer dans Studio ; `Img_TabletMap`,
couche tunnels, `Img_DOC06`, `Img_DOC16`, `Img_Museum_M1–M8`, `Img_News_CS14` à créer (13.5) ;
tous les sons de 13.7 à fournir.
