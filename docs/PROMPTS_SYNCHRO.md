# Prompts de synchronisation (à copier-coller)

Référence de ce qui a été produit en cloud : dépôt `m5c586444w-blip/partir-ui-jeu-roblox---studio`,
branche `claude/rojo-lobby-partie-setup-czyyqs`, dernier commit `0d42d2c` (2026-11-05).

---

## Prompt 1 — IA « Projet » et session Claude Code (Studio)

À coller dans chacune des deux, séparément. Elles répondent chacune pour elles-mêmes.

```
Fais un point d'avancement honnête et vérifiable. Ne modifie rien (ni fichier, ni place Studio,
ni publication) pendant ce point : lecture seule.

Contexte : une session cloud a produit le dépôt GitHub m5c586444w-blip/partir-ui-jeu-roblox---studio,
branche claude/rojo-lobby-partie-setup-czyyqs, dernier commit 0d42d2c. Il contient : le code Rojo des
places Lobby et Partie, la bible découpée (docs/bible/INDEX.md), SUIVI.md, HANDOFF.md (étape 0
« Remise à zéro » puis phase B), UI_MAP.md et les builds dans builds/.

1. Synchronisation. Dis-moi précisément :
   - si tu as accès à ce dépôt et à cette branche, et à quel commit tu es (git log -1) ;
   - si tu as lu CLAUDE.md, SUIVI.md, HANDOFF.md et docs/bible/INDEX.md, ou seulement une partie ;
   - quelle version de la bible tu utilises (présence de 15.7, 19.5 et 19.6 : oui/non pour chacune).

2. Écart avec ce dépôt. Sous forme de tableau « Élément | Ton état | État du dépôt | Écart » :
   - dispositions Layout_Desktop / Layout_Touch (15.7) et nombre de boutons tactiles visibles ;
   - réponses C1 à C43 (19.5 et 19.6) : lesquelles sont appliquées chez toi ;
   - objectifs d'acte (C19), fins (C25), sources du musée (C36), accessoires (C38) ;
   - portage d'un blessé (C6), indices cachés de la Descendante (C7), machette en P10 (C15) ;
   - terrain : gorges, lacets de T3, génération par TerrainBuilder ;
   - places Lobby et Partie : contenu actuel, publiées ou non, en Overwrite ou non ;
   - DataStore utilisé (le dépôt prévoit PisteFroide_v1) et MemoryStore.

3. Avancement réel. Pour chaque phase (étape 0 remise à zéro, B1 terrain et végétation, B2 ambiance,
   B3 modèles / animations / tests) : fait, en cours, pas commencé. Joins une preuve (commande, capture,
   extrait de journal) pour ce qui est « fait ». Ce qui n'a pas été testé en jeu doit être dit comme tel.

4. Reste à faire, exactement. Liste numérotée, dans l'ordre d'exécution, chaque ligne avec : ce qu'il
   faut faire, où (place, chemin), ce qui bloque, qui le fait (toi, Gabriel, autre session).

5. Risques. Tout ce qui pourrait écraser du travail : publication en Overwrite, rojo build sur une
   place déjà ouverte, retouches faites dans Studio et absentes du dépôt, assets non crédités.

6. Conclusion en une ligne : « À jour avec le dépôt : oui / non / en partie », et la liste des
   commits ou fichiers à reprendre si non.

Réponds en français, sans inventer : « je ne sais pas » est une réponse valable.
```

---

## Prompt 2 — Session coordinatrice (celle qui a tout géré)

Gabriel a recommencé de zéro avec les mêmes contraintes de la bible, plus quelques mises à jour. Ce prompt
sert à ce que la coordinatrice dise ce qui a changé, pour qu'on aligne le dépôt cloud dessus (et non l'inverse).

```
Je recommence le projet PISTE FROIDE depuis zéro avec les mêmes contraintes de la bible, plus quelques
mises à jour. Ne modifie aucun fichier ni aucune place pendant ce point : lecture seule. Je veux
t'interroger pour réconcilier ton travail avec celui d'une session cloud.

Contexte : cette session cloud a produit le dépôt m5c586444w-blip/partir-ui-jeu-roblox---studio, branche
claude/rojo-lobby-partie-setup-czyyqs, dernier commit 0d42d2c (2026-11-05). Tout y est décrit dans
HANDOFF.md, SUIVI.md et docs/bible/INDEX.md. Cette branche n'a reçu aucun commit d'une autre session.

1. Ta structure actuelle. Décris l'organisation que tu as mise en place : sessions et rôles (qui fait
   quoi), dépôt(s) et branches, fichiers de passation, ordre de travail, règles que tu as ajoutées.

2. Ce qui a changé par rapport à la bible. Tableau « Sujet | Bible (section) | Ta version | Pourquoi ».
   Cite toute mise à jour de la bible que j'ai pu ne pas voir (15.7, 19.5, 19.6 ou plus récentes) et
   toute décision prise en dehors d'elle. Si une règle de la section 0 est modifiée, dis-le en premier.

3. Compatibilité avec le dépôt cloud. Pour chacun de ces blocs, dis : reprendre tel quel / adapter /
   écarter, avec la raison :
   - Config (ReplicatedStorage/Config, valeurs C1 à C43) ;
   - services serveur, IA de la famille, directeur de tension ;
   - UI générée (Layout_Desktop / Layout_Touch, tools/ui/build_ui.py, check_ui.py) ;
   - TerrainBuilder, textures Poly Haven ;
   - outils (split_bible.py, tools/studio/Reset*.luau, reset_diff.py) et .claude/settings.json ;
   - étape 0 « Remise à zéro » de HANDOFF.md.

4. État réel. Pour chaque place (Lobby, Partie) : contenu, ce qui est publié, ce qui est testé en jeu,
   ce qui ne l'est pas. Noms de DataStore et de MemoryStore utilisés.

5. Reste à faire, dans l'ordre, avec responsable et blocage éventuel.

6. Consignes pour la session cloud. Donne-moi la liste exacte de ce qu'elle doit refaire, supprimer
   ou ne plus toucher pour rester alignée sur ton projet, et le format de passation que tu veux
   (fichiers, nommage, commits).

Réponds en français, sans inventer : « je ne sais pas » est une réponse valable. Termine par une ligne :
« Projet cloud réutilisable : oui / non / en partie ».
```

---

## Comment les utiliser

1. Lance le prompt 1 dans l'IA Projet et dans la session Claude Code, puis le prompt 2 dans la coordinatrice.
2. Colle-moi les trois réponses : je compare avec le dépôt (`git log`, `check_ui.py`, builds), je liste ce
   qui manque de mon côté et je prépare la reprise ou l'adaptation.
3. Rien ne doit être publié en Overwrite tant que les écarts ne sont pas tranchés.
