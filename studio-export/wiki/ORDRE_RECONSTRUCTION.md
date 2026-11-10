# ORDRE DE RECONSTRUCTION DES SECTEURS (place Partie, carte PISTE FROIDE)

Document de travail, rédigé le 10/11/2026 à partir des copies exactes `studio-export/terrain/*.lua` et des pages `wiki/secteurs/*.md`, `BRIEF_SECTEUR_COMMUN.md`, `BRIEF_POLISSAGE.md`. Rien n'a été exécuté dans Studio pour l'écrire.

Conventions de lecture :
- **[code]** : lu dans un module de `terrain/`. **[page]** : écrit dans une page wiki. **[déduit]** : conclusion tirée des boîtes monde ou du graphe des `require`, jamais testée. **non vérifié** : ni code ni page.
- Quand une page contredit le code, c'est le code qui est cité et le texte périmé est nommé (section 6).
- Dossier Studio : **`ServerStorage/TerrainSectors`** (nom DÉFAUT de la coordinatrice ; ce n'est pas le `TerrainBuilder` du dépôt Rojo). Les en-têtes de modules, les briefs et les pages disent encore « TerrainBuilder » : lire `TerrainSectors`. Les modules s'appellent entre eux par `script.Parent`, donc le renommage ne casse rien.

---

## 1. Secteurs, boîtes monde et découpage en chunks

Monde : `X = x - 4000`, `Z = y - 4000`. Chunks de 256 x 256, voxels de 4 studs. Les indices de chunk sont donnés par les `Nb*` des modules `Terrain`.

| Secteur | Boîte construite (X / Z) | Modules | Chunks `Construire` [code] | Écrase / recouvre |
| --- | --- | --- | --- | --- |
| S1 Zone interdite | -4000..-1000 / -4000..-500 | S1Donnees, S1Terrain | cx 0..11, cz 0..13 (168) | bande Z -600..-500 de S5, et X -1100..-1000 de la marge ouest de S4 [déduit] |
| S2 Plateau (boîte A) | -1000..1400 / -4000..-200 | S2Donnees, S2Terrain | b=1 : cx 0..9, cz 0..14 (150) | bande Z -600..-200 de S4 [page] ; X -1000..-790 de S5 [déduit] |
| S2 (boîte B) | 1400..1500 / -4000..-2500 | idem | b=2 : cx 0, cz 0..5 (6) | rien (au nord de S3) |
| S3 Nord-est | 1400..4000 / -2500..1700 | S3Donnees, S3Terrain | cx 0..10, cz 0..16 (187) | bande Z 1400..1700 de S7 [page, code] |
| S4 Centre | -1100..1400 / -600..2500 | S4Donnees, S4Terrain | cx 0..9, cz 0..12 (130) | marge ouest X -1100..-1000 de S5 [page] |
| S5 Ouest | -4000..-790 / -600..2500 | S5Donnees, S5Terrain | cx 0..12, cz 0..12 (169) | bande X -1000..-790 = colonnes de S4 [code] |
| S6 Sud-ouest/centre | -4000..1400 / 2500..4000 | S6Donnees, S6Terrain | cx 0..21, cz 0..5 (132) | `ReecrireBandeS4` écrit Z 2400..2500 dans S4/S5 [code] |
| S7 Sud-est | 1400..4000 / 1400..4000 | S7Donnees, S7Terrain | cx 0..10, cz 0..10 (121) | — |
| S8 zone "M" (montagne) | 1500..4000 / -4000..-2440 | S8Donnees, S8Terrain | `Construire("M",cx,cz)` cx 0..9, cz 0..6 (70) | Z -2500..-2440 de S3 [déduit] |
| S8 zone "O" (couloir) | 2440..2900 / -2440..-1380 | idem | `Construire("O",cx,cz)` cx 0..1, cz 0..4 (10) | colonnes de S3 (sentier + ruisseau) [code] |

Modules partagés : `HauteurGlobale` (H, Basse, Lisse, Arase, CreuserGorge), `MelangeMateriaux` (Sol, Voxel, Lit, Bord). Région EST uniquement : `Alignement_EST` (Delta), `HauteurEST` (proxy : H et Basse + Delta ; `P.Brut` = HauteurGlobale). Post-passes EST : `Raccords_EST`, `Ponceau_RD1`.

Graphe des `require` [code], utile pour la matrice (section 5) :
- `HauteurEST` <- `HauteurGlobale`, `Alignement_EST`.
- `S4Donnees` <- `HauteurGlobale`. `S5Donnees` <- `HauteurGlobale`, `S4Donnees`. `S6Donnees` <- `HauteurGlobale`, `S5Donnees`, `S4Donnees`. `S1Donnees` <- `HauteurGlobale`, `MelangeMateriaux`.
- `S7Donnees` <- `HauteurEST`, `S4Donnees`, `Alignement_EST`. `S3Donnees` <- `HauteurEST`, `HauteurGlobale`, `Alignement_EST`, `S4Donnees`, `S7Donnees`. `S8Donnees` <- `HauteurEST`, `S3Donnees`, `S7Donnees`.
- `S2Donnees` <- `HauteurGlobale`, `S4Donnees`, `S3Donnees`. `S2Terrain` <- `S2Donnees`, `S3Donnees`.
- `Raccords_EST` <- `S3Donnees`, `S7Donnees`, `S8Donnees`, `MelangeMateriaux`. `Ponceau_RD1` <- `S7Donnees`, `MelangeMateriaux`.

---

## 2. ORDRE global recommandé pour une reconstruction TOTALE

Principe : (a) chaque boîte ne s'écrit qu'après les boîtes qu'elle recouvre en partie ; (b) l'OUEST et le CENTRE d'abord, parce que `Raccords_EST` lit le terrain réel voisin (raycast en X = 1390) ; (c) `Raccords_EST` en DERNIER pour l'EST ; (d) le polissage tout à la fin.

| # | Étape | Pourquoi (source) |
| --- | --- | --- |
| 0 | Studio en mode Edit, clone frais de `TerrainSectors` (section 6, piège 1) | cache de `require` |
| 1 | **S4** : nettoyage borné (voir 3.4, `Nettoyer` interdit) puis `Construire` 130 chunks | base du CENTRE ; S5, S6, S2, S3, S7 en dépendent [code] |
| 2 | **S5** : `Nettoyer()` puis `Construire` 169 chunks | « Reconstruire S5 APRÈS S4 » [en-tête S5Donnees] |
| 3 | `S6Terrain.ReecrireBandeS4(i)` pour **i = 0..10** | retire le rabais de 30 de S4 ; après S4 et S5 [page S6 + code] |
| 4 | **S6** : `Nettoyer()` puis `Construire` 132 chunks | [code] |
| 5 | `S6Terrain.EcrireSentierCave()` puis `S6Terrain.EcrireSentierPoste(i)` i = 0..3 | sentiers qui entrent dans les boîtes de S5 et S4, écrasés par leur reconstruction [code] |
| 6 | **S1** : `Nettoyer()` puis `Construire` 168 chunks | « S1 APRÈS S4/S5 » [en-tête S1Terrain] |
| 7 | **S2** : `NettoyerBoite(1)` puis `Construire(1,..)`, `NettoyerBoite(2)` puis `Construire(2,..)`. **Ne pas appeler `S2Terrain.Raccord()`** | S2 recouvre Z -600..-200 de S4 [page S2] ; `Corr3` doublonne S3 (section 4) |
| 8 | **S7** : `Nettoyer()` puis `Construire` 121 chunks | avant S3 : S3 réécrit la bande Z 1400..1700 [en-tête S3Terrain] |
| 9 | **S3** : `Nettoyer()` puis `Construire` 187 chunks | [code] |
| 10 | **S8 "M"** : `Nettoyer("M")` puis `Construire("M",..)` 70 chunks | après S3 (fondu Z -2440 -> -2560) |
| 11 | **S8 "O"** : `Nettoyer("O")` puis `Construire("O",..)` 10 chunks | « S7 -> S3 -> S8 M -> S8 O » [page A1 phase A] |
| 12 | `Raccords_EST.Appliquer()` (ou `AppliquerOuest()` puis `AppliquerNord()`), puis `Raccords_EST.Mesurer()` | « à lancer en DERNIER » [en-tête Raccords_EST] |
| 13 | Relire T1 dans X 1500..1700 | la bande de couture peut recouvrir la fin de T1 [page T1] |
| 14 | `Ponceau_RD1.Appliquer()` puis 2e appel (doit renvoyer 0), puis `Mesurer()` | efface par S7 (8,7)/(8,8) [page ponceau] |
| 15 | Polissage (`BRIEF_POLISSAGE.md`) | après raccords ; section 4 |
| 16 | Vérifications de la section 7 | — |

Les étapes 1 à 7 (OUEST/CENTRE) et 8 à 11 (EST) sont indépendantes en données ; l'ordre ci-dessus garantit seulement que les voisins existent pour l'étape 12. S1 et S2 n'ont aucun recouvrement entre eux (X <= -1000 contre X >= -1000) [déduit] ; leur ordre relatif n'est pas documenté.

---

## 3. Par secteur : appels exacts, pré-requis, durée, suite à relancer

Gabarit commun (cloner, requérir le clone, détruire) : voir section 6. Découper chaque boucle en appels de moins de 30 s avec `task.wait()` entre chunks.

### 3.1 S1 Zone interdite
- Appels [code] : `S1Terrain.Nettoyer()` (boîte S1 seule) ; `for cx=0,11 do for cz=0,13 do S1Terrain.Construire(cx,cz) end end`. `S1Terrain.NettoyerChunk(cx,cz)` existe.
- Pré-requis : S4 et S5 déjà (re)construits [en-tête]. Sinon la bande Z -600..-500 redevient la marge provisoire (chute de 45).
- Durée connue : environ 1 min pour 168 chunks [page S1] ; durée de `Nettoyer` non vérifiée. Dépasse 30 s : découper par colonnes cx (par exemple 3 à 4 colonnes de cx par appel, soit environ 40 à 56 chunks ; le découpage exact est une estimation [déduit] : 1 min / 168 chunks = 0,36 s par chunk).
- Ensuite : rien en aval dans le dépôt. Si seul S5 est relancé : refaire `S1Terrain.Construire(cx,13)` pour cx 0..11 [page S1].

### 3.2 S2 Plateau
- Appels [code] : `S2Terrain.NettoyerBoite(1)` puis `for cx=0,9 do for cz=0,14 do S2Terrain.Construire(1,cx,cz) end end` ; `S2Terrain.NettoyerBoite(2)` puis `for cz=0,5 do S2Terrain.Construire(2,0,cz) end`. `S2Terrain.NbChunks(b)` renvoie (nx,nz).
- **Nettoyer d'abord** : une cellule d'eau ne s'écrit pas sur un voxel déjà occupé [page S2].
- Pré-requis : S4 et S5 d'abord [page S2 pour S4 ; S5 déduit des boîtes].
- Durée connue : reconstruction complète environ 15 s [page S2] ; durée de `NettoyerBoite` non vérifiée.
- **Ne pas lancer `S2Terrain.Raccord()`** (voir section 4, Corr3).
- Ensuite : `Raccords_EST.Appliquer()` (couture S3 <-> S2, Z -2400..-604, lue par raycast à X = 1390).

### 3.3 S3 Nord-est
- Appels [code] : `S3Terrain.Nettoyer()` (boîte S3 seule, jamais `Terrain:Clear`) ; `for cx=0,10 do for cz=0,16 do S3Terrain.Construire(cx,cz) end end`. `S3Terrain.NettoyerChunk(cx,cz)` existe.
- Pré-requis : S7 reconstruit avant (S3 réécrit Z 1400..1700) ; modules `HauteurEST` et `Alignement_EST` présents dans le dossier cloné.
- Socle Slate sous la bande écrite (y -40 jusqu'à y0) : déjà dans `Construire` [code S3Terrain l.83].
- Durée connue : environ 10 s la reconstruction complète [page S3] ; phase A : S7 + S3 + S8 M + S8 O = 121 + 187 + 70 + 10 chunks en environ 35 s [page phase A].
- Ensuite : S8 "M" puis "O" (S8 recouvre Z -2500..-2440 et le couloir X 2440..2900 / Z -2440..-1380), puis `Raccords_EST.Appliquer()`.

### 3.4 S4 Centre (attention : piège de nettoyage)
- Appels [code] : `for cx=0,9 do for cz=0,12 do S4Terrain.Construire(cx,cz) end end`.
- **`S4Terrain.Nettoyer()` vaut `workspace.Terrain:Clear()`** (S4Terrain.lua l.14) et S4Terrain n'a pas de `NettoyerChunk`. **Interdit** : il efface toute la carte.
- Remplacement borné : **proposition, non vérifiée, pas dans le code.** FillBlock Air chunk par chunk sur la boîte de S4 (X -1100..1400, Z -600..2500, Y -40..640), sur le modèle de `S5Terrain.NettoyerChunk` (`FillBlock(CFrame.new(x0+lx/2,(YBAS+YHAUT)/2,z0+lz/2), Vector3.new(lx,YHAUT-YBAS,lz), Enum.Material.Air)`). Ne pas sauter le nettoyage : l'eau ne s'écrit pas sur du voxel occupé [pages S2, ponceau]. S4 n'a pas de socle Slate [grep].
- Ce nettoyage efface aussi : la bande X -1100..-790 de S5, la bande Z -600..-200 de S2, la bande Z 2400..2500 (réécrite par S6), la bande X -1100..-1000 / Z -600..-500 de S1, les sentiers `EcrireSentierPoste`. Tout est à refaire ensuite (matrice, section 5).
- Durée connue : environ 10 s (130 appels) [page S4].
- Ensuite (documenté) : `for i=0,10 do S6Terrain.ReecrireBandeS4(i) end` ; `S6Terrain.EcrireSentierPoste(0..3)` ; S5 (après S4) ; S2 chunks cz 13..14 [déduit] ; `Raccords_EST.Appliquer()`.

### 3.5 S5 Ouest
- Appels [code] : `S5Terrain.Nettoyer()` (boîte S5 seule) ; `for cx=0,12 do for cz=0,12 do S5Terrain.Construire(cx,cz) end end`. `NettoyerChunk(cx,cz)` existe (Y -40..640).
- Pré-requis : S4 d'abord [en-tête]. Les tubes (Ape Cave 7, tunnel 21) sont creusés dans la même passe.
- Durée connue : environ 5 s [page S5].
- Ensuite : `S6Terrain.ReecrireBandeS4(i)` i = 0..10 (le coin X -1300..-790 / Z 2400..2500 appartient à S5) ; `S6Terrain.EcrireSentierCave()` ; `S1Terrain.Construire(cx,13)` cx 0..11 ; blocs `MANQUANT_` posés au sol à vérifier [page S5].
- Les 35 studs du sentier de la grotte (Z 2345..2380) restent non écrits : limite connue [page S6] ; `S5Donnees` n'appelle pas `AppliquerSentierCave` [grep].

### 3.6 S6 Sud-ouest/centre
- Appels [code] : `S6Terrain.Nettoyer()` (boîte S6 seule) ; `for cx=0,21 do for cz=0,5 do S6Terrain.Construire(cx,cz) end end`.
- Pré-requis : `S5Donnees` (queue du ruisseau copiée) ; terrain de S4 et S5 présent avant `ReecrireBandeS4`.
- Durée connue : environ 5 s [page S6].
- Ensuite : `Raccords_EST.Appliquer()` si les chunks cx 21 (X 1376..1400) ont changé [déduit].

### 3.7 S7 Sud-est
- Appels [code] : `S7Terrain.Nettoyer()` (bornée par chunk malgré l'en-tête « vide le terrain », voir section 6) ; `for cx=0,10 do for cz=0,10 do S7Terrain.Construire(cx,cz) end end`. `NettoyerChunk(cx,cz)` existe. Reconstruction partielle possible chunk par chunk.
- Socle Slate à y -40 : déjà dans `Construire` [code l.77].
- Durée connue : quelques secondes pour 121 chunks [page S7] ; incluse dans les 35 s de la phase A.
- Ensuite : **S3 obligatoirement** (S7 chunks cz 0..1 <-> S3 chunks cz 15..16 [déduit]), `Raccords_EST.Appliquer()`, et `Ponceau_RD1.Appliquer()` si les chunks (8,7) et (8,8) ont été reconstruits (cx 8 = X 3448..3704 ; cz 7..8 = Z 3192..3704).

### 3.8 S8 Nord-est (zones M puis O)
- Appels [code] : `S8Terrain.Nettoyer("M")` puis `for cx=0,9 do for cz=0,6 do S8Terrain.Construire("M",cx,cz) end end` ; puis `S8Terrain.Nettoyer("O")` puis `for cx=0,1 do for cz=0,4 do S8Terrain.Construire("O",cx,cz) end end`. `S8Terrain.Nettoyer()` sans argument vide les deux zones (Y 100..1100). `S8Terrain.Nb[zone]` = {nbX, nbZ}.
- Zone **M d'abord, O ensuite** (ordre de la phase A). "O" réécrit des colonnes de S3 identiques sauf le sentier et le ruisseau ; pour restaurer S3 : refaire `S3Terrain.Construire` sur les chunks de ces colonnes (cx 4..5, cz 0..4 [déduit]) puis `Construire("O",..)` [en-tête S8Terrain].
- Pré-requis : S3 d'abord ; `S7Donnees` et `S3Donnees` chargés. Socle Slate à y 100 [code l.88].
- Durée connue : "M" environ 4 s [page S8] ; "O" 10 chunks ; durée de `Nettoyer` non vérifiée.
- Ensuite : `Raccords_EST.AppliquerNord()` (qui lit `S8.Colonne` en X 1500..1700, Z -2560..-2400).
- Le correctif du trou d'eau à la jonction (seuil Z < -1952, `wm = Lisse((-1952-Z)/10)`) est dans le source de `S8Donnees` [page S8] ; après reconstruction de "O", vérifier l'eau sur X = 2690, Z -1940..-2000 (section 7).

---

## 4. Post-passes : contenu, place, relance

| Post-passe | Appel exact | Place dans l'ordre | Remarques |
| --- | --- | --- | --- |
| Bande sud de S4 | `S6Terrain.ReecrireBandeS4(i)`, **i = 0..10** | après S4 ET S5, avant ou avec S6 | `BandeX0 = -1300`, `BandeNb = ceil((XMax+1300)/256) = 11` [code]. Écrit Z 2400..2500, X -1300..1400 : colonnes `D5.Colonne` avec le rabais de S4 (30) retiré pour X >= -1000, et sentier du poste pour 150 < X < 310. Relancer après TOUTE reconstruction de S4 ou du coin sud-est de S5. |
| Sentier de la grotte | `S6Terrain.EcrireSentierCave()` (X -2480..-2400, Z 2380..2500) | après S5 | Appelle `D.AppliquerSentierCave` (filtre de colonne, pas une passe). Non appelé par `S5Donnees` [grep]. |
| Sentier du poste | `S6Terrain.EcrireSentierPoste(i)`, i = 0..3 (X 176..256, Z 1480..2400) | après S4 | Écrit dans la boîte de S4 ; la bande Z 2400..2500 est déjà dans `ReecrireBandeS4`. |
| **Corr3** | **ne pas appeler `S2Terrain.Raccord()`** | jamais après S3 | `S2Donnees.Corr3` et `D.BandesS3` ne sont atteintes que par `S2Terrain.Raccord()` ; `S2Terrain.Construire` ne les utilise pas [code]. `Raccord()` écrit X 1400..1700 (Z -1000..-500) et X 1400..1500 (Z -2500..-2400), à l'intérieur de la boîte de S3, et doublerait la correction déjà intégrée dans `S3Donnees.Colonne` (l.433) [page phase A, code]. « À retirer côté S2 » = ne jamais appeler `Raccord()` (ou supprimer `Corr3`/`BandesS3`/`Raccord` du module, à faire dans Studio : non fait, ce document est en lecture seule). |
| **Raccords_EST** | `Raccords_EST.Appliquer()` = `AppliquerOuest()` + `AppliquerNord()` ; `CalibrerProfil()`, `Delta(X,Z)` ; ensuite `Mesurer()` | **en DERNIER pour l'EST** | Couture ouest X = 1400, Fondu 240, Z -2400..4000, bandes de 256 (`Bande`), pas 8, Lissage 2, Recul 10, Biais 2.0, MaxCorr 30. Marge nord : X 1500..1700, Z -2560..-2400. Lit le terrain réel de S4/S6/S2 en X = 1390 : ces voisins doivent exister. Idempotent [en-tête]. Ne touche jamais S4, S2, S6, S5. `Mesurer()` renvoie `(R, texte)`. |
| **Ponceau_RD1** | `Ponceau_RD1.Appliquer()` (renvoie le nombre de cellules modifiées) ; `Ponceau_RD1.Mesurer()` | après S7 (chunks (8,7) et (8,8)), après Raccords | Boîte autorisée X 3390..3890, Z 3200..3700 ; zone X 3580..3700, Z 3360..3544, Y 0..112, tranches `PasZ` 48. Idempotent : le 2e appel doit renvoyer 0 ; sans effet si le ponceau est intact. L'ordre avec `Raccords_EST` est sans effet (frontières lointaines) [page ponceau]. |
| Polissage | modules `Polissage_<Region>` avec `Appliquer(zone)` [BRIEF_POLISSAGE] | après raccords et ponceau | Aucun module `Polissage_*` dans `terrain/` : leur existence dans Studio est **non vérifiée** (hot.md : agents stoppés). Toute `Construire` ultérieure efface le polissage de la zone. |

Raccords_EST : découper pour la règle des 30 s : appels séparés `AppliquerOuest()` puis `AppliquerNord()`. `AppliquerOuest()` lui-même n'est pas découpable (aucun paramètre de plage) ; sa durée est non vérifiée (25 bandes de 256 + 800 raycasts de calibrage, estimation [déduit]). `Mesurer()` n'est pas découpable non plus : durée non vérifiée.

---

## 5. Matrice : si je reconstruis X, je dois relancer Y

### 5.1 Reconstruction de terrain

« doc » = écrit dans une page ou un en-tête. « déduit » = tiré des boîtes (non testé).

| Si je reconstruis | Je relance | Source |
| --- | --- | --- |
| **S4** (entier) | nettoyage borné (3.4) ; `S6Terrain.ReecrireBandeS4(0..10)` ; `S6Terrain.EcrireSentierPoste(0..3)` ; S5 (au minimum cx 11..12, tout cz, pour la bande X -1100..-790) ; S1 `Construire(11,13)` ; S2 chunks cz 13..14 (Z -600..-200) ; `Raccords_EST.Appliquer()` + `Mesurer()` | doc : bande S6, S5 après S4, S1 après S4 ; déduit : sous-ensembles de chunks |
| **S5** | `S6Terrain.ReecrireBandeS4(0..10)` ; `S6Terrain.EcrireSentierCave()` ; `S1Terrain.Construire(cx,13)` cx 0..11 ; blocs `MANQUANT_` au sol | doc (pages S1, S5, S6) |
| **S6** | rien d'obligatoire côté terrain ; `Raccords_EST.Appliquer()` si le chunk cx 21 est touché | déduit |
| **S1** | rien | — |
| **S2** | `Raccords_EST.Appliquer()` (couture S3 <-> S2) ; **jamais `S2Terrain.Raccord()`** | doc + code |
| **S7** (entier) | **S3 entier** (ou au minimum cz 15..16) ; S8 non ; `Raccords_EST.Appliquer()` ; `Ponceau_RD1.Appliquer()` | doc : ordre S7 -> S3 ; déduit : cz 15..16 |
| **S7** chunks (8,7) et (8,8) seulement | `Ponceau_RD1.Appliquer()` ; `Raccords_EST` inutile (frontières lointaines) | doc |
| **S3** (entier) | S8 "M" puis S8 "O" ; `Raccords_EST.Appliquer()` ; relire T1 en X 1500..1700 | doc |
| **S3** chunk cz 0 | S8 "M" cz 5..6 [déduit] | déduit |
| **S8 "M"** | S8 "O" (non nécessaire en données, mais dans l'ordre phase A) ; `Raccords_EST.AppliquerNord()` | doc partiel |
| **S8 "O"** | rien ; vérifier l'eau X 2690, Z -1940..-2000 | doc |
| **Raccords_EST seul** | rien (idempotent) | doc |

### 5.2 Modification d'un module de données ou de hauteur

D'après le graphe des `require` [code] ; chaque ligne = quels secteurs il faut reconstruire pour que le terrain reflète la modification.

| Module modifié | Secteurs à reconstruire |
| --- | --- |
| `HauteurGlobale` | tous (S1 à S8) puis post-passes |
| `MelangeMateriaux` | tous (matériaux seulement, hauteurs inchangées) ; les passes `Raccords_EST`, `Ponceau_RD1` utilisent aussi ce module |
| `S4Donnees` | S4, S5, S6, S3, S7, S2, S8 (tous en dépendent) |
| `S5Donnees` | S5, S6 (ruisseau recopié) |
| `S7Donnees` | S7, S3, S8, puis `Raccords_EST`, `Ponceau_RD1` |
| `S3Donnees` | S3, S8 ; S2 ne l'utilise que via `Corr3` (ne pas lancer) |
| `Alignement_EST` ou `HauteurEST` | S7, S3, S8 (reconstruction EST entière), puis `Raccords_EST`, `Ponceau_RD1` |
| `S8Donnees` | S8 "M" et "O" ; `Raccords_EST.AppliquerNord()` |
| `S1Donnees`, `S2Donnees`, `S6Donnees` | S1, S2, S6 respectivement |

---

## 6. Pièges

1. **Cache de `require`.** Un module modifié dans Studio renvoie l'ancienne version. Le cache peut même être plus ancien que la Source (`H(2550,1500)` valait 63 en cache contre 99 en source fraîche [page S4]). Procédure : supprimer tout ancien clone, cloner le dossier **entier** sous un nom unique, `require` dans le clone, détruire le clone à la fin. Gabarit non exécuté :
   ```lua
   local SS = game:GetService("ServerStorage")
   local ancien = SS:FindFirstChild("TEMP_TS_CLONE"); if ancien then ancien:Destroy() end
   local c = SS.TerrainSectors:Clone(); c.Name = "TEMP_TS_CLONE"; c.Parent = SS
   local S7T = require(c.S7Terrain)
   -- ... boucles de Construire ...
   c:Destroy()
   ```
   Plusieurs clones de même nom : `ServerStorage.TEMP_x` renvoie le plus vieux [page S2] : en garder un seul.
2. **`Terrain:Clear()` interdit** : il effacerait les autres secteurs. Utiliser les `Nettoyer` bornés. Exception de fait : `S4Terrain.Nettoyer()` EST un `Terrain:Clear()` : ne pas l'appeler (3.4). Les autres : `S1Terrain.Nettoyer()`, `S2Terrain.NettoyerBoite(b)`, `S3Terrain.Nettoyer()`, `S5Terrain.Nettoyer()`, `S6Terrain.Nettoyer()`, `S7Terrain.Nettoyer()` (l'en-tête dit « vide le terrain », le code est borné par chunk), `S8Terrain.Nettoyer(zone)`.
3. **Socle Slate.** `S3Terrain`, `S7Terrain` (y -40) et `S8Terrain` (y 100) remplissent un socle Slate plein sous la bande écrite, car `Alignement_EST` relève le sol de 100 à 175 studs par endroits et `Nettoyer` vide toute la hauteur. S1, S2, S4, S5 n'ont pas de socle dans leur code (grep).
4. **`execute_luau` renvoie toujours `nil`.** Retourner les résultats par `error("...")` ou par un attribut temporaire de `workspace` nommé `TEMP_<Quoi>_...`, puis `inspect_instance`, puis le supprimer. Les `print` vont dans la console cumulative (ne pas la relire en entier).
5. **Un appel doit durer moins de 30 s.** Boucles par chunks avec `task.wait()`, regroupées par morceaux (S1 par colonnes de cx). Durées des `Nettoyer` : non vérifiées. Studio est partagé : les appels peuvent expirer, réessayer.
6. **Studio en Play : les éditions sont refusées.** Rester en mode Edit pour construire et mesurer. Test de lecture : poser `workspace:SetAttribute("LOCK_PLAY","<nom>")`, tester, arrêter le play, remettre à nil [BRIEF_SECTEUR_COMMUN].
7. **`WriteVoxels` et l'eau résiduelle.** `WriteVoxels` ignore l'eau écrite dans une cellule qui garde une occupation résiduelle (1/256). Vider d'abord (Air) puis écrire : c'est ce que fait `Ponceau_RD1`, et la raison de `NettoyerBoite` avant `Construire` en S2.
8. **Contradictions entre pages et code.**
   - La page S6 écrit `for i=0,9 do S6Terrain.ReecrireBandeS4(i)` : périmé. Le code donne `BandeNb = ceil((XMax+1300)/256) = 11`, donc **i = 0..10**.
   - La page S6 parle de `RabaisNord 30` : le code a `RabaisNord = 0` (S4/S5 n'ont plus de rabais côté S5 : `SudChute = 0`).
   - L'en-tête de `S7Terrain` dit « vide le terrain » ; le code est borné par chunk (A1).
   - Pages et briefs : `ServerStorage/TerrainBuilder` ; réel : `TerrainSectors`.
   - Page S3 : « S3Terrain non copié en local » ; la copie existe dans `terrain/`.
9. **Objets posés sur l'ancien sol.** `Nettoyer`/`Construire` ne touchent que le terrain. Les hauteurs sont déterministes (même graine) : si le code des données n'a pas changé, les modèles restent bien posés ; sinon vérifier par raycast. Ne pas toucher `Workspace.Model` (pont de Gabriel, pivot 3467, 133.6, 1600, rotation -30.4 [page phase A]), `Workspace.TEMP_out`, `Workspace.TEST_Rock09`. Ne pas toucher `MaterialService`.
10. **Idempotence.** `Raccords_EST` et `Ponceau_RD1` sont idempotents [en-têtes] : relancer sans risque. Les `Construire` ne le sont pas vis-à-vis des passes qui les suivent : toute `Construire` EST efface le raccord, le ponceau et le polissage de son chunk.

---

## 7. Commande de vérification type après reconstruction

Gabarits NON exécutés (à adapter, à lancer en Edit, résultats par `error()` ou attribut temporaire). Valeurs de référence : voir ci-dessous.

```lua
-- (a) cibles bible 3.2 : hauteur de sol par raycast (Raccords_EST.Ray ignore l'eau, filtre Terrain)
local TS = game.ServerStorage.TEMP_TS_CLONE
local RE = require(TS.Raccords_EST)
local cibles = { -- nom, X, Z, cible ; le raycast = conception + ~2 (Biais mesuré 1.84..2.07)
  {"P01",2800,3200,120},{"P03",3200,2200,110},{"P16",3467,1600,150},{"P05",2600,-1400,400},
  {"P05c",2550,-1300,300},{"P15",3333,-667,390},{"P23",2400,-3467,560},{"P24",3800,667,300},{"CreteEst",3200,-800,400},
}
local out = {}
for _, c in ipairs(cibles) do out[#out+1] = c[1] .. " " .. tostring(RE.Ray(c[2], c[3])) .. " (cible " .. c[4] .. ")" end
-- (b) sauts de frontière et couture : table + texte
local R, texte = RE.Mesurer()
-- (c) ponceau : eau sur l'axe de R2, chaussée
local PR = require(TS.Ponceau_RD1)
local Rp = PR.Mesurer()
workspace:SetAttribute("TEMP_VERIF", table.concat(out, "\n") .. "\n" .. texte .. "\ntrous=" .. #Rp.Trous .. " hausses=" .. Rp.Hausses)
```

Eau monotone décroissante vers l'aval (lecture voxel) : gabarit : pour chaque X, Z de l'axe, `T:ReadVoxels(Region3.new(Vector3.new(x0,0,z0), Vector3.new(x0+4,Ymax,z0+4)), 4)` avec x0, z0 multiples de 4, puis le haut de la plus haute cellule `Enum.Material.Water` ; compter les hausses > 0,05 entre points successifs (même méthode que `Ponceau_RD1.Mesurer`). Le contrôle des chaînes se fait dans le sens du courant.

Valeurs à retrouver (toutes issues des pages ; elles datent des dernières mesures et peuvent avoir bougé) :
- **Cibles bible 3.2** : la table 3.2 elle-même n'est pas dans les sources lues ; les cibles ci-dessus viennent de `Alignement_EST.Ancres` et des mesures de la phase A. Plateaux : P01 120, P03 bord 110 (fond 41,5 visé, 37,8 mesuré), P16 tablier 150 (eau 100, lit 100,5), P05 bord 400 (399,6 mesuré), P05c corniche 300, P15 pad 390, P24 pad 300, P23 pad 560, CreteEst 400, lit P02 sud 110 (NiveauLahar mesuré 105,9..109,6). Sortie de T1 en X = 1500 : (1500,-2240), 322,4 (plan) / 324,4 (voxel).
- **Sauts de frontière** : <= 3 à 4 studs aux coutures de hauteur (BRIEF_SECTEUR_COMMUN) ; `Raccords_EST.Mesurer()` donne par couture n, max, médiane, nombre > 4 et l'écart à la 2e différence. Valeurs historiques : S5/S4 max 5,8 au bord de la cuvette du ruisseau ; S3/S8 saut max 11,5 (pente naturelle de montagne) ; S3/S7 4,0 au bord de la cuvette.
- **Eau monotone** : 0 hausse sur chaque chaîne (mesures historiques : S7 24 points, S3 196 points, S2 115 points, S4, S8 68 points, R2 125 points sur le ponceau).
- **Jonctions de ruisseaux** : S5/S6 : eau 40,28 / 40,20, largeur 32,7 ; S2/S4 : lit 228,5, différence 0,00 sur Z -202/-198 ; S4/S5 : lit 79,4, largeur 22 ; lac de S1 : niveau 336 constant, sortie de l'affluent 252,5, largeur 24 ; S3/S7 : bedC 112, largeur 20 ; S8/S3 : eau 244,4 à Z -1952.
- **Trou d'eau S8** : eau présente sur X = 2690, Z de -1940 à -2000 (le défaut historique était absent de -1956 à -1976).
- **Ponceau** : 0 trou sur 125 échantillons, 0 hausse, hauteur libre mini 16,75 (>= 6), RD1 100 % Asphalt, pente voxel max 8,07 %, 2e `Appliquer()` = 0.
- **Raccord Raccords_EST** : après relance, `Mesurer()` doit redonner le même terrain (idempotence).
- T1 : relire l'axe en X 1500..1700 après `Raccords_EST`.

---

## 8. Nom du dossier

`ServerStorage/TerrainSectors` (DÉFAUT de la coordinatrice, 10/11/2026) : ancien nom `TerrainBuilder`, renommé pour éviter la collision avec le ModuleScript `TerrainBuilder` du dépôt Rojo. Tout `require` passe par `script.Parent` : cloner **ce dossier entier** dans un dossier temporaire (section 6, piège 1).

---

## 9. Liste des « non vérifié »

1. Procédure de nettoyage borné de S4 : proposition inspirée de `S5Terrain.NettoyerChunk`, absente du code (3.4).
2. Durées de tous les `Nettoyer`, de `Raccords_EST.AppliquerOuest/AppliquerNord/Mesurer`, de `Ponceau_RD1.Appliquer/Mesurer` : non documentées.
3. Découpage exact en appels de moins de 30 s (estimation pour S1 : environ 0,36 s par chunk).
4. Les sous-ensembles de chunks « minimaux » de la matrice (S5 cx 11..12, S2 cz 13..14, S1 `Construire(11,13)`, S7 cz 0..1 <-> S3 cz 15..16, S8 "M" cz 5..6, S3 cx 4..5 pour "O") sont déduits des boîtes, jamais testés ; la règle documentée est la reconstruction du secteur entier.
5. Ordre relatif S1 / S2 : non documenté (aucun recouvrement) ; S2 après S5 : déduit des boîtes.
6. Phase B : T1 a été reconstruit par un constructeur temporaire par tuiles de 64 x 64, copie conforme de `Construire` mais non exporté (page T1) ; l'équivalence exacte avec une `Construire` complète n'est pas vérifiée (seuls les voxels souterrains à plus de 48 studs sous la surface ont été signalés comme Slate).
7. Les copies de `S3Donnees`, `S7Donnees`, `S8Donnees` (modifiées 18:52 à 18:59) sont plus récentes que `Raccords_EST` (18:27) et `Ponceau_RD1` (18:31) : aucune page ne dit que ces passes ont été relancées après la dernière édition de T1.
8. Table bible 3.2 : absente des sources lues ; cibles tirées de `Alignement_EST.Ancres` et des mesures de phase A.
9. Modules `Polissage_*` : absents de `terrain/`, existence dans Studio non vérifiée ; aucune page `POLISSAGE_<Region>.md` lue.
10. Suppression effective de `Corr3`/`BandesS3`/`Raccord` dans `S2Donnees`/`S2Terrain` : non faite (le dossier `terrain/` contient encore les trois) ; la consigne est de ne pas appeler `Raccord()`.
11. Sentier de la grotte : les 35 studs Z 2345..2380 ne sont écrits par aucune passe du code lu (limite de la page S6) ; l'état actuel dans Studio n'est pas vérifié.
12. Présence réelle de `Alignement_EST`, `HauteurEST`, `Raccords_EST`, `Ponceau_RD1` dans `ServerStorage/TerrainSectors` et identité avec les copies de `terrain/` : non vérifiée dans ce document (Studio non consulté).
13. Comportement du gabarit de vérification (section 7) : non exécuté.
