# Brief commun de POLISSAGE de la carte (à lire en premier)

But (demande de Gabriel) : rendre le terrain beaucoup plus naturel et réaliste par des petits détails qui font la différence. Style de référence : Sons of the Forest. Les 8 secteurs sont construits (voir `wiki/secteurs/*.md`) : on ne les reconstruit pas, on les POLIT par-dessus (post-passes sur les voxels existants).

Lis d'abord : `wiki/BRIEF_SECTEUR_COMMUN.md` (outils, pièges, verrou LOCK_PLAY, TEMP_ uniques), `CLAUDE.md`, `wiki/hot.md`, et les pages `wiki/secteurs/` de ta région. Règles du brief commun inchangées, SAUF : tu peux écrire dans les secteurs de ta région (jamais hors région), et un seul agent « textures » touche à `MaterialService`.

## Ce qu'il faut polir (dans ta région)
1. **Eau variée** : rivières à largeur ET profondeur variables (resserrements/élargissements, mouilles profondes 6–10 studs, radiers/gués peu profonds 1–2 studs, bancs de gravier et de sable (Sand/Slate/Cobblestone) en bordure intérieure des méandres, berges abruptes côté extérieur, blocs de roche dans le lit, petits îlots), rapides et cascades secondaires. Niveau d'eau MONOTONE décroissant (mesure obligatoire sur voxels), jonctions inchangées (même niveau/largeur aux frontières de région).
2. **Mares et eaux dormantes** : petites mares (10–40 studs) dans des cuvettes naturelles, flaques de boue, zones marécageuses près des ruisseaux, sources suintantes, trous d'eau dans le lit de lahar ; eau stagnante (niveau constant, rives Mud/boue, bords irréguliers), jamais de bords circulaires ni parfaitement plats. Pas dans les chemins (axes de sentiers/routes restent secs ou en gué marqué).
3. **Micro-relief** : buttes, creux, ravinements d'érosion, petits talus, éboulis au pied des falaises (Rock/Slate), blocs rocheux émergents (voxels Rock, groupes de 3–8), monticules de chablis (souches arrachées), terrasses de berge, replats de cendre soufflée, congères de cendre dans la zone de cendre. Bruit multi-échelle (2–12 studs) à faible amplitude (0,5–3 studs), sans casser les pentes jouables (< 45° sur les chemins) ni les raccords (saut ≤ 4 studs aux frontières).
4. **Matériaux/transitions** (via `MelangeMateriaux` et tes post-passes) : usure des sentiers (Ground plus clair/compacté au centre, boue aux gués, herbe en bordure), mousse (LeafyGrass/Grass) sur les pentes nord et près de l'eau, sol nu sous les grands arbres (Ground), cendre plus claire sur les crêtes, taches de sable/gravier dans les lits, bords de falaise (Rock) irréguliers, jamais de lignes droites ni de damier ; aucun matériau > 70 % hors lieux spéciaux.
5. **Petits détails de lieux** : autour des lieux déjà posés (camp, poste, mine, chantier, ruine, charnier, lac, Ape Cave…) : traces d'usage au sol (Ground/Mud piétiné), flaques, ornières (Mud) sur pistes forestières, éboulis devant les entrées de grottes. Aucun asset nouveau (pas de modèle) : uniquement terrain/matériaux, sauf blocs gris `MANQUANT_<nom>` utiles (ex. `MANQUANT_Roseaux`, `MANQUANT_BranchesMortes`) posés avec parcimonie.

## Invariants à ne JAMAIS casser (re-mesure à la fin et écris les chiffres)
- Axes de sentiers/routes : 100 % continus, pente inchangée ; pathfinding de bout en bout inchangé (Edit, par étapes < 1000 studs, joueur 5×2, créature 10×4) sur au moins 3 trajets de ta région.
- Niveaux d'eau monotones ; mêmes niveaux/largeurs aux frontières de région ; raccords de hauteur (saut ≤ 4) ; aucun point < y≈0 hors lit d'eau peu profond ; aucun trou dans le sol.
- Ape Cave et tunnel 21 : ne retouche pas leurs voûtes ; rien ne doit rendre un passage de 10 studs de haut impraticable.
- Ne reconstruis PAS un secteur (les `S*Terrain.Construire` écraseraient le polissage) : écris tes post-passes comme modules `ServerStorage/TerrainBuilder/Polissage_<Region>` (fonctions `Appliquer(zone)`, idempotentes, par chunks 256×256 avec `task.wait()`) et copie le .lua dans `terrain/`. Documente l'ORDRE : (re)construction du secteur, puis raccords, puis polissage.

## Méthode et validation
- Mesure avant/après (échantillonnage voxels/raycast) : variété de largeur/profondeur des rivières (min/médiane/max), nombre de mares, répartition des matériaux, pentes max sur les chemins.
- Captures : caméra à hauteur d'avatar (≈ 5 studs au-dessus du sol local, raycast) ou en survol à 60–150 studs ; réessaie une fois ; les captures échouent souvent : complète par mesures. Compare avant/après quand possible.
- Écris `wiki/secteurs/POLISSAGE_<Region>.md` (ce qui a été ajouté, paramètres, comment relancer) ; ne modifie pas hot.md, decoupage.md, assets.md, CLAUDE.md. Nettoie tes `TEMP_<Region>_*`.
- Rapport final court : avant/après chiffrés, invariants re-mesurés, limites d'outils, ce que Gabriel doit regarder.

## Découpage des agents
- **Textures** (seul à toucher `MaterialService`) : ajouter des textures Poly Haven CC0 (1K) pour les matériaux de terrain non encore surchargés (Sandstone, Limestone, Pavement, Salt, Snow, CrackedLava… selon l'usage : sentier de randonnée, éboulis clair, vieille route, neige/cendre en altitude), ajuster `StudsPerTile`, rugosité, normales (éviter la répétition visible) et la couleur de l'asphalte (trop vert/sombre), vérifier chaque rendu par captures au sol. Téléchargement Poly Haven (API publique) + `upload_image` (serveur HTTP local) comme déjà fait (voir wiki/assets.md et wiki/hot.md « Textures Poly Haven »).
- **Régions** (chacune fait eau + mares + micro-relief + transitions de matériaux) : EST = S7 + S3 + S8 ; CENTRE = S4 + S2 ; OUEST = S5 + S6 ; NORD-OUEST = S1 (zone interdite, lac, affluent).
