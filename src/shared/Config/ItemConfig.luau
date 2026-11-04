-- ReplicatedStorage/Config/ItemConfig
-- Valeurs de la bible, sections 8 (intro), 8.1, 8.3 et 8.4. Ne rien ajouter ici sans la bible.
local ItemConfig = {}

-- 8 : inventaire
ItemConfig.QuickSlots = 4 -- 3 pour la Mécanicienne (PlayerConfig.Abilities.Mechanic)
ItemConfig.BagMaxWeight = 12 -- kg
ItemConfig.HeavyAbove = 5 -- kg : à deux mains, pas de course, pas d'arme

-- 16.3 : RE_PickupItem, distance ≤ 10 studs
ItemConfig.PickupDistance = 10

-- 8.1 : objets. weight en kg ; stack = pile ; uses = usages ; noise = rayon (studs)
-- duration = durée d'utilisation (s). Les effets sont appliqués par InventoryService.
ItemConfig.Items = {
	ITM_Flashlight = {
		name = "Lampe torche",
		weight = 0.4,
		stack = 1,
		noise = 8,
		light = { angle = 45, range = 120, batteryMinutes = 8, flickerBelow = 0.15 },
	},
	ITM_Headlamp = {
		name = "Lampe frontale",
		weight = 0.2,
		stack = 1,
		noise = 8,
		light = { angle = 45, range = 70, batteryMinutes = 10, handsFree = true, flickerBelow = 0.15 },
	},
	ITM_PowerLight = {
		name = "Lampe puissante",
		weight = 0.8,
		stack = 1,
		noise = 8,
		light = { angle = 45, range = 220, batteryMinutes = 6, flickerBelow = 0.15, blindDuration = 1, blindRange = 20 },
	},
	ITM_Battery = { name = "Pile", weight = 0.1, stack = 6, duration = 3, effect = "RechargeLight" },
	ITM_Bandage = { name = "Bandage", weight = 0.1, stack = 5, duration = 4, noise = 10, effect = "Bandage", heal = 10 },
	ITM_Splint = { name = "Attelle", weight = 0.3, stack = 2, duration = 6, noise = 10, effect = "Splint" },
	ITM_Medkit = {
		name = "Trousse complète",
		weight = 1.5,
		stack = 1,
		uses = 5,
		duration = 8,
		noise = 10,
		effect = "Medkit",
		heal = 40,
	},
	ITM_Flare = {
		name = "Fusée à main",
		weight = 0.3,
		stack = 3,
		noise = 300,
		effect = "Flare",
		burn = 60,
		lightRadius = 60,
		fearPerSecond = -3,
		creatureKeepAway = 40,
	},
	ITM_Matches = {
		name = "Allumettes",
		weight = 0.05,
		stack = 1,
		noise = 20,
		effect = "Campfire",
		branchesNeeded = 3,
		burn = 180,
		visibleRange = 800,
	},
	ITM_Branch = { name = "Branche morte", weight = 0.5, stack = 3, breakNoise = 45, throwable = true },
	ITM_Stone = { name = "Pierre", weight = 0.3, stack = 3, impactNoise = 50, throwable = true },
	ITM_Rope = { name = "Corde", weight = 1.0, stack = 1 },
	ITM_Plank = { name = "Planche", weight = 2.0, stack = 1, nailNoise = 120 },
	ITM_BearSpray = {
		name = "Bombe anti-ours",
		weight = 0.4,
		stack = 1,
		uses = 3,
		noise = 40,
		effect = "BearSpray",
		cone = 6,
		creatureRecoil = 4,
	},
	ITM_ToolBox = { name = "Caisse à outils", weight = 3.0, stack = 1, openNoise = 30, withoutFactor = 2 },
	ITM_Compass = { name = "Boussole", weight = 0.1, stack = 1 },
	ITM_RadioScanner = { name = "Scanner radio", weight = 0.6, stack = 1, noise = 15 },
	ITM_Walkie = { name = "Talkie-walkie", weight = 0.3, stack = 1, beepNoise = 20, range = 1500 },
	ITM_TinCan = { name = "Boîte de conserve", weight = 0.1, stack = 3 },
	ITM_DuctTape = { name = "Ruban", weight = 0.1, stack = 3 },
	ITM_Notebook = { name = "Carnet Halvorsen", weight = 0.2, stack = 1, document = "DOC_12" },
	ITM_Keys = { name = "Clés du van", weight = 0.1, stack = 1 },
	ITM_Jack = { name = "Cric", weight = 4.0, stack = 1 },
	ITM_CoaxCable = { name = "Câble d'antenne", weight = 1.0, stack = 1 },
	ITM_CarBattery = { name = "Batterie de voiture", weight = 8.0, stack = 1, dropNoise = 30, twoHands = true },
	ITM_Jerrycan = { name = "Jerrican", weight = 6.0, stack = 1, noise = 15, twoHands = true },
	ITM_StarterRelay = { name = "Relais de démarreur", weight = 0.5, stack = 1 },
	ITM_PlasterKit = {
		name = "Kit de moulage",
		weight = 1.2,
		stack = 1,
		uses = 2,
		duration = 30,
		noise = 10,
		effect = "PlasterCast",
	},
	ITM_AudioRecorder = { name = "Enregistreur", weight = 0.3, stack = 1, effect = "RecordCall", range = 150 },
	ITM_SampleBag = { name = "Sachet à échantillon", weight = 0.05, stack = 3, effect = "CollectHair" },
	ITM_Camcorder = {
		name = "Caméscope vision nocturne",
		weight = 0.9,
		stack = 1,
		noise = 10,
		effect = "Film",
		recordMinutes = 6,
		nightVision = true,
	},
	ITM_PhotoCamera = {
		name = "Appareil photo",
		weight = 0.5,
		stack = 1,
		uses = 12,
		noise = 15,
		effect = "Photo",
		flashLightFactor = 3,
		flashDuration = 0.2,
	},
	ITM_TabletField = { name = "Tablette de terrain", weight = 0.7, stack = 1, effect = "Tablet" },
	ITM_TabletGeo = { name = "Tablette des géologues", weight = 0.7, stack = 1, documents = { "DOC_07", "DOC_08" } },
	-- 8.4 : carte mémoire créée après une vidéo de classe A = preuve A
	ITM_SDCard = { name = "Carte mémoire", weight = 0, stack = 1, evidence = { class = "A", kind = "Video" } },
	-- 8.4 : preuves B et C (objets d'inventaire ; noms du tableau 8.4)
	EVD_Cast = { name = "Moulage d'empreinte", weight = 0, stack = 1, evidence = { class = "B", kind = "Cast" } },
	EVD_Call = { name = "Enregistrement d'un cri", weight = 0, stack = 1, evidence = { class = "B", kind = "Call" } },
	EVD_Hair = { name = "Poils", weight = 0, stack = 1, evidence = { class = "B", kind = "Hair" } },
	EVD_PhotoCreature = {
		name = "Photo de la créature",
		weight = 0,
		stack = 1,
		evidence = { class = "B", kind = "Photo" },
	},
	EVD_Document = { name = "Document", weight = 0, stack = 1, evidence = { class = "C", kind = "Document" } },
	EVD_PhotoCharnier = {
		name = "Photo du charnier P19",
		weight = 0,
		stack = 1,
		evidence = { class = "C", kind = "PhotoP19" },
	},
	-- 3.4 et 8.2 : munitions de réserve (boîte A1–A5)
	AMMO_WPN_Rifle = { name = "Balles de fusil", weight = 0, stack = 99, ammoFor = "WPN_Rifle" },
	AMMO_WPN_Revolver = { name = "Balles de revolver", weight = 0, stack = 99, ammoFor = "WPN_Revolver" },
	AMMO_WPN_Shotgun = { name = "Cartouches", weight = 0, stack = 99, ammoFor = "WPN_Shotgun" },
}
-- TODO(BIBLE): poids des preuves (carte mémoire, moulage, etc.) et des munitions. PROVISOIRE : 0 kg.
-- DÉFAUT : pile de 99 munitions (valeur technique de rangement).

-- 8.1, colonne « Où » : objets de départ par rôle (quantité = nombre d'unités)
ItemConfig.StartingItems = {
	All = { ITM_Walkie = 1, ITM_Bandage = 2 },
	-- lampe torche : tous sauf Descendante et Géologue
	Flashlight = { item = "ITM_Flashlight", exceptRoles = { Descendant = true, Geologist = true } },
	Roles = {
		Leader = { ITM_TabletField = 1 },
		Medic = { ITM_Medkit = 1 },
		Tracker = { ITM_PlasterKit = 1 },
		Cameraman = { ITM_Camcorder = 1 },
		Mechanic = { ITM_ToolBox = 1 },
		Descendant = { ITM_Headlamp = 1, ITM_Notebook = 1 },
		Geologist = { ITM_PowerLight = 1, ITM_Compass = 1 },
		RadioOperator = { ITM_RadioScanner = 1, ITM_AudioRecorder = 1 },
		-- TODO(BIBLE): combien de fusées à main pour le Pyrotechnicien au départ ? (1 en attendant)
		Pyrotechnician = { ITM_Flare = 1 },
	},
}

-- 8.3 : tablette de terrain
ItemConfig.Tablet = {
	BatteryMinutes = 30, -- d'écran allumé pour la nuit
	VisibilityFactor = 1.5,
	GpsError = 30, -- ±30 studs
	GpsInterval = 10,
	DenseForestNoSignalChance = 0.5,
	MaxMarkers = 8,
	-- Réseau : une barre au sommet de P11 et à P23
	NetworkPlaces = { "P11", "P23" },
}

-- 8.4 : preuves (XP dans ProgressionConfig.XPGains)
ItemConfig.Evidence = {
	VideoA = { minVisibleFraction = 0.6, maxDistance = 30, minDuration = 2 },
	PlasterB = { footprintMaxAge = 120, workTime = 30 },
	CallB = { maxDistance = 150 },
	HairB = { places = { "StickStructure", "P05" } }, -- structure de branches ou bord d'Ape Canyon
	PhotoB = { maxDistance = 40 },
	DocumentC = { "DOC_03", "DOC_04", "DOC_05", "DOC_06", "DOC_07", "DOC_08", "DOC_09", "DOC_10" },
	PhotoC = { place = "P19" }, -- photo du charnier
}

-- 13.5 : icônes Icon_<ID> (assets/ui/png). Identifiants rbxassetid à renseigner après import dans Studio.
-- DÉFAUT : chaîne vide = pas d'icône affichée.
ItemConfig.Icons = {}

-- DÉFAUT (technique) : bloc gris MANQUANT_ et pose au sol
ItemConfig.PlaceholderSize = Vector3.new(1, 1, 1)
ItemConfig.PlaceholderColor = Color3.fromRGB(128, 128, 128)
ItemConfig.SpawnLift = 0.5
ItemConfig.ClueItemSpacing = 1.5 -- écart entre deux objets posés sur le même point
ItemConfig.DocumentOffset = Vector3.new(0, 0, 3) -- document posé à côté du centre du lieu
-- DÉFAUT (affichage) : fusée et feu de camp posés au sol
ItemConfig.FireVisuals = {
	Size = Vector3.new(0.4, 0.4, 0.4),
	FlareColor = Color3.fromRGB(255, 40, 30),
	CampfireColor = Color3.fromRGB(255, 150, 60),
	GroundOffset = 2.5, -- sous le HumanoidRootPart
	CampfireAhead = 3, -- devant le joueur
}

-- TODO(BIBLE): distance et vitesse d'un lancer (pierre, branche). PROVISOIRE : 40 studs/s, 1 s de vol.
ItemConfig.Throw = { Speed = 40, Flight = 1 }
-- TODO(BIBLE): bruit du piège à bruit du Pyrotechnicien (boîte de conserve + corde). Sans valeur : pas de piège.
ItemConfig.NoiseTrapRadius = nil

-- 13.3 : modèles d'objets dans ReplicatedStorage/Items (Item_<Nom>) ; absent → bloc gris MANQUANT_<ID>
ItemConfig.ModelsFolder = "Items"

return ItemConfig
