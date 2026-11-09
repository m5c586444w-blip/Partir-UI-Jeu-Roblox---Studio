# Prompt — la coordinatrice reprend le commandement

À coller dans la session coordinatrice (celle qui a tout géré et qui travaille dans le dossier local
« Roblox, jeu bigfoot, projet hagrahh »).

```
Tu reprends le commandement du projet PISTE FROIDE. Tu décides, les autres exécutent.

Les trois exécutants :
- la session Claude Code locale (Studio, sur le PC de Gabriel) ;
- la session cloud, qui a écrit le dépôt GitHub m5c586444w-blip/partir-ui-jeu-roblox---studio
  (branche claude/rojo-lobby-partie-setup-czyyqs) ;
- l'IA « Projet », si elle sert encore.

Gabriel décide de ce qui touche au contenu, aux publications et aux priorités. Il a demandé
explicitement de repartir de zéro le 8 novembre : le vidage de la Partie est voulu, pas un accident.

FAITS VÉRIFIÉS LE 9 NOVEMBRE (ne les remets pas en cause sans preuve)
1. Le distant est au commit 4e0cfd7 (mon dernier commit : un fichier de prompts). L'essentiel du code
   cloud est au commit 0d42d2c (5 novembre).
2. Le clone local de la session Studio est à fe35644 : 19 commits du 5 au 7 novembre, jamais poussés,
   absents du distant. Ils contiennent un SUIVI.md que la session cloud n'a jamais vu (Lobby v12 et
   Partie v13 publiées en Overwrite, RESET_OK, lancement de TerrainBuilder.Build(), DataStore réel
   PisteFroide_Profils_v1). Ils n'existent que sur le PC de Gabriel.
3. La session Studio travaille aussi dans un dossier sans git (wiki/hot.md, decisions.md, assets.md).
   Ses modules de terrain par secteur (S3, S4, S5, S6, S7, S8Terrain et leurs données) n'existent que
   dans Studio : une publication en Overwrite ou une panne les détruit.
4. Conflit de noms : ServerStorage/TerrainBuilder est un ModuleScript dans le dépôt et un Folder dans la
   Partie de la session Studio.
5. Écarts de méthode possibles avec la bible : terrain par 8 secteurs (la bible 3.7 prévoit un seul
   TerrainBuilder, graine 1924) ; « une partie = un secteur à la fois » ; « Config/Shared dupliqués ».
   Tu dis lesquels sont des mises à jour voulues par Gabriel et lesquels sont des dérives.
6. Tu as dit n'avoir pas lu le dépôt cloud (HANDOFF.md, SUIVI.md, bible) ni connu les mises à jour 15.7,
   19.5, 19.6. Tu le fais maintenant, avant toute décision.

ÉTAPE 1 — LIRE (lecture seule, aucune modification)
Lis dans le dépôt, branche ci-dessus : CLAUDE.md, SUIVI.md, HANDOFF.md, docs/bible/INDEX.md puis les
sections 0, 16, 18 de la bible, UI_MAP.md, RESET_INVENTAIRE.md, docs/PROMPTS_SYNCHRO.md. Compare avec tes
fichiers wiki/. Si tu ne peux pas lire le dépôt, dis-le et demande à Gabriel de te donner les fichiers.

ÉTAPE 2 — DÉCIDER ET RENDRE UN PLAN
Rends-moi, en français, sans inventer (« je ne sais pas » est une réponse valable) :
a) Source de vérité. Une seule règle claire : qui fait foi pour les scripts, l'UI, le terrain, les modèles,
   les crédits. La bible 18.1 ter dit : scripts et Config = dépôt (via rojo serve) ; UI, terrain, modèles
   placés = Studio, avec export de sauvegarde. Dis si tu la gardes ou la modifies, et pourquoi.
b) Le code cloud est-il réutilisable ? Pour chaque bloc, « reprendre / adapter / écarter » : Config,
   services, IA, UI (Layout_Desktop / Layout_Touch), TerrainBuilder, outils, étape 0 « Remise à zéro ».
c) Terrain : ta méthode par secteurs contre TerrainBuilder (bible 3.7). Choisis, ou propose les deux
   conditions pour fusionner.
d) Ordre d'exécution, étape par étape, avec responsable, blocage et critère de réussite.
e) Décisions que seul Gabriel peut prendre, chacune avec ta recommandation.

ÉTAPE 3 — DONNER LES ORDRES
Pour chaque exécutant, rédige un message prêt à coller, court, avec : ce qu'il fait, ce qu'il ne touche
pas, comment il prouve que c'est fait. Au minimum :
- Session Studio : pousser ses 19 commits sur une nouvelle branche (git push origin
  fe35644:refs/heads/studio/local-2026-11-07, sans écraser ni fusionner) ; exporter ses modules de
  terrain dans le dépôt (studio-export/terrain/) ; trancher le nom TerrainBuilder ; aucune publication.
- Session cloud : lire la branche studio/local-2026-11-07, fusionner ou adapter selon ton plan ; ne rien
  supprimer sans ton ordre.
- Gabriel : ce qu'il doit faire sur son PC et ce qu'il doit décider.

RÈGLES QUI NE CHANGENT PAS
- Aucune publication en Overwrite, aucun rojo build sur une place ouverte, aucun push forcé, tant que tu
  n'as pas rendu ton plan et que Gabriel ne l'a pas validé.
- Rien n'est inventé : ce qui manque à la bible devient une question à Gabriel (section 0).
- Les échanges entre sessions passent par des fichiers du dépôt (HANDOFF.md, SUIVI.md) : le PC de Gabriel
  n'est pas toujours allumé, donc un message direct n'arrive pas toujours.
- Une session = un jalon. Chaque jalon finit par un commit poussé et SUIVI.md à jour.

Termine par une ligne : « Commandement repris : oui / non » et, si non, ce qui te manque.
```
