# PISTE FROIDE — règles pour Claude Code

Bible (seule source de vérité) : `BIBLE_PISTE_FROIDE.md` à la racine du dépôt.
Tant que Gabriel ne l'a pas exportée en Markdown (18.1), la version de référence est
`BIBLE_PISTE_FROIDE.pdf` (94 pages, même racine).

À lire au début de chaque session : ce fichier, `SUIVI.md`, `HANDOFF.md`, puis la bible,
sections 0, 16 et la section du jalon demandé.

## Règles absolues (bible, section 0)

1. **Ne rien inventer.** Une information absente de la bible = arrêt et question à Gabriel.
   En attendant la réponse, laisser `-- TODO(BIBLE): <question>` dans le code, la noter
   dans `SUIVI.md`, et passer à la tâche suivante.
2. **Les tableaux font foi.** Chaque valeur chiffrée est recopiée telle quelle dans le module
   `ReplicatedStorage/Config` correspondant. Aucune valeur « magique » dans le code.
3. **L'UI est faite d'instances, pas de code.** Toutes les interfaces sont des `ScreenGui`
   dans `StarterGui`, avec les noms exacts de la section 15, écrites en fichiers d'instances
   (`.model.json`). Jamais d'`Instance.new` pour un élément d'UI (seule exception : cloner
   un enfant `Template` déjà présent). Gabriel doit pouvoir tout déplacer et recolorer.
4. **Aucun asset gratuit du Marketplace Roblox.** Seules les sources de la section 13.
   Chaque asset importé est inscrit dans `ReplicatedStorage/Credits` (nom, auteur, URL, licence).
   Un asset manquant devient un bloc gris `MANQUANT_<ID>`, noté dans `SUIVI.md`.
5. **Le serveur décide.** Dégâts, inventaire, IA, preuves et morts côté serveur.
   Le client affiche et envoie des intentions.
6. **Mobile d'abord** (section 17). Une fonctionnalité trop lourde est désactivée sur mobile,
   jamais supprimée.
7. **Une session = un jalon** (section 18). Ne pas modifier les fichiers des autres jalons,
   sauf demande explicite.

Autres règles de la bible à garder en tête :
- Tout texte affiché en jeu vient de la bible ; Claude Code n'en rédige pas d'autre (section 2).
- Claude Code ne publie pas le jeu, ne remplit pas le questionnaire de maturité, ne crée
  pas de produit payant (18.3). Bloqué plus de 30 min sur un bug : s'arrêter et expliquer.

## Rituel de session (section 0)

1. Lire les sections 0, 16 et la section du jalon.
2. Lister l'arborescence existante avant d'écrire quoi que ce soit.
3. Annoncer en trois lignes ce qui va être fait, puis le faire.
4. Finir par : critères d'acceptation cochés ou non, TODO(BIBLE) laissés, mise à jour de
   `SUIVI.md` (date, fait, laissé ouvert) et de `HANDOFF.md`, commit, résumé en 5 lignes.

## Conventions de nommage (section 0)

| Élément | Règle | Exemple |
|---|---|---|
| ModuleScript, Script, LocalScript | PascalCase, en anglais | `CreatureBrain`, `EvidenceService` |
| RemoteEvent / RemoteFunction | préfixe `RE_` / `RF_` | `RE_PickupItem`, `RF_GetLoadout` |
| Attribut d'instance | camelCase | `noiseLevel`, `isDowned` |
| Asset 3D | `Catégorie_Nom_Variante` | `Tree_DouglasFir_A` |
| Lieu de la carte | code Pxx de la section 3 | `P07_ApeCanyonRim` |
| Son | `SFX_`, `AMB_`, `MUS_`, `VO_` | `SFX_WoodKnock_03` |
| Animation | `ANIM_<Rig>_<Action>` | `ANIM_Creature_RockThrow` |
| Commentaires du code | en français | `-- la créature recule si 3 tirs reçus` |

Unités : studs, secondes, degrés. Carte 8 000 × 8 000 studs, 1 stud = 28 cm.

## Synchronisation cloud ↔ Studio (section 18.1 ter)

Le dépôt Git est la seule mémoire commune entre la session cloud (phase A) et la session
Studio (phase B).

| Fichier | Écrit par | Contenu |
|---|---|---|
| `BIBLE_PISTE_FROIDE.md` | Gabriel | La bible, seule source de vérité |
| `CLAUDE.md` | Session cloud, au début | Règles de la section 0, rappel de ce tableau |
| `SUIVI.md` | Les deux sessions | Phases faites, `TODO(BIBLE)`, assets `MANQUANT_`, questions pour Gabriel |
| `HANDOFF.md` | Session cloud, à la fin | Ce qui est prêt, ce qui reste à faire dans Studio, ordre exact, commandes |
| `builds/Lobby.rbxlx`, `builds/Partie.rbxlx` | Session cloud | Places assemblées par Rojo |

Qui fait foi, et quand :

| Contenu | Avant la 1re ouverture dans Studio | Après |
|---|---|---|
| Scripts et modules Config | Fichiers du dépôt | Fichiers du dépôt (synchronisés par `rojo serve`) |
| Interfaces (UI) | Fichiers `.model.json` | Studio. Les fichiers d'UI sont retirés du projet Rojo ; les retouches de Gabriel sont conservées |
| Terrain, éclairage, modèles 3D placés | — | Studio |

Règles :
1. La session cloud finit toujours par un commit, `HANDOFF.md` à jour, et le build des deux places.
2. La session Studio commence par lire `CLAUDE.md`, `SUIVI.md` et `HANDOFF.md`, puis ouvre les places de `builds/`.
3. Dès que Gabriel a ouvert une place, plus aucun `rojo build` ne doit l'écraser. Les scripts passent ensuite uniquement par `rojo serve`.
4. Une UI modifiée dans Studio est réexportée dans le dépôt (`ui-export/`) à chaque fin de session, pour sauvegarde, sans être réinjectée par Rojo.
5. Chaque session note dans `SUIVI.md` la date, ce qu'elle a fait et ce qu'elle a laissé ouvert.

## Projet Rojo (mis en place en phase A1)

- Rojo 7.7.1 (version épinglée dans `rokit.toml`).
- Deux projets : `Lobby.project.json` et `Partie.project.json`.
- Build : `rojo build Lobby.project.json -o builds/Lobby.rbxlx` et
  `rojo build Partie.project.json -o builds/Partie.rbxlx`.
- Synchronisation dans Studio (phase B) : `rojo serve Lobby.project.json` ou
  `rojo serve Partie.project.json`, avec le plugin Rojo.
- Vérification de syntaxe (aucun test en jeu possible en phase A) : `stylua --check src`
  (StyLua lit le Luau ; une erreur de syntaxe fait échouer la commande) et `selene src`.

Arborescence des sources :

```
src/shared/Config/        → ReplicatedStorage/Config   (identique dans les deux places)
src/shared/Shared/        → ReplicatedStorage/Shared   (identique dans les deux places)
src/shared/Remotes/Common → ReplicatedStorage/Remotes  (les deux places)
src/shared/Remotes/Lobby  → ReplicatedStorage/Remotes  (Lobby)
src/shared/Remotes/Partie → ReplicatedStorage/Remotes  (Partie)
src/server/Common/Services → ServerScriptService/Services (les deux places)
src/server/<Place>/Bootstrap.server.luau → ServerScriptService/Bootstrap
src/server/<Place>/Services → ServerScriptService/Services
```

Fichier `.luau` = ModuleScript, `.server.luau` = Script, `.client.luau` = LocalScript,
`.model.json` = instance (remotes, UI). Les dossiers vides de 16.1 sont déclarés dans les
`.project.json` (`"$className": "Folder"`).

Chaque service serveur expose `Init(services)` puis `Start()` ; `Bootstrap` les charge dans
l'ordre de sa liste `ORDER`.
