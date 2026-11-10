# Objets interactifs : écarts entre la bible et le code (ticket T04B, 2026-11-10)

Lecture seule. Aucun service créé, aucune règle de gameplay ajoutée. Sources lues : bible 8 (8.1 à 8.4),
15.1, 15.4 (`InteractGui`), 16.2, 16.3 ; `InteractionService`, `ItemSpawnService`, `InventoryService`,
`ItemConfig`, `InteractController`. Numéros de ligne : branche `integration/2026-11-10`.

## 1. Tableau

| La bible demande | Le code fait déjà (fichier:ligne) | Ce qui manque |
| --- | --- | --- |
| 16.3 : les interactions passent par des `ProximityPrompt` dont `Triggered` arrive côté serveur | `src/server/Partie/Services/InteractionService.luau:40` (`CreatePrompt`, style Custom, `Triggered` serveur l. 61) | Rien |
| 16.2 : `ProximityPrompt` pour les réparations, les barricades, les soins | réparations : `src/server/Partie/Services/ExtractionService.luau:130` ; barricades : `src/server/Partie/Services/GameStateService.luau:226` ; relever, porter, poser un blessé : `src/server/Partie/Services/HealthService.luau:211`, `:304`, `:320` | Les soins par objet (bandage, attelle, trousse) passent par `RE_UseItem` sur soi (`InventoryService.luau:575`, `:583`, `:590`), pas par une invite sur un coéquipier. La bible (7.3, 8.1) ne dit pas si l'on peut soigner un autre joueur : **question** |
| 0 règle 5 : le serveur décide | durée de maintien vérifiée au serveur (`InteractionService.luau:65`–`71`, tolérance `PlayerConfig.Technical.HoldTolerance`) ; ramassage validé au serveur (`InventoryService.luau:317`) | Rien |
| 7.7 / 8.1 : durées propres au rôle et à la caisse à outils | attribut `hold_<UserId>` écrit par le serveur (`InteractionService.luau:29`–`35`), lu par le client (`src/client/Partie/Controllers/InteractController.luau:29`) | Rien |
| 15.4 : `InteractGui` > `Prompt` > `KeyHint`, `ActionText`, `Progress` > `Fill` | `InteractController.luau:52`–`58` (chemins), `:35`–`37` (texte), `:78`–`83` (jauge `Fill`) | Rien |
| 15.1 : les scripts ne changent que `Text`, `Visible`, `Fill.Size.X.Scale`… ; élément introuvable = un avertissement | `InteractController.luau` ne touche que `Visible`, `Text`, `Fill.Size` ; `Util.findUI` avertit | Rien |
| 16.3 : `RE_PickupItem`, distance ≤ 10 studs | `InventoryService.luau:326` (`ItemConfig.PickupDistance` = 10, `ItemConfig.luau:11`) ; remote branché l. 842 | Rien |
| 16.3 : `RE_EquipSlot`, `RE_UseItem`, `RE_DropItem` (objet présent, pas en action) ; 10 appels/s | `InventoryService.luau:833`–`847`, `RateLimiter.connect` l. 865 ; `Equip` l. 356, `Use` l. 738, `Drop` l. 259 | Rien |
| 8 : 4 emplacements (3 Mécanicienne), sac 12 kg, objet > 5 kg à deux mains | `InventoryService.luau:62`–`66`, `:226`, `:57`, `:94`, `:363` ; `ItemConfig.luau:6`–`8` | Rien |
| 8.1 : les 35 identifiants `ITM_*` | tous présents dans `ItemConfig.Items` (contrôle par script, 2026-11-10) | Rien |
| 8.1 : objets posés aux lieux (Où) ; 3.4 : points C/K/A/J/R tirés | `src/server/Partie/Services/ItemSpawnService.luau:290` (`spawnAll` : indices, objets clés, objets fixes, documents), `:203` (branches et pierres au sol, 19.6 C17) | Rien côté code |
| 13.3 : modèles des objets (`Item_Walkie`, `Item_PhotoCamera`, `Item_Flashlight`…) | `ItemSpawnService.luau:35`–`53` cherche `ReplicatedStorage/Items/Item_<Nom>` (`ItemConfig.ModelsFolder`, `ItemConfig.luau:248`) ; sinon bloc gris `MANQUANT_Item_<Nom>` (l. 47) | **Aucun modèle n'est rangé à cet endroit dans Studio** : les imports sont dans `ServerStorage/Assets/{Props,Structures,Weapons,Camp}` sous des noms français (`CameraVintage`, `Radio`…), voir `studio-export/placements.md`. À faire dans Studio : copier les modèles d'objets dans `ReplicatedStorage/Items` sous les noms de 13.3 (ex. `Item_PhotoCamera`) |
| 8.1 : `ITM_Stone` lançable, bruit de leurre à l'impact (50) ; `ITM_Branch` lançable (45) | trajectoire au serveur (`InventoryService.luau:506`), bruit à l'impact (`:546`–`551`), signal `ProjectileLanded` (l. 550) | L'objet lancé n'est **pas reposé au sol** après l'impact (il est consommé, l. 546). La bible ne dit pas s'il reste ramassable : **question** |
| 7.3 : à la mort, l'inventaire tombe dans un sac | `ItemSpawnService.luau:90` (`SpawnBag`), `InventoryService.luau:277`, `:300` | Rien |
| 17.1 : débris physiques non ancrés : 60 (30 s) PC, 20 (15 s) mobile | aucun objet du monde n'est non ancré : `ItemSpawnService.luau:62`–`66` et `:93`–`97` ancrent tout | Rien à faire tant qu'aucune source de débris n'est décrite (voir partie 3) |

## 2. La tronçonneuse

La tronçonneuse est dans la liste d'objets de Gabriel (registre de décisions du 2026-11-10). **La bible 8
ne la décrit pas** : aucun `ITM_` ni arme `MEL_` ne lui correspond en 8.1 ou 8.2 (recherche de
« tronçonneuse » et « chainsaw » dans `docs/bible/` : 0 résultat). Rien n'est codé. Pour l'ajouter, la bible
doit donner au moins : identifiant, poids, pile, effet (outil ou arme ; dégâts si arme, 8.2), bruit, lieu.

## 3. Réaction physique aux impacts

**La bible ne décrit pas de réaction physique des objets aux impacts** (tir, coup, lancer, passage de la
créature). Ce qu'elle dit : bruit à l'impact d'une pierre (8.1), impacts de la créature sur les
barricades (section 5, acte 2, géré par l'attribut `impacts`, `GameStateService.luau:254`), budget de
débris non ancrés (17.1, sans dire ce qui les produit). Aucune modification n'est faite.

## 4. Questions pour Gabriel

1. Peut-on soigner un coéquipier (bandage, attelle, trousse) par une invite, ou seulement soi-même ?
2. Une pierre ou une branche lancée reste-t-elle au sol, ramassable ?
3. Tronçonneuse : quelle ligne en 8.1 ou 8.2 ?
4. Quelles sources produisent les débris physiques de 17.1 ?
