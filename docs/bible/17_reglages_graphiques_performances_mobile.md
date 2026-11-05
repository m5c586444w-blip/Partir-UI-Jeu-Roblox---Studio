## 17. Réglages graphiques, performances, mobile

Le jeu vise 60 images/s sur un PC moyen et 30 images/s sur un téléphone milieu de gamme, avec 10 joueurs. Une fonctionnalité trop lourde est désactivée par le réglage, jamais supprimée.

### 17.1 Budgets

| Poste | PC | Mobile |
| --- | --- | --- |
| Images par seconde | 60 | 30 |
| `StreamingEnabled` | Oui | Oui |
| Rayon de streaming visé | 1 024 studs | 512 studs |
| Lampes avec ombres actives | 6 | 2 |
| Arbres animés par os | à moins de 120 studs | aucun |
| Débris physiques non ancrés | 60, disparition après 30 s | 20, après 15 s |
| Flaques de sang | 40 | 15 |
| Mémoire client (à mesurer dans la console développeur) | ≤ 1,5 Go | ≤ 800 Mo |

Le rayon de streaming est fixé par le serveur pour tous : la « distance d'affichage » du menu ne règle donc que le décor côté client (petite végétation taguée `Clutter`, effets).

Les lieux qui contiennent des scripts ou des objectifs (P05c, P09, P11, les véhicules) sont réglés pour rester chargés (`ModelStreamingMode` persistant), afin qu'un objectif ne disparaisse jamais.

### 17.2 Menu Réglages (façon Sons of the Forest)

| Onglet | Réglage | Valeurs | Défaut PC / mobile |
| --- | --- | --- | --- |
| Graphismes | Préréglage | Bas, Moyen, Élevé, Ultra | Élevé / Bas |
| Graphismes | Luminosité (gamma) | −0,5 à +0,5 ajouté à `ExposureCompensation`, avec écran de calibrage « le symbole doit être à peine visible » | 0 |
| Graphismes | Distance d'affichage du décor | 25 %, 50 %, 75 %, 100 % | 100 % / 50 % |
| Graphismes | Densité de végétation | 25 %, 50 %, 75 %, 100 % | 100 % / 50 % |
| Graphismes | Vent dans les arbres | Oui / Non | Oui / Non |
| Graphismes | Ombres des lampes | Oui / Non | Oui / Non |
| Graphismes | Profondeur de champ, flou lumineux | Oui / Non | Oui / Non |
| Graphismes | Densité des particules (pluie, neige, cendre) | Faible, Normale | Normale / Faible |
| Graphismes | Champ de vision | 60 à 90 | 70 |
| Contrôles | Sensibilité, inverser l'axe vertical | — | 1,0 / non |
| Contrôles | Taille des boutons tactiles | 80 % à 130 % | — / 100 % |
| Audio | Général, ambiance, voix, musique, effets | 0 à 100 | 80 |
| Accessibilité | Sous-titres, taille | Oui / Non ; 3 tailles | Oui ; moyenne |
| Accessibilité | Réduire les mouvements (balancement de caméra) | Oui / Non | Non |
| Accessibilité | Gore réduit (11.4) | Oui / Non | Non |
| Accessibilité | Langue | Français, anglais | Langue du compte |

Les réglages sont sauvegardés dans `settings` (16.4).

### 17.3 Ce que change chaque préréglage

| Élément | Bas | Moyen | Élevé | Ultra |
| --- | --- | --- | --- | --- |
| Petite végétation (`Clutter`) | 40 % | 70 % | 100 % | 100 % |
| Ombres des lampes | Lampe du joueur seulement | 2 | 6 | 6 |
| Arbres animés | Non | Non | 120 studs | 200 studs |
| Profondeur de champ, bloom | Non | Bloom | Oui | Oui |
| Particules | Faible | Normale | Normale | Normale |
| Flaques de sang | 15 | 25 | 40 | 40 |

### 17.4 Mobile

- `MobileControlsGui` (15.4) remplace les touches ; le joystick de déplacement est celui de Roblox.
- Vibration à chaque blessure et pendant une saisie (si l'appareil le permet).
- Interfaces lisibles sur un écran de 6 pouces : texte à 14 au minimum (15.2).
- Test obligatoire à chaque jalon : émulateur d'appareils de Studio, puis un vrai téléphone avant la publication.

