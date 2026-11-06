# RESET_INVENTAIRE — contenu des places avant la remise à zéro

Rempli par la session Studio, étape 0a de `HANDOFF.md`, **avant** que Gabriel publie les places de
`builds/` en Overwrite. Rien n'est modifié dans les places pendant cet inventaire (lecture seule).
Ensuite, étape 0b : vérifier que plus rien d'ancien ne reste et noter ici ce qui a été supprimé.

Outils : `tools/studio/ResetInventory.luau` (inventaire en Markdown), `tools/studio/ResetPaths.luau`
(chemins de toutes les instances) et `python3 tools/studio/reset_diff.py <chemins.txt> Lobby|Partie`.

## Lobby — PlaceId 77677833738174

Date, version de la place : 2026-11-06, place « Place1 » (GameId 10772103184), version 10. Lecture seule, rien modifié.

Contenu (ancien projet en français, rien à conserver) :
- Workspace : `Ville` (Folder vide), `Baseplate` (+ Texture `rbxassetid://6372755229`), `SpawnLocation`, Terrain (0 cellule).
- Lighting : `Sky` (ciels `rbxassetid://6444884337`, `6444884785`, `6412503613`), `SunRays`, `Atmosphere`, `Bloom`, `DepthOfField`.
- ReplicatedStorage : `Config` (8 modules `Config*` : Places, Carte, Joueur, Armes, Creature, Actes, Ambiance, Progression), `Shared` (4 : Journal, TableRoles, Carte, DonneesPartie), `Remotes` (vide).
- ServerScriptService : `Demarrage` (Script), `Services` (GroupesService, MatchmakingService, ProgressionService, TeleportationService). 17 scripts au total.
- TextChatService : configurations par défaut (+ ImageLabel, UICorner, UIGradient, UIPadding dans `BubbleChatConfiguration`).
- Vides : MaterialService, ReplicatedFirst, ServerStorage, StarterGui, StarterPack, SoundService, Teams, Chat. Aucun package.
- **Noms de stockage (DataStore, MemoryStore) trouvés dans les scripts : aucun.** `PisteFroide_v1`, `Parties` et `Launch_*` ne sont donc pas pris par ces scripts ; la liste des DataStores reste à faire après publication et accès aux API (étape 3).

## Partie — PlaceId 103506696801797

Date, version de la place : 2026-11-06, place « Place1 » (GameId 10772103184), version 11. Lecture seule, rien modifié.

Contenu (ancien projet en français, rien à conserver) :
- Workspace : dossiers vides `Carte`, `Zones`, `EmplacementsIndices`, `Cachettes`, `Barricades`, `Escalade`, `Extractions` ; `Departs` (6 descendants) ; `Baseplate`, `SpawnLocation`, Terrain (0 cellule).
- Lighting : `Sky` (mêmes ciels que le Lobby), `SunRays`, `Atmosphere`, `Bloom`, `DepthOfField`.
- ReplicatedStorage : `Config` (8 modules), `Shared` (4), `Remotes` (vide), `EtatPartie` (vide).
- ServerScriptService : `Demarrage`, `Services` (ChargementDonnees, GameManager, DirecteurTension, SanteService, ArmesService, ObjectifsService, BruitService, GoreService, ProgressionService, `IAFamille/CerveauGroupe`). 24 scripts au total, dont le LocalScript `StarterPlayerScripts/ControleurDemarrage`.
- ServerStorage : `Personnages` (20 descendants), `Creatures` et `Gore` (vides).
- Aucun package, aucune UI, aucun son.

Noms de stockage de l'ancien projet (trouvés par `script_grep`, absents de `ResetInventory.luau` car définis dans des modules Config, pas en littéral à l'appel) — les mêmes modules `ConfigProgression` et `ConfigPlaces` existent dans le Lobby :
- DataStore `PisteFroide_Progression_v1` (`ConfigProgression.NomDataStore`).
- MemoryStore HashMap `PisteFroide_DonneesPartie` (`ConfigPlaces.NomMemoireGroupes`).
- Aucun ne coïncide avec les noms du nouveau code (`PisteFroide_v1`, `Parties`, `Launch_<PrivateServerId>`). La liste réelle des DataStores reste à faire après publication (étape 3).

## Expérience « PISTE FROIDE (test) » (Creator Dashboard, par Gabriel)

Ces éléments ne sont pas dans les fichiers de place : une publication en Overwrite ne les touche pas.

| Élément | Contenu trouvé | Décision |
| --- | --- | --- |
| Autres places de l'univers | _à remplir_ | |
| DataStores (`DataStoreService:ListDataStoresAsync`, avant tout test avec accès aux API) | _à remplir_ | |
| Badges, passes de jeu, produits développeur | _à remplir_ | |
| Paramètres de l'expérience (avatar, sécurité, accès) et collaborateurs | _à remplir_ | |
| Packages à mise à jour automatique | _à remplir_ | |

## Étape 0b — résidus après publication

| Place | Chemin | Type (script, modèle, terrain, UI, son, package, ID d'asset) | Supprimé le |
| --- | --- | --- | --- |
| | | | |
