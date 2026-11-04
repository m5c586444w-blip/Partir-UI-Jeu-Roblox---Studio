-- ReplicatedStorage/Config/LaunchConfig
-- Groupe, lancement et téléportation Lobby ↔ Partie : bible, sections 4.4, 16.2, 16.3 et 16.4.
-- Ne rien ajouter ici sans la bible.
-- TODO(BIBLE): la section 16.1 ne liste aucun module Config pour ces valeurs.
-- Ce module a été ajouté au jalon J1 pour respecter « aucune valeur hors Config ». À valider.
local LaunchConfig = {}

-- Identifiants des deux places de l'expérience. Absents de la bible : connus seulement
-- après publication. Tant qu'ils valent 0, aucune téléportation n'est tentée (avertissement).
LaunchConfig.PlaceIds = {
	Lobby = 0, -- TODO(BIBLE): PlaceId de la place « Lobby » (à remplir par Gabriel après publication)
	Partie = 0, -- TODO(BIBLE): PlaceId de la place « Partie » (à remplir par Gabriel après publication)
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
	-- Limite de l'API Roblox (MemoryStoreSortedMap:GetRangeAsync lit 200 entrées au plus)
	PartiesScanCount = 200,
	-- « Launch_<code> » : configuration de partie lue par la Partie, durée de vie 600 s
	-- TODO(BIBLE): la bible ne nomme pas la structure qui contient les clés Launch_ ; carte de hachage « Launch » choisie.
	LaunchMapName = "Launch",
	LaunchKeyPrefix = "Launch_",
	LaunchTTL = 600,
	-- TODO(BIBLE): PROPOSITION — essais et délai (s) en cas d'échec d'un appel MemoryStore
	Attempts = 3,
	RetryDelay = 2,
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
