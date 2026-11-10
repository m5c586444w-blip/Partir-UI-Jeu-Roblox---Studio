2026-11-10 : décision de Gabriel. La coordinatrice (session Claude PISTE FROIDE) décide de l'ordre des tâches et rédige les prompts. Cette session est opérateur Studio exclusif et exécute les tickets.

# État actuel (08/11/2026)
- Place Partie cloud (103506696801797) **vidée le 08/11 à la demande de Gabriel** (1 654 éléments : ancien projet scripts, StarterGui, 8 matériaux PF_, Places, terrain effacé). Garde : Workspace.Camera, Terrain (vide), Lighting.
- Le squelette du jalon 1 (22/10) n'existait plus dans la place : à reconstruire (Config, Shared, Demarrage) si on le veut.
- Un fichier local `Partie.rbxlx` (PlaceId 0) contenait la même ancienne structure : non touché.
- Collaborateur Team Create vu : TheDarkArtist02.
- Secteurs : S7 sud-est construit (terrain, ruisseau, gorge, lahar, routes, lieux, départ S1) le 08/11, test play OK, validation visuelle de Gabriel en attente (voir `secteurs/S7_SudEst.md`). Autres : aucun. Base commune (base/) : vide.
- Place Lobby : pas encore ouverte, pas inspectée.
- S7 retouché le 08/11 (vallée aval relevée, pont raccordé, parking plat, lahar global, route 100 % asphalte, rivières élargies, matériaux en mélange) ; **S4 Centre construit** (terrain, ruisseau 16-22, sentiers, camp 9 + départ S3, poste 17, forêt 4, B4/B6, blocs MANQUANT_) : voir `secteurs/S4_Centre.md`, validation visuelle de Gabriel en attente. Module partagé `MelangeMateriaux` (S1-S6).
- Prochaine étape (ancienne, S4 fait) : Gabriel valide S7 visuellement + importe les assets MANQUANT_ ; puis S4 Centre (réutiliser ServerStorage/TerrainBuilder/HauteurGlobale, même graine).

- **S3 Nord-est construit (08/11)** : terrain X 1400..4000 / Z -2500..1700 (raccords S7 et S4 sans marche), ruisseau amont + gorge d'Ape Canyon (monotone, jonction S7 identique), lahar nord, sentiers, ruine 5, mine 15 (site (3300,-75)), tour 24 ((3360,1130)), B1/B5, blocs MANQUANT_ : voir `secteurs/S3_NordEst.md`, validation visuelle en attente. **Coin nord-est de la carte (X 1500..4000, Z -4000..-2500) dans aucun secteur : non construit.** Restent S5, S6, S2, S1.

## Test matériaux (08/11)
- `generate_material` fonctionne : crée 4 variantes dans `MaterialService/AssistantMaterials/Material: <id>` (test supprimé ensuite).
- Non testé : application des textures Poly Haven (ColorMap/NormalMap sur MaterialVariant), import impossible via MCP → manuel par Gabriel.
- Piège : `execute_luau` renvoie `nil` ; les `print` vont dans la console, qui est cumulative et très longue (éviter de la relire).

## Outils installés (08/11)
- uv 0.13.7 (winget), Blender MCP (`claude mcp add --scope user blender`, addon dans Blender 5.0). **Actif après redémarrage de Claude Code** ; dans Blender : Préférences → Add-ons → activer « MCP for Blender », puis N → onglet MCP → Start MCP Server.
- Sketchfab : il faudra une clé API Sketchfab de Gabriel dans l'addon (je ne la saisis pas).
- Skills : roblox-world-level-design, roblox-playtest-qa (dans ~/.claude/skills).
- Non installés (lus, écartés) : plugin Roblox officiel (doublon), SyphoDev roblox-ai-skills.

## Texturage terrain (08/11, global à toute la carte)
- 6 matériaux générés (generate_material, IA, 4 variantes chacun) dans `MaterialService/AssistantMaterials` : PF_SousBois (LeafyGrass), PF_Prairie (Grass), PF_SolForet (Ground), PF_Boue (Mud), PF_Lahar (Pebble), PF_Roche (Rock). Les variantes `PF_X1..3` sont des alternatives.
- Appliqués par `MaterialService:SetBaseMaterialOverride(Enum.Material.X, "PF_X")` : valable pour toute la carte et les futurs secteurs, sans réécrire de voxels. Teintes ajustées par `Terrain:SetMaterialColor` (Pebble gris, Grass, LeafyGrass).
- À améliorer : Asphalt/Slate/Basalt/Sand non surchargés ; remplacer par les textures Poly Haven une fois importées ; mélange de matériaux par bruit à ajouter aux builders (S7/S4) après le sous-agent.
- Correctif : `Pebble` n'est PAS un matériau de terrain Roblox. PF_Lahar rattaché à Slate (override Slate). Constat visuel : le lahar et le sentier restent brun-rouge (probablement Ground = PF_SolForet, trop rouge) ; Asphalt (route/parking) apparaît blanc-grisâtre. À régler après le sous-agent S7/S4 : identifier le matériau réel par voxel, choisir parmi les variantes PF_X1..3, teinter.

## Textures Poly Haven appliquées (08/11, remplacent les PF_ générés par IA)
- Téléchargées (CC0, 1K, ~24 Mo) dans `assets/polyhaven/textures/<slug>/` et envoyées sur le compte Roblox de Gabriel via `upload_image`. Variantes dans `MaterialService/PolyHaven` + overrides par matériau de base : Grass=forrest_ground_01, LeafyGrass=forest_floor, Ground=forest_ground_04, Mud=brown_mud_03, Slate (lahar)=river_small_rocks, Rock=rock_wall_02, Basalt=dry_riverbed_rock, Asphalt=asphalt_02, Sand=gravel_ground_01, Cobblestone=large_pebbles.
- Les textures mettent quelques dizaines de secondes à charger après l'envoi (aplat de couleur avant).
- Demandé au sous-agent (à faire après S4) : rivières élargies + module MelangeMateriaux (mélange organique). Un mélange organique est déjà visible sur S7.
- Les PF_* (IA) dans MaterialService/AssistantMaterials sont inutilisés : à supprimer si Gabriel valide.

## Coordination du 08/11 (soir)
- Agents en parallèle (brief commun : `wiki/BRIEF_SECTEUR_COMMUN.md`, verrou de play `LOCK_PLAY`) : S5 (repris), S6, S2, S1, S8 NE, + agent assets (placement des 15 modèles Sketchfab ; pont de S7 = remplacé par Gabriel, ne pas toucher).
- ServerStorage/Assets/{Props,Structures,Weapons,Camp} contient déjà des modèles importés ; Workspace/Carte/{S7,S4,S3}/Assets des clones placés (état précis : voir wiki/assets.md).
- Ne PAS laisser les sous-agents modifier hot.md/decoupage.md : le coordinateur met à jour.
- Ensuite : ambiance (jalon 3), squelette du jeu (Config/Shared/Demarrage/mode test), UI, joueur... (PROMPT section 15).

## Phase de polissage (demandée par Gabriel, 08/11)
- Brief prêt : `wiki/BRIEF_POLISSAGE.md` (eau variée, mares, micro-relief, transitions de matériaux, détails de lieux ; 1 agent Textures + 4 agents régions EST/CENTRE/OUEST/NORD-OUEST). À lancer APRÈS les rapports de S2, S6 (raccords S5/S4), S8 (couloir S3) et l'agent de raccords S1/S4/S5, pour ne pas polir des zones encore modifiées.

## Export au dépôt GitHub et renommage (10/11/2026)
- Branche `studio/local-2026-11-07` du dépôt `m5c586444w-blip/Partir-UI-Jeu-Roblox---Studio` : `fe35644` poussé par Gabriel, puis commit `d86b4ec` (export Studio : 18 modules de terrain vérifiés par somme de contrôle, wiki, `studio-export/placements.md`). Aucun fichier de src/ ni builds/ touché.
- Dans Studio, `ServerStorage/TerrainBuilder` (Folder) est renommé **`ServerStorage/TerrainSectors`** pour éviter la collision avec le ModuleScript `TerrainBuilder` du dépôt Rojo. Les pages wiki et briefs qui disent « ServerStorage/TerrainBuilder » désignent désormais `TerrainSectors` ; les modules s'appellent entre eux par `script.Parent`, donc rien n'est cassé.
- Les agents de polissage et de raccords sont stoppés (limite d'usage) ; à relancer sur commande de Gabriel.
