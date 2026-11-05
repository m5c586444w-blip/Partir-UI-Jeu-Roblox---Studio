## 6. Cinématiques

Le jeu compte 17 cinématiques, toutes faites dans le moteur (caméra scriptable, pas de vidéo). En partie, elles durent 12 s au plus et ne coupent jamais une poursuite.

### 6.1 Règles communes

- **Technique :** `Camera.CameraType = Scriptable`, plans définis par des `Part` invisibles nommés `CS_xx_Shot_n` dans `Workspace/Cinematics` (Gabriel peut les déplacer à la main), transitions par `TweenService`. Bandes noires 2.35:1 (`CinematicGui`, section 15).
- **Qui la voit :** une cinématique de lieu ne joue que pour les joueurs dans son rayon ; les autres entendent un message radio. Les cinématiques de fin jouent pour tous.
- **Sécurité :** pendant une cinématique, le personnage est invulnérable et retiré des cibles de la créature, plus 3 s après.
- **Passer :** en lobby, bouton « Passer » après 10 s. En partie, vote à la majorité des joueurs concernés.
- **Sous-titres :** toujours affichés, texte ci-dessous.

### 6.2 Liste

| ID | Déclencheur | Durée | Plans (caméra → cible, focale) | Son et texte |
| --- | --- | --- | --- | --- |
| CS\_00 | 1re connexion au lobby | 70 s | 1. Nuit, cabane de 1924 en diorama, travelling lent (FOV 50). 2. Pierres qui frappent le toit, plan serré. 3. Deux rangers au bord d'une gorge, lumière de jour. 4. Machine à écrire qui tape « Ordinance 69-01 ». 5. Panache de 1980 au loin (particules), son étouffé. 6. Avis de recherche DOC\_01 punaisé, zoom. 7. Le van au parking du lobby, les phares s'allument. | Voix off : « 1924. Cinq hommes, une cabane, une nuit de pierres. Les rangers n'ont rien trouvé. En 1969, le comté a quand même voté une loi pour le protéger. En 1980, la montagne a explosé. Et il y a trois semaines, quatre géologues ont cessé de répondre. Cette nuit, on y va. » |
| CS\_01 | Compte à rebours fini | 8 s | 1. Intérieur du van, plan sur les joueurs assis. 2. Extérieur, le van passe la barrière fermée de la route 83, fondu au noir. | Moteur, pluie fine. Texte : « Route forestière 83 — fermée » |
| CS\_02a/b/c | Début de partie (S1, S2 ou S3) | 10 s | a : le van s'arrête au parking, plan large sur la forêt. b : bulldozer rouillé, arbres coupés. c : tentes déchirées, lampe qui pend. | Radio du Meneur : « OK. On trouve le camp, on filme, on rentre. » |
| CS\_03 | 1er aperçu de la créature (directeur) | 4 s | Pas de coupe : la caméra du joueur est légèrement attirée vers une silhouette à 90–120 studs, qui se dérobe. | Silence de la faune 3 s avant. Aucun texte |
| CS\_04 | 1re entrée dans P09 | 9 s | 1. Plan subjectif lent sur le camp ravagé. 2. Corps de Leah Brandt partiellement recouvert de pierres, plan large (pas de gros plan). | Mouches, vent. Sous-titre du joueur le plus proche : « … Oh non. » |
| CS\_05 | Vidéo de la tablette (DOC\_08) | 25 s | Images de caméra à l'épaule, grain, horodatage J-17 02:14. 1. Intérieur de tente, lampe. 2. Bruit de pierres sur la toile. 3. Whitcombe : « Éteins ça. Éteins ça ! » 4. Extérieur : deux reflets d'yeux dans le faisceau, loin. 5. Une masse sombre masque l'objectif. 6. Écran : « Point de repli de l'équipe : cabane des mineurs » | Pas de musique. Coupure nette |
| CS\_06 | Début du siège | 6 s | 1. De l'intérieur de la cabane, plan sur la porte. 2. Premier impact sur le toit, poussière qui tombe. | Coup sourd, puis 3 coups sur un tronc au loin |
| CS\_07 | Fin du siège | 10 s | 1. Silence, plan sur les planches fendues. 2. Extérieur, nuit froide : sur le bord du canyon, une silhouette debout regarde la cabane, puis recule hors de vue ; des pierres partout. | Texte de la voie d'extraction tirée (ex. « La radio de la tour. C'est notre seule chance. ») |
| CS\_08 | Début de l'acte 3 | 5 s | Plan large en hauteur sur la forêt, une lampe de joueur au loin, quelque chose bouge entre les arbres. | Cri long à distance (SFX\_Call\_Long\_02) |
| CS\_09 | 05 h 00 | 6 s | Lever du jour bleu sur le volcan, plan fixe. | Oiseaux qui reprennent, puis se taisent d'un coup |
| CS\_10 | Extraction E1 | 12 s | 1. Le van démarre. 2. Rétroviseur : une silhouette sur la route derrière. 3. Fondu au blanc. | Moteur, souffle des joueurs |
| CS\_11 | Extraction E2 | 12 s | 1. L'hélicoptère monte. 2. Vue plongeante : sur la crête, plusieurs silhouettes regardent l'appareil. | Rotor, puis silence |
| CS\_12 | Extraction E3 | 12 s | 1. Le bulldozer enfonce la barrière. 2. Plan arrière : des pierres empilées au milieu de la piste. | Métal, moteur |
| CS\_13 | Extraction E4 | 12 s | 1. Sortie du tube dans la lumière de l'aube. 2. Derrière, dans le noir, la femelle porte les os du juvénile et ne les suit pas. | Page 3 du carnet lue en voix off |
| CS\_14 | Alpha tué | 12 s | 1. Le corps de l'Alpha, plan large, sans gros plan. 2. Titre de journal fictif : « Étudiants inculpés : première application de l'ordonnance 69-01 ». 3. Nuit, la ville du lobby, des pierres tombent sur un toit. | Sirène lointaine |
| CS\_15 | Preuve de classe A sortie | 6 s | La vidéo du Caméraman rejouée sur un écran de montage, compteur de vues qui monte. | Notification de téléphone |
| CS\_16 | Aucun survivant | 10 s | 1. Le van vide au parking, portière ouverte. 2. Écran du podcast : « Épisode 12 — Cold Trail — durée 00:47 », la barre de lecture s'arrête. | Le dernier son enregistré par un joueur, puis rien |

### 6.3 Caméras de mort (sans coupe)

Quand un joueur meurt, sa caméra reste 4 s sur place, légèrement au-dessus du corps, inclinée de 10°, puis passe en spectateur (section 7). Aucun gros plan sur une blessure.

