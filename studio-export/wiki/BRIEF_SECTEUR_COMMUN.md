# Brief commun des sous-agents de secteur (à lire en premier)

Tu construis UN secteur de la carte 8 000 × 8 000 de PISTE FROIDE, dans la place Partie (Studio, via `mcp__Roblox_Studio__*`). D'AUTRES AGENTS construisent d'autres secteurs EN MÊME TEMPS dans le même Studio : reste strictement dans ta boîte (+ marge de raccord), ne touche à rien d'autre.

## Outils et instance
- Charge les outils : ToolSearch "select:mcp__Roblox_Studio__list_roblox_studios,mcp__Roblox_Studio__get_studio_state,mcp__Roblox_Studio__execute_luau,mcp__Roblox_Studio__search_game_tree,mcp__Roblox_Studio__inspect_instance,mcp__Roblox_Studio__screen_capture,mcp__Roblox_Studio__get_console_output,mcp__Roblox_Studio__start_stop_play,mcp__Roblox_Studio__script_read,mcp__Roblox_Studio__multi_edit".
- `list_roblox_studios` : prends l'instance « Partie (placeId: 103506696801797) » (l'id change si Studio est rouvert). `studio_id` obligatoire partout. Mode Edit. Ne publie rien, n'ouvre pas le Lobby.

## Modèle de travail (déjà fait pour S7, S4, S3 : COPIE-LE)
- Code existant dans `ServerStorage/TerrainBuilder` : `HauteurGlobale` (fonction de hauteur GLOBALE, même graine pour toute la carte : ne la modifie pas), `MelangeMateriaux` (mélange organique des matériaux par bruit, paramétrable), `S7/S4/S3/S5 Donnees` + `Terrain` (exemples). Lis `wiki/secteurs/S7_SudEst.md`, `S4_Centre.md`, `S3_NordEst.md` (méthodes, pièges, paramètres) puis crée `S<n>Donnees` / `S<n>Terrain` (chunks 256×256, `Construire(cx,cz)`, `Nettoyer()` qui ne vide QUE ta boîte, jamais `Terrain:Clear()` global). Copies locales des .lua dans `terrain/`.
- Voxels 4 studs. Découpe tout travail lourd en morceaux avec `task.wait()`. Studio est partagé : les appels peuvent être lents ou expirer ; réessaie.
- `execute_luau` renvoie toujours `nil` : les `print` vont dans la console cumulative (très longue : ne la relis pas). Lis les résultats via un attribut temporaire de `workspace` nommé `TEMP_<TonSecteur>_...` (unique pour toi) puis `inspect_instance` ; supprime-le ensuite.
- `require` d'un module modifié renvoie l'ancienne version (cache) : clone un dossier temporaire `TEMP_<TonSecteur>_TB` (unique) puis `require` le clone ; supprime-le à la fin.
- Raccords avec les secteurs voisins déjà construits : continuité de hauteur sans marche (saut max 3–4 studs), même niveau et même largeur d'eau aux jonctions de ruisseaux, niveau d'eau MONOTONE décroissant vers l'aval (mesure sur voxels). Aucun point de terrain sous y≈0 (sauf lit d'eau peu profond). Marge douce (~100 studs) aux bords vers un secteur pas encore construit.
- Rivières LARGES (demande de Gabriel) : 16–25 studs en amont, 30–65 en vallée. Matériaux : n'utilise que le module `MelangeMateriaux` (aucun matériau > 70 % hors lieux spéciaux), sentiers = Ground à bords irréguliers et axe CONTINU (mesure : 100 % des points de l'axe). Routes = Asphalt 100 % sur l'axe.
- NE TOUCHE PAS à `MaterialService` (textures Poly Haven appliquées en overrides).

## Assets et blocs gris
- Aucun modèle n'est à insérer par toi, sauf clones depuis `ServerStorage/Assets` (Props, Structures, Weapons, Camp : PileBuches = Log pile, TourGuet_24, EntreeMine, Rails_01, Tente_01, Glaciere, Rechaud, SacADos_01, Radio, BarriereRoute, Panneau_ApeCanyonTrail…) dans `Workspace/Carte/<ton secteur>/Assets`, quand un lieu en a besoin ; échelle déjà corrigée, vérifie quand même la taille, l'ancrage (Anchored), la pose au sol par raycast. Pas de Marketplace, pas de generate_mesh.
- Asset absent (arbres, bulldozer, troncs, squelettes…) = bloc gris `MANQUANT_<nom>` (un par type et par lieu clé), jamais de forêt de blocs.
- Le pont suspendu de Lava Canyon (S7) a été remplacé par Gabriel lui-même (`Workspace.Model` ou équivalent) : n'y touche pas. Ne touche pas à `Workspace.TEMP_out`, `Workspace.TEST_Rock09`, `Workspace.Model`.

## Marqueurs et dossiers
`Workspace/Carte/S<n>_<Nom>/{Terrain_Notes,Routes,Eau,Lieux,Assets}` ; marqueurs de lieux : Part ancré invisible CanCollide=false `Lieu_<NN>_<Nom>` avec attributs Numero, Nom, Secteur ; zones Bigfoot `Workspace/Zones/B<n>` (Part invisible, attribut Rayon). Pas de scripts de jeu, pas d'UI, pas de végétation, pas d'éclairage final.

## Tests (un seul Studio : verrou de play !)
- Préfère les tests de navigation en mode Edit (PathfindingService:CreatePath, par étapes < 1000 studs, agent joueur 5×2 et agent créature 10×4) ; si un play test est indispensable, prends le verrou : lis `workspace:GetAttribute("LOCK_PLAY")` ; s'il est nil, pose `workspace:SetAttribute("LOCK_PLAY","<TonSecteur>")`, fais ton test, ARRÊTE le play, remets-le à nil. S'il est pris, attends 60 s et réessaie. N'arrête jamais un play que tu n'as pas lancé.
- Captures : peu fiables (timeouts, caméra dans le terrain). Caméra AU-DESSUS du sol (≥ 60 studs de hauteur locale, vérifie par raycast), réessaie une fois ; complète par mesures. Console : ignore le plugin `roblox-path-plugin-main` et l'avertissement asset 203785492.

## Livrables et rapport
1. Terrain + eau + sentiers/routes + lieux + blocs MANQUANT_ comme demandé, mesures de continuité (voisins) et de monotonie de l'eau.
2. Écris SEULEMENT `wiki/secteurs/S<n>_<Nom>.md` (fait, positions déduites ou déplacées, paramètres, limites). **Ne modifie PAS `wiki/hot.md`, `decoupage.md`, `assets.md` ni CLAUDE.md** (d'autres agents écrivent en même temps : le coordinateur les met à jour).
3. Nettoie tes `TEMP_<TonSecteur>_*`.
4. Rapport final court (5 lignes + liste) : ce qui marche, ce qui manque, positions à valider, limites d'outils, nombre de captures. Si un blocage dépasse ~30 min d'essais, arrête-toi et explique.
