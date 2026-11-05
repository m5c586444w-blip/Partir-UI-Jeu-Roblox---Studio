## 11. Gore, morts et règles Roblox

Le gore explicite validé impose le label **Restricted**, désormais réservé aux joueurs de **18 ans et plus** dont l'âge est vérifié ; le créateur doit lui aussi avoir 18 ans pour publier une nouvelle expérience Restricted ([DevForum Roblox, mise à jour du 6 novembre 2025](https://devforum.roblox.com/t/updating-age-requirements-for-experiences-with-%E2%80%98restricted%E2%80%99-content-maturity-label/3905863)). Le GDD disait 17+ : c'est dépassé.

**Conséquence à trancher par Gabriel (section 19) :** s'il n'a pas 18 ans vérifiés, il ne peut pas publier la version Restricted. Et un proche de moins de 18 ans ne pourra pas y jouer.

### 11.1 Ce que Roblox autorise

Source : [doc Content Maturity](https://create.roblox.com/docs/production/promotion/content-maturity).

| Label | Violence | Sang |
| --- | --- | --- |
| Moderate | Violence ou mort réalistes mais non graphiques | Sang réaliste léger (éclaboussures vues de loin) |
| Restricted (18+ vérifiés) | Violence graphique, par ex. démembrement, mutilation | Sang abondant : flaques, jets, éclaboussures de près |
| **Jamais autorisé** | Violence extrême, maltraitance ou torture d'animaux, gore extrême réaliste, torture | — |

Le questionnaire de maturité doit être rempli **avant** d'ajouter du contenu Restricted (même source). C'est Gabriel qui le remplit, jamais Claude Code.

### 11.2 Deux profils dans le même code

`Config/GoreConfig.Profile` vaut `"Restricted"` ou `"Moderate"`. Le même jeu peut ainsi être publié en deux expériences distinctes, une par label.

| Élément | Restricted | Moderate |
| --- | --- | --- |
| Membres détachables (bras, jambes) | Oui : un coup de plus de 50 sur un membre à moins de 10 % de PV | Non |
| Mise à mort ATK\_Execution | Oui, avec noir à l'instant de la mort | Non : l'Alpha traîne le joueur hors de vue |
| Flaques de sang | Oui, 600 s, 40 au plus sur la carte | Petites taches au sol, 120 s |
| Plaies sur le personnage | Decals de plaies | Taches sombres sur les vêtements |
| Corps des géologues | Membres manquants, sang séché | Corps couverts (bâche, pierres) |
| Traînées de sang | Oui | Oui, discrètes |

### 11.3 Limites fixes (les deux profils)

- Pas d'organes ni d'entrailles visibles, pas de gros plan sur une blessure, pas de ralenti sur une mort.
- Pas de torture : la créature tue ou emporte, elle ne fait jamais durer.
- Aucun animal tué ou blessé à l'écran : les wapitis de P19 sont des restes anciens, comme dans un documentaire.
- Aucune victime réelle de 1980 montrée ou nommée.
- Aucune image réelle (photo de vrai cadavre, vraie scène de crime) utilisée comme texture.

### 11.4 Option « Gore réduit »

Réglage local par joueur, désactivé par défaut (dans le profil Restricted) : il applique localement l'affichage du profil Moderate. Il ne change pas le label de l'expérience.

### 11.5 Implémentation

- Chaque personnage a 6 maillages ; un membre détaché devient une pièce libre, avec un capuchon (`Gore_Stump_<Membre>`) qui masque la coupe sans détail anatomique.
- Sang : `ParticleEmitter` court (0,3 s) + decal de flaque posé par rayon vers le sol.
- Ragdoll : `BallSocketConstraint` sur les articulations à la mort ; le corps passe ancré après 10 s immobile, pour économiser la physique.

