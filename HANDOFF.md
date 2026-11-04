# HANDOFF — de la session cloud à la session Studio

Mis à jour le 2026-11-04, fin de la phase A8. Toute la phase A (A1 → A8) est écrite, relue et
assemblée. Section 18.1 ter de la bible. Questions ouvertes : `SUIVI.md`.

## Ce qui est prêt

- `builds/Lobby.rbxlx` et `builds/Partie.rbxlx`, assemblées par Rojo 7.7.1 (`rojo build`, 2026-11-04).
- A1 : `Config` (15 modules), `Shared`, 29 RemoteEvents, `DataService`, groupe, lancement, retour (PlaceId 16.4).
- A2 : les 24 ScreenGui de la section 15, libellés 15.6, `UITemplates` (`PingMarker`, `NameTag`, `CreatureDebug`), `UI_MAP.md`.
- A3 : joueur (santé par membre, sang, à terre, mort, spectateur, endurance, peur, bruits), objets,
  inventaire, lampes, tablette, documents, preuves, armes.
- A4 : actes, horloge, siège, extractions E1–E4, fins, cinématiques, météo, ambiance ; lobby complet côté scripts.
- A5 : IA de la famille (`ServerScriptService/AI`), directeur de tension, événements EVT_01–22, `CreatureDebug`.
- A6 : gore (deux profils), musée, dialogue du ranger, skins, records, tableau des preuves, menu Réglages (touche P).
- A7 : `ServerStorage/TerrainBuilder`, textures Poly Haven (`assets/terrain/`), `ReplicatedStorage/Credits`.
- Images d'interface (`assets/ui/png` : vignettage, 41 icônes) ; objets `Animation` vides (section 14).

Rien n'a tourné dans Roblox. Vérifié dans le cloud : StyLua et selene sans erreur ni avertissement,
aucun nombre hors `Config` (`tools/check_values.py`), aucun `Instance.new` d'UI, les 268 chemins de la
section 15 présents, `require`, services et remotes tous résolus, build des deux places réussi.

## Ce que la session Studio doit faire, dans l'ordre

### 1. Préparer (une fois)
1. Installer Rokit, puis `rokit install` à la racine (Rojo 7.7.1, StyLua, selene) ; plugin : `rojo plugin install`.
2. Lire `CLAUDE.md`, `SUIVI.md`, ce fichier (18.1 ter, règle 2).

### 2. Ouvrir et publier (Gabriel — 18.3)
3. Ouvrir `builds/Lobby.rbxlx`, publier sur la place Lobby (77677833738174) de « PISTE FROIDE (test) ».
4. Ouvrir `builds/Partie.rbxlx`, publier sur la place Partie (103506696801797). Si l'expérience a été
   recréée : reporter les PlaceId dans `src/shared/Config/LaunchConfig.luau`, commit.
5. Dès ce moment, **plus aucun `rojo build`** vers ces places ; scripts par `rojo serve Lobby.serve.project.json`
   ou `rojo serve Partie.serve.project.json` uniquement (projets sans UI : l'UI appartient à Studio).
6. Paramètres du jeu > Sécurité : « Enable Studio Access to API Services ».

### 3. Phase B1 (J2, J3) — terrain et végétation
7. Partie, barre de commande : `require(game.ServerStorage.TerrainBuilder).Build()` (long : progression en console).
8. Vérifier les lieux à ±5 studs du tableau 3.2 (blocs gris `Workspace/Places/Pxx_<Nom>`) ; P01 → P05 par T1
   en 6 à 8 min de marche (J2) ; tracer à la main les lacets de T3 sous F01 (C42).
9. Importer les textures `assets/terrain/*` et créer les `MaterialVariant` de 13.4 (MaterialService).
10. Importer les modèles validés de 13.3 dans `ServerStorage/Vegetation` (noms de 13.3), puis
    `require(game.ServerStorage.TerrainBuilder).Vegetation()` ; contrôler ≤ 20 000 modèles et les FPS (J3).
11. Poser les Part taguées : `ClimbPoint` (paires bas/haut : Ape Canyon, Lava Canyon, F01), `StoneTree`
    (3 arbres à pierres, C28), `Foliage` (feuillage), `CreatureNav` (au besoin) ; volumes `PathfindingModifier`
    `Cover`, `Trail`, `Forbidden` (9.11) ; au besoin `Workspace/SpawnPoints/S1_1…`, `Workspace/CluePoints/C01…`,
    ancres d'extraction (`E1_Van`, `E2_Radio`, `E3_Bulldozer`, `E4_Plug`), ouvertures de la cabane
    (`P05c/Door`, `Window`, `RoofHole`), `Body_LeahBrandt` (P09).
12. Lobby : poser la ville (4.1) et les Part taguées `RangerHollis`, `MuseumPanel` ×8 (attribut `panelId`),
    `EvidenceBoard`, `SkinShop`, `RecordsBoard`, une `SpawnLocation` en L01 (0, 5, 120).

### 4. Phase B2 (J4) — ambiance
13. Régler à l'œil `AmbienceConfig` (lumière 12.1, brouillard 12.2, vent 12.4) ; captures de chaque moment ;
    nuit noire réelle entre 0 h et 4 h ; vérifier les réverbérations (19.3).
14. Importer les sons (13.7) et coller leurs identifiants dans `AudioConfig.Sounds`, `.Ambience`, `.Music`,
    `.Footsteps`, `.Documents` ; créer les `SoundGroup` Ambience, Voice, Music, Effects (réglages).

### 5. Phase B3 (J0, J15) — modèles, animations, tests
15. Importer les modèles : personnages `ReplicatedStorage/Characters/<ROLE>/Skin_A–C`, créatures
    `ServerStorage/Creatures/CRT_Alpha`, `CRT_Scout`, `CRT_Female`, objets `ReplicatedStorage/Items/Item_<Nom>`,
    décors `ServerStorage/Props`. En attendant : mannequins `MANQUANT_CHR_*`, capsules `MANQUANT_CRT_*`,
    blocs gris `MANQUANT_Item_*` (créés par les scripts).
16. Coller les identifiants des animations dans `ReplicatedStorage/Animations/Player|Creature/ANIM_*`.
17. Importer `assets/ui/png` ; identifiant de `Img_FearVignette` dans `HUDGui/FearVignette.Image` ;
    icônes dans `ItemConfig.Icons` et `WeaponConfig.Icons`.
18. Poser les plans de caméra `Workspace/Cinematics/CS_xx_Shot_n` (6.2).
19. Vérifier les polices `SpecialElite` et `RobotoMono` (15.2) et l'UI dans l'émulateur (PC, téléphone,
    tablette), puis retoucher à la main ; exporter les UI retouchées dans `ui-export/` en fin de session.
20. Tests de jalons (18.2) : J1 (groupe de 2 part et revient), J6–J8 (attributs, armes), J9 (partie complète
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
stylua --check src tools/terrain && selene src tools/terrain
python3 tools/check_values.py                           # aucun nombre hors Config
python3 tools/ui/check_ui.py                            # chemins d'UI de la section 15 (sur les builds)
# Cloud seulement, avant la 1re ouverture d'une place :
python3 tools/ui/build_ui.py                            # UI + UI_MAP.md
python3 tools/animations/build_animations.py            # objets Animation (14)
python3 tools/images/make_images.py && node tools/images/rasterize.js   # images 13.5
python3 tools/terrain/download_polyhaven.py             # textures 13.4 + Credits
rojo build Lobby.project.json -o builds/Lobby.rbxlx
rojo build Partie.project.json -o builds/Partie.rbxlx
```
