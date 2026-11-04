# SUIVI — PISTE FROIDE

Tenu par les deux sessions (cloud et Studio), section 18.1 ter. Chaque session ajoute une
entrée au journal : date, ce qui est fait, ce qui reste ouvert.

Règle de la section 0 : une question qui ne touche ni un texte affiché aux joueurs, ni une
valeur de gameplay, ni un asset est tranchée par Claude Code et marquée **DÉFAUT**. Les autres
restent des `TODO(BIBLE)` jusqu'à une réponse écrite dans la bible.

## Journal des sessions

### 2026-11-04 (2) — session cloud, réponses de Gabriel + phase A2 (jalon J5)

Fait :
- `BIBLE_PISTE_FROIDE.pdf` remplacé par `BIBLE_PISTE_FROIDE.md` (version de Gabriel).
- A1 mis à jour avec les réponses de la bible : identifiants des rôles (2.5), PlaceId (16.4),
  `LaunchConfig` (16.1), clé `Launch_<PrivateServerId>` et contrôle de version côté Partie
  (16.1, 16.4), valeurs techniques acceptées (mention PROPOSITION retirée), messages système
  `MSG_` de la section 4.6 dans `LoreConfig.Messages`, envoyés par `RE_Notify` (clé + `{player}`/`{n}`).
- Nouveaux comportements tirés de 4.6 : créateur du groupe et passation (`MSG_HostLeft`),
  `MSG_PartyLeft`, `MSG_WaitingReady`, `MSG_Countdown`, `MSG_CountdownCancelled`,
  `MSG_Teleporting`, nouvel essai de départ (`MSG_TeleportRetry` puis `MSG_TeleportAbort`),
  `MSG_WaitingPlayers`, `MSG_PlayerMissing`, `MSG_VersionMismatch`, `MSG_ReturnToLobby`,
  `MSG_DataLoadFailed`.
- **Phase A2** : les 24 ScreenGui de la section 15 (11 Lobby, 10 Partie, 3 dans les deux places)
  et 2 BillboardGui modèles (`ReplicatedStorage/UITemplates`), en fichiers `.model.json`,
  générés par `tools/ui/build_ui.py`, avec le style de 15.2. `UI_MAP.md` livré.
- Projets `Lobby.serve.project.json` et `Partie.serve.project.json` (sans UI) pour `rojo serve`
  après la première ouverture dans Studio (18.1 ter).
- `Util.findUI` : un élément d'UI introuvable produit un seul avertissement « UI manquante : … » (15.1).
- Relecture : StyLua et selene sans erreur ; aucune valeur hors `Config` ; aucun `Instance.new`
  d'UI (les deux seuls `Instance.new` créent des `TeleportOptions`) ; les 268 chemins de la
  section 15 sont présents dans les deux builds (vérification automatique) ; `rojo build` des
  deux places réussi.

Laissé ouvert :
- 39 textes d'interface absents de la bible (B1 ci-dessous) : les éléments ont un texte vide.
- Assets d'interface absents de 13.5 (B2).
- Aucun test dans Studio : affichage PC et mobile à vérifier en phase B (seul un aperçu
  approximatif a été fait ici, rendu des fichiers en HTML).

### 2026-11-04 (1) — session cloud, phase A1 (jalon J1)

- Dépôt Git et projet Rojo 7.7.1 (installé depuis crates.io) pour les places `Lobby` et `Partie` ;
  `CLAUDE.md`, `SUIVI.md`, `HANDOFF.md` ; arborescence de 16.1 ; modules `Config` et `Shared` ;
  28 RemoteEvents de 16.3 ; `DataService` ; `PartyService`, `MatchmakingService`,
  `LaunchService` ; `PartyLoaderService`, `ReturnService`. Aucun test en jeu possible.

## Phases

| Phase | Où | Jalons | Contenu | État |
|---|---|---|---|---|
| A1 | Cloud | J1 | Arborescence Rojo, Config, Shared, remotes, DataService, téléportation Lobby ↔ Partie | Fait (code) — à tester en phase B |
| A2 | Cloud | J5 | Toutes les UI en fichiers d'instances, noms de la section 15, `UI_MAP.md` | Fait (fichiers) — textes manquants (B1), à tester en phase B |
| A3 | Cloud | J6, J7, J8 | Joueur, objets, inventaire, tablette, documents, preuves, armes | À faire |
| A4 | Cloud | J9 | Actes, horloge, extractions, fins, cinématiques (scripts), lobby (scripts) | À faire |
| A5 | Cloud | J10, J11, J12 | IA complète de la famille, directeur de tension, événements inexpliqués | À faire |
| A6 | Cloud | J13, J14 (scripts) | Gore (deux profils), musée, dialogues, skins, records | À faire |
| A7 | Cloud | J2 (préparation) | Script `TerrainBuilder` complet, téléchargement des textures Poly Haven | À faire |
| A8 | Cloud | — | `rojo build` des deux places, liste de ce qui reste à faire dans Studio | À faire |
| B1 | Studio | J2, J3 | Lancer `TerrainBuilder`, vérifier les positions, poser la végétation | À faire |
| B2 | Studio | J4 | Lumière, brouillard, météo, sons : réglage à l'œil, captures | À faire |
| B3 | Studio | J0, J15 | Import des modèles 3D et animations, tests en jeu, mobile, équilibrage | À faire |

## Critères d'acceptation

J1 (18.2) :
- [ ] Un groupe de 2 part et revient — code écrit, non testé (téléportation possible seulement dans l'expérience publiée ; il faut aussi le contrôleur de `PartyGui`, A4).
- [ ] Données sauvegardées — code écrit, non testé.
- [ ] Zéro erreur console — non vérifiable sans Studio (zéro erreur de syntaxe vérifiée).

J5 (18.2) :
- [x] Aucun `Instance.new` d'UI dans le code.
- [ ] Affichage correct sur PC et mobile — non vérifiable sans Studio. Fait ici : tout en Scale,
      contraintes de 15.2, éléments contraints ancrés au centre, listes à hauteur calculée depuis
      la largeur, aperçu approximatif à 1280 × 720 et 844 × 390. À vérifier dans l'émulateur
      d'appareils de Studio (17.4).

## Questions encore ouvertes (TODO(BIBLE))

| # | Question | Bloque | Où |
|---|---|---|---|
| B1 | **Textes d'interface absents de la bible.** 39 éléments ont un texte vide : boutons Fermer / Confirmer / Prendre / Équiper / Continuer / Jeter / Envoyer / Lire, boutons du groupe (créer public, créer privé, rejoindre avec le code, quitter), titre « Groupe », texte d'aide du champ de code, aide « à terre », boutons et note du spectateur, 12 boutons mobiles, tailles de sous-titres « petite » et « grande », Appliquer / Réinitialiser. Liste complète avec mes propositions : `UI_MAP.md`, section « Textes absents de la bible ». | A2 complet | `tools/ui/build_ui.py` |
| B2 | **Images d'interface absentes de 13.5.** Vignettage de peur (`HUDGui/FearVignette`), portraits des 10 rôles (`RoleCard_<ROLE>/Portrait`), icônes des 3 armes (`WeaponBoardGui`), icônes d'objets (`Icon` de l'inventaire). Faut-il les ajouter à 13.5, et qui les crée ? En attendant : `ImageLabel` vides. | Affichage final | `tools/ui/build_ui.py` |
| B3 | Le départ S1 / S2 / S3 est-il tiré de façon équiprobable ? (valeur de gameplay) | J9 | `LaunchService` (équiprobable en attendant) |
| B4 | Difficulté transmise si personne n'a voté (valeur de gameplay). | J9 | `LaunchService` (aucune en attendant) |

## Décisions DÉFAUT (section 0)

Lancement et données (A1) :
- `LaunchConfig.MemoryStore.LaunchMapName = "Launch"` : carte de hachage qui contient les clés `Launch_`.
- Téléportation ratée : 3 essais, 5 s d'écart (`LaunchConfig.Teleport`), au départ comme au retour.
- File rapide et code privé : seulement les groupes du même serveur du lobby.
- Seul le groupe privé a un code.
- Un joueur déjà dans un groupe qui demande à créer ou rejoindre : la demande est ignorée sans message (l'interface masque ces boutons).
- Le créateur qui part est remplacé par le plus ancien membre restant (`MSG_HostLeft`).
- `MSG_Countdown` est envoyé une fois au début du compte à rebours (n = 10) ; `MSG_CountdownCancelled` à chaque arrêt d'un compte à rebours en cours (membre qui n'est plus prêt, qui part, ou nouveau membre).
- Partie hors serveur réservé (test dans Studio) : aucune configuration ; un joueur absent de la configuration, ou arrivé après 60 s, peut rester.
- Configuration de partie illisible : retour au Lobby avec `MSG_ReturnToLobby` (le seul message de 4.6 qui convient ; 4.6 n'en prévoit pas pour ce cas).
- `{player}` = nom d'affichage Roblox (`DisplayName`), transmis dans la configuration de partie.
- L'état du groupe passe par des attributs du joueur (`partyId`, `partyCode`, `partyHostId`, `isReady`, `partyCountdownEnd`).
- Le verrou de session est rangé dans les métadonnées de la clé DataStore.
- La graine (3.4) est tirée par le Lobby au départ du groupe et écrite dans la console des deux places.
- Les résultats renvoyés au Lobby voyagent dans les données de téléportation, pour l'affichage seulement.
- Limite de 16.3 appliquée par joueur et par remote.

Interfaces (A2) :
- Positions, tailles et ordre d'affichage (`DisplayOrder` : notifications 50, cinématiques 60, réglages 70, chargement 100) : réglages de départ, à retoucher à la main.
- Couleur « Hurt » des membres du HUD : rouge danger à moitié transparent (15.2 ne donne pas de couleur intermédiaire) ; « Ok » : vert mousse ; « Critical » : rouge danger.
- Menus cachés au départ (`Visible = false`), le contrôleur les montre ; HUD, inventaire rapide, objectifs et notifications visibles.
- Éléments ajoutés pour la lisibilité, marqués « décoratif » dans `UI_MAP.md` : titres « Difficulté » et « Météo » (4.4), nom de l'arme sur chaque emplacement (8.2), étiquettes des réglages (17.2).
- `SettingsGui/Window/Pages` : une page par onglet (`Graphics`, `Controls`, `Audio`, `Accessibility`), une ligne par réglage de 17.2 (noms anglais, ex. `Preset`, `FieldOfView`), options `Opt_<valeur>` ou curseur `Slider/Track/Fill` + `Value`. Ordre des onglets : celui du tableau 17.2.
- Cartes de rôle et tenues : `TextButton` sans texte (cliquables en entier) ; cartes ordonnées Meneur, Caméraman, puis l'ordre de 2.5 (4.4 : proposés en premier).
- Grille des rôles défilante (sur téléphone, 10 cartes ne tiennent pas avec un texte à 14 au minimum).
- Listes défilantes : chaque ligne a une hauteur calculée depuis sa largeur (`UIAspectRatioConstraint` en `ScaleWithParentSize`), pour rester tout en Scale.
- Boutons mobiles regroupés à droite au-dessus du bouton de saut de Roblox ; pencher à gauche et à droite au milieu gauche.
- Bandes de cinématique : hauteur calculée pour un format 2.35:1 sur un écran 16:9.
- `UITemplates` : `PingMarker` et `NameTag` (noms choisis).
- Polices : `SpecialElite` et `RobotoMono` existent dans `Enum.Font` (Rojo refuse un nom de police inconnu et a accepté ces deux) ; rendu à confirmer dans Studio (15.2).

## Questions réglées par la bible (pour mémoire)

Q1 `LaunchConfig` (16.1) · Q2 PlaceId (16.4) · Q3 identifiants des rôles (2.5) · Q4, Q5, Q9 valeurs
techniques acceptées (16.4) · Q6 et Q17 messages 4.6 · Q8 et Q12 clé `Launch_<PrivateServerId>`
et contrôle de version côté Partie (16.1, 16.4) · Q7, Q13, Q14, Q15, Q16, Q18, Q19 → DÉFAUT ·
Q20 (sol provisoire pour les tests) → DÉFAUT : rien dans les fichiers, Gabriel pose une plaque
provisoire dans Studio pour ses tests et la retire ensuite (voir `HANDOFF.md`).

Rappel : les décisions de la section 19.4 restent à trancher (Restricted 18+, langue, voix, etc.).

## Assets MANQUANT_

Aucun bloc `MANQUANT_<ID>` n'est encore placé. Assets marqués MANQUANT dans la section 13.3 :

| ID | Contenu | Jalon qui les place |
|---|---|---|
| `CHR_<ROLE>_Skin_A–C` | 10 humains réalistes avec squelette, découpés en 6 | J6 |
| `WPN_Revolver`, `WPN_Shotgun`, `WPN_FlareGun`, `MEL_Axe`, `MEL_Machete` | Armes | J8 |
| `Item_Tablet`, `Item_Camcorder`, `Item_Jerrycan`, `Item_CarBattery`, `Item_Jack`, `Item_ToolBox`, `Item_BearSpray`, `Item_Headlamp`, `Item_Flare`, `Item_Bandage`, `Item_Medkit` | Objets | J7 |

Images d'interface encore vides (voir B2) : `Img_TabletMap` et la couche « tunnels » (13.5, à créer),
illustrations du musée `Img_Museum_M1–M8` (13.5), vignettage de peur, portraits, icônes.
