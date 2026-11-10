2026-11-10 : décision de Gabriel. La coordinatrice (session Claude PISTE FROIDE) décide de l'ordre des tâches et rédige les prompts. Cette session est opérateur Studio exclusif et exécute les tickets.

# Décisions

## De Gabriel
- Titre : PISTE FROIDE. Carte 8000 × 8000 studs, compressée (distances non réelles).
- Gore explicite, label Restricted, option « gore réduit » locale. Mort définitive.
- Zone interdite = raccourci risqué, jamais obligatoire.
- Réalisme visé : Sons of the Forest. Créature à IA adaptative (METHODE.md).
- Monétisation : cosmétique seulement, en dernier.
- Jamais de publication, pas de questionnaire de maturité (c'est Gabriel).
- Panneaux : Wooden Sign de carlossamuelariza + texte en texture. Bigfoot : whitehair19 (secours : gorille dmlbaker).
- Priorité : carte jouable (terrain, rivières, routes, 26 lieux) → UI → monétisation.
- Une partie = un secteur à la fois, validé visuellement par Gabriel.

## Techniques
- Monde centré : X = x − 4000, Z = y − 4000 (voir `Shared/Carte`).
- Config/ et Shared/ dupliqués à l'identique dans Lobby et Partie.
- Terrain : une seule fonction de hauteur globale, à graine fixe, évaluée par secteur → raccords invisibles entre secteurs.
- Lieux 15 à 26 : coordonnées absentes de CARTE.md → positions déduites dans `secteurs/decoupage.md`, **à valider**.
- Partage de code entre jeux : proposition en cours (Git + Rojo + Wally), à valider.

## Crédits (08/11/2026)
- Les modèles Sketchfab utilisés sont sous licence CC BY : l'écran « Crédits » (affichant `assets/sketchfab/CREDITS.md`) est **obligatoire dans l'UI du jeu avant toute publication**.
- Règle 2 précisée (confirmé par Gabriel) : `insert_asset` autorisé uniquement pour les AssetId de `wiki/assets.md` / `assets/sketchfab/uploaded_assets.json` (uploads de Gabriel, compte 4566808450).

## Lieu 18 (08/11/2026)
- Barrière de la zone interdite : déplacée de S7 (position déduite incohérente) vers l'ENTRÉE de la zone interdite (S1), sur le sentier d'accès (décision Gabriel). Position à valider.
