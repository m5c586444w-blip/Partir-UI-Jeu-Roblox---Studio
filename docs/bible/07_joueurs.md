## 7. Joueurs

Chaque joueur incarne un des 10 personnages de la section 2.5, avec une apparence imposée. Il gère six jauges : santé par membre, sang, endurance, peur, bruit et lumière. Toutes les valeurs ci-dessous vont dans `Config/PlayerConfig`.

### 7.1 Personnages et skins

- L'avatar Roblox n'est jamais utilisé en partie. Chaque rôle a son modèle dans `ReplicatedStorage/Characters/<ROLE>/Skin_<n>` ; au spawn, le serveur clone le skin choisi et l'assigne à `Player.Character`.
- Le corps est découpé en 6 maillages (tête, torse, 2 bras, 2 jambes) : chacun reste sous la limite de triangles et peut se détacher pour le gore (section 11).
- 3 skins par personnage : **A** tenue de départ (dès le début), **B** tenue de pluie (5 parties jouées), **C** tenue « Cold Trail » (1 survie). Accessoires déblocables : bonnet, frontale colorée, sac.

### 7.2 Déplacement et caméra

| Action | Vitesse (studs/s) | Bruit (rayon entendu, studs) |
| --- | --- | --- |
| Marche | 12 | 25 |
| Course (endurance) | 20 (Médecin 18) | 60 |
| Accroupi | 6 | 6 |
| Couché | 2,5 | 0 |
| Porter un blessé | 8 (Sportif 12, peut courir) | 40 |
| Boiter (jambe < 30 %) | ×0,6 | +10 |
| Eau aux genoux / cendre / neige | ×0,7 / ×0,9 / ×0,85 | eau : ×2 |
| Saut (réception) | — | 30 |

- Vue à la première personne verrouillée, FOV 70 (76 en course). Balancement de marche, souffle audible. Se pencher (A/E sur PC, bouton sur mobile).
- Pas de réticule permanent : il n'apparaît qu'en visant.

### 7.3 Santé, sang, à terre, mort

| Membre | PV | Effet sous 30 % |
| --- | --- | --- |
| Tête | 30 | Vision floue, bourdonnement |
| Torse | 100 | Endurance max ÷ 2 |
| Bras gauche / droit | 50 / 50 | Visée qui tremble, recharge ×1,5 plus lente |
| Jambe gauche / droite | 60 / 60 | Boiterie, course impossible |

- **Sang (100) :** hémorragie légère −0,5/s (un bandage l'arrête), grave −2/s (seule la Médecin l'arrête ; un bandage la ramène à légère). Une hémorragie laisse une traînée que la créature suit. Sang < 40 : vision qui se désature ; < 20 : à terre ; 0 : mort.
- **À terre** quand tête ou torse tombe à 0, ou sang < 20 : 45 s (35 / 25 selon la difficulté), ramper à 1,5 studs/s, appel à l'aide. Relever : 6 s (3 s pour la Médecin), le joueur revient avec 20 % sur le membre touché.
- La créature peut traîner un joueur à terre (10 studs/s) vers une « réserve » (section 9) ; le groupe a jusqu'à la fin du compte à rebours pour le récupérer.
- **Mort définitive** pour la partie. Le corps reste en ragdoll ; l'inventaire tombe dans un sac ramassable.
- **Spectateur :** vue « caméra corporelle » d'un survivant (flèches ou balayage pour changer). Le spectateur n'a plus de voix de proximité, seulement le canal spectateurs.

### 7.4 Endurance

100 points. Course −12/s, saut −10, porter −6/s. Récupération +15/s en marchant, +25/s à l'arrêt, après 1,5 s sans effort. À 0 : 4 s d'essoufflement, haletèment audible à 35 studs. Le Géologue a 80 points.

### 7.5 Peur (0 à 100)

| Monte | Valeur | Baisse | Valeur |
| --- | --- | --- | --- |
| Aucune lumière à 10 studs | +1/s | Coéquipier à 15 studs | −2/s |
| Aucun coéquipier à 40 studs | +1,5/s | Dans la lumière | −1/s |
| Voir un corps | +15 (une fois par corps) | Près d'un feu ou d'une fusée | −3/s |
| Voir la créature | +20 à +35 (plus si proche) | Ordre du Meneur | −20 d'un coup (recharge 90 s) |
| Cri à moins de 100 studs | +10 | — | — |
| Coup sur tronc entendu | +4 | — | — |

La Descendante gagne de la peur ×1,25.

| Seuil | Effet |
| --- | --- |
| 40 | Battements de cœur audibles (pour soi) |
| 60 | Visée ×1,5 plus instable, respiration audible à 20 studs |
| 80 | Sons parfois mal placés (gauche/droite inversées 2 s), récupération d'endurance ×0,7 |
| 100 | Cri involontaire (bruit 200), au plus une fois par minute |

La peur n'est jamais affichée en chiffre : seulement par les effets et un léger vignettage.

### 7.6 Visibilité pour la créature

Coefficient multiplié à la portée de vue de la créature (section 9) :

| Situation | Coefficient |
| --- | --- |
| Debout à découvert | 1,0 |
| Debout en forêt | 0,6 |
| Accroupi | ×0,6 |
| Couché dans les fougères | ×0,1 (invisible au-delà de 10 studs) |
| Lampe allumée | ×3, visible jusqu'à 600 studs |
| Pluie ou brouillard | ×0,6 |

### 7.7 Capacités des rôles

| Rôle | Capacité | Valeurs | Faiblesse |
| --- | --- | --- | --- |
| Meneur | Voit ses coéquipiers en contour à travers le décor ; donne un ordre qui réduit la peur | contour à 30 studs ; ordre −20 peur à 15 studs, recharge 90 s | Aucune |
| Médecin | Soigne vite, arrête les hémorragies graves | soins ×2, relève en 3 s | Course à 18 |
| Pisteur | Voit les empreintes fraîches en surbrillance ; devine la direction de la créature | empreintes de moins de 120 s ; direction approximative à ±45°, recharge 60 s | Ses tirs comptent double pour la rancune |
| Caméraman | Seul à produire des preuves de classe A | voir section 8 | Batterie de 6 min |
| Mécanicienne | Répare deux fois plus vite | ×2 | Inventaire : 3 emplacements rapides au lieu de 4 |
| Descendante | Lit le carnet familial, voit les indices cachés | indices « cachés » visibles à 8 studs | Peur ×1,25 |
| Géologue | Lit la carte des tunnels, se repère sous terre | tracé visible sur la tablette dans le réseau | Endurance 80 |
| Sportif | Porte un blessé en courant, barricade vite | course à 12 en portant, planche en 4 s | Respiration : bruit de course 75 |
| Opératrice radio | Écoute les fréquences, repère les voix imitées | entend les éclaireurs imiter à 150 studs, voit leur direction | Aucune arme à feu possible |
| Pyrotechnicien | Fabrique une fusée ou un piège à bruit | 1 fusée par 2 piles + 1 ruban ; piège : boîte de conserve + corde | Torse 80 PV |

### 7.8 Communication

- Chat vocal de proximité si le joueur y a accès, sinon chat texte. La voix compte comme du bruit (rayon jusqu'à 80 studs selon le volume).
- Talkie-walkie : canal de groupe, portée 1 500 studs (toute la carte via le talkie du Meneur, section 8) ; il grésille dans les gorges et les tunnels, et son bip s'entend à 20 studs.
- Ping : touche ou bouton, place un repère visible 10 s par le groupe.

