# SUIVI — PISTE FROIDE

Tenu par les deux sessions (cloud et Studio), section 18.1 ter. Chaque session ajoute une
entrée au journal : date, ce qui est fait, ce qui reste ouvert.

Règle de la section 0 : une question qui ne touche ni un texte affiché aux joueurs, ni une
valeur de gameplay, ni un asset est tranchée par Claude Code et marquée **DÉFAUT**. Les autres
restent des `TODO(BIBLE)`. Une valeur marquée **PROVISOIRE** est une valeur de gameplay mise
seulement pour que le code tourne : elle attend la bible.

## État de reprise (à lire en premier)

- Session cloud du 2026-11-04 (3) : Gabriel a demandé d'enchaîner A3 → A8 sans s'arrêter.
- Phases terminées dans cette session : **A3**. En cours : A4. Restent : A5, A6, A7, A8.
- Outils de relecture de fin de phase : `stylua --check src`, `selene src`,
  `python3 tools/check_values.py` (0 nombre hors Config), `python3 tools/ui/check_ui.py`,
  puis `rojo build` des deux places.

## Journal des sessions

### 2026-11-04 (3) — session cloud, réponses B1–B4 puis phases A3 → A8

Réponses de la bible appliquées (commit `39d62eb`) : libellés 15.6 dans les interfaces,
images 13.5 (`Img_FearVignette` et 41 icônes `Icon_<ID>`, dessinées par script dans
`assets/ui/`), départ équiprobable (4.4), votes par défaut et égalités (5.4),
`MSG_LaunchConfigMissing` (4.6), `Portrait` en `ViewportFrame`.

**Phase A3 (J6, J7, J8)** — fait :
- Config : `PlayerConfig` (section 7 complète), `ItemConfig` (8, 8.1, 8.3, 8.4),
  `WeaponConfig` (8.2), `MapConfig` (section 3 complète : lieux, départs, extractions, zones,
  points tirés, tracés, biomes, génération), `ActConfig` (section 5), `AmbienceConfig` (12.1–12.4),
  `AudioConfig` (12.5, 12.6, 13.7 ; identifiants vides), `LoreConfig.Documents` (2.7).
- Serveur (Partie) : `NoiseService`, `InteractionService` (invites Custom, durées par rôle, ping),
  `CharacterService` (rôle, skin ou mannequin `MANQUANT_CHR_<ROLE>_Skin_<n>`, copie des ScreenGui),
  `SpawnService`, `HealthService` (6 membres, sang, hémorragies, à terre, relever, mort, ragdoll,
  sac au sol), `StaminaService` (postures, vitesses, endurance, bruits de pas), `FearService`
  (peur, cri involontaire, ordre du Meneur), `InventoryService` (emplacements, sac 12 kg, objets
  lourds, lampes et piles, soins, fusée, feu de camp, lancers, bombe anti-ours, capacités),
  `ItemSpawnService` (tirage 6 indices sur 12, objets clés, objets fixes, graine en console),
  `WeaponService` (validation, cadence, munitions, plombs, tir allié, mêlée, rechargement
  interruptible), `EvidenceService` (A/B/C, vidéo à 60 % visible, sauvegarde à l'extraction),
  `DocumentService` (journal, tablette des géologues, carnet), `TabletService` (DÉFAUT, voir plus bas).
- Client : `ClientBootstrap` (DÉFAUT) et les contrôleurs `InputController`, `CameraController`,
  `HUDController`, `InventoryController`, `InteractController`, `TabletController`,
  `DocumentController`, `DownedController`, `SpectatorController`, `RadioController`,
  `LightController`, `FearFXController` (Partie) et `NotificationController` (les deux).
- Relecture : StyLua et selene sans erreur ; `tools/check_values.py` : 0 nombre hors Config ;
  chemins d'UI tous présents ; `rojo build` des deux places réussi.

Non fait en A3 (bloqué par la bible) : porter un blessé (7.2, 7.7 : l'interaction n'est pas
décrite), indices « cachés » de la Descendante (8 studs : aucun indice n'est désigné comme
caché), voix comme bruit (7.8 : chat vocal non décidé, 19.4), sons (13.7 : à fournir).
`TreeWindController` (12.4) est laissé au jalon J3/J4 : il anime les os des arbres, qui ne
sont pas encore importés.

### 2026-11-04 (2) — session cloud, réponses de Gabriel + phase A2 (jalon J5)

- Bible Markdown ; réponses Q1–Q20 appliquées ; messages 4.6 ; 24 ScreenGui de la section 15
  et 2 BillboardGui générés par `tools/ui/build_ui.py` ; `UI_MAP.md` ; projets `*.serve.project.json`.

### 2026-11-04 (1) — session cloud, phase A1 (jalon J1)

- Dépôt Git, projet Rojo 7.7.1, `CLAUDE.md`, `SUIVI.md`, `HANDOFF.md`, arborescence 16.1,
  Config, Shared, 28 RemoteEvents, `DataService`, groupe, lancement, retour.

## Phases

| Phase | Où | Jalons | Contenu | État |
|---|---|---|---|---|
| A1 | Cloud | J1 | Arborescence Rojo, Config, Shared, remotes, DataService, téléportation Lobby ↔ Partie | Fait (code) — à tester en B |
| A2 | Cloud | J5 | Toutes les UI en fichiers d'instances, noms de la section 15, `UI_MAP.md` | Fait — à tester en B |
| A3 | Cloud | J6, J7, J8 | Joueur, objets, inventaire, tablette, documents, preuves, armes | Fait (code) — à tester en B |
| A4 | Cloud | J9 | Actes, horloge, extractions, fins, cinématiques (scripts), lobby (scripts) | En cours |
| A5 | Cloud | J10, J11, J12 | IA complète de la famille, directeur de tension, événements inexpliqués | À faire |
| A6 | Cloud | J13, J14 (scripts) | Gore (deux profils), musée, dialogues, skins, records | À faire |
| A7 | Cloud | J2 (préparation) | Script `TerrainBuilder` complet, téléchargement des textures Poly Haven | À faire |
| A8 | Cloud | — | `rojo build` des deux places, liste de ce qui reste à faire dans Studio | À faire |
| B1 | Studio | J2, J3 | Lancer `TerrainBuilder`, vérifier les positions, poser la végétation | À faire |
| B2 | Studio | J4 | Lumière, brouillard, météo, sons : réglage à l'œil, captures | À faire |
| B3 | Studio | J0, J15 | Import des modèles 3D et animations, tests en jeu, mobile, équilibrage | À faire |

## Critères d'acceptation (18.2)

En phase A rien ne se teste en jeu : « code » = écrit et relu, pas vérifié dans Roblox.

- J1 : [ ] groupe de 2 part et revient (code) · [ ] données sauvegardées (code) · [ ] zéro erreur console (non vérifiable ; zéro erreur de syntaxe)
- J5 : [x] aucun `Instance.new` d'UI · [ ] affichage correct PC et mobile (à vérifier dans l'émulateur)
- J6 : [ ] chaque valeur de la section 7 vérifiable dans `CreatureDebug` ou la console — les valeurs sont toutes dans `PlayerConfig` et lisibles en attributs du joueur ; `CreatureDebug` vient en A5
- J7 : [ ] 6 indices sur 12 tirés (code) · [ ] graine affichée (code : console de `ItemSpawnService`) · [ ] preuves sauvegardées après extraction (code : `EvidenceService:CommitForSurvivor`, appelé par l'extraction en A4)
- J8 : [ ] tir impossible sans munitions (code) · [ ] cadence respectée (code) · [ ] tir allié seulement en Difficile et Cauchemar (code)

## Questions encore ouvertes (TODO(BIBLE))

Chaque ligne correspond à un marqueur `TODO(BIBLE)` dans le code. Rien ne bloque la suite des
phases A ; ces points bloquent le réglage final.

| # | Question | Où | En attendant |
|---|---|---|---|
| C1 | Distance à laquelle un joueur « voit » un corps (+15 peur) et la créature (+20 à +35). | `PlayerConfig.Fear` | Hausses non appliquées |
| C2 | Qu'est-ce qui déclenche une hémorragie légère ou grave (seuil de dégâts, attaque) ? | `PlayerConfig.BleedOnDamage` | Seules les attaques qui le précisent font saigner |
| C3 | Un coup reçu à terre tue-t-il ? | `PlayerConfig.Technical.DownedDamageKills` | PROVISOIRE : oui |
| C4 | Sur quel membre agissent le bandage et la trousse ? | `PlayerConfig.HealTarget` | PROVISOIRE : le plus abîmé |
| C5 | Sang rendu au joueur relevé après être tombé faute de sang. | `PlayerConfig.ReviveBlood` | PROVISOIRE : 20 |
| C6 | Porter un blessé : comment le prendre et le poser (7.2, 7.7) ? | — | Non fait (vitesses prêtes dans `PlayerConfig`) |
| C7 | Quels indices sont « cachés » (visibles par la Descendante à 8 studs) ? | — | Non fait |
| C8 | Nombre de fusées à main du Pyrotechnicien au départ. | `ItemConfig.StartingItems` | PROVISOIRE : 1 |
| C9 | Poids des preuves et des munitions. | `ItemConfig.Items` | PROVISOIRE : 0 kg |
| C10 | Distance et vitesse d'un lancer (pierre, branche). | `ItemConfig.Throw` | PROVISOIRE : 40 studs/s, 1 s |
| C11 | Bruit du piège à bruit du Pyrotechnicien. | `ItemConfig.NoiseTrapRadius` | Piège désactivé |
| C12 | Munitions au départ (chargeur plein ? réserve ?). | `InventoryService` | PROVISOIRE : chargeur plein, réserve 0 |
| C13 | Fusil à pompe : forme de la baisse entre 15 et 40 studs, portée au-delà, écart des plombs. | `WeaponConfig` | PROVISOIRE : linéaire, plombs dans l'axe |
| C14 | Pistolet lance-fusées : cadence et brûlure sur un coéquipier ; munitions de réserve. | `WeaponConfig` | Cadence = rechargement (2 s) |
| C15 | Qui porte la machette au départ, ou où est-elle ? | `WeaponConfig` | Personne |
| C16 | Portée des armes de mêlée. | `WeaponConfig.MeleeRange` | PROVISOIRE : 7 (portée du coup de la créature) |
| C17 | Quantité de chaque objet sur C09–C12 et aux lieux fixes de 8.1. | `MapConfig` | PROVISOIRE : 1 |
| C18 | 12.3 « endurance ×0,85 » par neige : sur le maximum, la dépense ou la récupération ? | `StaminaService` | PROVISOIRE : récupération |
| C19 | Textes d'objectif des actes 3 et 4 pour E1, E3, E4 (CS_07 ne donne que l'exemple de E2). | `ActConfig.Objectives` | Vides |
| C20 | Cadence des pierres pendant le siège. | `ActConfig.Siege.StoneInterval` | Réglée avec l'IA (A5) |
| C21 | Période du cycle en sinus des rafales de pluie ; intervalle des rafales de neige. | `AmbienceConfig` | — |
| C22 | Ce qui allume l'indicateur `RadioGui/Talking` (dépend du chat vocal, 19.4). | `RadioController` | Caché |

Interprétations à confirmer (non bloquantes) : « bruit des 10 dernières secondes » (9.7) = le
bruit le plus fort émis pendant ces 10 s ; « la Médecin soigne ×2 » = deux fois plus vite.

## Décisions DÉFAUT (section 0)

Lancement et données (A1) :
- Carte de hachage MemoryStore « Launch » ; 3 essais de téléportation à 5 s ; file rapide et code limités au serveur du lobby ; seul le groupe privé a un code ; demande ignorée si le joueur a déjà un groupe ; le plus ancien membre remplace le créateur ; `MSG_Countdown` envoyé une fois au début ; partie de test sans configuration dans Studio (Normal, aléatoire, S1, rôles dans l'ordre) ; `{player}` = `DisplayName` ; état du groupe en attributs ; verrou dans les métadonnées DataStore ; graine tirée au départ du groupe ; résultats dans les données de téléportation (affichage seulement) ; limite 16.3 par joueur et par remote.

Interfaces (A2) :
- Positions, tailles, `DisplayOrder` (notifications 50, cinématiques 60, réglages 70, chargement 100) ; couleur « Hurt » = rouge à moitié transparent ; menus cachés au départ ; éléments décoratifs ajoutés (titres « Difficulté », « Météo », nom de l'arme, étiquettes des réglages) ; pages et lignes de `SettingsGui` ; cartes et tenues en `TextButton` ; grille des rôles défilante ; lignes de listes à hauteur calculée depuis la largeur ; boutons mobiles au-dessus du saut ; bandes 2.35:1 calculées pour un écran 16:9 ; `PingMarker` et `NameTag` ; libellés courts hors 15.6 : « Groupe », « Petite », « Grande », et les invites (« Ramasser », « Relever », « Barricader », « Réparer », « Changer la roue », « Appeler », « Conduire », « Dégager le bouchon », « Ouvrir »).

Joueur, objets, armes (A3) :
- `TabletService` ajouté (16.2 ne nomme pas le service de `RE_TabletAction`) ; `ClientBootstrap` charge les contrôleurs ; état partagé dans `ReplicatedStorage/MatchState` (attributs : journal, preuves, repères, couche tunnels, carnet).
- Numéros d'emplacement : 1..N rapides, N+1.. sac ; `RE_UseItem(0)` = capacité du rôle.
- Inventaire publié en attribut JSON `inventory` ; munitions de réserve rangées en objets `AMMO_<arme>` (pile de 99) ; preuves = objets `EVD_*` et `ITM_SDCard`.
- Objet lourd porté = mains prises, même s'il n'est pas sélectionné ; il reste en main.
- Lampe torche et lampe puissante : allumées seulement en main ; frontale : partout.
- Fusée posée aux pieds ; feu de camp posé devant le joueur ; lancer dans la direction du personnage.
- Pluie : le facteur 0,6 est appliqué une seule fois, par la perception (12.3 et 9.4 décrivent le même effet).
- Tirage des indices : les 4 documents tirés reçoivent chacun un point compatible distinct, les 2 autres points sont pris parmi C09–C12 ; appareil photo de C03–C06 posé sur un de ces points s'il est tiré.
- Points de départ alignés d'ouest en est ; `Workspace/SpawnPoints` et `Workspace/CluePoints` (Part nommées comme les codes) remplacent les coordonnées si Gabriel en pose.
- Touches : Maj courir, C accroupi, X couché, Q/E se pencher (= A/E en AZERTY, 7.2), T lampe, R recharger, Tab tablette, G signaler, B sac, V capacité, F interagir, 1–4 emplacements ; manette : L3, B, R2, L2, Y, X.
- Durée de maintien propre au joueur : attribut `hold_<UserId>` sur l'invite, vérifié par le serveur (marge 0,3 s).
- Personnage absent : mannequin Roblox neutre (`HumanoidDescription` vide) nommé `MANQUANT_CHR_<ROLE>_Skin_<n>`.
- Tablette : « sommet » de P11 / P23 = dans le rayon et au niveau de la cabine ; le Géologue est le seul à voir son point dans les tunnels.
- Valeurs d'affichage et techniques regroupées dans `PlayerConfig.Interface`, `PlayerConfig.Technical`, `PlayerConfig.Keys`, `ItemConfig` (bloc gris, placement, visuels du feu).

## Assets MANQUANT_

Aucun bloc `MANQUANT_<ID>` n'est posé à la main ; les scripts en créent quand le modèle manque :
- `MANQUANT_CHR_<ROLE>_Skin_<n>` (mannequin) par `CharacterService` ;
- `MANQUANT_Item_<Nom>` (bloc gris 1 × 1 × 1) par `ItemSpawnService` pour chaque objet du monde.

| ID (13.3) | Contenu | Utilisé par |
|---|---|---|
| `CHR_<ROLE>_Skin_A–C` | 10 humains réalistes avec squelette, découpés en 6 | `CharacterService`, `RoleSelectGui/Portrait` |
| `WPN_Revolver`, `WPN_Shotgun`, `WPN_FlareGun`, `MEL_Axe`, `MEL_Machete` | Armes | `ItemSpawnService` |
| `Item_Tablet`, `Item_Camcorder`, `Item_Jerrycan`, `Item_CarBattery`, `Item_Jack`, `Item_ToolBox`, `Item_BearSpray`, `Item_Headlamp`, `Item_Flare`, `Item_Bandage`, `Item_Medkit` | Objets | `ItemSpawnService` |

Images et sons : `assets/ui/png` (vignettage, icônes) à importer dans Studio ; `Img_TabletMap`,
couche tunnels, `Img_DOC06`, `Img_DOC16`, `Img_Museum_M1–M8`, `Img_News_CS14` à créer (13.5) ;
tous les sons de 13.7 à fournir.
