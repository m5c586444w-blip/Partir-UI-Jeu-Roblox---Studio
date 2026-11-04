# SUIVI — PISTE FROIDE

Tenu par les deux sessions (cloud et Studio), section 18.1 ter. Chaque session ajoute une
entrée au journal : date, ce qui est fait, ce qui reste ouvert.

## Journal des sessions

### 2026-11-04 — session cloud, phase A1 (jalon J1)

Fait :
- Dépôt Git et projet Rojo (Rojo 7.7.1, installé ici depuis crates.io) pour deux places,
  `Lobby` et `Partie`. `rojo build` des deux places réussi : `builds/Lobby.rbxlx`, `builds/Partie.rbxlx`.
- `CLAUDE.md`, `SUIVI.md`, `HANDOFF.md`.
- Arborescence de 16.1 (dossiers vides compris).
- 14 modules `Config` : les 13 de 16.1 (squelettes, sauf ceux dont J1 a besoin) et
  `LaunchConfig`, ajouté (voir Q1).
- `Shared` : `Types`, `Util`, `Signal`, `RateLimiter`, `NoiseTypes` (squelette), `Version`.
- Les 28 RemoteEvents de 16.3, en fichiers d'instances.
- `DataService` (les deux places) : DataStore `PisteFroide_v1`, clé `player_<UserId>`,
  verrou de session, sauvegarde toutes les 120 s et à la fermeture.
- Lobby : `PartyService` (groupes, codes, prêt, compte à rebours de 10 s),
  `MatchmakingService` (carte triée « Parties », 900 s), `LaunchService` (configuration
  en MemoryStore, 600 s, serveur réservé, téléportation).
- Partie : `PartyLoaderService` (lit la configuration, attend les joueurs 60 s au plus,
  vérifie la version), `ReturnService` (retour au Lobby avec les résultats).
- Relecture : StyLua lit tous les fichiers Luau sans erreur ; aucune valeur chiffrée hors `Config`.

Laissé ouvert :
- Aucun test en jeu possible en phase A : les critères de J1 se testent en phase B (voir `HANDOFF.md`).
- Les questions Q1 à Q20 ci-dessous.
- `BIBLE_PISTE_FROIDE.md` n'est pas dans le dépôt : seule la version PDF a été fournie
  (copiée en `BIBLE_PISTE_FROIDE.pdf`). L'export Markdown est à faire par Gabriel (18.1).

## Phases

| Phase | Où | Jalons | Contenu | État |
|---|---|---|---|---|
| A1 | Cloud | J1 | Arborescence Rojo, Config, Shared, remotes, DataService, téléportation Lobby ↔ Partie | Fait (code) — à tester en phase B |
| A2 | Cloud | J5 | Toutes les UI en fichiers d'instances, noms de la section 15, `UI_MAP.md` | À faire |
| A3 | Cloud | J6, J7, J8 | Joueur, objets, inventaire, tablette, documents, preuves, armes | À faire |
| A4 | Cloud | J9 | Actes, horloge, extractions, fins, cinématiques (scripts), lobby (scripts) | À faire |
| A5 | Cloud | J10, J11, J12 | IA complète de la famille, directeur de tension, événements inexpliqués | À faire |
| A6 | Cloud | J13, J14 (scripts) | Gore (deux profils), musée, dialogues, skins, records | À faire |
| A7 | Cloud | J2 (préparation) | Script `TerrainBuilder` complet, téléchargement des textures Poly Haven | À faire |
| A8 | Cloud | — | `rojo build` des deux places, liste de ce qui reste à faire dans Studio | À faire |
| B1 | Studio | J2, J3 | Lancer `TerrainBuilder`, vérifier les positions, poser la végétation | À faire |
| B2 | Studio | J4 | Lumière, brouillard, météo, sons : réglage à l'œil, captures | À faire |
| B3 | Studio | J0, J15 | Import des modèles 3D et animations, tests en jeu, mobile, équilibrage | À faire |

## Critères d'acceptation de J1 (18.2)

- [ ] Un groupe de 2 part et revient — code écrit, non testé (impossible sans Studio ; la
      téléportation ne marche que dans l'expérience publiée, et les PlaceId sont à renseigner, Q2).
- [ ] Données sauvegardées — code écrit, non testé (DataStore indisponible ici).
- [ ] Zéro erreur console — non vérifiable sans Studio. Vérifié en phase A : zéro erreur de
      syntaxe (StyLua), aucune valeur hors `Config`.

## TODO(BIBLE) et questions pour Gabriel

Chaque question correspond à un marqueur `TODO(BIBLE)` dans le code (fichier indiqué).
« PROPOSITION » = une valeur provisoire a été mise pour que le code tourne ; elle est à
confirmer ou à remplacer.

| # | Question | Où | Provisoire |
|---|---|---|---|
| Q1 | 16.1 ne liste aucun module Config pour le groupe, le lancement, MemoryStore et la limite des remotes. J'ai ajouté `Config/LaunchConfig`. D'accord, ou ailleurs ? | `Config/LaunchConfig` | Module ajouté |
| Q2 | PlaceId des places Lobby et Partie (connus après publication). | `Config/LaunchConfig` | 0 = pas de téléportation |
| Q3 | Identifiants anglais des 9 rôles autres que `Leader` (utilisés dans `RoleCard_<ROLE>`, `Characters/<ROLE>`, `VO_<ROLE>_*` et les données `skins`/`equipped`). Proposition : `Medic`, `Tracker`, `Cameraman`, `Mechanic`, `Descendant`, `Geologist`, `Athlete`, `RadioOperator`, `Pyrotechnician`. | `Config/PlayerConfig` | Rôles sans id ignorés |
| Q4 | Verrou de session : au bout de combien de secondes un verrou non rafraîchi est-il abandonné ? | `Config/ProgressionConfig` | PROPOSITION 360 s |
| Q5 | Verrou tenu par l'autre place pendant une téléportation : combien d'essais de chargement, et à quel intervalle ? | `Config/ProgressionConfig` | PROPOSITION 6 essais, 5 s |
| Q6 | Que faire d'un joueur dont les données restent verrouillées ou illisibles (l'expulser, le laisser jouer sans sauvegarde) ? | `DataService` | Il joue, rien n'est sauvegardé |
| Q7 | 16.4 nomme la clé `Launch_<code d'accès>` mais pas la structure MemoryStore qui la contient. | `Config/LaunchConfig` | Carte de hachage « Launch » |
| Q8 | La Partie ne peut pas lire son code d'accès, seulement `game.PrivateServerId`. La clé devient `Launch_<PrivateServerId>`. D'accord ? | `LaunchService` | `Launch_<PrivateServerId>` |
| Q9 | Essais et délai en cas d'échec d'un appel MemoryStore. | `Config/LaunchConfig` | PROPOSITION 3 essais, 2 s |
| Q10 | Le départ S1/S2/S3 est-il tiré de façon équiprobable ? | `LaunchService` | Équiprobable |
| Q11 | Difficulté transmise si personne n'a voté (J9). | `LaunchService` | Aucune (nil) |
| Q12 | 16.1 : « le Lobby refuse de téléporter si la Partie n'a pas la même version ». Le Lobby ne peut pas connaître la version de la Partie avant d'y envoyer le groupe. D'accord pour que la Partie compare et renvoie le groupe au Lobby ? | `PartyLoaderService` | La Partie renvoie le groupe |
| Q13 | File « Rejoindre un groupe » : un groupe public ouvert sur un autre serveur du lobby doit-il être proposé (téléportation vers ce serveur) ? | `MatchmakingService` | Seuls les groupes du même serveur |
| Q14 | Un code privé doit-il trouver un groupe ouvert sur un autre serveur du lobby ? | `PartyService` | Même serveur seulement |
| Q15 | Un groupe public a-t-il aussi un code ? | `PartyService` | Non |
| Q16 | File rapide sans groupe public disponible : créer un groupe, ou rien ? | `PartyService` | Rien + notification |
| Q17 | Textes des notifications du lobby et de la Partie (groupe complet, code introuvable, aucun groupe public, déjà dans un groupe, départ raté, versions différentes, configuration introuvable). | `Config/LoreConfig` | Chaînes vides |
| Q18 | Partie hors serveur réservé (test dans Studio) : faut-il une configuration de test ? Et un joueur absent de la configuration, ou arrivé après 60 s, peut-il rester ? | `PartyLoaderService` | Pas de configuration ; il reste |
| Q19 | Retour au Lobby raté : nouvel essai, après quel délai ? | `ReturnService` | Avertissement seulement |
| Q20 | Pour tester J1 avant le lobby (J14) et le terrain (J2), les joueurs tombent dans le vide : puis-je poser une plateforme provisoire sous L01 (0, 5, 120) et sous S1–S3, ou Gabriel en pose-t-il une à la main dans Studio ? | `HANDOFF.md` | Rien de posé |

Choix techniques faits sans la bible (à relire, pas bloquants) :
- L'état du groupe passe par des attributs du joueur (`partyId`, `partyCode`, `isReady`,
  `partyCountdownEnd`), comme les jauges (16.3), car 16.3 ne prévoit pas de remote serveur → client pour le groupe.
- Le verrou de session est rangé dans les métadonnées de la clé DataStore : la valeur garde exactement le format de 16.4.
- La graine (3.4) est tirée par le Lobby au départ du groupe (16.4 la range dans la configuration) et écrite dans la console des deux places.
- Les résultats renvoyés au Lobby voyagent dans les données de téléportation, pour l'affichage seulement ; les gains sont sauvegardés par la Partie.
- Le compte à rebours s'annule si un membre n'est plus prêt, part, ou si un joueur rejoint le groupe.
- Limite de 16.3 appliquée par joueur et par remote.
- `RE_Notify` et `RE_PlayCinematic` sont présents dans les deux places (NotificationController et CinematicController existent dans les deux, 16.2) ; les autres remotes sont rangées selon 16.3.

Rappel : les décisions de la section 19.4 restent à trancher (Restricted 18+, langue, voix,
corrections, nouveautés, noms des personnages, modèles humains, créature, chat vocal, mode
« La nuit suivante »).

## Assets MANQUANT_

Aucun bloc `MANQUANT_<ID>` n'est encore placé (J1 n'utilise aucun asset).
Assets marqués MANQUANT dans la section 13.3, à remplacer par un bloc gris le moment venu :

| ID | Contenu | Jalon qui les place |
|---|---|---|
| `CHR_<ROLE>_Skin_A–C` | 10 humains réalistes avec squelette, découpés en 6 | J6 |
| `WPN_Revolver`, `WPN_Shotgun`, `WPN_FlareGun`, `MEL_Axe`, `MEL_Machete` | Armes | J8 |
| `Item_Tablet`, `Item_Camcorder`, `Item_Jerrycan`, `Item_CarBattery`, `Item_Jack`, `Item_ToolBox`, `Item_BearSpray`, `Item_Headlamp`, `Item_Flare`, `Item_Bandage`, `Item_Medkit` | Objets | J7 |
