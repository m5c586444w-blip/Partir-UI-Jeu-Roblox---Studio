# Découpage proposé (À VALIDER par Gabriel)
Coordonnées carte (x vers l'est, y vers le sud), origine nord-ouest. Les lieux 15–26 n'ont pas de coordonnées dans CARTE.md : positions **déduites**, marquées (~).

| Secteur | Zone (x, y) | Lieux | Départ / Bigfoot |
| --- | --- | --- | --- |
| **S7 Sud-est** | 5 500–8 000, 5 500–8 000 | 1 parking (6800,7200), 3 Lava Canyon (7200,6200), 16 pont (~7200,6000), 22 épave (~6600,7000), 18 barrière (~6200,5600), route 83, bas du lahar | Départ S1 |
| **S6 Sud-ouest** | 0–3 500, 6 500–8 000 + piste | 10 chantier (2600,7300), piste forestière | Départ S2 |
| **S5 Ouest** | 0–3 000, 3 500–6 500 | 7 Ape Cave (1500,6400), 21 tunnel effondré (~1200,5800), 12 prairie (1800,4200), 13 cascade (2200,5200), 26 tour ouest (~1500,4000) | B2 |
| **S4 Centre** | 3 000–5 500, 3 500–6 500 | 9 camp géologues (3200,4600), 4 forêt ancienne (4500–6000), 17 poste rangers (~4200,5500), 11 tour de guet (4000,2400 : voir S2) | Départ S3, B4, B6 |
| **S3 Nord-est** | 5 500–8 000, 1 500–5 500 | 5 Ape Canyon (6600,2600), 2 lahar (5800–6400), 15 mine (~7200,4000), 24 tour est (~7300,5000) | B1, B5 |
| **S2 Plateau** | 3 000–5 500, 0–3 500 | 6 plateau de cendres (5200,1400), 11 tour (4000,2400), 23 station météo (~4500,1800), volcan 14 (décor) | — |
| **S1 Zone interdite** | 0–3 500, 0–3 500 | 8 zone soufflée, 19 charnier (~1800,1800), 20 lac (~1500,2200), 25 tour nord (~2500,3300) | B3 |

Lahar (2) traverse S3/S4/S7 : une seule coulée, construite dans S3 puis prolongée par S7.
Rivières : ruisseau principal (plateau → cascade 13), ruisseau de Lava Canyon, affluent du lac — découpés par secteur sur la même courbe.

## Ordre proposé
1. **S7 Sud-est** (petit, a un départ, route 83, Lava Canyon : teste toute la chaîne terrain → rivière → route → lieux)
2. S4 Centre, 3. S3, 4. S5, 5. S6, 6. S2, 7. S1.
Terrain : fonction de hauteur globale à graine fixe, évaluée secteur par secteur.

## Découpage FINAL (mis à jour le 08/11/2026 : couverture complète de la carte, X = x − 4000, Z = y − 4000)
| Secteur | Boîte monde | État |
| --- | --- | --- |
| S7 Sud-est | X 1400..4000, Z 1400..4000 | construit, retouché |
| S4 Centre | X −1100..1400, Z −600..2500 | construit |
| S3 Nord-est | X 1400..4000, Z −2500..1700 | construit |
| S5 Ouest | X −4000..−1000, Z −500..2500 | en cours (agent repris) |
| S6 Sud (ouest + centre) | X −4000..1500, Z 2500..4000 | en cours (étendu : x 0–5500 pour couvrir le vide entre S5 et S7) |
| S2 Plateau | X −1000..1500, Z −4000..−500 | en cours |
| S1 Zone interdite | X −4000..−1000, Z −4000..−500 | en cours |
| S8 Coin nord-est | X 1500..4000, Z −4000..−2500 | en cours (aucun lieu numéroté) |
Corrections : tour 25 = bord NORD de la zone interdite (≈ (−2200, −3500), à valider ; l'ancienne position (−1500,−700) était fausse). Lieu 18 (barrière de la zone interdite) : placé en S7 par déduction (≈ (2200,1600)), incohérent avec la zone interdite au nord-ouest : à arbitrer par Gabriel.
