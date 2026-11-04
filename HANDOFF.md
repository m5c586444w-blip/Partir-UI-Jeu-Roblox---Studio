# HANDOFF — de la session cloud à la session Studio

Mis à jour le 2026-11-04, fin de la phase A2 (jalon J5). Section 18.1 ter de la bible.

## Ce qui est prêt

- `builds/Lobby.rbxlx` et `builds/Partie.rbxlx`, assemblées par Rojo 7.7.1
  (`Lobby.project.json`, `Partie.project.json`).
- Scripts (A1) : `Config` (14 modules), `Shared` (6 modules), 28 RemoteEvents, `Bootstrap`,
  `DataService`, `PartyService`, `MatchmakingService`, `LaunchService` (Lobby),
  `PartyLoaderService`, `ReturnService` (Partie). PlaceId déjà renseignés dans `LaunchConfig`
  (16.4). Messages système de 4.6 envoyés par `RE_Notify`.
- Interfaces (A2) : les 24 ScreenGui de la section 15 dans `StarterGui` (11 Lobby, 10 Partie,
  3 dans les deux), et `PingMarker` / `NameTag` dans `ReplicatedStorage/UITemplates`.
  Carte complète : `UI_MAP.md`.
- Pas encore de contrôleurs client (ils viennent avec leurs jalons) : les interfaces
  s'affichent mais ne réagissent pas encore. 39 libellés sont vides en attendant la bible
  (`SUIVI.md`, question B1).

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
8. **Fin de session Studio** : exporter les ScreenGui retouchés dans `ui-export/`
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

## Commandes

```
python3 tools/ui/build_ui.py                            # cloud, avant la 1re ouverture : UI + UI_MAP.md
rojo build Lobby.project.json -o builds/Lobby.rbxlx     # cloud, avant la 1re ouverture
rojo build Partie.project.json -o builds/Partie.rbxlx   # cloud, avant la 1re ouverture
rojo serve Lobby.serve.project.json                     # Studio, place Lobby (scripts seulement)
rojo serve Partie.serve.project.json                    # Studio, place Partie (scripts seulement)
stylua --check src                                      # syntaxe et mise en forme
selene src                                              # analyse statique
```

## Prochaine session cloud

Phase A3 (jalons J6, J7, J8) : joueur, objets, inventaire, tablette, documents, preuves, armes.
Lire d'abord les réponses de Gabriel aux questions B1 à B4 de `SUIVI.md`. Si Gabriel donne
les libellés manquants avant d'ouvrir les places dans Studio, les reporter dans
`tools/ui/build_ui.py` et relancer le générateur ; après, les saisir à la main dans Studio.
