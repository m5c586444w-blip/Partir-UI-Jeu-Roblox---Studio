## 8. Objets, armes, tablette et preuves

Le joueur a 4 emplacements rapides (3 pour la Mécanicienne) et un sac limité à 12 kg. Un objet lourd (plus de 5 kg) se porte à deux mains : pas de course, pas d'arme. Valeurs dans `Config/ItemConfig` et `Config/WeaponConfig`.

### 8.1 Objets

| ID | Objet | Poids (kg) | Pile | Effet | Bruit | Où |
| --- | --- | --- | --- | --- | --- | --- |
| ITM\_Flashlight | Lampe torche | 0,4 | 1 | Cône 45°, portée 120 studs, 8 min de pile ; clignote sous 15 % | clic 8 | Départ (tous sauf Descendante et Géologue), C09–C12 |
| ITM\_Headlamp | Lampe frontale | 0,2 | 1 | Portée 70, 10 min, mains libres | clic 8 | Descendante |
| ITM\_PowerLight | Lampe puissante | 0,8 | 1 | Portée 220, 6 min ; éblouit la créature 1 s si elle la fixe à moins de 20 studs | clic 8 | Géologue |
| ITM\_Battery | Pile | 0,1 | 6 | Recharge une lampe à 100 % (3 s) | — | Tiré sur les points C |
| ITM\_Bandage | Bandage | 0,1 | 5 | 4 s : arrête une hémorragie légère, +10 PV au membre | 10 | Départ (2 chacun), points C |
| ITM\_Splint | Attelle | 0,3 | 2 | 6 s : supprime la boiterie | 10 | C12, P17 |
| ITM\_Medkit | Trousse complète | 1,5 | 1 (5 usages) | 8 s : +40 PV ; arrête une hémorragie grave (Médecin seulement) | 10 | Médecin |
| ITM\_Flare | Fusée à main | 0,3 | 3 | 60 s de lumière rouge, rayon 60 ; peur −3/s ; la créature reste à plus de 40 studs sauf si elle est enragée | 300 à l'allumage | C10, Pyrotechnicien |
| ITM\_Matches | Allumettes | 0,05 | 1 | Avec 3 branches : feu de camp 180 s, visible à 800 studs, même effet qu'une fusée | 20 | P17, P10 |
| ITM\_Branch | Branche morte | 0,5 | 3 | Combustible ; lançable | casse : 45 | Sol de la forêt |
| ITM\_Stone | Pierre | 0,3 | 3 | Lançable : bruit de leurre à l'impact | 50 à l'impact | Partout au sol |
| ITM\_Rope | Corde | 1,0 | 1 | Descendre dans le puits P21 ; piège du Pyrotechnicien | — | C11, P15 |
| ITM\_Plank | Planche | 2,0 | 1 | Barricade (section 5, acte 2) | clouage : 120 | Cabane P05c (6 planches) |
| ITM\_BearSpray | Bombe anti-ours | 0,4 | 1 (3 usages) | Cône de 6 studs : la créature lâche sa prise et recule 4 s | 40 | P17, P01 (boîte à gants) |
| ITM\_ToolBox | Caisse à outils | 3,0 | 1 | Réparations à vitesse normale ; sans elle, ×2 plus long | ouverte : 30 | Mécanicienne |
| ITM\_Compass | Boussole | 0,1 | 1 | Affiche le nord | — | Géologue |
| ITM\_RadioScanner | Scanner radio | 0,6 | 1 | Capacité de l'Opératrice (section 7.7) | grésillement 15 | Opératrice |
| ITM\_Walkie | Talkie-walkie | 0,3 | 1 | Canal de groupe, portée 1 500 studs ; celui du Meneur couvre la carte et relaie les autres | bip 20 | Tous |
| ITM\_TinCan, ITM\_DuctTape | Boîte de conserve, ruban | 0,1 | 3 | Ingrédients du Pyrotechnicien | — | P09, P10 |
| ITM\_Notebook | Carnet Halvorsen | 0,2 | 1 | DOC\_12, pages débloquées par l'histoire | — | Descendante |
| ITM\_Keys | Clés du van | 0,1 | 1 | Extraction E1 | — | K1–K3 |
| ITM\_Jack | Cric | 4,0 | 1 | Extraction E1 | — | J1–J2 |
| ITM\_CoaxCable | Câble d'antenne | 1,0 | 1 | Extraction E2 | — | R1–R2 |
| ITM\_CarBattery | Batterie de voiture | 8,0 | 1 | Extraction E2 (deux mains) | posée : 30 | R3 |
| ITM\_Jerrycan | Jerrican | 6,0 | 1 | Extraction E3 (deux mains) | clapotis 15 | R4–R6 |
| ITM\_StarterRelay | Relais de démarreur | 0,5 | 1 | Extraction E3 | — | R7 |
| ITM\_PlasterKit | Kit de moulage | 1,2 | 1 (2 usages) | 30 s sur une empreinte fraîche : moulage, preuve B | 10 | Pisteur, P17 |
| ITM\_AudioRecorder | Enregistreur | 0,3 | 1 | Enregistre un cri à moins de 150 studs : preuve B | — | Opératrice, P23 |
| ITM\_SampleBag | Sachet à échantillon | 0,05 | 3 | Ramasser des poils : preuve B | — | P09 |
| ITM\_Camcorder | Caméscope vision nocturne | 0,9 | 1 | Filme ; vision nocturne ; 6 min d'enregistrement | bip 10 | Caméraman |
| ITM\_PhotoCamera | Appareil photo | 0,5 | 1 | 12 photos ; flash = lumière ×3 pendant 0,2 s | déclic 15 | P09, C03–C06 |
| ITM\_TabletField | Tablette de terrain | 0,7 | 1 | Voir 8.3 | — | Meneur |
| ITM\_TabletGeo | Tablette des géologues | 0,7 | 1 | DOC\_07 et DOC\_08 | — | P09, tente de Leah |

### 8.2 Armes

Les armes à feu dépendent de la taille du groupe : 1 à 3 joueurs = fusil ; 4 à 6 = fusil + revolver ; 7 à 10 = fusil + revolver + fusil à pompe. Le fusil revient d'office au Pisteur s'il est présent. L'Opératrice ne peut pas en porter.

| ID | Arme | Munitions | Cadence | Rechargement | Dégâts créature (corps / tête) | Tir allié (torse) | Bruit |
| --- | --- | --- | --- | --- | --- | --- | --- |
| WPN\_Rifle | Fusil à verrou | 5 | 1 tir / 1,4 s | 1,2 s par balle | 180 / 400 | 120 | Toute la carte |
| WPN\_Revolver | Revolver | 6 | 1 tir / 0,6 s | 0,8 s par balle | 70 / 160 | 60 | 2 500 |
| WPN\_Shotgun | Fusil à pompe | 4 | 1 tir / 1,0 s | 0,9 s par cartouche | 8 plombs × 18 jusqu'à 15 studs, puis −70 % à 40 studs | 15 par plomb | Toute la carte |
| WPN\_FlareGun | Pistolet lance-fusées (Pyrotechnicien) | 3 | — | 2 s | 20 + éblouissement 3 s, la créature fuit 8 s | 30 + brûlure | 1 200 |
| MEL\_Axe | Hache (Sportif) | — | 1 coup / 1,1 s | — | 25 ; un coup sur le bras qui saisit = lâcher | 30 | 40 |
| MEL\_Machete | Machette | — | 1 coup / 0,8 s | — | 18 ; deux coups = lâcher | 20 | 30 |

- Une seule boîte de munitions de secours (A1–A5) : 5 balles de fusil, 6 de revolver, 4 cartouches. Absente en Cauchemar.
- Recul, balancement de visée (aggravé par la peur et un bras blessé), rechargement manuel balle par balle, interruptible.
- Le serveur valide chaque tir (origine, direction, munitions, cadence).

### 8.3 Tablette de terrain

Une seule par groupe, au départ dans les mains du Meneur (sans Meneur : le premier joueur du groupe). Si elle tombe (mort), un autre peut la ramasser. Son écran éclaire : visibilité ×1,5 tant qu'elle est ouverte. Batterie : 30 minutes d'écran allumé pour la nuit.

| Appli | Contenu |
| --- | --- |
| Carte | Carte topographique du secteur (image de la section 3). Position GPS à ±30 studs, mise à jour toutes les 10 s ; sous forêt dense, 50 % de chances de « Pas de signal GPS ». 8 repères plaçables. Couche « tunnels » après lecture de DOC\_07 |
| Objectifs | Acte en cours, objectif, heure en jeu (en Cauchemar, seule source des objectifs) |
| Journal | Textes des documents lus (DOC\_xx), dans l'ordre de découverte |
| Preuves | Preuves du groupe, classe, qui les porte |
| Réseau | Toujours « Aucun réseau » ; une barre au sommet de P11 et à P23 : envoi d'un SMS au ranger Hollis, réponse automatique « Restez groupés. Personne ne monte avant l'aube. » |

La tablette des géologues (ITM\_TabletGeo) ne contient que DOC\_07 et DOC\_08. La lire copie la couche « tunnels » sur la tablette de terrain. Dans les tunnels, seul le Géologue voit sa position sur ce tracé.

### 8.4 Preuves

Inspiré des classes de fiabilité du BFRO (voir GDD). Une preuve est un objet d'inventaire ; elle ne compte que si un survivant la sort de la forêt.

| Classe | Preuve | Conditions | XP |
| --- | --- | --- | --- |
| A | Vidéo du Caméraman | Créature visible à 60 % au moins, à 30 studs ou moins, pendant 2 s sans interruption, vision nocturne ou lumière suffisante | 500 |
| B | Moulage d'empreinte | Empreinte de moins de 120 s, 30 s de travail | 150 |
| B | Enregistrement d'un cri | Cri à moins de 150 studs | 150 |
| B | Poils | Sur une structure de branches ou au bord d'Ape Canyon | 150 |
| B | Photo de la créature | Appareil photo, à 40 studs ou moins | 150 |
| C | Document (DOC\_03 à DOC\_10) | Ramassé | 50 |
| C | Photo du charnier P19 | Appareil photo | 50 |

La carte mémoire du caméscope (ITM\_SDCard) est créée automatiquement après une vidéo de classe A ; elle peut être confiée à un autre joueur.

