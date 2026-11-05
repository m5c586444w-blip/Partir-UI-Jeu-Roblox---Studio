## 5. Déroulé d'une partie

Une partie dure 35 à 52 minutes réelles, du crépuscule à l'aube du **28 octobre**, en cinq actes. Avec le lobby, une session complète reste sous 1 h 30. Les objectifs font avancer les actes ; chaque acte a une durée maximale pour qu'un groupe ne stagne pas.

### 5.1 Horloge

L'heure affichée dépend de l'acte, pas d'un chronomètre fixe. Dans un acte, elle avance linéairement de l'heure de début à l'heure de fin sur la durée maximale de l'acte. Au changement d'acte, elle saute à l'heure de début suivante en 10 s (ciel accéléré).

| Acte | Heure en jeu | Durée min → max (réelle) | Passage à l'acte suivant |
| --- | --- | --- | --- |
| 0. Arrivée | 18 h 30 → 19 h 00 | 3 min fixes | Automatique |
| 1. L'enquête | 19 h 00 → 22 h 00 | 10 → 15 min | Tablette des géologues lue ET 3 indices trouvés, ou durée max |
| 2. Le siège | 22 h 00 → 00 h 00 | 8 → 14 min (trajet jusqu'à la cabine compris) | Fin du bombardement (6 min après le début du siège) |
| 3. La chasse | 00 h 00 → 05 h 00 | 10 → 15 min | Conditions d'extraction réunies, ou durée max |
| 4. L'aube | 05 h 00 → 06 h 00 | 3 → 5 min | Extraction, ou 06 h 00 |

À 06 h 00 (au plus tard 55 min réelles après le début), la partie s'arrête. Les joueurs encore dans la forêt sont **disparus**.

### 5.2 Les actes en détail

**Acte 0, l'arrivée.** Cinématique CS\_02 selon le départ tiré. La faune est bruyante (oiseaux, écureuils). Le Meneur reçoit la tablette de terrain. Objectif affiché : « Trouver le camp des géologues ». La créature ne se montre pas ; elle a déjà repéré le van.

**Acte 1, l'enquête.**

1. Atteindre P09 (déjà fait si départ S3) : cinématique CS\_04 à la première entrée.
2. Trouver la tablette des géologues dans la tente de Leah Brandt : elle contient DOC\_07 (carte des tunnels) et DOC\_08 (vidéo, cinématique CS\_05).
3. Trouver 3 des 6 indices tirés.
4. La tablette indique le point de repli prévu par l'équipe : la cabane de 1924 (P05c). Nouvel objectif : « Rejoindre la cabane avant minuit ».

Créature : observation, coups sur les troncs au loin, structures de branches, silence de la faune. Au moins un aperçu lointain garanti par le directeur.

**Acte 2, le siège.** La météo se dégrade (pluie ou neige selon le tirage). Le siège commence 60 s après l'entrée du premier joueur dans la cabane, ou à 23 h 05 si personne n'y est.

1. Barricader 3 ouvertures : porte, fenêtre, trou du toit (planches trouvées dans la cabane ; 8 s par planche, 4 s pour le Sportif).
2. Tenir 6 minutes de bombardement. Les pierres frappent le toit et les murs ; une planche reçoit 4 impacts avant de céder.
3. Une barricade cédée = tentative d'entrée (bras qui passe, saisie possible).
4. Fin : silence total 20 s, puis cinématique CS\_07. La page 2 du carnet Halvorsen se débloque. Le jeu annonce la voie d'extraction de la partie.

Un joueur resté dehors pendant le siège est la cible prioritaire.

**Acte 3, la chasse.** Une voie principale est tirée parmi E1, E2, E3. La voie secrète E4 est toujours ouverte si DOC\_07 a été lue.

| Voie | Ce qu'il faut | Où | Danger |
| --- | --- | --- | --- |
| E1 Van | Clés (K1–K3) + cric (J1–J2) ; changer la roue lacérée (20 s, 10 s pour la Mécanicienne) | P01 | Démarrage bruyant : attaque quasi certaine |
| E2 Hélicoptère | Câble d'antenne (R1–R2) + batterie (R3, lourde : course impossible) ; réparer la radio de P11 (30 s) ; appel ; tenir 180 s sur l'aire | P11 | Aire à découvert sur la crête |
| E3 Bulldozer | Jerrican (R4–R6) + relais (R7) ; réparer (40 s) ; conduire 650 studs jusqu'à la barrière | P10 | Lent (8 studs/s), la créature peut y grimper |
| E4 Tunnels | DOC\_07 + une lampe ; traverser le réseau P07a → P07b → P07c ; dégager le bouchon (60 s) | P07 | Femelle, obscurité totale |

**Acte 4, l'aube.** À 05 h 00, la créature lance le dernier assaut, le plus violent. Les joueurs doivent atteindre le point d'extraction et le déclencher. À l'aube, la créature se retire vers les tunnels (animal nocturne) : aucune attaque après 05 h 50, sauf dans les tunnels.

### 5.3 Fins

| Fin | Condition | Cinématique | Récompense |
| --- | --- | --- | --- |
| Survie | ≥ 1 joueur extrait par E1, E2 ou E3 | CS\_10, CS\_11 ou CS\_12 | XP selon les survivants |
| Preuve | Survie + une preuve de classe A sortie | idem + CS\_15 | XP majorée, entrée au musée |
| La vérité | ≥ 1 joueur extrait par E4 | CS\_13 | Page 3 du carnet, panneau final du musée |
| Ordonnance 69-01 | L'Alpha est tué (quel que soit le reste) | CS\_14 | Fin amère ; débloque la variante « La nuit suivante » (version 2) |
| Silence | Aucun survivant | CS\_16 | Le podcast est publié… incomplet |

Plusieurs fins peuvent se cumuler (ex. La vérité + Preuve). Ordonnance 69-01 remplace Survie.

### 5.4 Difficultés

| Réglage | Normal | Difficile | Cauchemar |
| --- | --- | --- | --- |
| Dégâts de la créature | ×1,0 | ×1,3 | ×1,6 |
| Portées de perception | ×1,0 | ×1,15 | ×1,3 |
| Points de vie de la créature | ×1,0 | ×1,25 | ×1,5 |
| Tir allié | Non | Oui | Oui |
| Temps à terre avant la mort | 45 s | 35 s | 25 s |
| Boîte de munitions de secours | Oui | Oui | Non |
| Indications d'objectif à l'écran | Oui | Oui | Non (tablette seulement) |
| Déblocage | Dès le début | Dès le début | Après une première survie |

**Sans vote :** difficulté Normal, météo aléatoire. **Égalité :** la difficulté la plus basse l'emporte ; pour la météo, aléatoire.

### 5.5 Taille du groupe

| Joueurs | Créatures en surface | Armes à feu | Événements du directeur |
| --- | --- | --- | --- |
| 1 à 3 | Alpha | 1 | ×0,8 |
| 4 à 6 | Alpha + 1 éclaireur | 2 | ×1,0 |
| 7 à 10 | Alpha + 2 éclaireurs | 3 | ×1,2 |

La femelle n'existe que dans les tunnels, quelle que soit la taille du groupe.

