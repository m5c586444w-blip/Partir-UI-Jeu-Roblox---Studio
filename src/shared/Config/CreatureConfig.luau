-- ReplicatedStorage/Config/CreatureConfig
-- Valeurs de la bible, section 9 (et 5.5 pour la présence). Ne rien ajouter ici sans la bible.
local CreatureConfig = {}

-- 9.2 : la famille. height en studs ; modèles dans ServerStorage/Creatures (16.1).
-- Modèle absent : capsule de la taille donnée (J10 : « capsule de 10 studs puis modèle »).
CreatureConfig.Family = {
	CRT_Alpha = { model = "CRT_Alpha", height = 10, health = 1000, presence = "Always", hearing = 1.0, role = "Hunter" },
	CRT_Scout1 = {
		model = "CRT_Scout",
		height = 8,
		health = 500,
		presence = "GroupSize",
		hearing = 1.2,
		role = "Scout",
	},
	CRT_Scout2 = {
		model = "CRT_Scout",
		height = 8,
		health = 500,
		presence = "GroupSize",
		hearing = 1.2,
		role = "Scout",
	},
	CRT_Female = { model = "CRT_Female", height = 9, health = 800, presence = "Tunnels", hearing = 1.0, role = "Guard" },
}
CreatureConfig.JuvenileBones = "Juvenile_Bones" -- os gardés par la femelle en P07b
CreatureConfig.LairPlace = "P07b"

-- 9.2 : régénération hors combat, jusqu'à 70 % du maximum
CreatureConfig.Regen = { PerSecond = 2, MaxFraction = 0.7 }
-- TODO(BIBLE): « hors combat » = combien de secondes sans dégâts ni attaque ? PROVISOIRE : 10 s (fenêtre de BHV_Retreat)
CreatureConfig.OutOfCombatAfter = 10

-- 9.2 : allures (studs/s) et bruit
CreatureConfig.Gaits = {
	Sneak = { speed = 6, noise = 8 },
	Walk = { speed = 10, noise = 30 },
	Run = { speed = 22, noise = 80 },
	Sprint = { speed = 30, duration = 6, recovery = 20 }, -- à quatre pattes
	Climb = { speed = 5 }, -- seulement entre deux ClimbPoint
}

-- 9.3 : architecture et fréquences (fois par seconde)
CreatureConfig.Rates = {
	Director = 1,
	Family = 2,
	Brain = 5,
	PerceptionNear = 10, -- à moins de 150 studs
	PerceptionFar = 2,
	PerceptionNearRange = 150,
}
-- 9.3 : simulation à distance
CreatureConfig.Simulation = {
	BodyRange = 600, -- aucun joueur à moins de 600 studs : plus de corps physique
	NodeSpacing = 200, -- CreatureNav : un nœud tous les 200 studs, plus un par lieu
}

-- 9.4 : perception
CreatureConfig.Vision = {
	RangeNight = 180,
	RangeDawn = 300,
	WeatherFactor = { Fog = 0.5, Rain = 0.7 },
	Cone = 120, -- degrés
	Peripheral = 200, -- jusqu'à 200° avec ×0,4
	PeripheralFactor = 0.4,
	GainRate = 1.5, -- +1,5 × (1 − d / Rv) × visibilité par seconde
	DecayRate = 0.1, -- −0,1 par seconde
	TurnHeadAt = 0.3,
	KnowsPositionAt = 0.7,
	TargetAt = 1.0,
}
CreatureConfig.Hearing = {
	Attenuation = { Rain = 0.6, Stream = 0.4, Waterfall = 0.2, CabinWalls = 0.7 },
	StreamRange = 30, -- à moins de 30 studs d'un ruisseau
	WaterfallPlace = "P13",
	CabinPlace = "P05c",
	PositionError = 0.1, -- l'endroit retenu est faux de 10 % de la distance
}
CreatureConfig.Smell = {
	Upwind = 80, -- le vent va du joueur vers elle
	Crosswind = 30,
	Downwind = 10,
	TrailSpacing = 4, -- un point de piste tous les 4 studs
	TrailLifetime = 300, -- actif 300 s ; la créature le suit au pas
}

-- 9.5 : comportements (durée min en s ; score fixe éventuel)
CreatureConfig.Behaviors = {
	BHV_Roam = { minDuration = 20, fixedScore = 0.2 },
	BHV_Feed = { minDuration = 40, hungerAbove = 0.7, hungerPerMinute = 0.01, places = { "P19" } },
	BHV_Mark = { baseScore = 0.3, minDuration = 15, branchHeight = 3 }, -- casse une branche à 3 m
	BHV_Observe = { baseScore = 0.5, minDuration = 30, minDistance = 40, maxDistance = 90, fleeIfApproached = 25 },
	BHV_Intimidate = { baseScore = 0.55, minDuration = 0 }, -- une marche de l'échelle
	BHV_Stalk = { baseScore = 0.45, minDuration = 45, minDistance = 50, maxDistance = 80 },
	BHV_Ambush = { baseScore = 0.4, maxDuration = 90, minDistance = 20, maxDistance = 30 },
	BHV_Attack = { baseScore = 0.9, minDuration = 0 },
	-- 19.5 (C10) : 1 lancer toutes les 3 à 5 s hors siège
	BHV_Throw = {
		baseScore = 0.5,
		minDuration = 20,
		minDistance = 20,
		maxDistance = 120,
		intervalMin = 3,
		intervalMax = 5,
	},
	BHV_Sabotage = { baseScore = 0.6, minDuration = 30, tightGroupFor = 120 },
	BHV_Drag = { baseScore = 0.8, reserves = { "P20", "P04", "P07b" } }, -- rive du lac, sous les troncs, repaire
	BHV_Retreat = { baseScore = 0.6, minDuration = 30, maxDuration = 60, healthLost = 0.15, window = 10 },
	BHV_Siege = { minRadius = 25, maxRadius = 40 },
	BHV_Guard = { range = 40 },
	BHV_Mimic = { baseScore = 0.5, minDuration = 10 },
	BHV_Avoid = { fireRange = 40 },
}
-- DÉFAUT d'interprétation : baseScore = score quand la condition de 9.5 est pleinement remplie
-- (la bible ne donne que des conditions) ; à régler en phase B3.
CreatureConfig.SwitchFactor = 1.25 -- garde le comportement sauf si un autre dépasse son score ×1,25
-- DÉFAUT (C28) : les 3 « arbres à pierres » fixes (9.1) sont des Part taguées « StoneTree », posées à
-- la main dans Studio en B1 (placement de décor).
CreatureConfig.StoneTreeTag = "StoneTree"

-- 9.6 : échelle d'intimidation (8 crans)
CreatureConfig.Intimidation = {
	Steps = {
		"FaunaSilence", -- 1. silence de la faune (60 studs)
		"WoodKnock", -- 2. coups sur un tronc
		"Call", -- 3. cri long à distance ou grognement proche
		"NearThrow", -- 4. branche ou pierre qui tombe à côté du joueur
		"BranchSnap", -- 5. branche cassée tout près, hors de vue
		"ChestBeat", -- 6. apparition debout, martellement (Alpha)
		"FakeCharge", -- 7. fausse charge
		"Attack", -- 8. vraie attaque
	},
	FaunaSilenceRadius = 60,
	StepWithin = 5 * 60, -- chaque cran attend le précédent (moins de 5 min avant)
	DecayEvery = 3 * 60, -- redescend d'un cran toutes les 3 min sans contact
	FakeChargeStopMin = 4,
	FakeChargeStopMax = 8,
	FakeChargeChance = 0.6, -- si le joueur ne fuit pas et n'éclaire pas
}

-- 9.7 : choix de la cible
CreatureConfig.Target = {
	Weights = { I = 3.0, B = 1.5, N = 1.0, L = 1.2, R = 2.0, P = 0.8, C = 0.5 },
	Interval = 2,
	IsolationDistance = 60,
	BleedBonus = 0.3,
	CarrierBonus = 0.5, -- 19.5 (C6) : score de cible du porteur +0,5
	NoiseWindow = 10,
	NoiseDivisor = 100,
	LampOn = 1,
	TabletOpen = 0.5,
	GrudgeDamageDivisor = 200,
	GrudgePerFlare = 0.3,
	GrudgeFilmed = 0.5,
	GrudgeFilmedDistance = 30,
	TrackerShotFactor = 2,
	ProximityDistance = 300,
	SwitchMargin = 0.2, -- change seulement si un autre dépasse de 20 %
}

-- 9.8 : mémoire
CreatureConfig.Memory = {
	PathCell = 64,
	ShotsToAdapt = 2, -- 2 tirs reçus
	OpenGroundDistance = 60, -- reste à plus de 60 studs à découvert
	LitToAdapt = 3, -- éclairée 3 fois
	FlareFleeFirst = 8, -- fuite de 8 s…
	FlareFleeLater = 4, -- …réduite à 4 s à partir de la 2e fusée
	TightGroupRadius = 25,
	TightGroupFor = 120,
	-- TODO(BIBLE): « lance plus » après 2 tirs reçus : de combien ? PROVISOIRE : ×1,5
	ThrowMoreFactor = 1.5,
}
-- 9.8 : imitation (éclaireurs) — sons préenregistrés uniquement
CreatureConfig.MimicSounds = { "SFX_Whistle_01", "SFX_Whistle_02", "SFX_Whistle_03", "VO_<ROLE>_Hey", "VO_<ROLE>_Help" }

-- 9.8 : personnalité de l'Alpha (tirée à chaque partie)
CreatureConfig.Personalities = {
	Patient = { stalkDuration = 1.5, attackFrequency = 0.8, prefersIsolated = true },
	Territorial = { intimidation = 1.4, attackFrequency = 1.3, territoryPlace = "P05", territoryRadius = 800 },
	Playful = { mimic = 1.6, stones = 1.6, moreFakeCharges = true, noKillAct1 = true },
}
CreatureConfig.PersonalityOrder = { "Patient", "Territorial", "Playful" }

-- 9.9 : coordination
CreatureConfig.MaxVisiblePerPlayer = 2 -- jamais plus de 2 créatures visibles en même temps
CreatureConfig.AlphaInTunnelsFromAct = 4

-- 9.10 : attaques (signal en s avant les dégâts)
CreatureConfig.Attacks = {
	ATK_Strike = { range = 7, signal = 0.6, damage = 35, knockback = true, sound = "SFX_Growl_Close" },
	ATK_Charge = { minRange = 15, maxRange = 40, signal = 0.8, damage = 40, knockdown = 2, sound = "SFX_Call_Long" },
	ATK_Grab = { range = 6, signal = 0.4, damagePerSecond = 10, dragAfter = 3 },
	-- 19.5 (C10) : erreur de visée = 3 % de la distance (×0,8 Difficile, ×0,6 Cauchemar) ;
	-- C2 : une pierre ne cause jamais d'hémorragie grave (PlayerConfig.BleedOnDamage.StoneMax)
	ATK_Throw = {
		minRange = 20,
		maxRange = 120,
		damageMin = 15,
		damageMax = 30,
		sound = "SFX_StoneWhoosh",
		aimError = 0.03,
		aimErrorFactor = { Hard = 0.8, Nightmare = 0.6 },
	},
	ATK_Slam = { range = 5, signal = 1.0, damage = 60 },
	ATK_ReachThrough = { range = 5, signal = 0.5 },
	ATK_Execution = { range = 3, signal = 1.5, profile = "Restricted", creature = "CRT_Alpha" },
}
-- 19.5 (C10) : pierres à 90 studs/s
CreatureConfig.StoneSpeed = 90
-- TODO(BIBLE): force du recul de ATK_Strike (C30, la vitesse des pierres est réglée par C10). PROVISOIRE : 40.
CreatureConfig.KnockbackForce = 40

-- 7.3 : la créature traîne un joueur à terre à 10 studs/s vers une réserve
CreatureConfig.DragSpeed = 10

-- 9.11 : déplacement
CreatureConfig.Path = {
	AgentRadius = 3,
	AgentHeight = 10,
	AgentCanJump = true,
	Costs = { Water = 5, Sand = 3, Pebble = 2, Rock = 2, Grass = 1, LeafyGrass = 0.8 },
	Modifiers = { Cover = 0.6, Trail = 1.5, Forbidden = 10, ForbiddenWhileHunting = 1 },
	ForbiddenPlace = "P08",
	DirectRange = 30, -- près de la cible : déplacement direct avec évitement par rayons
	ClimbTag = "ClimbPoint",
}

-- 9.12 : directeur de tension (voir DirectorConfig)

-- 8.1, 8.2 : effets des objets sur la créature
CreatureConfig.Repellents = {
	FlareKeepAway = 40, -- reste à plus de 40 studs sauf si enragée
	PowerLightBlind = 1, -- éblouie 1 s si elle fixe la lampe puissante à moins de 20 studs
	PowerLightRange = 20,
	BearSprayRecoil = 4, -- lâche sa prise et recule 4 s
	FlareGunFlee = 8,
}

-- Empreintes (EVT_05, 7.7 Pisteur, 8.4 moulage) : Part taguées « Footprint » (Decal_Footprint_Big, 13.5)
-- DÉFAUT (affichage) : une empreinte tous les 6 studs ; retirée après 300 s (12.3 : durée sous la neige)
CreatureConfig.Footprints = { Spacing = 6, Lifetime = 300, Size = Vector3.new(1.5, 0.05, 1.5) } -- 41 cm ≈ 1,5 stud (13.5)

-- DÉFAUT (technique et affichage) : capsule de remplacement, recalcul de chemin, cadences internes
CreatureConfig.Technical = {
	RepathDistance = 8, -- un nouveau chemin si le but bouge de plus de 8 studs
	CapsuleWidth = 3, -- AgentRadius (9.11)
	CapsuleColor = Color3.fromRGB(40, 34, 30),
	MimicCooldownFactor = 3, -- BHV_Mimic : 3 durées minimales entre deux imitations
	TabletBarDuration = 3, -- EVT_21 : la barre de réseau reste 3 s
	DragOffset = 0.25, -- BHV_Drag : le corps traîné derrière la créature (× sa taille)
}

-- 9.1 et 5.2 : se retire à l'aube (05 h 50)
CreatureConfig.DawnRetreatHour = 5 + 50 / 60

return CreatureConfig
