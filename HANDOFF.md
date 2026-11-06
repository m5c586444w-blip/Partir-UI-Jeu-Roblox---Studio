# HANDOFF — de la session cloud à la session Studio

Mis à jour le 2026-11-05 (soir) : phase A (A1 → A8) terminée, bible 19.5, 19.6 et 15.7 appliquées (plus
aucun `TODO(BIBLE)` ni PROVISOIRE), bible découpée dans `docs/bible/` (point d'entrée : `docs/bible/INDEX.md`). Section 18.1 ter de la bible. Questions ouvertes : `SUIVI.md`.

> **État au 2026-11-06 (session Studio)** : 0a faite (`RESET_INVENTAIRE.md`, Lobby et Partie). Prochaine étape exacte :
> section 2 (écrans de `builds/Lobby.rbxlx` puis `builds/Partie.rbxlx`, sans publier), puis « Prêt à publier ».
> Le tableau Creator Dashboard est laissé à Gabriel (non bloquant). Python : `python`, pas `python3` (Windows).

## Ce qui est prêt

- `builds/Lobby.rbxlx` et `builds/Partie.rbxlx`, assemblées par Rojo 7.7.1 (`rojo build`, 2026-11-05).
- 15.7 : chaque écran a `Layout_Desktop` et `Layout_Touch` (mêmes noms dedans) ; `Util.prepareGui` montre la
  bonne selon `TouchEnabled` et lie les voiles (`Veil`, attribut `veilFor`). `tools/ui/check_ui.py` :
  0 débordement, 0 chevauchement à 1280 × 720 et 844 × 390 ; aperçus de chaque écran dans `previews/`.
- 19.5 : portage d'un blessé, indices cachés de la Descendante (`HiddenClueService`), machette en P10,
  accessoires, objectifs séquentiels, messages radio, fins, sources du musée, gorges et lacets de T3,
  attaque imposée en acte 3 ; profil Moderate.
- A1 : `Config` (15 modules), `Shared`, 29 RemoteEvents, `DataService`, groupe, lancement, retour (PlaceId 16.4).
- A2 : les 24 ScreenGui de la section 15, libellés 15.6, `UITemplates` (`PingMarker`, `NameTag`, `CreatureDebug`), `UI_MAP.md`.
- A3 : joueur (santé par membre, sang, à terre, mort, spectateur, endurance, peur, bruits), objets,
  inventaire, lampes, tablette, documents, preuves, armes.
- A4 : actes, horloge, siège, extractions E1–E4, fins, cinématiques, météo, ambiance ; lobby complet côté scripts.
- A5 : IA de la famille (`ServerScriptService/AI`), directeur de tension, événements EVT_01–22, `CreatureDebug`.
- A6 : gore (deux profils), musée, dialogue du ranger, skins, records, tableau des preuves, menu Réglages (touche P).
- A7 : `ServerStorage/TerrainBuilder`, textures Poly Haven (`assets/terrain/`), `ReplicatedStorage/Credits`.
- Images d'interface (`assets/ui/png` : vignettage, 41 icônes d'objets, 12 icônes de boutons tactiles,
  2 icônes de jauges, 6 silhouettes de membres) ; objets `Animation` vides (section 14).

Rien n'a tourné dans Roblox. Vérifié dans le cloud : StyLua et selene sans erreur ni avertissement,
aucun nombre hors `Config` (`tools/check_values.py`), aucun `Instance.new` d'UI, les 268 chemins de la
section 15 présents, 0 signalement de `check_ui.py`, build des deux places réussi. La mise en page de
`check_ui.py` est une approximation : l'émulateur de Studio fait foi (15.7, 8).

## Ce que la session Studio doit faire, dans l'ordre

### 0. Remise à zéro (avant toute autre tâche)

Les places Lobby et Partie publiées sur Roblox peuvent contenir un ancien contenu. Ordre : **0a** (inventaire,
lecture seule) → étapes 1 à 4 → publication en **Overwrite** par Gabriel (étape 5) → **0b** (vérification
et suppression des résidus). Outils : `tools/studio/ResetInventory.luau`, `tools/studio/ResetPaths.luau`
(à coller dans la barre de commande ou à lancer par l'outil MCP de Roblox Studio ; aucun n'écrit rien),
`python3 tools/studio/reset_diff.py`.

**0a — inventaire, avant la publication, sans rien modifier**
- 0.1. Ouvrir dans Studio la place **publiée** Lobby (77677833738174), depuis Roblox (pas `builds/`).
  Ne jamais Enregistrer ni Publier, ne pas lancer `rojo serve`. Si Team Create est actif, toute
  modification est enregistrée aussitôt : ne rien toucher dans l'Explorer.
- 0.2. Lancer `ResetInventory.luau` et `ResetPaths.luau`. Coller la sortie du premier dans
  `RESET_INVENTAIRE.md` (section Lobby) et garder la sortie du second (chemins) pour 0b. L'inventaire couvre
  scripts (chemin, taille), modèles et instances par service, terrain (nombre de cellules), UI,
  sons (`SoundId`), packages (`PackageLink`), identifiants d'assets et noms de stockage trouvés dans les scripts.
- 0.3. Même chose pour la place publiée Partie (103506696801797).
- 0.4. Faire remplir par Gabriel, dans `RESET_INVENTAIRE.md`, ce que l'Overwrite ne touche pas (Creator
  Dashboard) : autres places de l'univers, badges, passes de jeu, produits développeur, paramètres et
  collaborateurs, packages à mise à jour automatique.
- 0.5. Commit de `RESET_INVENTAIRE.md`. **Aucune modification des places avant la publication en Overwrite.**

**Noms de stockage jamais utilisés auparavant.** Le code utilise le DataStore `PisteFroide_v1`
(clé `player_<UserId>`, 16.4) et les MemoryStore `Parties` et `Launch_<PrivateServerId>` (`LaunchConfig`).
- Comparer avec les noms trouvés par `ResetInventory.luau` dans les anciens scripts.
- Après la publication et l'accès aux API (étape 7), **avant tout test en jeu** (sinon `DataService` crée
  lui-même `PisteFroide_v1`), lister les DataStores existants dans la barre de commande :
  `for _, p in game:GetService("DataStoreService"):ListDataStoresAsync():GetCurrentPage() do print(p.DataStoreName) end`.
- Les noms de MemoryStore ne se listent pas : seule la recherche dans les anciens scripts les révèle.
- Si un nom est déjà pris : arrêt, proposer un nouveau nom à Gabriel (la bible fixe `PisteFroide_v1`) et le
  noter dans `SUIVI.md` ; ne lancer aucun test avant sa réponse.

**0b — après la publication en Overwrite (étape 5)**
- 0.6. Rouvrir chaque place publiée, relancer `ResetPaths.luau`, enregistrer la sortie dans un fichier, puis
  `python3 tools/studio/reset_diff.py <fichier> Lobby` (ou `Partie`) : tout chemin absent de `builds/` est un
  résidu (scripts, modèles, terrain, UI, sons). Relancer `ResetInventory.luau` : aucun package, aucun ancien
  identifiant d'asset, terrain vide tant que la phase B1 n'a pas commencé.
- 0.7. Supprimer les résidus dans Studio, les noter dans `RESET_INVENTAIRE.md` (section 0b), publier
  (Gabriel), commit. Vérifier aussi les éléments de l'expérience listés en 0.4 avec Gabriel.

### 1. Préparer (une fois)
1. Installer Rokit, puis `rokit install` à la racine (Rojo 7.7.1, StyLua, selene) ; plugin : `rojo plugin install`.
2. Lire `CLAUDE.md`, `SUIVI.md`, ce fichier (18.1 ter, règle 2).

### 2. Vérifier les écrans, sans publier (15.7, 8) — après l'inventaire 0a
3. Ouvrir `builds/Lobby.rbxlx` puis `builds/Partie.rbxlx` **sans les publier**.
4. Dans chaque place, émulateur d'appareils de Studio (onglet Test > Device) : vérifier **chaque écran** au
   format PC 1280 × 720 et au format téléphone 844 × 390 (paysage), capture de chacun. Pour faire apparaître
   un écran : lancer la place (Play) et ouvrir les menus, ou passer `Visible` à vrai dans l'Explorer.
   Comparer avec `previews/<écran>_<taille>.png`. À regarder : textes coupés, chevauchements, coins bas
   gauche et bas droit libres sur téléphone (joystick, saut), 6 boutons tactiles au plus, voiles derrière
   les fenêtres, verrous opaques. Retoucher à la main si besoin (Studio fait foi pour l'UI) et noter les
   écarts dans `SUIVI.md`.
5. **Attendre la publication par Gabriel** (18.3 : Claude Code ne publie pas), **en Overwrite** : il publie
   `builds/Lobby.rbxlx` sur la place 77677833738174 et `builds/Partie.rbxlx` sur 103506696801797 de
   « PISTE FROIDE (test) ». Si l'expérience a été
   recréée : reporter les PlaceId dans `src/shared/Config/LaunchConfig.luau`, commit.
6. Dès l'ouverture des places, **plus aucun `rojo build`** vers elles ; scripts par `rojo serve Lobby.serve.project.json`
   ou `rojo serve Partie.serve.project.json` uniquement (projets sans UI : l'UI appartient à Studio).
7. Après la publication : Paramètres du jeu > Sécurité : « Enable Studio Access to API Services ».
   Puis, avant tout test : la liste des DataStores (étape 0) et l'étape **0b**.

### 3. Phase B1 (J2, J3) — terrain et végétation
8. Partie, barre de commande : `require(game.ServerStorage.TerrainBuilder).Build()` (long : progression en console).
9. Vérifier les lieux à ±5 studs du tableau 3.2 (blocs gris `Workspace/Places/Pxx_<Nom>`) ; P01 → P05 par T1
   en 6 à 8 min de marche (J2) ; contrôler les lacets de T3 sous F01 (C42, générés) et la largeur des gorges
   (C40 : maille de 8 studs, l'étroit de P05s à 9 studs est à retoucher à la main).
10. Importer les textures `assets/terrain/*` et créer les `MaterialVariant` de 13.4 (MaterialService).
11. Importer les modèles validés de 13.3 dans `ServerStorage/Vegetation` (noms de 13.3), puis
    `require(game.ServerStorage.TerrainBuilder).Vegetation()` ; contrôler ≤ 20 000 modèles et les FPS (J3).
12. Poser les Part taguées : `ClimbPoint` (paires bas/haut : Ape Canyon, Lava Canyon, F01), `StoneTree`
    (3 arbres à pierres, C28), `Foliage` (feuillage), `CreatureNav` (au besoin) ; volumes `PathfindingModifier`
    `Cover`, `Trail`, `Forbidden` (9.11) ; au besoin `Workspace/SpawnPoints/S1_1…`, `Workspace/CluePoints/C01…`,
    ancres d'extraction (`E1_Van`, `E2_Radio`, `E3_Bulldozer`, `E4_Plug`), ouvertures de la cabane
    (`P05c/Door`, `Window`, `RoofHole`), `Body_LeahBrandt` (P09) ; 19.5 (C7) : Part `CrawlSpace` (vide
    sanitaire sous le plancher de P05c, 2 joueurs) et `Ford` (gué, 60 studs en aval de HC3, près de P16) ;
    19.6 (C17) : branches et pierres au sol, Part taguées `GroundItem` avec l'attribut `itemId`
    (`ITM_Branch` en forêt, `ITM_Stone` partout).
13. Lobby : poser la ville (4.1) et les Part taguées `RangerHollis`, `MuseumPanel` ×8 (attribut `panelId`),
    `EvidenceBoard`, `SkinShop`, `RecordsBoard`, une `SpawnLocation` en L01 (0, 5, 120).

### 4. Phase B2 (J4) — ambiance
14. Régler à l'œil `AmbienceConfig` (lumière 12.1, brouillard 12.2, vent 12.4) ; captures de chaque moment ;
    nuit noire réelle entre 0 h et 4 h ; vérifier les réverbérations (19.3).
15. Importer les sons (13.7) et coller leurs identifiants dans `AudioConfig.Sounds`, `.Ambience`, `.Music`,
    `.Footsteps`, `.Documents` ; créer les `SoundGroup` Ambience, Voice, Music, Effects (réglages).

### 5. Phase B3 (J0, J15) — modèles, animations, tests
16. Importer les modèles : personnages `ReplicatedStorage/Characters/<ROLE>/Skin_A–C`, créatures
    `ServerStorage/Creatures/CRT_Alpha`, `CRT_Scout`, `CRT_Female`, objets `ReplicatedStorage/Items/Item_<Nom>`,
    décors `ServerStorage/Props`. En attendant : mannequins `MANQUANT_CHR_*`, capsules `MANQUANT_CRT_*`,
    blocs gris `MANQUANT_Item_*` (créés par les scripts).
17. Coller les identifiants des animations dans `ReplicatedStorage/Animations/Player|Creature/ANIM_*`.
18. Importer `assets/ui/png` ; identifiant de `Img_FearVignette` dans `HUDGui/*/FearVignette.Image` ;
    icônes dans `ItemConfig.Icons` et `WeaponConfig.Icons` ; `Icon_Ctrl_*` dans l'`Image` des boutons de
    `MobileControlsGui/Layout_Touch` ; `Icon_Stamina`, `Icon_Battery` dans `HUDGui/*/StaminaIcon`, `BatteryIcon` ;
    `Img_Body_<membre>` dans `HUDGui/*/BodyStatus/<membre>/Ok`, `Hurt`, `Critical` (deux dispositions).
19. Poser les plans de caméra `Workspace/Cinematics/CS_xx_Shot_n` (6.2).
20. Vérifier les polices `SpecialElite` et `RobotoMono` (15.2) et l'UI dans l'émulateur (PC, téléphone,
    tablette), puis retoucher à la main ; exporter les UI retouchées dans `ui-export/` en fin de session.
21. Tests de jalons (18.2) : J1 (groupe de 2 part et revient), J6–J8 (attributs, armes), J9 (partie complète
    sans créature : retirer `FamilyBrain` de `AI_ORDER` le temps du test), J10–J12 (F8 : `CreatureDebug`),
    J13 (`GoreConfig.Profile`), J14 (musée, skins), J15 (durée 35–52 min sur 3 tests, budgets 17.1, mobile réel).

## Tests utiles (barre de commande, contexte Serveur)

- Hors serveur réservé, la Partie lance une partie de test (DÉFAUT) : Normal, S1, rôles dans l'ordre de 2.5.
- Blesser : `require(game.ServerScriptService.Services.HealthService):Damage(game.Players.Player1, "LegL", 50, "test")`.
- Donner un objet : `require(game.ServerScriptService.Services.InventoryService):Add(game.Players.Player1, "WPN_Rifle", 1)`.
- Retour au Lobby : `require(game.ServerScriptService.Services.ReturnService):ReturnAll(nil)` (console développeur, en ligne).
- Accélérer un test : réduire temporairement `ActConfig.Acts` (ne pas commit).

## Commandes

```
rojo serve Lobby.serve.project.json                     # Studio, place Lobby (scripts seulement)
rojo serve Partie.serve.project.json                    # Studio, place Partie (scripts seulement)
stylua --check src tools/terrain tools/studio && selene src tools/terrain tools/studio
python3 tools/split_bible.py                            # nouvelle bible → docs/bible/ (une section par fichier)
python3 tools/check_values.py                           # aucun nombre hors Config
python3 tools/ui/check_ui.py --previews                 # chemins (builds) ; débordements et chevauchements
                                                        # à 1280 × 720 et 844 × 390 ; aperçus dans previews/
# Cloud seulement, avant la 1re ouverture d'une place :
python3 tools/ui/build_ui.py                            # UI + UI_MAP.md
python3 tools/animations/build_animations.py            # objets Animation (14)
python3 tools/images/make_images.py && node tools/images/rasterize.js   # images 13.5
python3 tools/terrain/download_polyhaven.py             # textures 13.4 + Credits
rojo build Lobby.project.json -o builds/Lobby.rbxlx
rojo build Partie.project.json -o builds/Partie.rbxlx
```
