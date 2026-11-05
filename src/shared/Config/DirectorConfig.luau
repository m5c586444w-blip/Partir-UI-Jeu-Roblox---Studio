-- ReplicatedStorage/Config/DirectorConfig
-- Valeurs de la bible, sections 9.12 et 10. Ne rien ajouter ici sans la bible.
local DirectorConfig = {}

-- 9.12 : T = 0,5 × peur + 0,3 × (100 − santé moyenne) + 20 × e^(−t/30)
DirectorConfig.Tension = { FearWeight = 0.5, HealthWeight = 0.3, EventWeight = 20, EventDecay = 30, Max = 100 }

-- 9.12 : règles
DirectorConfig.Rise = { Below = 25, For = 120 } -- intensité < 25 pendant 120 s : un événement « bas »
DirectorConfig.Peak = { Above = 75, For = 90, PauseMin = 60, PauseMax = 90 } -- pause imposée
DirectorConfig.Act1 = { IsolatedDistance = 200, IsolatedFor = 60, GuaranteedSightings = 1, GuaranteedSigns = 2 }
DirectorConfig.Act2MaxDeaths = { Normal = 1, Hard = 2, Nightmare = math.huge }
-- 19.5 (J12) : si, 10 min après le début de l'acte 3, il y a eu moins de 2 tentatives d'attaque,
-- le directeur impose BHV_Attack sur la meilleure cible
DirectorConfig.Act3 = { MinAttackAttempts = 2, MaxDeathsPer = 1, Window = 3 * 60, ForceAttackAfter = 10 * 60 }
DirectorConfig.Act4 = { AllCreatures = true, NoPause = true }

-- 10.1 : règles de mise en scène
DirectorConfig.Staging = {
	OutOfViewOrBeyond = 80, -- hors du champ de tous les joueurs, ou à plus de 80 studs
	PerPlayerInterval = 45, -- 1 événement au plus toutes les 45 s par joueur
	NoRepeatFor = 10 * 60, -- le même événement jamais deux fois en 10 min
	JumpMusicOncePerGame = true, -- seule exception : premier vrai contact de l'acte 2
}

-- 10.2 : catalogue (acts = actes où l'événement peut arriver ; asset = son ou modèle)
DirectorConfig.Events = {
	EVT_01 = {
		name = "La faune se tait d'un coup autour du joueur",
		acts = { 0, 4 },
		kind = "FaunaSilence",
		radius = 60,
	},
	EVT_02 = {
		name = "Trois coups sur un tronc au loin, puis trois de l'autre côté",
		acts = { 1, 3 },
		kind = "Sound",
		sounds = { "SFX_WoodKnock_01", "SFX_WoodKnock_06" },
		pair = true,
	},
	EVT_03 = {
		name = "Structure de branches entrelacées sur un sentier déjà pris",
		acts = { 1, 3 },
		kind = "Prop",
		props = { "Prop_StickStructure_A", "Prop_StickStructure_B", "Prop_StickStructure_C" },
		tag = "StickStructure",
	},
	EVT_04 = {
		name = "Tas de pierres au pied d'un arbre, plus haut qu'au passage précédent",
		acts = { 1, 3 },
		kind = "Prop",
		props = { "Prop_StonePile_A", "Prop_StonePile_B", "Prop_StonePile_C" },
	},
	EVT_05 = {
		name = "Empreintes fraîches autour du van ou des tentes",
		acts = { 1, 3 },
		kind = "Footprints",
		places = { "P01", "P09" },
		decal = "Decal_Footprint_Big",
	},
	EVT_06 = {
		name = "Bâtons enfoncés dans la toile d'une tente",
		acts = { 1, 1 },
		kind = "Prop",
		props = { "Prop_TentSticks" },
		places = { "P09" },
	},
	EVT_07 = {
		name = "Sifflement humain dans le noir",
		acts = { 1, 4 },
		kind = "Sound",
		sounds = { "SFX_Whistle_01", "SFX_Whistle_02", "SFX_Whistle_03" },
	},
	EVT_08 = { name = "Un « Hey ! » avec la voix d'un coéquipier", acts = { 2, 4 }, kind = "Mimic" },
	EVT_09 = {
		name = "Lampe abandonnée, allumée, sur le sentier, tournée vers la forêt",
		acts = { 1, 1 },
		kind = "Prop",
		props = { "Prop_DroppedFlashlight" },
		light = true,
	},
	EVT_10 = {
		name = "La porte du poste des rangers est ouverte, alors qu'elle était fermée",
		acts = { 1, 3 },
		kind = "Door",
		places = { "P17" },
		sounds = { "SFX_DoorCreak_02" },
	},
	EVT_11 = {
		name = "Une pierre tombe sur le toit du van",
		acts = { 0, 1 },
		kind = "Sound",
		sounds = { "SFX_StoneOnMetal_01" },
		places = { "P01" },
	},
	EVT_12 = {
		name = "Odeur forte (vignettage vert très léger, réplique « Vous sentez ça ? »)",
		acts = { 1, 4 },
		kind = "Smell",
		voice = "VO_<ROLE>_Smell",
	},
	EVT_13 = {
		name = "Deux yeux reflètent la lampe à 60 studs, puis disparaissent",
		acts = { 1, 3 },
		kind = "EyeShine",
		distance = 60,
		effect = "FX_EyeShine",
		duration = 4,
	},
	EVT_14 = {
		name = "Respiration lente sur le canal radio",
		acts = { 2, 4 },
		kind = "Radio",
		sounds = { "SFX_RadioBreath_01" },
	},
	EVT_15 = {
		name = "Le corps de Leah Brandt a bougé entre deux passages",
		acts = { 1, 3 },
		kind = "MoveBody",
		zone = "B6",
	},
	EVT_16 = {
		name = "Arbre cassé net à 3 m de haut, cassure fraîche",
		acts = { 1, 4 },
		kind = "Prop",
		props = { "Prop_SnappedTree_A" },
	},
	EVT_17 = {
		name = "Des pas qui s'arrêtent une demi-seconde après ceux du joueur",
		acts = { 1, 3 },
		kind = "EchoSteps",
		sounds = { "SFX_Steps_Heavy_Delay" },
		delay = 0.5,
	},
	EVT_18 = {
		name = "Un cri long au loin, auquel un autre répond à l'opposé",
		acts = { 1, 4 },
		kind = "Sound",
		sounds = { "SFX_Call_Long_01", "SFX_Call_Long_04" },
		pair = true,
	},
	EVT_19 = { name = "Les objets d'un sac posé sont alignés à côté", acts = { 2, 4 }, kind = "AlignBag" },
	EVT_20 = {
		name = "Un caillou tombe dans l'eau à côté du joueur",
		acts = { 1, 4 },
		kind = "Sound",
		sounds = { "SFX_Splash_Small" },
		nearWater = true,
	},
	EVT_21 = { name = "La tablette affiche une barre de réseau, puis plus rien", acts = { 1, 3 }, kind = "TabletBar" },
	EVT_22 = {
		name = "Une silhouette debout sur les troncs flottants du lac",
		acts = { 1, 3 },
		kind = "Silhouette",
		places = { "P20" },
		duration = 4,
	},
}
-- 10 : le directeur tire les événements du catalogue « bas »
-- 19.6 (C32) : catalogue « bas ». Les autres suivent leurs propres règles (acte, lieu, comportement)
DirectorConfig.LowCatalog = {
	"EVT_01",
	"EVT_02",
	"EVT_03",
	"EVT_04",
	"EVT_07",
	"EVT_10",
	"EVT_11",
	"EVT_13",
	"EVT_16",
	"EVT_17",
	"EVT_18",
	"EVT_20",
	"EVT_21",
}
-- 19.6 (C33) : « au loin » tiré entre 150 et 300 studs ; « tout près » entre 10 et 20 studs
DirectorConfig.Far = { min = 150, max = 300 }
DirectorConfig.Near = { min = 10, max = 20 }

function DirectorConfig.farDistance()
	return DirectorConfig.Far.min + math.random() * (DirectorConfig.Far.max - DirectorConfig.Far.min)
end

function DirectorConfig.nearDistance()
	return DirectorConfig.Near.min + math.random() * (DirectorConfig.Near.max - DirectorConfig.Near.min)
end

-- 10.3 : ce que le joueur ne doit jamais avoir (rappel, appliqué par le code)
DirectorConfig.Never = { "DangerGauge", "CreatureArrow", "SourcelessCreatureSound", "DeathWithoutSignal" }

return DirectorConfig
