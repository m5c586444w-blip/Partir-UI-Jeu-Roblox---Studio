## 16. Architecture des scripts

L'expérience a deux places : **Lobby** (place de départ) et **Partie**. Le serveur fait autorité sur tout ce qui compte ; le client affiche et envoie des intentions. Toute valeur réglable vit dans `ReplicatedStorage/Config`, commentée en français.

### 16.1 Arborescence

```
ReplicatedStorage/
  Config/       PlayerConfig, ItemConfig, WeaponConfig, CreatureConfig, DirectorConfig,
                ActConfig, MapConfig, AmbienceConfig, GoreConfig, AudioConfig,
                LoreConfig (textes DOC_xx, M1-M8, dialogues), CinematicConfig, ProgressionConfig, LaunchConfig (groupe, lancement, MemoryStore)
  Shared/       Types, Util, Signal, RateLimiter, NoiseTypes, Version
  Remotes/      (RemoteEvents et RemoteFunctions de 16.3)
  Animations/   Player/, Creature/   (objets Animation, section 14)
  Characters/   <ROLE>/Skin_A..C
  Items/        modèles d'objets
  UITemplates/  BillboardGui de ping, noms
ServerStorage/
  Creatures/    CRT_Alpha, CRT_Scout, CRT_Female, Juvenile_Bones
  Props/        StickStructure, StonePile, SnappedTree, ElkRemains...
ServerScriptService/
  Bootstrap     (Script : charge les services dans l'ordre)
  Services/     (16.2)
  AI/           TensionDirector, FamilyBrain, CreatureBrain, Perception, NavGraph,
                Behaviors/ (un module par BHV_), Attacks/ (un module par ATK_),
                CreatureAnimator, MimicService, EventDirector, CreatureDebug
StarterPlayer/StarterPlayerScripts/
  Controllers/  (16.2)
StarterGui/     (section 15)
Workspace/
  Terrain, Vegetation/Chunk_X_Z, Places/Pxx_<Nom>, SpawnPoints/, ClimbPoints/,
  CluePoints/, Cinematics/, Navigation/ (nœuds CreatureNav)
```

Les modules partagés (`Config`, `Shared`) sont identiques dans les deux places. `Shared/Version` porte un numéro ; le Lobby l'envoie avec la configuration de partie ; la Partie la compare à la sienne et, si elles diffèrent, renvoie le groupe au Lobby avec MSG\_VersionMismatch.

### 16.2 Services et contrôleurs

| Place | Côté | Module | Rôle |
| --- | --- | --- | --- |
| Les deux | Serveur | `DataService` | DataStore, verrouillage de session, sauvegarde toutes les 120 s et à la fermeture |
| Lobby | Serveur | `PartyService`, `MatchmakingService` | Groupes, codes, file rapide (MemoryStore) |
| Lobby | Serveur | `RoleService`, `WeaponBoardService`, `VoteService` | Rôles uniques, armes, votes |
| Lobby | Serveur | `LaunchService` | Écrit la configuration de partie dans MemoryStore, réserve le serveur, téléporte |
| Lobby | Serveur | `DialogueService`, `MuseumService`, `SkinService`, `RecordsService` | PNJ, musée, skins, records |
| Partie | Serveur | `PartyLoaderService` | Lit la configuration, attend les joueurs (60 s max) |
| Partie | Serveur | `GameStateService` | Actes, horloge, voie d'extraction, fins, fin à 06 h 00 |
| Partie | Serveur | `SpawnService`, `CharacterService` | Départs S1–S3, skins, 6 membres |
| Partie | Serveur | `HealthService`, `FearService`, `StaminaService` | Membres, sang, à terre, mort, peur, endurance |
| Partie | Serveur | `NoiseService` | Reçoit tous les bruits (section 7, 8) et les diffuse à la perception |
| Partie | Serveur | `InventoryService`, `ItemSpawnService`, `InteractionService` | Inventaire, tirages C/K/A/J/R, `ProximityPrompt` (réparations, barricades, soins) |
| Partie | Serveur | `WeaponService` | Validation des tirs, dégâts, tir allié |
| Partie | Serveur | `EvidenceService`, `DocumentService` | Preuves A/B/C, documents |
| Partie | Serveur | `ExtractionService` | E1–E4 |
| Partie | Serveur | `WeatherService`, `CinematicService` | Météo, vent, déclenchement des cinématiques |
| Partie | Serveur | `ReturnService` | Téléportation vers le Lobby avec les résultats |
| Partie | Client | `InputController` | Clavier, manette, `MobileControlsGui` |
| Partie | Client | `CameraController`, `FootstepController`, `LightController`, `FearFXController`, `TreeWindController` | Vue, pas, lampes, effets de peur, vent dans les arbres |
| Partie | Client | `HUDController`, `InventoryController`, `ObjectiveController`, `InteractController`, `TabletController`, `DocumentController`, `DownedController`, `SpectatorController`, `RadioController` | Interfaces de la section 15.4 |
| Les deux | Client | `AmbienceController`, `CinematicController`, `SettingsController`, `NotificationController` | Lumière, sons, cinématiques, réglages |

### 16.3 Communication client ↔ serveur

Les jauges (santé par membre, sang, endurance, peur, pile, munitions) passent par des **attributs** du joueur, répliqués automatiquement. Les interactions passent par des `ProximityPrompt`, dont l'événement `Triggered` arrive déjà côté serveur. Il reste donc peu de remotes. Toutes celles du client vers le serveur sont limitées à 10 appels par seconde.

| Remote | Sens | Données | Contrôle serveur |
| --- | --- | --- | --- |
| `RE_SetStance` | C → S | debout, accroupi, couché, course | Vitesse réelle comparée à la posture |
| `RE_EquipSlot`, `RE_UseItem`, `RE_DropItem` | C → S | n° d'emplacement | Objet présent, pas en action |
| `RE_PickupItem` | C → S | id de l'objet | Distance ≤ 10 studs |
| `RE_ToggleLight` | C → S | — | Lampe équipée, pile > 0 |
| `RE_FireWeapon` | C → S | origine, direction, horodatage | Origine à moins de 5 studs de la tête, cadence, munitions |
| `RE_Reload` | C → S | — | Réserve > 0 |
| `RE_Ping` | C → S | position | 1 toutes les 2 s |
| `RE_TabletAction` | C → S | appli, action, données | Porte la tablette |
| `RE_CinematicSkipVote`, `RE_Spectate` | C → S | — / joueur suivi | — |
| `RE_Objective`, `RE_PlayCinematic`, `RE_Notify`, `RE_OpenDocument`, `RE_EndGame` | S → C | acte, texte / id / clé de texte / id / résultats | — |
| Lobby : `RE_PartyCreate`, `RE_PartyJoin`, `RE_PartyQuickJoin`, `RE_PartyLeave`, `RE_SelectRole`, `RE_TakeWeapon`, `RE_Vote`, `RE_Ready`, `RE_DialogueChoice`, `RE_EquipSkin`, `RE_MuseumRead` | C → S | selon le nom | Appartenance au groupe, unicité des rôles, déblocages |

### 16.4 Données

**DataStore `PisteFroide_v1`**, clé `player_<UserId>` :

```
{ version = 1, xp = 0, plays = 0, survivals = 0,
  endings = { Survie = false, Preuve = false, Verite = false, Ordonnance = false, Silence = false },
  evidence = { { class = "A", kind = "Video", date = 0 } },      -- 200 au plus
  skins = { Leader = { A = true, B = false, C = false }, ... },
  equipped = { Leader = "A", ... },
  notebookPages = { true, false, false },
  museumRead = { M1 = false, ... },
  nightmareUnlocked = false,
  settings = { ... } }
```

**MemoryStore :** `Parties` (carte triée, durée de vie 900 s) pour les groupes du lobby ; `Launch_<PrivateServerId>` (600 s) pour la configuration lue par la Partie (joueurs, rôles, armes, difficulté, météo, départ, graine).

La clé de lancement utilise l'identifiant du serveur réservé : le Lobby l'obtient en réservant le serveur, la Partie le lit dans `game.PrivateServerId`. Le code d'accès, lui, n'est pas lisible depuis la Partie.

**Identifiants :** expérience « PISTE FROIDE (test) », PlaceId Lobby **77677833738174**, PlaceId Partie **103506696801797** (relevés dans Studio le 22 octobre 2026 ; à reconfirmer dans le Creator Dashboard si l'expérience a été recréée). Ils vont dans `Config/LaunchConfig`.

**Valeurs techniques du lancement et de `DataService`** (verrou de session, nombre d'essais, délais) : les valeurs proposées par Claude Code en phase A1 sont acceptées telles quelles le 4 novembre 2026. Elles restent dans `Config`, commentées.

**XP :** niveau = partie entière de la racine de (XP ÷ 100). Gains : panneau de musée lu 5, partie jouée 50, survie 200, preuves selon 8.4.

### 16.5 Format d'un module de configuration

```lua
-- ReplicatedStorage/Config/MapConfig (extrait)
-- Toutes les positions viennent de la section 3 de la bible. Ne rien ajouter ici sans la bible.
local MapConfig = {}

MapConfig.Places = {
	P01 = { name = "Parking du sentier d'Ape Canyon", pos = Vector3.new(2800, 120, 3200), radius = 60 },
	P05c = { name = "Ruine de la cabane de 1924", pos = Vector3.new(2550, 300, -1300), radius = 25 },
	P11 = { name = "Tour de guet centrale", pos = Vector3.new(0, 420, -1600), radius = 15 },
}

MapConfig.Spawns = {
	S1 = Vector3.new(2780, 120, 3220),
	S2 = Vector3.new(-1380, 70, 3290),
	S3 = Vector3.new(-820, 230, 640),
}

return MapConfig
```

