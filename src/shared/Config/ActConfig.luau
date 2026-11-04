-- ReplicatedStorage/Config/ActConfig
-- Valeurs de la bible, section 5 (déroulé d'une partie). Ne rien ajouter ici sans la bible.
local ActConfig = {}

-- 5 : la nuit du 28 octobre
ActConfig.Date = "28 octobre"

-- 5.1 : horloge. Heures en jeu (h décimales) ; durées réelles en secondes.
-- Dans un acte, l'heure avance linéairement de start à finish sur maxDuration.
ActConfig.Acts = {
	[0] = { name = "Arrivée", start = 18.5, finish = 19, minDuration = 180, maxDuration = 180 },
	[1] = { name = "L'enquête", start = 19, finish = 22, minDuration = 600, maxDuration = 900 },
	[2] = { name = "Le siège", start = 22, finish = 24, minDuration = 480, maxDuration = 840 },
	[3] = { name = "La chasse", start = 0, finish = 5, minDuration = 600, maxDuration = 900 },
	[4] = { name = "L'aube", start = 5, finish = 6, minDuration = 180, maxDuration = 300 },
}
ActConfig.ActTransition = 10 -- l'heure saute au début de l'acte suivant en 10 s (ciel accéléré)
ActConfig.EndHour = 6 -- 06 h 00 : la partie s'arrête, les joueurs encore dans la forêt sont disparus
ActConfig.MaxGameDuration = 55 * 60 -- au plus tard 55 min réelles après le début

-- 5.2 : objectifs affichés (textes de la bible)
ActConfig.Objectives = {
	[0] = "Trouver le camp des géologues",
	[1] = "Trouver le camp des géologues",
	Cabin = "Rejoindre la cabane avant minuit",
	-- TODO(BIBLE): textes d'objectif des actes 3 et 4 (voie d'extraction) ; 6.2 CS_07 n'en donne qu'un exemple
	Extraction = {
		E1 = nil,
		E2 = "La radio de la tour. C'est notre seule chance.", -- exemple de CS_07 (6.2)
		E3 = nil,
		E4 = nil,
	},
}

-- 5.2 : acte 1
ActConfig.Act1 = {
	CluesNeeded = 3, -- 3 des 6 indices tirés
	CampPlace = "P09",
}

-- 5.2 : acte 2, le siège
ActConfig.Siege = {
	CabinPlace = "P05c",
	StartDelayAfterEntry = 60, -- 60 s après l'entrée du premier joueur dans la cabane
	StartHourIfNobody = 23 + 5 / 60, -- ou à 23 h 05
	Openings = { "Door", "Window", "RoofHole" }, -- porte, fenêtre, trou du toit
	PlankTime = 8,
	RolePlankTime = { Athlete = 4 },
	Duration = 6 * 60, -- 6 minutes de bombardement
	PlankImpacts = 4, -- une planche reçoit 4 impacts avant de céder
	SilenceAfter = 20, -- silence total 20 s, puis CS_07
	NotebookPageUnlocked = 2,
	-- TODO(BIBLE): cadence des pierres pendant le siège (impacts par minute) — réglée au jalon J11/J12
	StoneInterval = nil,
}

-- 5.2 : acte 3 — voie principale tirée parmi E1, E2, E3 ; E4 ouverte si DOC_07 a été lu
ActConfig.MainRoutes = { "E1", "E2", "E3" }
ActConfig.SecretRoute = { id = "E4", requiresDocument = "DOC_07" }
ActConfig.Routes = {
	E1 = {
		place = "P01",
		needs = { "ITM_Keys", "ITM_Jack" },
		repairTime = 20,
		roleRepairTime = { Mechanic = 10 },
		cinematic = "CS_10",
	},
	E2 = {
		place = "P11",
		needs = { "ITM_CoaxCable", "ITM_CarBattery" },
		repairTime = 30,
		holdTime = 180,
		cinematic = "CS_11",
	},
	E3 = {
		place = "P10",
		needs = { "ITM_Jerrycan", "ITM_StarterRelay" },
		repairTime = 40,
		driveDistance = 650,
		driveSpeed = 8,
		cinematic = "CS_12",
	},
	E4 = { place = "P07c", needs = { "DOC_07", "Light" }, clearTime = 60, cinematic = "CS_13" },
}

-- 5.2 : acte 4
ActConfig.Dawn = {
	FinalAssaultHour = 5, -- dernier assaut
	CreatureRetreatHour = 5 + 50 / 60, -- aucune attaque après 05 h 50, sauf dans les tunnels
}

-- 5.3 : fins (clés des données 16.4)
ActConfig.Endings = {
	Survie = { cinematics = { E1 = "CS_10", E2 = "CS_11", E3 = "CS_12" } },
	Preuve = { cinematic = "CS_15" },
	Verite = { cinematic = "CS_13", notebookPage = 3 },
	Ordonnance = { cinematic = "CS_14", replaces = "Survie" },
	Silence = { cinematic = "CS_16" },
}

-- 5.4 : difficultés
ActConfig.Difficulties = {
	Normal = {
		creatureDamage = 1.0,
		perception = 1.0,
		creatureHealth = 1.0,
		friendlyFire = false,
		downedTime = 45,
		ammoBox = true,
		objectiveHints = true,
		unlock = "Start",
	},
	Hard = {
		creatureDamage = 1.3,
		perception = 1.15,
		creatureHealth = 1.25,
		friendlyFire = true,
		downedTime = 35,
		ammoBox = true,
		objectiveHints = true,
		unlock = "Start",
	},
	Nightmare = {
		creatureDamage = 1.6,
		perception = 1.3,
		creatureHealth = 1.5,
		friendlyFire = true,
		downedTime = 25,
		ammoBox = false,
		objectiveHints = false,
		unlock = "FirstSurvival",
	},
}

-- 5.5 : taille du groupe
ActConfig.GroupSizes = {
	{ maxPlayers = 3, creatures = { "CRT_Alpha" }, firearms = 1, directorEvents = 0.8 },
	{ maxPlayers = 6, creatures = { "CRT_Alpha", "CRT_Scout1" }, firearms = 2, directorEvents = 1.0 },
	{ maxPlayers = 10, creatures = { "CRT_Alpha", "CRT_Scout1", "CRT_Scout2" }, firearms = 3, directorEvents = 1.2 },
}

-- réglages de la difficulté et de la taille de groupe pour une partie
function ActConfig.difficulty(id)
	return ActConfig.Difficulties[id] or ActConfig.Difficulties.Normal
end

function ActConfig.groupSize(count)
	for _, entry in ActConfig.GroupSizes do
		if count <= entry.maxPlayers then
			return entry
		end
	end
	return ActConfig.GroupSizes[#ActConfig.GroupSizes]
end

return ActConfig
