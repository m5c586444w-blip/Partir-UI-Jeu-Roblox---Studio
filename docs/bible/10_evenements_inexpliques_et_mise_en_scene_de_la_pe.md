## 10. Événements inexpliqués et mise en scène de la peur

Le jeu fait peur par ce qu'on entend et ce qu'on devine, pas par des sursauts. Chaque événement ci-dessous a une explication naturelle possible, que le jeu ne tranche jamais. Le directeur (9.12) les tire dans le catalogue « bas » quand la tension retombe.

### 10.1 Règles de mise en scène

1. **Le son avant l'image.** Une menace s'entend toujours avant de se voir.
2. **Rien n'apparaît sous les yeux.** Un objet ou un décor modifié n'apparaît que hors du champ de vision de tous les joueurs, ou à plus de 80 studs.
3. **La fausse sécurité.** Après une pause imposée, la première menace arrive là où le groupe se croit à l'abri (camp, cabane, van).
4. **Pas de musique de sursaut.** Une seule exception par partie : le premier vrai contact de l'acte 2.
5. **Cadence :** 1 événement au plus toutes les 45 s par joueur ; le même événement jamais deux fois en 10 min.

### 10.2 Catalogue

| ID | Événement | Explication possible | Actes | Son / asset |
| --- | --- | --- | --- | --- |
| EVT\_01 | La faune se tait d'un coup autour du joueur | Un prédateur passe, n'importe lequel | 0–4 | Coupure des AMB\_Birds et AMB\_Insects sur 60 studs |
| EVT\_02 | Trois coups sur un tronc au loin, puis trois de l'autre côté | Branches qui cognent au vent | 1–3 | SFX\_WoodKnock\_01–06 |
| EVT\_03 | Structure de branches entrelacées sur un sentier déjà pris | Chablis, randonneurs | 1–3 | Prop\_StickStructure\_A–C |
| EVT\_04 | Tas de pierres au pied d'un arbre, plus haut qu'au passage précédent | Quelqu'un d'autre est passé | 1–3 | Prop\_StonePile\_A–C (+1 niveau) |
| EVT\_05 | Empreintes fraîches autour du van ou des tentes | Un ours ? Une farce ? (les rangers de 1924 disaient qu'on peut les truquer) | 1–3 | Decal\_Footprint\_Big |
| EVT\_06 | Bâtons enfoncés dans la toile d'une tente | Débris de tempête | 1 | Prop\_TentSticks |
| EVT\_07 | Sifflement humain dans le noir | Un oiseau, peut-être | 1–4 | SFX\_Whistle\_01–03 |
| EVT\_08 | Un « Hey ! » avec la voix d'un coéquipier, qui jure ne rien avoir dit | Écho, fatigue | 2–4 | Imitation (9.8) |
| EVT\_09 | Lampe abandonnée, allumée, sur le sentier, tournée vers la forêt | Celle de Ben Castillo | 1 | Prop\_DroppedFlashlight |
| EVT\_10 | La porte du poste des rangers est ouverte, alors qu'elle était fermée | Le vent | 1–3 | SFX\_DoorCreak\_02 |
| EVT\_11 | Une pierre tombe sur le toit du van | Chute naturelle | 0–1 | SFX\_StoneOnMetal\_01 |
| EVT\_12 | Odeur forte (vignettage vert très léger, réplique « Vous sentez ça ? ») | Une carcasse. Les récits locaux parlent aussi d'une puanteur ([Wenatchee World](https://www.wenatcheeworld.com/news/local/colville-stick-indian-legend-sasquatch-is-getting-his-own-roadside-monument/article_36cee63c-0a7c-540b-8aca-a23eafade59a.html)) | 1–4 | VO\_\<ROLE>\_Smell |
| EVT\_13 | Deux yeux reflètent la lampe à 60 studs, puis disparaissent | Un cerf ou un wapiti | 1–3 | FX\_EyeShine |
| EVT\_14 | Respiration lente sur le canal radio | Interférence | 2–4 | SFX\_RadioBreath\_01 |
| EVT\_15 | Le corps de Leah Brandt a bougé entre deux passages | On s'est trompé d'endroit | 1–3 | Zone B6 |
| EVT\_16 | Arbre cassé net à 3 m de haut, cassure fraîche | Coup de vent | 1–4 | Prop\_SnappedTree\_A |
| EVT\_17 | Des pas qui s'arrêtent une demi-seconde après ceux du joueur | L'écho de ses propres pas | 1–3 | SFX\_Steps\_Heavy\_Delay |
| EVT\_18 | Un cri long au loin, auquel un autre répond à l'opposé | Coyotes, wapitis en rut | 1–4 | SFX\_Call\_Long\_01–04 |
| EVT\_19 | Les objets d'un sac posé sont alignés à côté | Personne ne s'en souvient | 2–4 | Script, aucun asset |
| EVT\_20 | Un caillou tombe dans l'eau à côté du joueur | Berge qui s'effrite | 1–4 | SFX\_Splash\_Small |
| EVT\_21 | La tablette affiche une barre de réseau, puis plus rien | Réseau instable | 1–3 | UI de la tablette |
| EVT\_22 | Une silhouette debout sur les troncs flottants du lac | Un tronc dressé | 1–3 | Pose fixe de la créature, 4 s |

### 10.3 Ce que le joueur ne doit jamais avoir

- Une jauge de « danger » ou une flèche vers la créature.
- Un son de créature sans source réelle (chaque son a une position).
- Une mort sans signal sonore avant (9.10).

