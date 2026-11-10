# HANDOFF A1 : état après les phases A et B (région EST), 10/11/2026

Rédigé par l'opérateur Studio. Ce qui est **mesuré** est marqué [mesuré] (raycast ou voxels, ou somme de contrôle recalculée par l'opérateur) ; [rapport agent] = repris d'un rapport, non re-mesuré ; [non testé] = jamais exécuté.

## 1. État
- **Git** (dépôt `m5c586444w-blip/Partir-UI-Jeu-Roblox---Studio`, branche `studio/local-2026-11-07`) : `fe35644` (poussé par Gabriel) → `d86b4ec` (export Studio : 18 modules, wiki, placements) → **`ab4e968`** (phases A et B : 19 fichiers, +1539/−203) ; le distant est à `ab4e968` [mesuré, `git ls-remote`]. Rien dans `src/`, `builds/`, `docs/bible/`. Fichiers non suivis ignorés : `.codex/`, `AGENTS.md`. La branche distante `integration/2026-11-10` (`4477c9b`) n'est pas de l'opérateur Studio.
- **Studio** : place « Partie » (placeId 103506696801797), mode Edit au dernier relevé. Dossier `ServerStorage/TerrainSectors` (Folder, 22 ModuleScripts, nom conservé par décision de la coordinatrice, DÉFAUT : évite la collision avec le ModuleScript `TerrainBuilder` du dépôt Rojo).
- **Sauvegardes `.rbxl`** (`Documents\Roblox, jeu bigfoot, projet hagrahh\Sauvegardes\`) : `Partie_2026-11-10.rbxl` (16:26, avant A), `Partie_apres_A1_A.rbxl` (18:18). **`Partie_apres_A1_B.rbxl` : pas encore enregistré** (à faire par Gabriel après la phase B).
- **La place ne contient pas le code du dépôt** : `ServerScriptService` vide, 0 `ScreenGui`, pas de `ReplicatedStorage/Config` (vidée le 08/11 sur ordre de Gabriel ; le contenu d'alors ressemblait au build Rojo du 07/11).

## 2. Mesures de la région EST
- **Cibles bible 3.2** [mesuré, raycast terrain, tout à ±5] : P01 122,0 (cible 120) ; P02 sud 109,6 (110) ; P02 nord 382,5 (380) ; P03 fond 37,8 (40) ; P05 401,6 (400) ; P05c 302,0 (300) ; P05s 331,7 (330) ; P15 392,0 (390) ; P23 562,0 (560) ; P24 302,0 (300) ; départ S1 122,0 (120).
- **P16** [mesuré, datamodel Server pendant un Play] : tablier du pont de Gabriel 152,2 à 153,5 (cible 150), eau à Y 100,0 (cellule d'eau jusqu'à ~100,3), lit 97,9, pièces ancrées 74/74. Le pont est à (3467, 133,6, 1600), axe ≈ est-ouest.
- **Ponceau RD1 × R2** [rapport B3 ; `Appliquer()` relancé par l'opérateur : 0 cellule modifiée, donc intact] : 26 trous d'eau avant, 0 après (125 échantillons), eau monotone, hauteur libre min 16,75, chaussée 100 % Asphalt, pente RD1 8,00 % (données) / 8,07 % (voxels, accepté).
- **Coutures** [rapport B1 ; `Raccords_EST.Appliquer()` relancé après B4 : durée 7,1 s, correction max 0,52 ouest / 27,09 nord] : écart à la pente médiane 0,1 à 0,5, max 0,9 à 2,5 ; saut brut ±4 jusqu'à 7,5 (S3↔S4) = pente naturelle ; X=1500 contre S2 : 26,9 → 5,8 max.
- **T1 / branche P05** [rapport B4] : T1 1 540 échantillons, 99,4 % Ground, 0 saut > 4 ; sortie en (1500, −2240), Y 322 ; branche P05 162 échantillons, 99,4 % Ground.
- **Pathfinding (mode Edit)** [rapport agents] : P01→P05 par T1, P15↔P05 (joueur et créature 10×4, 9 étapes, route en grande partie sur T4), RD1 de bout en bout (4 trajets, joueur et créature), P16→P15, spur→pont : réussis.

## 3. Modules (ServerStorage/TerrainSectors) et sommes recalculées [mesuré, 22/22 identiques entre Studio et `studio-export/terrain/`]
Somme = h ← (h·31 + octet) mod 2³² sur les octets sans CR ; (taille : somme).
Alignement_EST 4218 : 2695166297 · HauteurEST 487 : 270032142 · HauteurGlobale 3199 : 3315308139 · MelangeMateriaux 4970 : 2225053288 · Ponceau_RD1 11518 : 3830865520 · Raccords_EST 12637 : 3211957102 · S1Donnees 12324 : 3396266743 · S1Terrain 3422 : 659971472 · S2Donnees 12755 : 1615773608 · S2Terrain 4759 : 1198036626 · S3Donnees 23109 : 1309579070 · S3Terrain 3456 : 312476561 · S4Donnees 9140 : 482697921 · S4Terrain 2667 : 2856209471 · S5Donnees 18195 : 3755284885 · S5Terrain 3970 : 3041516267 · S6Donnees 14638 : 1542874453 · S6Terrain 4884 : 1182426630 · S7Donnees 17413 : 1429997213 · S7Terrain 3184 : 2057108831 · S8Donnees 14914 : 4152324195 · S8Terrain 3559 : 3041272855.

## 4. Ordre de relance
L'ordre complet, avec les appels exacts, est dans **`ORDRE_RECONSTRUCTION.md`** (même dossier). Résumé : S4 → S5 → bande sud de S4 (`S6Terrain.ReecrireBandeS4(i)`, i = 0..10) → S6 → sentiers cave et poste (`EcrireSentierCave`, `EcrireSentierPoste(0..3)`) → S1 → S2 (sans `Raccord`) → S7 → S3 → S8 « M » puis « O » → `Raccords_EST.Appliquer()` puis `Mesurer()` → `Ponceau_RD1.Appliquer()` (après toute reconstruction de S7 touchant les chunks (8,7) et (8,8), sans effet s'il est intact) → polissage. `S4Terrain.Nettoyer()` appelle en réalité `Terrain:Clear()` (à ne pas lancer). `Corr3` : ne jamais l'appeler après S3 (doublon déjà dans `S3Donnees` ; à retirer côté S2 si S2 est reconstruit).
**Attention : T1 et la branche P05 ont été écrits par un constructeur de tuiles temporaire de l'agent B4, non exporté et détruit.** Une reconstruction complète par `S3Terrain.Construire` avec les nouvelles données doit produire le même tracé, mais l'équivalence n'a jamais été vérifiée [non testé].

## 5. Pièges du connecteur Studio (MCP)
- `execute_luau` renvoie toujours `nil` : retourner un résultat par `error("TEXTE")` (le message est affiché) ou par un attribut temporaire de `workspace` lu avec `inspect_instance` (qui tronque une chaîne à ~700 caractères : découper en attributs courts). La console est cumulative et très longue : ne pas la relire.
- Un identifiant Luau avec un accent fait échouer l'analyse (« Failed to parse command code »). `Instance` hors Play : `Edit` est refusé quand Studio est en mode Play (Gabriel qui teste) ; mesurer alors en datamodel `Server`.
- Cache de `require` : après modification d'un ModuleScript, cloner `ServerStorage/TerrainSectors` dans un dossier temporaire puis `require` le clone ; détruire le clone (plusieurs clones ralentissent Studio).
- Appels longs : rester sous 30 s par appel (`task.wait()` entre les blocs) ; quelques appels ont répondu « not reachable » alors que le code s'était exécuté : lire l'état avant de relancer.
- `WriteVoxels` ignore l'eau écrite dans une cellule qui garde une occupation résiduelle : vider puis écrire. `Terrain:Clear` interdit (efface tout). Voxels de 4 studs : rendu des matériaux décalé d'environ 2 studs.
- `screen_capture` expire souvent et place parfois la caméra dans le terrain : mesures plutôt que captures. `multi_edit` avec `replace_all` n'a pas été appliqué : vérifier par hash.
- HttpService et le réseau local sont refusés depuis Studio ; `AssetImportService` inaccessible ; l'import passe par `open_cloud_invoke` (dossier d'upload approuvé) puis `insert_asset`.
- Le classifieur de permissions refuse les écritures qui réécrivent des colonnes d'un autre secteur dans un contexte de sous-agent (accepté dans le contexte principal après accord explicite de Gabriel).
- La limite d'usage de 5 h a coupé des agents (leurs fichiers de sortie font alors 0 octet : pas d'historique d'erreurs).
- Git : l'authentification se fait par Gabriel (PowerShell) ; envoi avec `git -c http.version=HTTP/1.1 push` ; avertissements « LF → CRLF » sans gravité ; ne jamais commiter `.codex/` ni `AGENTS.md`.

## 6. Ce qui reste (phase C et au-delà) : état « non fait »
1. **Lacets locaux** (décision coordinatrice, début de phase C), sans refaire 2 000 studs : T4 au gué d'Ape (110 % sur 12 studs en (2759, −292)), accès à la ruine P05c (36,6 % mesuré, doit rester accessible), branche P05 (20,2 % sur 24 studs en (2588, −1678)).
2. Lisser les marches du remblai du ponceau ; couloir créature strictement hors T4 (non testé) ; T4 91–92 % Ground (règle de `MelangeMateriaux`) ; lahar bord est +11 par endroits.
3. Marge nord de S3 à X > 1700 : chute de 45 conservée (provisoire) ; côté S2 de la couture X=1500 (reste 5,8 max, 8 échantillons > 4) : ticket CENTRE ; doublon `S2.Corr3`.
4. **Non testé** : P01→P16 de bout en bout (franchissement du pont), tout play test, toute capture exploitable ; pathfinding sur les bandes de coutures réécrites ; validation visuelle de Gabriel.
5. Polissage (`BRIEF_POLISSAGE.md` : eau variée, mares, micro-relief, transitions de matériaux, détails de lieux) : jamais exécuté ; agent Textures (seul à toucher `MaterialService`) : jamais exécuté.
6. Autres régions (CENTRE, OUEST, NORD-OUEST) : positions et altitudes non alignées sur la bible 3.2 (P22 → ticket OUEST). Nettoyage en attente : S2 (`MANQUANT_StationMeteo` et `Lieu_23` en ≈(350, −2200)), S7 (`Lieu_22_Epave`, `MANQUANT_EpaveVoiture`), `Workspace.TEMP_Raccords_Out`, `Workspace.TEST_Rock09` (suppressibles après sauvegarde selon la coordinatrice ; non supprimés), `TEMP_out` et `MaterialService/AssistantMaterials` à laisser.
7. Gabriel : enregistrer `Partie_apres_A1_B.rbxl` ; valider visuellement la région EST.

## 7. DÉFAUTS PROPOSÉS (aucun appui dans la bible)
Raccords_EST : `Fondu` 240, `Pas` 8, `Lissage` 2, `Recul` 10, `Biais` 2,0, `MaxCorr` 30, `Nord` {X0 1500, Fondu 200, Z −2560..−2400}. Ponceau : `DemiLargeur` 16, `LibreMin` 6, voûte à 8 au centre, Concrete/Rock (validés). `PenteT1` 0,14. Définition du « saut » de couture : écart à la pente (à valider). Nom `TerrainSectors`.
