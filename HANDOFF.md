# HANDOFF — de la session cloud à la session Studio

Mis à jour le 2026-11-04, fin de la phase A1 (jalon J1). Section 18.1 ter de la bible.

## Ce qui est prêt

- `builds/Lobby.rbxlx` et `builds/Partie.rbxlx`, assemblées par Rojo 7.7.1 à partir des
  fichiers du dépôt (`Lobby.project.json`, `Partie.project.json`).
- Contenu des deux places : `ReplicatedStorage/Config` (14 modules), `Shared` (6 modules),
  `Remotes` (28 RemoteEvents de 16.3, rangées par place), dossiers vides de 16.1,
  `ServerScriptService/Bootstrap` et `Services`.
- Lobby : `DataService`, `MatchmakingService`, `LaunchService`, `PartyService`.
- Partie : `DataService`, `ReturnService`, `PartyLoaderService`.
- Pas encore d'UI (phase A2), pas de terrain (A7/B1), pas de contrôleurs client.

## Ce que la phase A1 n'a pas pu vérifier

Rien n'a tourné dans Roblox : ni DataStore, ni MemoryStore, ni téléportation.
Vérifié ici : syntaxe (StyLua et selene, zéro erreur), build Rojo des deux places,
aucune valeur chiffrée hors `Config`.

## Ordre exact dans Studio (jalon J1)

1. **Outils.** Installer Rokit, puis à la racine du dépôt : `rokit install`
   (Rojo 7.7.1, StyLua, selene). Installer le plugin Rojo dans Studio : `rojo plugin install`.
2. **Ouvrir** `builds/Lobby.rbxlx` dans Studio. À partir de là, ne plus jamais lancer
   `rojo build` vers ce fichier (18.1 ter, règle 3).
3. **Publier** (Gabriel, jamais Claude Code — 18.3) : Fichier > Publier sur Roblox, nouvelle
   expérience. Le Lobby est la place de départ.
4. Ouvrir `builds/Partie.rbxlx`, puis Fichier > Publier sur Roblox **dans la même expérience**,
   comme nouvelle place nommée « Partie ».
5. **PlaceId** (question Q2 de `SUIVI.md`) : noter les deux PlaceId (Asset Manager > Places)
   et les écrire dans `src/shared/Config/LaunchConfig.luau` (`PlaceIds.Lobby`, `PlaceIds.Partie`),
   puis commit.
6. **Synchroniser les scripts** dans chaque place ouverte :
   `rojo serve Lobby.project.json` (place Lobby) ou `rojo serve Partie.project.json`
   (place Partie), puis « Connect » dans le plugin Rojo. Republier les deux places.
7. **Accès aux API** : Paramètres du jeu > Sécurité > « Enable Studio Access to API Services »
   (DataStore et MemoryStore dans Studio).
8. **Sol provisoire** (question Q20) : sans terrain ni ville, les joueurs tombent dans le vide.
   Attendre la réponse à Q20 avant de poser quoi que ce soit.

## Tests de J1

**Dans Studio** (Test > Clients et serveurs, 2 joueurs) — la téléportation ne marche pas
dans Studio, le test s'arrête donc au départ :

- Barre de commande, contexte Joueur1 :
  `game.ReplicatedStorage.Remotes.RE_PartyCreate:FireServer(false)`
- Contexte Joueur2 : `game.ReplicatedStorage.Remotes.RE_PartyQuickJoin:FireServer()`
  (variante sans MemoryStore : Joueur1 crée un groupe privé avec `FireServer(true)`, lit son
  code avec `game.Players.LocalPlayer:GetAttribute("partyCode")`, et Joueur2 envoie
  `game.ReplicatedStorage.Remotes.RE_PartyJoin:FireServer("<code>")`)
- Les deux : `game.ReplicatedStorage.Remotes.RE_Ready:FireServer(true)`
- Attendu : attributs `partyId` identiques et `isReady = true` sur les deux joueurs,
  `partyCountdownEnd` renseigné, puis 10 s après, l'avertissement
  « LaunchService : réservation impossible (normal en Studio) » et `isReady` remis à vide.
- Données : après avoir quitté, contexte Serveur :
  `game:GetService("DataStoreService"):GetDataStore("PisteFroide_v1"):GetAsync("player_<UserId>")`
  doit renvoyer la table de 16.4.

**Dans l'expérience publiée** (2 comptes) — test complet « part et revient » :
il faut une interface pour créer le groupe (PartyGui, phase A2, et son contrôleur).
Retour au Lobby : en attendant l'acte final (J9), le déclencher depuis la console
développeur côté serveur :
`require(game.ServerScriptService.Services.ReturnService):ReturnAll(nil)`.
Vérifier dans la console de la Partie : « graine … , départ S… » et « 2/2 joueur(s) arrivé(s) ».

## Commandes

```
rojo build Lobby.project.json -o builds/Lobby.rbxlx     # cloud seulement, avant la 1re ouverture
rojo build Partie.project.json -o builds/Partie.rbxlx   # cloud seulement, avant la 1re ouverture
rojo serve Lobby.project.json                           # Studio, place Lobby
rojo serve Partie.project.json                          # Studio, place Partie
stylua --check src                                      # syntaxe et mise en forme
selene src                                              # analyse statique
```

## Prochaine session cloud

Phase A2 (jalon J5) : toutes les UI de la section 15 en fichiers `.model.json`, et `UI_MAP.md`.
Lire d'abord les réponses de Gabriel aux questions Q1 à Q20 de `SUIVI.md`.
