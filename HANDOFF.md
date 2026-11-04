# HANDOFF — de la session cloud à la session Studio

Mis à jour le 2026-11-04 au fil des phases A3 → A8 (voir `SUIVI.md`, « État de reprise »).
Section 18.1 ter de la bible.

## Ce qui est prêt

- `builds/Lobby.rbxlx` et `builds/Partie.rbxlx`, assemblées par Rojo 7.7.1.
- A1 : `Config`, `Shared`, 28 RemoteEvents, `DataService`, groupe, lancement, retour (PlaceId renseignés).
- A2 : les 24 ScreenGui de la section 15 et `PingMarker` / `NameTag` ; libellés de 15.6 ; `UI_MAP.md`.
- A3 : joueur (santé par membre, sang, à terre, mort, spectateur, endurance, postures, peur, bruits),
  objets, inventaire, lampes, tablette, documents, preuves, armes ; contrôleurs client de la Partie.
- A4 : actes, horloge, siège, extractions E1–E4, fins, cinématiques, météo, ambiance ;
  lobby complet côté scripts (groupe, rôles, armes, votes, CS_01, résultats).
- A5 : IA de la famille (dossier `ServerScriptService/AI`), directeur de tension, événements
  inexpliqués, outil `CreatureDebug` (F8 en Studio) ; objets `Animation` vides (section 14).
- A6 : gore (deux profils, `GoreConfig.Profile`), musée, dialogue du ranger, skins, records,
  tableau des preuves, menu Réglages (touche P).
- Images d'interface dans `assets/ui/png` (vignettage de peur, 41 icônes) : à importer.

## Ce que la phase A n'a pas pu vérifier

Rien n'a tourné dans Roblox. Vérifié ici : syntaxe (StyLua, selene), build Rojo, présence de
tous les chemins de la section 15, aucune valeur hors `Config`, aucun `Instance.new` d'UI.
L'affichage n'a été contrôlé que par un aperçu approximatif (HTML), pas dans Studio.

## Ordre exact dans Studio

1. **Outils.** Installer Rokit, puis à la racine du dépôt : `rokit install`
   (Rojo 7.7.1, StyLua, selene). Plugin Rojo dans Studio : `rojo plugin install`.
2. **Ouvrir** `builds/Lobby.rbxlx`. À partir de là, ne plus jamais lancer `rojo build` vers ce
   fichier (18.1 ter, règle 3) ni `tools/ui/build_ui.py` pour cette place : l'UI appartient à Studio.
3. **Publier** (Gabriel, jamais Claude Code — 18.3) dans l'expérience « PISTE FROIDE (test) » :
   la place Lobby (PlaceId 77677833738174). Puis ouvrir `builds/Partie.rbxlx` et publier sur la
   place Partie (PlaceId 103506696801797). Si l'expérience a été recréée, reporter les nouveaux
   PlaceId dans `src/shared/Config/LaunchConfig.luau` et commit.
4. **Synchroniser les scripts** dans chaque place ouverte, avec les projets **sans UI** :
   `rojo serve Lobby.serve.project.json` (place Lobby) ou
   `rojo serve Partie.serve.project.json` (place Partie), puis « Connect » dans le plugin.
   Ne jamais servir `Lobby.project.json` / `Partie.project.json` : ils réécriraient l'UI.
5. **Accès aux API** : Paramètres du jeu > Sécurité > « Enable Studio Access to API Services ».
6. **Sol provisoire** (DÉFAUT) : pour les tests de J1, poser à la main une plaque ancrée sous
   L01 (0, 5, 120) dans le Lobby et sous S1–S3 dans la Partie ; la retirer avant J2 / J14.
7. **Vérifier l'UI (J5)** : polices `SpecialElite` et `RobotoMono` bien rendues (15.2) ;
   émulateur d'appareils (téléphone en paysage, tablette) : textes lisibles, rien hors écran,
   boutons mobiles au-dessus du bouton de saut. Rendre visibles un à un les menus cachés
   (`Visible = false` au départ) pour les contrôler. Retouches à la main autorisées : c'est
   l'objectif de 15.
8. **Images (13.5)** : importer `assets/ui/png/*.png` (Asset Manager > Import). Coller
   l'identifiant de `Img_FearVignette` dans `HUDGui/FearVignette.Image`, et ceux des icônes
   dans `Config/ItemConfig.Icons` et `Config/WeaponConfig.Icons` (`["ITM_Bandage"] = "rbxassetid://…"`).
9. **Fin de session Studio** : exporter les ScreenGui retouchés dans `ui-export/`
   (clic droit > « Save to File… », `.rbxmx`), commit, et noter dans `SUIVI.md` ce qui a changé.

## Tests de J1

**Dans Studio** (Test > Clients et serveurs, 2 joueurs) — la téléportation ne marche pas dans
Studio, le test s'arrête au départ :
- Joueur1 : `game.ReplicatedStorage.Remotes.RE_PartyCreate:FireServer(true)`, puis
  `game.Players.LocalPlayer:GetAttribute("partyCode")`.
- Joueur2 : `game.ReplicatedStorage.Remotes.RE_PartyJoin:FireServer("<code>")`
  (ou `RE_PartyQuickJoin:FireServer()` après un groupe public créé avec `FireServer(false)`).
- Les deux : `game.ReplicatedStorage.Remotes.RE_Ready:FireServer(true)`.
- Attendu : même `partyId`, `isReady = true`, `partyCountdownEnd` renseigné ; 10 s après,
  3 essais de départ (« réservation impossible (normal en Studio) ») puis `isReady` remis à vide.
  Les messages 4.6 arrivent par `RE_Notify` (pas encore affichés : `NotificationController` à venir).
- Données : contexte Serveur,
  `game:GetService("DataStoreService"):GetDataStore("PisteFroide_v1"):GetAsync("player_<UserId>")`.

**Dans l'expérience publiée** (2 comptes) — « part et revient » : il faut le contrôleur de
`PartyGui` (A4) pour créer le groupe sans barre de commande. Retour au Lobby, en attendant J9 :
console développeur côté serveur,
`require(game.ServerScriptService.Services.ReturnService):ReturnAll(nil)`.
Console de la Partie : « graine …, départ S… » et « 2/2 joueur(s) arrivé(s) ».

## Tests de J6, J7, J8 (Studio, Test > Clients et serveurs)

Hors serveur réservé, la Partie lance une partie de test (DÉFAUT) : Normal, départ S1, rôles
dans l'ordre de 2.5. Sans terrain, poser d'abord la plaque provisoire sous S1 (étape 6).
- Console serveur : « ItemSpawnService : graine … » et la liste des 6 points d'indice tirés.
- Attributs du joueur (fenêtre Propriétés > Attributs) : `hpHead`…`hpLegR`, `blood`, `stamina`,
  `fear`, `stance`, `inventory`, `heldItem`, `lightOn`, `ammo`.
- Blesser un joueur (barre de commande, contexte Serveur) :
  `require(game.ServerScriptService.Services.HealthService):Damage(game.Players.Player1, "LegL", 50, "test")`
  → boiterie (vitesse ×0,6) ; `Damage(..., "Torso", 100, ...)` → à terre, invite « Relever » pour l'autre joueur.
- Armes : donner un fusil (`require(game.ServerScriptService.Services.InventoryService):Add(game.Players.Player1, "WPN_Rifle", 1)`),
  tirer 5 fois puis vérifier que le 6e tir est refusé ; en Normal, aucun dégât à un coéquipier.

## Tests de J9 (partie sans créature)

- Poser dans `Workspace/Cinematics` des Part invisibles `CS_02a_Shot_1`, `CS_04_Shot_1`… (6.2) ;
  sans elles, seules les bandes noires et les sous-titres s'affichent (avertissement console).
- Poser au besoin les ancres `Workspace/Places/E1_Van`, `E2_Radio`, `E3_Bulldozer`, `E4_Plug`,
  `P05c/Door`, `P05c/Window`, `P05c/RoofHole` (sinon ancres invisibles aux coordonnées de la bible).
- Accélérer un test : réduire temporairement les durées dans `Config/ActConfig.Acts` (ne pas commit).
- Fin attendue : cinématique de fin, `RE_EndGame`, retour au Lobby et `ResultsGui`.

## Tests de J10 à J12 (IA)

- Sans modèle `ServerStorage/Creatures/CRT_Alpha`, une capsule `MANQUANT_CRT_Alpha` de 10 studs la remplace (J10).
- F8 en Studio : comportement, cible, scores, vigilance, chemin, tension au-dessus de chaque créature.
- À poser dans Studio : Part taguées `ClimbPoint` (paires bas/haut, 9.11 ; l'escalade reste à brancher),
  `StoneTree` (3 arbres à pierres, 9.1), `Foliage` sur le feuillage (ne bloque pas la vue, 9.4),
  `CreatureNav` (nœuds en plus) ; volumes `PathfindingModifier` nommés `Cover`, `Trail`, `Forbidden` (9.11).
- Coller les identifiants des animations dans `ReplicatedStorage/Animations/Creature/ANIM_Creature_*`.

## Lobby (J14) à poser dans Studio

Ville du lobby (4.1) : Part taguées `RangerHollis` (L02), `MuseumPanel` ×8 avec l'attribut `panelId`
= M1…M8 (L03), `EvidenceBoard` (L03), `SkinShop` (L04), `RecordsBoard` (L05) ; `SpawnLocation` en
L01 (0, 5, 120). Sans elles, des ancres invisibles sont créées aux positions de 4.1.
Créer dans `SoundService` les `SoundGroup` Ambience, Voice, Music, Effects (réglages 17.2).

## Commandes

```
python3 tools/ui/build_ui.py                            # cloud, avant la 1re ouverture : UI + UI_MAP.md
rojo build Lobby.project.json -o builds/Lobby.rbxlx     # cloud, avant la 1re ouverture
rojo build Partie.project.json -o builds/Partie.rbxlx   # cloud, avant la 1re ouverture
rojo serve Lobby.serve.project.json                     # Studio, place Lobby (scripts seulement)
rojo serve Partie.serve.project.json                    # Studio, place Partie (scripts seulement)
python3 tools/check_values.py                           # aucun nombre hors Config
python3 tools/ui/check_ui.py                            # chemins d'UI de la section 15 dans les builds
python3 tools/images/make_images.py && node tools/images/rasterize.js   # images 13.5
stylua --check src                                      # syntaxe et mise en forme
selene src                                              # analyse statique
```

## Prochaine étape

Suite des phases A4 → A8 dans la même session (voir `SUIVI.md`).
