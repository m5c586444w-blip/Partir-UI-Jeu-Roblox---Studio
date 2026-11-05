## 18. Plan de production et critères d'acceptation

Le jeu se construit en 15 jalons, un par session Claude Code, chacun testé en jeu avant le suivant. Le jalon 0 est le travail de Gabriel.

### 18.1 Remettre ce document à Claude Code

1. Exporter ce document en Markdown et l'enregistrer dans le dossier du projet sous le nom `BIBLE_PISTE_FROIDE.md`. Les tableaux de coordonnées suffisent : un dessin de carte serait perdu à l'export.
2. À la première session, Claude Code crée `CLAUDE.md` (rappel des règles de la section 0, chemin de la bible) et `SUIVI.md` (jalons, `TODO(BIBLE)`, assets `MANQUANT_`).
3. Message à coller au début de chaque session :

```
Lis CLAUDE.md, SUIVI.md, puis BIBLE_PISTE_FROIDE.md sections 0, 16 et <SECTION DU JALON>.
Fais uniquement le jalon J<N>. N'invente rien : toute information absente de la bible
devient un TODO(BIBLE) dans le code et une question pour moi.
Termine par : critères d'acceptation cochés ou non, erreurs de la console, capture d'écran,
mise à jour de SUIVI.md, résumé en 5 lignes.
```

### 18.1 bis Travail en cloud, puis dans Studio

Gabriel veut que Claude Code avance seul autant que possible. Le travail se fait donc en deux phases : d'abord tout ce qui se fait sans Studio (en cloud), puis seulement ce qui exige Studio.

**Outil :** Rojo. Claude Code écrit le projet sous forme de fichiers (scripts `.luau`, modules `Config`, instances d'UI en `.model.json`), puis `rojo build` assemble les fichiers de place `Lobby.rbxlx` et `Partie.rbxlx`. Gabriel n'a qu'à les ouvrir dans Studio. Fonctionnement exact de Rojo à vérifier au début de la phase A.

**Assets :** Claude Code télécharge seul les assets Poly Haven (CC0, sans compte) et les note dans `ReplicatedStorage/Credits`. Les assets Sketchfab demandent un compte : Claude Code prépare la liste des liens, Gabriel télécharge.

| Phase | Où | Jalons | Ce que Claude Code produit |
| --- | --- | --- | --- |
| A1 | Cloud | J1 | Arborescence Rojo, `Config`, `Shared`, remotes, `DataService`, téléportation Lobby ↔ Partie |
| A2 | Cloud | J5 | Toutes les UI en fichiers d'instances, noms de la section 15, `UI_MAP.md` |
| A3 | Cloud | J6, J7, J8 | Joueur, objets, inventaire, tablette, documents, preuves, armes |
| A4 | Cloud | J9 | Actes, horloge, extractions, fins, cinématiques (scripts), lobby (scripts) |
| A5 | Cloud | J10, J11, J12 | IA complète de la famille, directeur de tension, événements inexpliqués |
| A6 | Cloud | J13, J14 (scripts) | Gore (deux profils), musée, dialogues, skins, records |
| A7 | Cloud | J2 (préparation) | Script `TerrainBuilder` complet, prêt à lancer, et téléchargement des textures Poly Haven |
| A8 | Cloud | — | `rojo build` des deux places, liste de ce qui reste à faire dans Studio |
| B1 | Studio | J2, J3 | Lancer `TerrainBuilder`, vérifier les positions, poser la végétation |
| B2 | Studio | J4 | Lumière, brouillard, météo, sons : réglage à l'œil, captures |
| B3 | Studio | J0, J15 | Import des modèles 3D et animations, tests en jeu, mobile, équilibrage |

En phase A, rien ne peut être testé en jeu. Chaque phase A se termine donc par une relecture du code (zéro erreur de syntaxe, aucune valeur hors `Config`) ; les vrais tests ont lieu en phase B.

### 18.1 ter Synchroniser la session cloud et la session Studio

La phase A et la phase B sont deux sessions Claude Code différentes. Elles partagent un seul dépôt Git, qui est la mémoire commune : rien ne passe d'une session à l'autre en dehors de ce dépôt.

**Fichiers de passation (à la racine du dépôt) :**

| Fichier | Écrit par | Contenu |
| --- | --- | --- |
| `BIBLE_PISTE_FROIDE.md` | Gabriel | Ce document, seule source de vérité |
| `CLAUDE.md` | Session cloud, au début | Règles de la section 0, rappel de ce tableau |
| `SUIVI.md` | Les deux sessions | Phases faites, `TODO(BIBLE)`, assets `MANQUANT_`, questions pour Gabriel |
| `HANDOFF.md` | Session cloud, à la fin | Ce qui est prêt, ce qui reste à faire dans Studio, ordre exact, commandes à lancer |
| `builds/Lobby.rbxlx`, `builds/Partie.rbxlx` | Session cloud | Places assemblées par Rojo |

**Qui fait foi, et quand :**

| Contenu | Avant la 1re ouverture dans Studio | Après |
| --- | --- | --- |
| Scripts et modules `Config` | Fichiers du dépôt | Fichiers du dépôt (synchronisés par `rojo serve` dans Studio) |
| Interfaces (UI) | Fichiers `.model.json` | **Studio.** Les fichiers d'UI sont retirés du projet Rojo ; toute retouche de Gabriel est conservée |
| Terrain, éclairage, modèles 3D placés | — | **Studio** |

**Règles :**

1. La session cloud finit toujours par un commit, `HANDOFF.md` à jour, et le build des deux places.
2. La session Studio commence par lire `CLAUDE.md`, `SUIVI.md` et `HANDOFF.md`, puis ouvre les places de `builds/`.
3. Dès que Gabriel a ouvert une place, plus aucun `rojo build` ne doit l'écraser. Les scripts passent ensuite uniquement par `rojo serve`.
4. Une UI modifiée dans Studio est réexportée dans le dépôt (`ui-export/`) à chaque fin de session, pour sauvegarde, sans être réinjectée par Rojo.
5. Chaque session note dans `SUIVI.md` la date, ce qu'elle a fait et ce qu'elle a laissé ouvert.

### 18.2 Jalons

| Jalon | Contenu | Sections | Critères d'acceptation |
| --- | --- | --- | --- |
| J0 (Gabriel) | Télécharger et vérifier les licences des assets ; réduire dans Blender ; décider les points de la section 19 | 13, 19 | Chaque asset « à valider » passé en validé ou écarté |
| J1 | Squelette des deux places, `Config`, `Shared`, remotes, `DataService`, téléportation Lobby → Partie → Lobby avec la configuration en MemoryStore | 16 | Un groupe de 2 part et revient ; données sauvegardées ; zéro erreur console |
| J2 | Terrain par `TerrainBuilder` : relief, gorges, rivières, lac, routes, sentiers, F01, limites ; un bloc gris étiqueté par lieu | 3 | Toutes les positions à ±5 studs du tableau 3.2 ; P01 → P05 par T1 (≈ 4 700 studs) en 6 à 8 min de marche ; aucune zone bloquante hors F01 et bords |
| J3 | Matériaux, `MaterialVariant`, végétation par blocs, LOD, streaming | 3.6, 13, 17 | ≤ 20 000 modèles ; 60 images/s PC et 30 en émulateur mobile sur P04 |
| J4 | Lumière par acte, brouillard par zone, météo, vent, sons d'ambiance, réverbération | 12 | Captures de chaque moment validées par Gabriel ; nuit noire réelle entre 0 h et 4 h |
| J5 | Toutes les UI en instances, `UI_MAP.md` | 15 | Aucun `Instance.new` d'UI dans le code ; affichage correct sur PC et mobile |
| J6 | Joueur : personnages, postures, caméra, membres, sang, à terre, mort, spectateur, endurance, peur, bruit | 7 | Chaque valeur de la section 7 vérifiable dans `CreatureDebug` ou la console |
| J7 | Objets, inventaire, tablette, documents, preuves, tirages aléatoires | 2.7, 3.4, 8 | 6 indices sur 12 tirés ; graine affichée ; preuves sauvegardées après extraction |
| J8 | Armes et mêlée, validation serveur, tir allié | 8.2 | Tir impossible sans munitions ; cadence respectée ; tir allié seulement en Difficile et Cauchemar |
| J9 | Actes, horloge, voies d'extraction, fins, cinématiques (plans provisoires), déroulé complet du lobby | 4, 5, 6 | Une partie complète jouable sans créature, de CS\_02 à l'écran de résultats |
| J10 | Créature v1 : capsule de 10 studs puis modèle, déplacement, perception, coup et saisie | 9.2–9.4, 9.10, 9.11 | Elle suit un joueur bruyant, perd un joueur couché dans les fougères, grimpe par les `ClimbPoint` |
| J11 | Créature v2 : tous les comportements, échelle d'intimidation, cible, mémoire, famille, imitation, personnalités | 9.5–9.9 | Chaque comportement observé au moins une fois en test ; aucune attaque sans signal |
| J12 | Directeur de tension et événements inexpliqués | 9.12, 10 | Aucun mort en acte 1 hors exceptions ; au moins un temps fort par acte |
| J13 | Gore (deux profils), ragdoll, option gore réduit | 11 | Bascule `Restricted` / `Moderate` sans erreur ; limites fixes respectées |
| J14 | Lobby complet : ville, musée, dialogue, skins, records, résultats | 4, 15.3 | Les 8 panneaux lisibles avec sources ; déblocages corrects |
| J15 | Habillage final, performances, test mobile réel, équilibrage à 1, 5 et 10 joueurs | 17, tout | Durée de partie entre 35 et 52 min sur 3 tests ; budgets 17.1 tenus |

### 18.3 Règles d'arrêt

- Bloqué plus de 30 minutes sur un bug : Claude Code s'arrête et explique.
- Claude Code ne publie pas le jeu, ne remplit pas le questionnaire de maturité, ne crée pas de produit payant.
- Les animations finales et les voix sont faites par Gabriel ; Claude Code prépare les emplacements et les listes.

