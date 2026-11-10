-- ReplicatedStorage/Credits
-- Section 0, règle 4 : chaque asset importé est inscrit ici (nom, auteur, URL, licence).
-- Généré par tools/terrain/download_polyhaven.py ; compléter à chaque import (phase B).
return {
	-- Les 8 textures d'origine (phase A7) ne sont plus appliquées dans Studio : la place Partie a été vidée
	-- le 08/11 avec « 8 matériaux PF_ » (studio-export/wiki/hot.md, ligne 2), puis chaque matériau de base
	-- a reçu une texture Poly Haven (hot.md, ligne 31). Entrées conservées (ticket C2, 2026-11-10).
	-- Plus appliquée dans Studio : override remplacé (LeafyGrass = forest_floor, hot.md ligne 31).
	{
		name = "Forest Ground 03",
		author = "Rob Tuytel",
		url = "https://polyhaven.com/a/forrest_ground_03",
		license = "CC0",
		usage = "Texture de terrain : LeafyGrass (sol de forêt : aiguilles et feuilles)",
	},
	-- Plus appliquée dans Studio : override remplacé (Grass = forrest_ground_01, hot.md ligne 31).
	{
		name = "Leafy Grass",
		author = "Charlotte Baglioni",
		url = "https://polyhaven.com/a/leafy_grass",
		license = "CC0",
		usage = "Texture de terrain : Grass (prairie)",
	},
	-- Plus appliquée dans Studio : override remplacé (Ground = forest_ground_04, hot.md ligne 31).
	{
		name = "Brown Mud Dry",
		author = "Rob Tuytel",
		url = "https://polyhaven.com/a/brown_mud_dry",
		license = "CC0",
		usage = "Texture de terrain : Ground (terre)",
	},
	-- Plus appliquée dans Studio : override remplacé (Mud = brown_mud_03, hot.md ligne 31).
	{
		name = "Mud Forest",
		author = "eye-candy.xyz",
		url = "https://polyhaven.com/a/mud_forest",
		license = "CC0",
		usage = "Texture de terrain : Mud",
	},
	-- Plus appliquée dans Studio : variante PF_MuddyTracks supprimée (hot.md ligne 2) ; jamais en override.
	{
		name = "Muddy Tracks",
		author = "Amal Kumar",
		url = "https://polyhaven.com/a/muddy_tracks",
		license = "CC0",
		usage = "Texture de terrain : Mud (pistes)",
	},
	-- Plus appliquée dans Studio : override remplacé (Rock = rock_wall_02, hot.md ligne 31).
	{
		name = "Rock Pitted Mossy",
		author = "Dimitrios Savva, Rico Cilliers",
		url = "https://polyhaven.com/a/rock_pitted_mossy",
		license = "CC0",
		usage = "Texture de terrain : Rock",
	},
	-- Plus appliquée dans Studio : override remplacé (Basalt = dry_riverbed_rock, hot.md ligne 31).
	{
		name = "Dark Rock",
		author = "Amal Kumar",
		url = "https://polyhaven.com/a/dark_rock",
		license = "CC0",
		usage = "Texture de terrain : Basalt (sombre)",
	},
	-- Plus appliquée dans Studio : override remplacé (Sand = gravel_ground_01, hot.md ligne 31).
	{
		name = "Burned Ground 01 (recoloré gris)",
		author = "Rob Tuytel",
		url = "https://polyhaven.com/a/burned_ground_01",
		license = "CC0",
		usage = "Texture de terrain : Sand (cendre)",
	},
	-- Textures Poly Haven appliquées dans Studio le 08/11 (ticket C2, 2026-11-10). Preuve : studio-export/wiki/hot.md,
	-- ligne 31 (« overrides par matériau de base »). polyhaven.com est inaccessible depuis la session cloud :
	-- titre et auteur à relever sur la fiche, sauf mention contraire. Rangement : MaterialService/PolyHaven.
	-- forrest_ground_01 : titre et auteur relevés dans Credits.luau du commit cb37b12 (écrits par l'API Poly Haven).
	{
		name = "Forest Ground 01",
		author = "Rob Tuytel",
		url = "https://polyhaven.com/a/forrest_ground_01",
		license = "CC0",
		usage = "Texture de terrain (Studio, override) : Grass",
	},
	-- forest_floor : titre et auteur relevés dans Credits.luau du commit cb37b12 (écrits par l'API Poly Haven).
	{
		name = "Forest Floor",
		author = "eye-candy.xyz",
		url = "https://polyhaven.com/a/forest_floor",
		license = "CC0",
		usage = "Texture de terrain (Studio, override) : LeafyGrass",
	},
	-- forest_ground_04 : identifiant recopié de hot.md ; la fiche peut s'écrire « forrest_ground_04 » (non confirmé).
	{
		name = "forest_ground_04",
		author = "non confirmé (à relever sur la fiche)",
		url = "https://polyhaven.com/a/forest_ground_04",
		license = "CC0",
		usage = "Texture de terrain (Studio, override) : Ground",
	},
	-- brown_mud_03 : titre et auteur relevés dans Credits.luau du commit cb37b12 (écrits par l'API Poly Haven).
	{
		name = "Brown Mud 03",
		author = "Rob Tuytel",
		url = "https://polyhaven.com/a/brown_mud_03",
		license = "CC0",
		usage = "Texture de terrain (Studio, override) : Mud",
	},
	{
		name = "river_small_rocks",
		author = "non confirmé (à relever sur la fiche)",
		url = "https://polyhaven.com/a/river_small_rocks",
		license = "CC0",
		usage = "Texture de terrain (Studio, override) : Slate (lahar)",
	},
	{
		name = "rock_wall_02",
		author = "non confirmé (à relever sur la fiche)",
		url = "https://polyhaven.com/a/rock_wall_02",
		license = "CC0",
		usage = "Texture de terrain (Studio, override) : Rock",
	},
	{
		name = "dry_riverbed_rock",
		author = "non confirmé (à relever sur la fiche)",
		url = "https://polyhaven.com/a/dry_riverbed_rock",
		license = "CC0",
		usage = "Texture de terrain (Studio, override) : Basalt",
	},
	{
		name = "asphalt_02",
		author = "non confirmé (à relever sur la fiche)",
		url = "https://polyhaven.com/a/asphalt_02",
		license = "CC0",
		usage = "Texture de terrain (Studio, override) : Asphalt",
	},
	{
		name = "gravel_ground_01",
		author = "non confirmé (à relever sur la fiche)",
		url = "https://polyhaven.com/a/gravel_ground_01",
		license = "CC0",
		usage = "Texture de terrain (Studio, override) : Sand",
	},
	{
		name = "large_pebbles",
		author = "non confirmé (à relever sur la fiche)",
		url = "https://polyhaven.com/a/large_pebbles",
		license = "CC0",
		usage = "Texture de terrain (Studio, override) : Cobblestone",
	},
	-- Modèles 3D importés par Gabriel (ticket C1, 2026-11-10). Liste de la coordinatrice ; rangement d'après
	-- studio-export/placements.md. Version de la licence CC BY à relever sur chaque page Sketchfab.
	{
		name = "Backpack",
		author = "MadeByYeshe",
		url = "https://sketchfab.com/3d-models/backpack-dd087558c1a24a9ea82d50d764ad4b78",
		license = "CC BY (version à relever)",
		usage = "Modèle 3D (Sketchfab) : ServerStorage/Assets/Camp/SacADos_01",
	},
	{
		name = "Cooler",
		author = "MrPuppet",
		url = "https://sketchfab.com/3d-models/cooler-56e6ce9e72994a45beae946239eaa7ac",
		license = "CC BY (version à relever)",
		usage = "Modèle 3D (Sketchfab) : ServerStorage/Assets/Camp/Glaciere",
	},
	{
		name = "DAE -  Rigby Hunting Rifle - Game Ready Asset",
		author = "Martijn",
		url = "https://sketchfab.com/3d-models/dae-rigby-hunting-rifle-game-ready-asset-e77855f0c3ea4340a4d67a4ece4b87ac",
		license = "CC BY (version à relever)",
		usage = "Modèle 3D (Sketchfab) : ServerStorage/Assets/Weapons/FusilRigby",
	},
	{
		name = "Fire lookout tower",
		author = "k1llreal",
		url = "https://sketchfab.com/3d-models/fire-lookout-tower-f7b4e5e0c64a4ec5a5331609c943ef2f",
		license = "CC BY (version à relever)",
		usage = "Modèle 3D (Sketchfab) : ServerStorage/Assets/Structures/TourGuet_24",
	},
	{
		name = "Hunting Rifle",
		author = "Ryan_Nein",
		url = "https://sketchfab.com/3d-models/hunting-rifle-b1897c572acd4c75b4b7859394e4b779",
		license = "CC BY (version à relever)",
		usage = "Modèle 3D (Sketchfab) : ServerStorage/Assets/Weapons/FusilChasse",
	},
	{
		name = "Log pile",
		author = "00amza",
		url = "https://sketchfab.com/3d-models/log-pile-c2052f1c6dc54fc9ad964073edfd06ce",
		license = "CC BY (version à relever)",
		usage = "Modèle 3D (Sketchfab) : ServerStorage/Assets/Props/PileBuches",
	},
	{
		name = "Mine entrance",
		author = "almarudjord",
		url = "https://sketchfab.com/3d-models/mine-entrance-4b5cb8b903754de4a3665b841090347b",
		license = "CC BY (version à relever)",
		usage = "Modèle 3D (Sketchfab) : ServerStorage/Assets/Structures/EntreeMine",
	},
	{
		name = "Modern Camping Tent",
		author = "Guy in a Poncho",
		url = "https://sketchfab.com/3d-models/modern-camping-tent-3f624d58d582430595179bdf9a156be3",
		license = "CC BY (version à relever)",
		usage = "Modèle 3D (Sketchfab) : ServerStorage/Assets/Camp/Tente_01",
	},
	{
		name = "Portable gas stove",
		author = "manamsudheer",
		url = "https://sketchfab.com/3d-models/portable-gas-stove-8f33df97e2a642be8a0f279ced1f0754",
		license = "CC BY (version à relever)",
		usage = "Modèle 3D (Sketchfab) : ServerStorage/Assets/Camp/Rechaud",
	},
	{
		name = "Radio",
		author = "3DSKETCH1550",
		url = "https://sketchfab.com/3d-models/radio-9ad8cb6283754b91a186016a3a51095d",
		license = "CC BY (version à relever)",
		usage = "Modèle 3D (Sketchfab) : ServerStorage/Assets/Props/Radio",
	},
	{
		name = "Rail track straight",
		author = "Unreal Nick",
		url = "https://sketchfab.com/3d-models/rail-track-straight-99596461f679492bafe0ddc4a22fa1d0",
		license = "CC BY (version à relever)",
		usage = "Modèle 3D (Sketchfab) : ServerStorage/Assets/Structures/Rails_01",
	},
	{
		name = "Road Gate Barrier",
		author = "ngooiwong",
		url = "https://sketchfab.com/3d-models/road-gate-barrier-586414c41f6c460ca9256ce691fbf93d",
		license = "CC BY (version à relever)",
		usage = "Modèle 3D (Sketchfab) : ServerStorage/Assets/Props/BarriereRoute",
	},
	{
		name = "Suspension Bridge",
		author = "coffeecat",
		url = "https://sketchfab.com/3d-models/suspension-bridge-003f92a284154e1cadeab8131d896eb6",
		license = "CC BY (version à relever)",
		usage = "Modèle 3D (Sketchfab) : ServerStorage/Assets/Structures/PontSuspendu",
	},
	{
		name = "Vintage  Camera",
		author = "EricKos",
		url = "https://sketchfab.com/3d-models/vintage-camera-dd2608dcbd3e4944b4614b2f2de4c73b",
		license = "CC BY (version à relever)",
		usage = "Modèle 3D (Sketchfab) : ServerStorage/Assets/Props/CameraVintage",
	},
	-- Wooden Sign : studio-export/wiki/decisions.md nomme l'auteur « carlossamuelariza » (identifiant Sketchfab ?).
	{
		name = "🧱Wooden Sign",
		author = "Carlos",
		url = "https://sketchfab.com/3d-models/wooden-sign-256975ecc4a947a79ffe2a0e963e8bbd",
		license = "CC BY (version à relever)",
		usage = "Modèle 3D (Sketchfab) : ServerStorage/Assets/Props/Panneau_ApeCanyonTrail",
	},
	-- Rock 09 : auteur relevé dans studio-export/wiki/assets.md, non vérifié sur la fiche Poly Haven (site
	-- inaccessible depuis la session cloud du 2026-11-10).
	{
		name = "Rock 09",
		author = "Jenelle van Heerden",
		url = "https://polyhaven.com/a/rock_09",
		license = "CC0",
		usage = "Modèle 3D (Poly Haven) : Workspace/TEST_Rock09 (test d'import) ; Rock_Small_A (13.3)",
	},
}
