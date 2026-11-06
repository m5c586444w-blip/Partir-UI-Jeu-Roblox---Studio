-- ReplicatedStorage/Config/MapConfig
-- Toutes les positions viennent de la section 3 de la bible. Ne rien ajouter ici sans la bible.
-- Repère (3.1) : X vers l'est, Z vers le sud (nord = −Z), Y = altitude du sol.
local MapConfig = {}

-- 3.1 : zone jouable et bande décorative
MapConfig.Size = 8000
MapConfig.PlayableHalf = 4000
MapConfig.DecorHalf = 4600
MapConfig.WarnHalf = 3900 -- message « Tu t'éloignes trop du groupe »
MapConfig.WarnText = "Tu t'éloignes trop du groupe" -- 3.8
MapConfig.HighestPlayableY = 560

-- 3.2 : lieux. pos = (X, Y du sol, Z) ; radius en studs.
-- Pour les zones et couloirs : from / to (X, Z), Y bas → haut.
MapConfig.Places = {
	P01 = { name = "Parking du sentier d'Ape Canyon", pos = Vector3.new(2800, 120, 3200), radius = 60 },
	P02 = {
		name = "Coulée de lahar",
		corridor = { from = Vector2.new(1800, -1500), to = Vector2.new(2400, 3600), width = 600 },
		yLow = 110,
		yHigh = 380,
	},
	P03 = {
		name = "Lava Canyon (fond de gorge)",
		pos = Vector3.new(3200, 40, 2200),
		radius = 120,
		rimY = 110,
		floorY = 40,
	},
	P04 = {
		name = "Forêt ancienne",
		zone = { minX = 507, maxX = 1800, minZ = -507, maxZ = 2507 },
		yLow = 150,
		yHigh = 330,
	},
	P05 = { name = "Ape Canyon", pos = Vector3.new(2600, 250, -1400), radius = 300, rimY = 400, floorY = 250 },
	P05c = { name = "Ruine de la cabane de 1924", pos = Vector3.new(2550, 300, -1300), radius = 25 },
	P05s = { name = "« Étroit » du canyon", pos = Vector3.new(2700, 330, -1650), width = 9 },
	P06 = { name = "Plateau de cendres", pos = Vector3.new(1200, 480, -2600), radius = 900 },
	P07a = { name = "Ape Cave, entrée principale", pos = Vector3.new(-2507, 60, 2400), radius = 20, tubeY = 5 },
	P07b = { name = "Salle du repaire", pos = Vector3.new(-2900, 30, 1700), radius = 45, underground = true },
	P07c = { name = "Sortie basse bouchée par le lahar", pos = Vector3.new(-2300, 20, 3600), radius = 6 },
	P08 = {
		name = "Zone interdite (forêt soufflée)",
		zone = { minX = -3707, maxX = -507, minZ = -3707, maxZ = -800 },
		yLow = 300,
		yHigh = 430,
	},
	P09 = { name = "Camp des géologues", pos = Vector3.new(-800, 230, 600), radius = 50 },
	P10 = { name = "Chantier forestier abandonné", pos = Vector3.new(-1400, 70, 3307), radius = 80 },
	P11 = { name = "Tour de guet centrale", pos = Vector3.new(0, 420, -1600), radius = 15, cabinOffset = 60 },
	P12 = { name = "Prairie et clairières", pos = Vector3.new(-2200, 200, 200), radius = 350 },
	P13 = { name = "Cascade et bassin", pos = Vector3.new(-1800, 150, 1200), radius = 40, topY = 210, poolY = 150 },
	P14 = { name = "Volcan (décor)", pos = Vector3.new(-500, 2600, -10000), outOfBounds = true },
	P15 = { name = "Mine abandonnée", pos = Vector3.new(3333, 390, -667), radius = 30 },
	P16 = {
		name = "Pont sur le ruisseau de Lava Canyon",
		pos = Vector3.new(3467, 150, 1600),
		length = 30,
		waterY = 100,
	},
	P17 = { name = "Poste des rangers fermé", pos = Vector3.new(800, 110, 3067), radius = 25 },
	P18 = { name = "Barrière de la zone interdite", pos = Vector3.new(-400, 300, -667), radius = 10 },
	P19 = { name = "Charnier de wapitis", pos = Vector3.new(-2933, 380, -2667), radius = 40 },
	P20 = { name = "Lac aux troncs flottants", pos = Vector3.new(-1667, 330, -1733), ellipse = Vector2.new(600, 320) },
	P21 = { name = "Tunnel effondré (puits)", pos = Vector3.new(-3200, 140, 933), radius = 15, tubeY = 85 },
	P22 = { name = "Épave de voiture", pos = Vector3.new(533, 100, 3733), radius = 10 },
	P23 = { name = "Station météo", pos = Vector3.new(2400, 560, -3467), radius = 12 },
	P24 = { name = "Tour est", pos = Vector3.new(3800, 300, 667), radius = 12, cabinOffset = 60 },
	P25 = { name = "Tour nord", pos = Vector3.new(-200, 470, -3067), radius = 12, cabinOffset = 60 },
	P26 = { name = "Tour ouest", pos = Vector3.new(-3600, 260, -667), radius = 12, cabinOffset = 60 },
	F01 = {
		name = "Falaise de la Crête",
		line = { fromX = -507, toX = 1800, z = -800 },
		height = 40,
		passMinX = -100,
		passMaxX = 100,
	},
}

-- 3.3 : départs (10 points espacés de 6 studs autour de S1)
MapConfig.Spawns = {
	S1 = Vector3.new(2780, 120, 3220),
	S2 = Vector3.new(-1380, 70, 3290),
	S3 = Vector3.new(-820, 230, 640),
}
MapConfig.SpawnPointCount = 10
MapConfig.SpawnPointSpacing = 6

-- 3.3 : extractions
MapConfig.Extractions = {
	E1 = { name = "Extraction van", pos = Vector3.new(2800, 120, 3200), exitX = 4000 },
	E2 = { name = "Extraction hélicoptère", pos = Vector3.new(-150, 425, -1750), area = Vector2.new(60, 60) },
	E3 = { name = "Extraction bulldozer", pos = Vector3.new(-1400, 70, 3950) }, -- barrière
	E4 = { name = "Extraction tunnels", place = "P07c" },
}

-- 3.3 : zones de la créature
MapConfig.CreatureZones = {
	B1 = { name = "Siège", places = { "P05" } },
	B2 = { name = "Repaire", places = { "P07a", "P07b", "P07c" } },
	B3 = { name = "Chasse", places = { "P08" } },
	B4 = { name = "Traque", places = { "P04" } },
	B5 = { name = "Embuscade", places = { "P02" } },
	B6 = { name = "Mise en scène", places = { "P09" } },
}

-- 3.4 : points tirés au hasard (6 points d'indice sur 12)
MapConfig.CluePointsDrawn = 6
MapConfig.CluePoints = {
	C01 = { name = "Camp, tente nord", pos = Vector3.new(-780, 232, 560), contents = { "DOC_03", "DOC_04" } },
	C02 = { name = "Camp, glacière", pos = Vector3.new(-840, 230, 640), contents = { "DOC_03", "DOC_04" } },
	C03 = { name = "Prairie, souche", pos = Vector3.new(-2150, 200, 260), contents = { "DOC_03", "DOC_04", "DOC_06" } },
	C04 = { name = "Cascade, rocher", pos = Vector3.new(-1760, 152, 1240), contents = { "DOC_03", "DOC_04", "DOC_06" } },
	C05 = {
		name = "Forêt, arbre creux",
		pos = Vector3.new(1100, 240, 900),
		contents = { "DOC_04", "DOC_05", "DOC_06" },
	},
	C06 = {
		name = "Épave, boîte à gants",
		pos = Vector3.new(533, 100, 3733),
		contents = { "DOC_04", "DOC_05", "DOC_06" },
	},
	C07 = { name = "Poste des rangers, bureau", pos = Vector3.new(800, 112, 3067), contents = { "DOC_05", "DOC_06" } },
	C08 = { name = "Mine, entrée", pos = Vector3.new(3300, 390, -640), contents = { "DOC_05", "DOC_06" } },
	C09 = {
		name = "Pied de la tour P11",
		pos = Vector3.new(20, 420, -1580),
		contents = { "ITM_Battery", "ITM_Bandage" },
	},
	C10 = { name = "Lahar, gros bloc", pos = Vector3.new(2100, 260, 400), contents = { "ITM_Battery", "ITM_Flare" } },
	C11 = { name = "Pont, culée", pos = Vector3.new(3440, 150, 1620), contents = { "ITM_Bandage", "ITM_Rope" } },
	C12 = {
		name = "Tour ouest, cabine",
		pos = Vector3.new(-3580, 320, -650),
		contents = { "ITM_Battery", "ITM_Splint" },
	},
}
-- 19.6 (C17) : quantités sur les points C09–C12, selon ce que le point peut contenir (3.4)
MapConfig.ClueItemQuantity = { ITM_Battery = 2, ITM_Bandage = 2, ITM_Flare = 1, ITM_Rope = 1, ITM_Splint = 1 }

-- 3.4 : objets clés (un emplacement tiré par objet ; R3 et R7 fixes).
-- Un emplacement donné par un lieu seul (« P26 cabine », « P22 coffre ») utilise la position du lieu.
MapConfig.KeyItems = {
	Keys = {
		item = "ITM_Keys",
		spots = { Vector3.new(-760, 230, 610), Vector3.new(-900, 229, 700), Vector3.new(-1500, 215, 420) },
	},
	AmmoBox = {
		item = "AmmoBox",
		spots = {
			Vector3.new(820, 112, 3050),
			Vector3.new(3360, 390, -700),
			"P26",
			Vector3.new(-1380, 72, 3280),
			Vector3.new(-2800, 380, -2550),
		},
	},
	Jack = { item = "ITM_Jack", spots = { "P22", "P17" } },
	CoaxCable = { item = "ITM_CoaxCable", spots = { "P23", "P17" } },
	CarBattery = { item = "ITM_CarBattery", spots = { "P22" } },
	Jerrycan = { item = "ITM_Jerrycan", spots = { "P17", "P22", "P15" } },
	StarterRelay = { item = "ITM_StarterRelay", spots = { "P17" } },
}

-- 8.1, colonne « Où » : objets posés à un lieu fixe (un exemplaire par lieu cité)
-- 19.6 (C17) : 1 objet par lieu fixe, sauf 6 planches (P05c), 3 bandages et 2 piles au poste P17.
-- Branches et pierres : partout au sol, générées par ItemSpawnService (MapConfig.GroundItems, DÉFAUT du 2026-11-07).
MapConfig.FixedItems = {
	{ item = "ITM_Splint", places = { "P17" } },
	{ item = "ITM_Bandage", places = { "P17" }, count = 3 },
	{ item = "ITM_Battery", places = { "P17" }, count = 2 },
	{ item = "ITM_Matches", places = { "P17", "P10" } },
	{ item = "ITM_Rope", places = { "P15" } },
	{ item = "ITM_Plank", places = { "P05c" }, count = 6 },
	{ item = "ITM_BearSpray", places = { "P17", "P01" } },
	{ item = "ITM_TinCan", places = { "P09", "P10" } },
	{ item = "ITM_DuctTape", places = { "P09", "P10" } },
	{ item = "ITM_PlasterKit", places = { "P17" } },
	{ item = "ITM_AudioRecorder", places = { "P23" } },
	{ item = "ITM_SampleBag", places = { "P09" } },
	{ item = "ITM_PhotoCamera", places = { "P09" } },
	{ item = "ITM_TabletGeo", places = { "P09" } }, -- tente de Leah Brandt
	-- 19.5 (C15) : une seule machette, fixe, dans la cabane du chantier P10, prenable par tous
	{ item = "MEL_Machete", places = { Vector3.new(-1390, 72, 3285) } },
}
MapConfig.PhotoCameraCluePoints = { "C03", "C04", "C05", "C06" } -- 8.1 : appareil photo aussi en C03–C06

-- 19.5 (C7) : 4 « marques de mineurs », visibles seulement par la Descendante à 8 studs
-- (PlayerConfig.Abilities.Descendant.HiddenClueRange), et seulement si elle est dans le groupe.
-- Les parties Workspace taguées CrawlSpace (vide sanitaire sous P05c) et Ford (gué de HC3) sont posées
-- à la main en B1 ; sans elles, le point de la marque sert de repli (DÉFAUT).
MapConfig.HiddenClues = {
	-- gros bloc du lahar : affiche l'emplacement de la boîte de munitions sur la tablette
	HC1 = { pos = Vector3.new(2140, 262, 380), effect = "AmmoBoxMarker" },
	-- plancher de la cabane : trappe vers un vide sanitaire pour 2 joueurs, invisibles à la vue de la créature
	HC2 = { place = "P05c", effect = "CrawlSpace", capacity = 2, tag = "CrawlSpace" },
	-- pierre près du pont P16 : gué 60 studs en aval, passage silencieux (bruit ×0,4)
	HC3 = {
		pos = Vector3.new(3420, 100, 1660),
		effect = "Ford",
		downstream = 60,
		noiseFactor = 0.4,
		tag = "Ford",
	},
	-- puits P21 : anneau scellé dans la roche, descente sans corde
	HC4 = { place = "P21", effect = "Ring" },
}
MapConfig.HiddenClueMarkSize = Vector3.new(2, 2, 0.2) -- DÉFAUT (technique) : marque MANQUANT_HiddenMark
MapConfig.WellDescentLift = 3 -- DÉFAUT (technique) : hauteur de pose au fond du puits P21 (studs)

-- 2.7 : documents à emplacement fixe
MapConfig.FixedDocuments = {
	DOC_02 = "P09",
	DOC_09 = "P11", -- rejoué si la radio est réparée
	DOC_10 = "P15",
	DOC_13 = "P17",
	DOC_14 = "P23",
	DOC_16 = "P09",
}

-- 3.5 : eau, routes et sentiers. Points (X, Z) ; c = point de contrôle d'une Bézier cubique.
-- Chaque tracé est une suite d'ancres ; entre deux ancres, 0 ou 2 contrôles.
MapConfig.Paths = {
	R1 = {
		kind = "River",
		widths = { 6, 14, 24, 30 },
		points = {
			{ 533, -3067 },
			{ c = { -133, -1600 } },
			{ c = { -1067, -267 } },
			{ -1800, 1200 },
			{ c = { -2200, 2133 } },
			{ c = { -2800, 3067 } },
			{ -3067, 4000 },
		},
	},
	R2 = {
		kind = "River",
		widths = { 8, 16, 22 },
		points = {
			{ 3067, -1600 },
			{ c = { 3467, 0 } },
			{ c = { 3067, 1200 } },
			{ 3467, 2400 },
			{ c = { 3667, 3067 } },
			{ c = { 3600, 3600 } },
			{ 3733, 4000 },
		},
	},
	R3 = {
		kind = "River",
		widths = { 5, 8 },
		points = {
			{ -1067, -1733 },
			{ c = { -667, -1067 } },
			{ c = { -533, -533 } },
			{ -700, -100 },
		},
	},
	RD1 = { kind = "Road", width = 18, surface = "Asphalt", points = { { 4000, 3467 }, "P01", { 3200, 2200 } } },
	RD2 = { kind = "Road", width = 14, surface = "Gravel", points = { { -1400, 4000 }, "P10", "P07a" } },
	T1 = { kind = "Trail", width = 6, points = { "P01", { 2400, 1867 }, { 2200, 267 }, "P05", "P06" } },
	T2 = {
		kind = "Trail",
		width = 5,
		points = { "P01", { c = { 933, 2400 } }, { c = { 0, 1200 } }, "P09", "P12", "P07a" },
	},
	T3 = { kind = "Trail", width = 5, points = { "P09", { 0, -800 }, "P11", "P06" }, switchbacks = true },
	-- 19.5 (C42) : lacets de T3 sous F01, 3 segments de 5 studs de large, de Y = 300 à Y = 340 (pente ≈ 8 %),
	-- puis T3 continue vers P11
	T3_Switchbacks = {
		kind = "Switchbacks",
		width = 5,
		points = { { -80, -780 }, { 80, -830 }, { -80, -880 }, { 60, -930 } },
		fromY = 300,
		toY = 340,
	},
	T4 = { kind = "Trail", width = 4, points = { "P16", "P15", "P05" } },
	T5 = { kind = "GameTrail", width = 0, points = { "P12", { -1500, -1000 }, { -900, -2300 }, "P25", "P06" } },
}

-- 3.6 : biomes (matériaux Roblox, arbres pour 10 000 studs²)
MapConfig.Biomes = {
	OldForest = {
		places = { "P04" },
		alongTrails = { "T2" },
		materials = { "LeafyGrass", "Ground" },
		treesPer10k = 9,
		trees = { "Tree_DouglasFir", "Tree_Hemlock" },
		minTreeSpacing = 11,
		undergrowth = { "Fern", "Trunk_Dead" },
	},
	MixedForest = {
		default = true,
		materials = { "Grass", "Ground" },
		treesPer10k = 6,
		trees = { "Tree_DouglasFir" },
		undergrowth = { "Fern", "Shrub" },
	},
	Meadow = { places = { "P12" }, materials = { "Grass" }, treesPer10k = 0.3, undergrowth = { "Weed" } },
	Lahar = {
		places = { "P02" },
		materials = { "Pebble", "Rock" },
		treesPer10k = 0,
		undergrowth = { "Rock_Boulder", "Rock_Small" },
	},
	Gorges = {
		places = { "P03", "P05" },
		materials = { "Basalt", "Rock" },
		treesPer10k = 1,
		rimOnly = true,
		undergrowth = { "Moss", "Rock_Small" },
	},
	Plateau = {
		places = { "P06", "P23" },
		materials = { "Sand", "Pebble" },
		sandColor = Color3.fromHex("#7A7670"),
		treesPer10k = 0.2,
		trees = { "Tree_Pine" },
	},
	ForbiddenZone = {
		places = { "P08" },
		materials = { "Sand", "Ground" },
		treesPer10k = 0,
		snagsPer10k = 4,
		fallenPer10k = 6,
		fallenOrientation = "NorthSouth",
		trees = { "Tree_Snag" },
		fallen = { "Tree_Fallen" },
	},
}
-- 19.6 (C17), DÉFAUT (réponse de Gabriel, 2026-11-07) : branches et pierres au sol, générées au lancement de la partie
-- (graine de la partie, par blocs de Terrain.ChunkSize comme la végétation), jamais posées à la main ; pas de réapparition.
-- Branches : par bloc, Forest dans la forêt ancienne et la forêt mixte (matériaux de Biomes), ForbiddenZone dans P08 ;
-- jamais à moins de trunkClearance d'un tronc (Workspace/Vegetation). Pierres : par bloc, partout sauf matériaux exclus.
-- DÉFAUT (technique) : « routes » = matériau Asphalt ; les routes de gravier et les sentiers partagent leur matériau avec
-- le lahar et le sol de forêt et ne sont donc pas exclus. Garantis près des abris : branches et pierres à moins de radius.
MapConfig.GroundItems = {
	Branch = {
		item = "ITM_Branch",
		perChunk = { Forest = 10, ForbiddenZone = 2 },
		forestMaterials = { "LeafyGrass", "Grass", "Ground" },
		trunkClearance = 4, -- studs
	},
	Stone = { item = "ITM_Stone", perChunk = 6, excludedMaterials = { "Water", "Asphalt" } },
	Shelters = { places = { "P05c", "P09", "P17" }, branches = 3, stones = 6, radius = 20 },
	AttemptsPerItem = 8, -- tirages maximum par objet à placer (un bloc d'eau ou de route reste vide)
}
-- 3.2 (P21, P07b, P07a, P07c) : réseau d'Ape Cave creusé en voxels par TerrainBuilder.Caves, DÉFAUT (réponse de Gabriel,
-- 2026-11-07). Les sols viennent du tableau 3.2 (tubeY pour P21 et P07a, sinon Y du lieu) : P21 85, P07b 30, P07a 5, P07c 20.
-- Pentes entre lieux : P21→P07b 6,7 %, P07b→P07a 3,1 %, P07a→P07c 1,2 % (aucune contradiction à arbitrer).
-- Section : arche à sol plat (boîte puis demi-cylindre) ; la partie haute (P21→P07b) est étroite et accidentée.
-- Hauteur de saut : non réglée dans le jeu (défaut Roblox 7,2 studs) ; éboulements de 4 studs de haut, franchissables.
MapConfig.ApeCave = {
	route = { "P21", "P07b", "P07a", "P07c" },
	sections = { "High", "Low", "Low" }, -- une section par tronçon de la route
	Low = { width = 36, boxHeight = 12 }, -- 30 de haut (12 + demi-cylindre de rayon 18), 36 de large (30 à 40)
	High = { width = 13, boxHeight = 24, meander = 4, floorRoughness = 1.5, floorNoiseScale = 0.53 }, -- 30 de haut, 13 de large (12 à 15)
	step = 6, -- longueur d'un tronçon de creusement (studs)
	overlap = 2, -- recouvrement entre tronçons (studs)
	rockfalls = { fractions = { 0.2, 0.5, 0.8 }, height = 4, radius = 5, ballOffsets = { -4, 0, 4 }, material = "Rock" },
	plug = { place = "P07c", length = 12, material = "Mud" }, -- bouchon de sédiments (rayon du lieu : 6)
	room = { place = "P07b", height = 30 }, -- salle de rayon 45 (rayon du lieu)
	shaft = { place = "P21", radius = 15, openLift = 6 }, -- puits vertical ; descente à la corde (ITM_Rope)
	entrance = { place = "P07a", toward = "P10", slope = 0.35, width = 40, openLift = 6, margin = 24 }, -- tranchée d'entrée vers la piste RD2
	seed = 7, -- bruit du relief des parois
}

MapConfig.VegetationCap = 20000 -- modèles de végétation et rochers
MapConfig.TreeLodDistance = 700 -- au-delà : Model.LevelOfDetail = StreamingMesh

-- 3.7 : génération procédurale (TerrainBuilder)
MapConfig.Terrain = {
	Seed = 1924,
	SouthY = 40, -- pente douce du sud (Y ≈ 40) vers le nord (Y ≈ 420)
	NorthY = 420,
	Noise = { octaves = 5, period = 1600, amplitude = 60, ridgeAmplitude = 40 },
	RiverDepthFactor = 0.35, -- profondeur = 0,35 × largeur + 4
	RiverDepthBase = 4,
	RiverBlendFactor = 3, -- raccord sur 3 × la largeur
	-- 19.5 (C40) : largeur en haut (topWidth) et au fond (bottomWidth), parois à plus de 60°.
	-- Ape Canyon se resserre à 9 studs au point P05s (narrowAt, largeur narrowWidth).
	Gorges = {
		ApeCanyon = {
			depth = 150,
			from = Vector2.new(2300, -600),
			to = Vector2.new(3000, -2200),
			topWidth = 80,
			bottomWidth = 20,
			narrowAt = "P05s",
			narrowWidth = 9,
		},
		LavaCanyon = { depth = 70, path = "R2", fromZ = 1600, toZ = 2600, topWidth = 60, bottomWidth = 15 },
	},
	-- 3.2 : pour un lieu « fond de gorge », Y est le fond et le bord est plus haut de la profondeur de la gorge
	-- (P03 : 110 − 70 = 40 ; P05 : 400 − 150 = 250 ; P05s : fond à 330). Gorge qui le contient :
	GorgeFloorPlaces = { P03 = "LavaCanyon", P05 = "ApeCanyon", P05s = "ApeCanyon" },
	-- DÉFAUT (géométrie) : le bord est relevé sur ce rayon, raccordé sur GorgeRimPinBlend, avant de creuser la gorge
	GorgeRimPinRadius = 60,
	GorgeRimPinBlend = 120,
	-- DÉFAUT (géométrie) : routes et sentiers prennent la hauteur du lieu qu'ils traversent à moins de ce rayon
	RoadPinRadius = 60,
	-- 3.2 : tolérance de position des lieux (studs), pour le contrôle TerrainBuilder.Measure
	PlaceTolerance = 5,
	GorgeMinWallDegrees = 60,
	-- DÉFAUT (géométrie) : le resserrement de P05s se fait sur une longueur égale à la largeur du haut
	GorgeNarrowTaperFactor = 1,
	FlattenBlendFactor = 1.5, -- raccord sur 1,5 fois le rayon
	MaxRoadSlope = 0.08,
	MaxTrailSlope = 0.15,
	CliffSlopeDegrees = 40, -- pente > 40° = Rock ou Basalt
	ScaleJitter = 0.15, -- échelle ±15 %
	ChunkSize = 512, -- Workspace/Vegetation/Chunk_X_Z
	Anchors = {
		{ name = "Dôme du plateau", pos = Vector2.new(1200, -2733), height = 520, radius = Vector2.new(1470, 800) },
		{ name = "Crête de la tour", pos = Vector2.new(200, -1573), height = 430, radius = Vector2.new(800, 373) },
		{ name = "Crête est", pos = Vector2.new(3200, -800), height = 400, radius = Vector2.new(667, 933) },
		{ name = "Colline ouest", pos = Vector2.new(-3067, 1200), height = 220, radius = Vector2.new(733, 533) },
		{
			name = "Cuvette du lac",
			pos = Vector2.new(-1667, -1733),
			height = 320,
			radius = Vector2.new(700, 420),
			hollow = true,
		},
	},
	SwiftReservoirZ = 4600, -- 3.8 : plan d'eau décoratif au-delà
	-- DÉFAUT (C41) : niveau du plan d'eau décoratif du réservoir Swift (3.8) = le bas de la pente
	ReservoirLevel = 40,
	-- DÉFAUT (technique) : maille de calcul du relief, blocs écrits par TerrainBuilder, bloc gris par lieu,
	-- hauteur du mur invisible des limites
	Cell = 8,
	WriteChunk = 256,
	-- DÉFAUT (technique) : hauteur maximale d'une tranche écrite par WriteVoxels (au-delà : « Region is too large »)
	WriteSlab = 512,
	PlaceBlockSize = 6,
	WallHeight = 2000,
	Materials = {
		-- 3.6 : sol par biome (premier matériau) ; routes et sentiers (3.5)
		Default = "Grass",
		Cliff = "Rock",
		GorgeCliff = "Basalt",
		Road = "Asphalt",
		Gravel = "Pebble",
		Trail = "Ground",
		AshColor = Color3.fromHex("#7A7670"),
	},
}

-- 8.3 : P11 et P23, une barre de réseau
MapConfig.NetworkPlaces = { "P11", "P23" }

-- 4.1 : plan du lobby (place « Lobby », 600 × 600 studs)
MapConfig.Lobby = {
	Size = 600,
	L01 = { name = "Point d'apparition", pos = Vector3.new(0, 5, 120) },
	L02 = { name = "Station des rangers", pos = Vector3.new(-80, 5, 20) },
	L03 = { name = "Musée « Ape Canyon 1924 »", pos = Vector3.new(80, 5, 20) },
	L04 = { name = "Magasin général", pos = Vector3.new(-80, 5, -80) },
	L05 = { name = "Diner", pos = Vector3.new(80, 5, -80) },
	L06 = { name = "Parking et van", pos = Vector3.new(0, 5, -180) },
	L07 = { name = "Ponton sur le lac", pos = Vector3.new(0, 0, 260) },
}

-- position (Vector3) d'une entrée de lieu ou d'un Vector3 direct ; nil si inconnue
function MapConfig.resolve(spot)
	if typeof(spot) == "Vector3" then
		return spot
	end
	local place = MapConfig.Places[spot]
	return place and place.pos or nil
end

return MapConfig
