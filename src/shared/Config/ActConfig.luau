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

-- 19.5 (C19) : objectifs, dans l'ordre, affichés dans ObjectiveGui et la tablette.
-- {n} : progression (indices trouvés, ouvertures barricadées, secondes restantes).
ActConfig.Objectives = {
	[0] = { "Trouver le camp des géologues" },
	[1] = { "Fouiller le camp", "Trouver la tablette des géologues", "Trouver des indices ({n}/3)" },
	[2] = { "Rejoindre la cabane des mineurs avant minuit", "Barricader la cabane ({n}/3)", "Tenir" },
	[3] = {
		E1 = { "Trouver les clés du van", "Trouver un cric", "Changer la roue du van" },
		E2 = {
			"Trouver un câble d'antenne",
			"Apporter la batterie de l'épave à la tour",
			"Réparer la radio de la tour",
		},
		E3 = { "Trouver du carburant", "Trouver le relais de démarreur", "Réparer le bulldozer" },
		E4 = { "Facultatif : suivre la carte des tunnels" }, -- en plus, si DOC_07 a été lu
	},
	[4] = {
		E1 = { "Partir avec le van" },
		E2 = { "Tenir sur l'aire jusqu'à l'hélicoptère ({n} s)" },
		E3 = { "Forcer la barrière de la piste" },
		E4 = { "Dégager la sortie basse et sortir" },
	},
}

-- 19.5 (C19) : phrase de CS_07 selon la voie tirée
ActConfig.RouteAnnounce = {
	E1 = "Le van. Si on retrouve les clés, on part.",
	E2 = "La radio de la tour. C'est notre seule chance.",
	E3 = "Le bulldozer du chantier. Il peut passer la barrière.",
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
	-- 19.5 (C20, C34) : cadence des pierres pendant les 6 min, par créature (from/to : s depuis le début).
	-- Les impacts sur le toit et les murs sont cosmétiques, sauf sur les 3 ouvertures.
	Phases = {
		{ from = 0, to = 120, interval = 4, jitter = 1.5 }, -- 0:00–2:00 : 1 pierre / 4 s (±1,5 s)
		{ from = 120, to = 180, interval = 2.5 }, -- 2:00–3:00 : 1 / 2,5 s
		{ from = 180, to = 200, silence = true }, -- 3:00–3:20 : silence total
		{ from = 200, to = 300, interval = 2.5, barricadeAttempts = true }, -- 3:20–5:00 : + essais
		{ from = 300, to = 360, interval = 2 }, -- 5:00–6:00 : 1 / 2 s
	},
}

-- phase du siège à `elapsed` secondes du début (nil hors des 6 min)
function ActConfig.siegePhase(elapsed)
	for _, phase in ActConfig.Siege.Phases do
		if elapsed >= phase.from and elapsed < phase.to then
			return phase
		end
	end
	return nil
end

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
		-- 19.6 (C26) : bruit de 1 500 studs ; le directeur autorise une attaque immédiate sur le van
		startNoise = 1500,
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
