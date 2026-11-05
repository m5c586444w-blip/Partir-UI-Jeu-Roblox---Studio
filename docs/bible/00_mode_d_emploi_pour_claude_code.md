## 0. Mode d'emploi pour Claude Code

Ce document est la seule source de vérité du projet PISTE FROIDE. Claude Code exécute ce qui est écrit ici. Il n'ajoute aucune règle, aucun lieu, aucun objet et aucun personnage qui n'y figure pas.

### Règles absolues

1. **Ne rien inventer.** Une information absente du document = arrêt et question à Gabriel. En attendant la réponse, laisser un marqueur `-- TODO(BIBLE): <question>` dans le code et passer à la tâche suivante.
2. **Les tableaux font foi.** Chaque valeur chiffrée (dégâts, vitesses, distances, durées) est recopiée telle quelle dans le module `Config` correspondant. Aucune valeur « magique » dans le code.
3. **L'UI est faite d'instances, pas de code.** Toutes les interfaces sont des `ScreenGui` placés dans `StarterGui` et construits une fois dans Studio, avec les noms exacts de la section 15. Les scripts ne créent jamais d'élément d'UI avec `Instance.new` (sauf les clones d'un modèle déjà présent, ex. une ligne de liste). Gabriel doit pouvoir tout déplacer et recolorer à la main.
4. **Aucun asset gratuit du Marketplace Roblox.** Seules les sources de la section 13 sont autorisées. Chaque asset importé est inscrit dans `ReplicatedStorage/Credits` (nom, auteur, URL, licence).
5. **Le serveur décide.** Dégâts, inventaire, IA, preuves et morts sont calculés côté serveur. Le client affiche et envoie des intentions.
6. **Mobile d'abord.** Toute fonctionnalité doit tourner sur un téléphone milieu de gamme (section 17). Une fonctionnalité qui ne passe pas le budget mobile est désactivée sur mobile, jamais supprimée.
7. **Une session = un jalon.** Chaque session Claude Code traite un seul jalon de la section 18 et ne modifie pas les fichiers des autres jalons, sauf demande explicite. Si Gabriel demande d'enchaîner plusieurs phases dans une session, chaque phase se termine quand même par un commit, un push et la mise à jour de SUIVI.md et HANDOFF.md avant de passer à la suivante.

**Questions en attente :** Gabriel veut que Claude Code avance seul. Une question de `SUIVI.md` qui ne touche ni un texte affiché aux joueurs, ni une valeur de gameplay, ni un asset est tranchée par la proposition de Claude Code : il l'applique, la marque `DÉFAUT` dans `SUIVI.md` et continue. Les autres attendent une réponse dans cette bible.

### Rituel de début de session

1. Lire les sections 0, 16 et la section du jalon demandé.
2. Lister l'arborescence existante dans Studio avant d'écrire quoi que ce soit.
3. Annoncer en trois lignes ce qui va être fait, puis le faire.
4. Finir par la liste des critères d'acceptation du jalon, cochés ou non, et les `TODO(BIBLE)` laissés.

### Conventions de nommage

| Élément | Règle | Exemple |
| --- | --- | --- |
| ModuleScript, Script, LocalScript | PascalCase, en anglais | `CreatureBrain`, `EvidenceService` |
| RemoteEvent / RemoteFunction | préfixe `RE_` / `RF_` | `RE_PickupItem`, `RF_GetLoadout` |
| Attribut d'instance | camelCase | `noiseLevel`, `isDowned` |
| Asset 3D | `Catégorie_Nom_Variante` | `Tree_DouglasFir_A`, `Prop_CabinBeck_Ruin` |
| Lieu de la carte | code `Pxx` de la section 3 | `P07_ApeCanyonRim` |
| Son | `SFX_`, `AMB_`, `MUS_`, `VO_` | `SFX_WoodKnock_03` |
| Animation | `ANIM_<Rig>_<Action>` | `ANIM_Creature_RockThrow` |
| Commentaires du code | en français | `-- la créature recule si 3 tirs reçus` |

### Unités

La carte fait 8 000 × 8 000 studs. L'échelle retenue est celle de la section 3 (1 stud = 28 cm, selon la doc Roblox). Les durées sont en secondes, les angles en degrés, les distances en studs.

