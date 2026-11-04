-- ReplicatedStorage/Config/LaunchConfig
-- Groupe, lancement et téléportation Lobby ↔ Partie : bible, sections 4.4, 16.1, 16.3 et 16.4.
-- Ne rien ajouter ici sans la bible.
local LaunchConfig = {}

-- 16.4 : expérience « PISTE FROIDE (test) » (relevés le 22 octobre 2026 ;
-- à reconfirmer dans le Creator Dashboard si l'expérience a été recréée)
LaunchConfig.PlaceIds = {
	Lobby = 77677833738174,
	Partie = 103506696801797,
}

-- 4.4 : groupe
LaunchConfig.Party = {
	MinSize = 1, -- capacité 1 à 10
	MaxSize = 10,
	PrivateCodeDigits = 4, -- groupe privé : code à 4 chiffres
	ReadyCountdown = 10, -- tous « Prêt » → compte à rebours de 10 s
}

-- 16.4 : MemoryStore
LaunchConfig.MemoryStore = {
	-- « Parties » : carte triée des groupes du lobby, durée de vie 900 s
	PartiesMapName = "Parties",
	PartiesTTL = 900,
	-- limite de l'API Roblox (MemoryStoreSortedMap:GetRangeAsync lit 200 entrées au plus)
	PartiesScanCount = 200,
	-- « Launch_<PrivateServerId> » : configuration de partie lue par la Partie, durée de vie 600 s
	LaunchMapName = "Launch", -- DÉFAUT : carte de hachage qui contient les clés Launch_
	LaunchKeyPrefix = "Launch_",
	LaunchTTL = 600,
	-- valeurs techniques acceptées le 4 novembre 2026 (16.4) : essais et délai (s) par appel MemoryStore
	Attempts = 3,
	RetryDelay = 2,
}

-- DÉFAUT (valeurs techniques) : essais et délai (s) d'une téléportation ratée
-- (départ : MSG_TeleportRetry puis MSG_TeleportAbort, 4.6 ; retour au Lobby)
LaunchConfig.Teleport = {
	Attempts = 3,
	RetryDelay = 5,
}

-- 4.4 et 5.4 : votes. Sans vote : Normal, météo aléatoire. Égalité : la difficulté la plus basse
-- l'emporte ; pour la météo, aléatoire.
LaunchConfig.Votes = {
	Difficulties = { "Normal", "Hard", "Nightmare" }, -- de la plus basse à la plus haute
	Weathers = { "Random", "Clear", "Fog", "Rain", "Snow" }, -- « Random » = tirage de 12.3
	DefaultDifficulty = "Normal",
	DefaultWeather = "Random",
	TieWeather = "Random",
}

-- 16.2 : PartyLoaderService attend les joueurs 60 s au plus
LaunchConfig.ArrivalTimeout = 60

-- 16.3 : toutes les remotes client → serveur sont limitées à 10 appels par seconde ;
-- RE_Ping : 1 toutes les 2 s
LaunchConfig.RateLimits = {
	Default = { calls = 10, per = 1 },
	RE_Ping = { calls = 1, per = 2 },
}

return LaunchConfig
