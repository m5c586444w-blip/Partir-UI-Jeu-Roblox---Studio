## 9. La créature : biologie et IA

La créature est un grand primate nocturne, territorial et rancunier, qui vit en famille. Elle ne poursuit pas bêtement : elle observe, avertit, teste, puis frappe quand une proie s'isole. Tout son comportement s'appuie sur des comportements réels de grands singes et sur les récits locaux. Valeurs dans `Config/CreatureConfig`.

### 9.1 Ce sur quoi le comportement repose

| Comportement | Base | Source | Statut | En jeu |
| --- | --- | --- | --- | --- |
| Activité nocturne | L'ordonnance de 1969 parle d'un possible « primate nocturne » | [WSBA](https://nwsidebar.wsba.org/2019/10/31/washington-rules-to-make-you-scream-this-halloween-completely-bizarre-but-totally-real-laws-legislation-and-legal-references/) | Texte réel, créature non prouvée | Se retire à l'aube (05 h 50) |
| Martellement de poitrine | Chez le gorille, signal honnête de la taille, rare (1,6 fois par 10 h en moyenne) et qui peut éviter le combat | [National Geographic](https://www.nationalgeographic.com/animals/article/why-do-gorillas-beat-their-chests) | Établi (gorille) | Alpha seulement, dernier avertissement avant une charge |
| Avertissement puis charge | Grognements, végétation arrachée, posture debout ; la plupart des charges s'arrêtent avant le contact | [Rwenzori Expeditions](https://www.rwenzoriexpeditions.com/things-to-observe-on-gorilla-trekking/) | Source touristique, à prendre avec prudence | Échelle d'intimidation, fausse charge |
| Lancer de pierres sur des arbres précis, tas de pierres | Observé chez quatre populations de chimpanzés d'Afrique de l'Ouest, surtout des mâles adultes | [Scientific Reports 2016](https://doi.org/10.1038/srep22219), [The Debrief](https://thedebrief.org/wild-chimpanzees-keep-hurling-rocks-at-the-same-trees-now-scientists-are-trying-to-figure-out-why/) | Établi (chimpanzé) | 3 « arbres à pierres » fixes, marquage du territoire |
| Coups sur les troncs, cris, pierres lancées pour faire partir | Rapports de témoins dans l'État de Washington | [BFRO 31749](https://www.bfro.net/GDB/show_report.asp?id=31749), [BFRO 67407](https://www.bfro.net/GDB/show_report.asp?id=67407) | Témoignages, non prouvés | Échelle d'intimidation |
| Bombardement nocturne d'une cabane | Récit de 1924 | [Wikipedia](https://en.wikipedia.org/wiki/Ape_Canyon) | Récit, contesté par les rangers | Acte 2 |
| Sifflements la nuit, vengeance, bâtons dans les tentes | Récits du Nord-Ouest | [Native Languages](https://www.native-languages.org/morelegends/stick-indians.htm), [Chinook Jargon](https://chinookjargon.com/2021/03/17/pre-1917-ka-mi-akin-last-hero-of-the-yakamas-part-2-of-2/) | Tradition orale | Sifflements des éclaireurs, rancune |

### 9.2 La famille

| ID | Membre | Taille | PV (Normal) | Présence | Rôle |
| --- | --- | --- | --- | --- | --- |
| CRT\_Alpha | Mâle dominant | 2,8 m (10 studs) | 1 000 | Toujours | Chasseur principal, saisit, tue, martelle |
| CRT\_Scout1/2 | Jeunes adultes | 2,2 m (8 studs) | 500 | Selon la taille du groupe (5.5) | Rabattent, lancent des pierres, imitent, sifflent |
| CRT\_Female | Femelle | 2,5 m (9 studs) | 800 | Tunnels uniquement | Garde le repaire, très agressive sous terre |
| — | Juvénile | 1,3 m | — | Mort (os gardés par la femelle en P07b) | Moteur de la vengeance |

Régénération : +2 PV/s hors combat, jusqu'à 70 % du maximum. Tuer l'Alpha demande donc des tirs rapprochés dans le temps.

| Allure | Vitesse (studs/s) | Limite |
| --- | --- | --- |
| Approche furtive | 6 | Bruit 8 |
| Marche | 10 | Bruit 30 (pas lourds) |
| Course debout | 22 | Bruit 80 |
| Sprint à quatre pattes | 30 | 6 s, puis 20 s de récupération |
| Escalade | 5 | Seulement entre deux points tagués `ClimbPoint` |

Un joueur qui court (20) ne la distance pas à découvert. Il survit grâce au groupe, à la lumière, au feu, à l'eau, à la cabane et aux armes.

### 9.3 Architecture

Trois niveaux, tout côté serveur, les modèles des créatures appartenant au serveur (`SetNetworkOwner(nil)`).

| Niveau | Module | Fréquence | Rôle |
| --- | --- | --- | --- |
| Directeur | `TensionDirector` | 1 fois/s | Mesure la tension, autorise ou interdit les attaques, déclenche des événements |
| Famille | `FamilyBrain` | 2 fois/s | Répartit les rôles, coordonne les pièges à plusieurs |
| Individu | `CreatureBrain` | 5 fois/s (perception 10 fois/s à moins de 150 studs, 2 fois/s au-delà) | Choisit un comportement (IA à utilité), l'exécute (machine à états) |

**Simulation à distance :** si aucun joueur n'est à moins de 600 studs d'une créature, elle n'a plus de corps physique et se déplace sur un graphe de points (`CreatureNav` : un nœud tous les 200 studs, plus un par lieu). Son corps réapparaît hors de vue dès qu'un joueur s'approche.

### 9.4 Perception

**Vue.** Portée `Rv = 180` (nuit) ou `300` (aube), × difficulté, × météo (brouillard 0,5, pluie 0,7), × coefficient de visibilité du joueur (7.6). Cône de 120°, vision périphérique jusqu'à 200° avec ×0,4. Deux rayons (tête et torse du joueur) depuis la tête de la créature ; les feuillages ne bloquent pas, troncs et rochers oui.

**Vigilance par joueur (0 à 1).** Quand un joueur est vu : `+1,5 × (1 − d / Rv) × visibilité` par seconde. Sinon, `−0,1` par seconde.

| Vigilance | Réaction |
| --- | --- |
| 0,3 | Tourne la tête, s'immobilise |
| 0,7 | Connaît la position exacte |
| 1,0 | Le joueur devient cible possible |

**Ouïe.** Chaque bruit est un événement `{position, rayon, type}`. Il est entendu si `distance ≤ rayon × ouïe × atténuation` (ouïe : Alpha 1,0, éclaireurs 1,2 ; atténuation : pluie 0,6, à moins de 30 studs d'un ruisseau 0,4, cascade P13 0,2, murs de la cabane 0,7). L'endroit retenu est faux de 10 % de la distance. Un coup de feu met la vigilance du tireur à 1,0.

**Odorat.** Selon le vent (`workspace.GlobalWind`) : joueur au vent de la créature (le vent va du joueur vers elle) senti à 80 studs, vent de travers 30, sous le vent 10. Une hémorragie dépose un point de piste tous les 4 studs, actif 300 s : la créature peut la suivre au pas.

**Lumière.** Un faisceau qui la touche dans sa portée met la vigilance du porteur à 1,0.

### 9.5 Comportements (IA à utilité)

Chaque comportement a un score de 0 à 1. La créature garde le comportement en cours sauf si un autre dépasse son score ×1,25, et chaque comportement a une durée minimale.

| ID | Comportement | Score élevé quand | Durée min | Ce qu'elle fait |
| --- | --- | --- | --- | --- |
| BHV\_Roam | Errance | Rien d'autre (score fixe 0,2) | 20 s | Parcourt son territoire par les zones couvertes |
| BHV\_Feed | Manger | Faim > 0,7 (faim +0,01/min) | 40 s | Va à P19 ou à une carcasse ; moment calme exploitable |
| BHV\_Mark | Marquer | Hors combat, près d'un arbre à pierres | 15 s | Ajoute des pierres au tas, casse une branche à 3 m |
| BHV\_Observe | Observer | Tension basse, cible inconsciente | 30 s | Se poste à 40–90 studs derrière un tronc ; fuit si éclairée ou approchée à 25 studs |
| BHV\_Intimidate | Intimider | Joueurs près du territoire ou du repaire | une marche | Monte d'un cran sur l'échelle 9.6 |
| BHV\_Stalk | Traquer | Cible choisie, pas encore isolée | 45 s | Suit à 50–80 studs sans être vue |
| BHV\_Ambush | Embuscade | Objectif des joueurs connu | 90 s max | Attend à 20–30 studs du chemin probable |
| BHV\_Attack | Attaquer | Cible isolée, directeur d'accord | — | Une attaque de la table 9.10 |
| BHV\_Throw | Lancer | En hauteur, cible à 20–120 studs | 20 s | Pierres sur les joueurs, les lampes, les planches |
| BHV\_Sabotage | Saboter | Groupe soudé depuis 120 s | 30 s | Casse les lanternes du camp, renverse le feu, vole un sac posé |
| BHV\_Drag | Traîner | Joueur à terre ou mort | jusqu'à la réserve | Emporte le corps vers une réserve : rive du lac P20, sous les troncs de P04, repaire P07b |
| BHV\_Retreat | Fuir blessée | 15 % de PV perdus en 10 s, fusée, bombe anti-ours | 30–60 s | Se replie vers la forêt dense ou les tunnels, régénère, revient enragée |
| BHV\_Siege | Siège | Acte 2 | tout le siège | Tourne à 25–40 studs, lance depuis le bord du canyon, teste les barricades |
| BHV\_Guard | Garder | Femelle, joueur à moins de 40 studs du repaire | — | Attaque sans avertissement |
| BHV\_Mimic | Imiter | Éclaireur, une cible s'éloigne du groupe | 10 s | Rejoue un son préenregistré (9.8) |
| BHV\_Avoid | Éviter | Feu ou fusée à moins de 40 studs, aube | — | Reste hors du rayon ; à 05 h 50, rentre au repaire |

### 9.6 Échelle d'intimidation

Chaque cran attend le précédent (moins de 5 min avant). L'échelle redescend d'un cran toutes les 3 min sans contact. Le joueur attentif voit donc toujours venir le danger.

1. Silence de la faune autour d'elle (60 studs).
2. Coups sur un tronc, souvent en réponse à un autre membre de la famille.
3. Cri long à distance ou grognement proche.
4. Branche lancée ou pierre qui tombe à côté du joueur, pas sur lui.
5. Branche cassée tout près, hors de vue.
6. Apparition debout, martellement de poitrine (Alpha).
7. Fausse charge : s'arrête à 4–8 studs, puis repart (60 % des cas si le joueur ne fuit pas et n'éclaire pas).
8. Vraie attaque.

### 9.7 Choix de la cible

Score recalculé toutes les 2 s pour chaque joueur, entre 0 et 1 pour chaque terme :

```latex
S = 3{,}0\,I + 1{,}5\,B + 1{,}0\,N + 1{,}2\,L + 2{,}0\,R + 0{,}8\,P + 0{,}5\,C
```

- I (isolement) = distance au coéquipier le plus proche ÷ 60, plafonné à 1.
- B (blessure) = 1 − santé moyenne ; +0,3 en hémorragie.
- N (bruit) = bruit des 10 dernières secondes ÷ 100.
- L (lumière) = 1 si la lampe est allumée, 0,5 si la tablette est ouverte.
- R (rancune) = dégâts infligés à cette créature ÷ 200 ; +0,3 par fusée ; +0,5 si filmée à moins de 30 studs ; tirs du Pisteur comptés double.
- P (proximité) = 1 − distance ÷ 300.
- C = 1 si le joueur porte une preuve de classe A.

La cible change seulement si un autre joueur dépasse le score actuel de 20 %.

### 9.8 Mémoire et apprentissage pendant la partie

| Ce qu'elle retient | Déclencheur | Ce qui change |
| --- | --- | --- |
| Cachettes | Un joueur s'y est caché (couché, dans un bâtiment) | Les fouille en premier ensuite |
| Chemins | Passages des joueurs, par case de 64 studs | Embuscades sur les chemins les plus pris |
| Armes | 2 tirs reçus | Attaque depuis les hauteurs, lance plus, reste à plus de 60 studs à découvert, arrive par derrière |
| Lumière | Éclairée 3 fois | Se cache au lieu de fuir ; attend que les piles faiblissent ; contourne les faisceaux |
| Fusées | 2e fusée | Fuite réduite de 8 à 4 s |
| Groupe soudé | Groupe dans un rayon de 25 studs pendant 120 s | Passe en usure : sabotage, pierres, attente des isolés |
| Rancune | Voir 9.7 | La cible préférée reste la même d'un acte à l'autre |

**Imitation (éclaireurs).** Ils rejouent des sons préenregistrés du jeu, jamais la vraie voix d'un joueur : sifflement humain (SFX\_Whistle\_01–03), appel « Hey ! », et l'appel à l'aide d'un personnage mort (VO\_\<ROLE>\_Help). L'Opératrice radio les repère (7.7).

**Personnalité de l'Alpha** (tirée à chaque partie) :

| Personnalité | Modificateurs |
| --- | --- |
| Patiente | Traque ×1,5 de durée, attaques ×0,8 de fréquence, vise surtout les isolés |
| Territoriale | Intimidation ×1,4, attaques ×1,3 dans un rayon de 800 studs autour de P05 |
| Joueuse | Imitation et pierres ×1,6, plus de fausses charges, harcèle sans tuer en acte 1 |

### 9.9 Coordination de la famille

- **Pince :** un éclaireur frappe un tronc d'un côté du groupe ; l'Alpha attend de l'autre côté, là où le groupe va fuir.
- **Rabattage :** les éclaireurs lancent des pierres pour pousser un joueur vers l'Alpha.
- **Séparation :** un éclaireur imite un appel à l'aide pour attirer un joueur hors du groupe.
- **Règle de lisibilité :** jamais plus de 2 créatures visibles en même temps par un joueur.
- **Tunnels :** la femelle garde P07b ; l'Alpha y suit les joueurs seulement à partir de l'acte 4.

### 9.10 Attaques

Chaque attaque a un signal sonore avant les dégâts, pour que la mort ne paraisse jamais injuste.

| ID | Attaque | Portée (studs) | Signal (s) | Dégâts | Parade |
| --- | --- | --- | --- | --- | --- |
| ATK\_Strike | Coup | 7 | 0,6 (grognement) | 35 sur un membre, recul | Esquive, hache |
| ATK\_Charge | Charge | départ 15–40 | 0,8 (cri + pas) | 40 + à terre 2 s | Fusée, lampe puissante, bombe anti-ours |
| ATK\_Grab | Saisie | 6 | 0,4 | 10/s tant que tenu ; traîné après 3 s | Coéquipier : hache 1 coup, machette 2, bombe, tir |
| ATK\_Throw | Pierre | 20–120 | sifflement de la pierre | 15–30 | Couvert |
| ATK\_Slam | Frappe au sol (joueur à terre) | 5 | 1,0 | 60 | Relever le joueur avant |
| ATK\_ReachThrough | Bras par une barricade cassée | 5 dans la cabane | 0,5 | Saisie | Reclouer, hache |
| ATK\_Execution | Mise à mort (Alpha, joueur à terre, profil Restricted seulement) | 3 | 1,5 | Mort | Aucune ; noir à l'instant de la mort (section 11) |

### 9.11 Déplacement

- `PathfindingService` avec `AgentRadius = 3`, `AgentHeight = 10`, `AgentCanJump = true`, et des coûts par matériau ([doc Roblox](https://create.roblox.com/docs/reference/engine/classes/PathfindingService)) : Water 5, Sand (cendre) 3, Pebble 2, Rock 2, Grass 1, LeafyGrass 0,8.
- Volumes `PathfindingModifier` : `Cover` 0,6 (forêt dense), `Trail` 1,5 (elle évite les sentiers), `Forbidden` 10 sur P08 sauf en chasse (1).
- Escalade : paires de `ClimbPoint` (bas/haut) sur les falaises d'Ape Canyon, de Lava Canyon et de F01. Les joueurs ne peuvent pas les utiliser.
- Près de la cible (moins de 30 studs), déplacement direct avec évitement par rayons, sans recalcul de chemin.

### 9.12 Directeur de tension

Le directeur mesure une tension T par joueur (0 à 100) et une intensité de groupe (moyenne des T). Il ne déplace pas la créature : il autorise, interdit ou suggère.

```latex
T = 0{,}5 \times \text{peur} + 0{,}3 \times (100 - \text{santé moyenne}) + 20 \times e^{-t/30}
```

t = secondes depuis le dernier événement fort vécu par ce joueur (attaque, créature vue de près, mort d'un coéquipier).

| Règle | Détail |
| --- | --- |
| Montée | Intensité < 25 pendant 120 s : un événement de la section 10 (catalogue « bas ») |
| Pic | Intensité > 75 pendant 90 s : pause imposée de 60 à 90 s, les créatures passent en Observer ou Fuir |
| Acte 1 | Aucune mort, sauf joueur isolé à plus de 200 studs du groupe pendant 60 s ou joueur qui tire sur la créature. Garantis : 1 aperçu lointain (CS\_03) et 2 signes |
| Acte 2 | 1 mort au plus en Normal (2 en Difficile, sans limite en Cauchemar) |
| Acte 3 | Au moins 2 tentatives d'attaque ; au plus 1 mort par tranche de 3 min |
| Acte 4 | Dernier assaut : toutes les créatures, plus de pause imposée |
| Groupe | Événements ×0,8 / ×1,0 / ×1,2 selon la taille (5.5) |

### 9.13 Outil de test

En Studio seulement, `CreatureDebug` (touche F8) affiche au-dessus de chaque créature : comportement, cible, scores, vigilance par joueur, chemin prévu, et la tension du directeur.

