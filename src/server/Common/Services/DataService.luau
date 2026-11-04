-- ServerScriptService/Services/DataService (les deux places)
-- Section 16.2 et 16.4 : DataStore PisteFroide_v1, clé player_<UserId>,
-- verrouillage de session, sauvegarde toutes les 120 s et à la fermeture.
-- Le verrou est rangé dans les métadonnées de la clé : la valeur garde exactement le format de 16.4.
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local PlayerConfig = require(Config:WaitForChild("PlayerConfig"))
local ProgressionConfig = require(Config:WaitForChild("ProgressionConfig"))
local Signal = require(Shared:WaitForChild("Signal"))
local Util = require(Shared:WaitForChild("Util"))

local DataService = {}

-- (player, data) : données chargées et prêtes
DataService.Loaded = Signal.new()

local store = nil -- nil si les API DataStore sont inaccessibles (Studio sans accès)
local sessions = {} -- [Player] = { data = table, released = bool }

local function keyFor(userId)
	return ProgressionConfig.KeyPrefix .. tostring(userId)
end

-- données par défaut d'un nouveau joueur (16.4)
local function buildDefaultData()
	local endings = {}
	for _, endingId in ProgressionConfig.EndingIds do
		endings[endingId] = false
	end

	local skins = {}
	local equipped = {}
	for _, role in PlayerConfig.Roles do
		-- un rôle sans identifiant (TODO(BIBLE) dans PlayerConfig) n'a pas encore de clé
		if role.id ~= nil then
			local owned = {}
			for _, skinId in ProgressionConfig.SkinIds do
				owned[skinId] = skinId == ProgressionConfig.DefaultSkin
			end
			skins[role.id] = owned
			equipped[role.id] = ProgressionConfig.DefaultSkin
		end
	end

	local museumRead = {}
	for _, panelId in ProgressionConfig.MuseumPanelIds do
		museumRead[panelId] = false
	end

	return {
		version = ProgressionConfig.DataVersion,
		xp = 0,
		plays = 0,
		survivals = 0,
		endings = endings,
		evidence = {},
		skins = skins,
		equipped = equipped,
		notebookPages = Util.deepCopy(ProgressionConfig.DefaultNotebookPages),
		museumRead = museumRead,
		nightmareUnlocked = false,
		-- TODO(J15): valeurs par défaut des réglages de la section 17.2 (Défaut PC / mobile)
		settings = {},
	}
end

-- vrai si une autre session (autre serveur) tient un verrou encore frais
local function isLockedByOther(metadata)
	if metadata == nil or metadata.lockJobId == nil then
		return false
	end
	if metadata.lockJobId == game.JobId then
		return false
	end
	local age = os.time() - (metadata.lockTime or 0)
	return age < ProgressionConfig.SessionLock.StaleAfter
end

local function lockMetadata()
	return { lockJobId = game.JobId, lockTime = os.time() }
end

-- une tentative : prend le verrou et lit les données.
-- Renvoie "ok" + données, ou "locked" si une autre session tient le verrou.
local function tryAcquire(userId)
	local status = "ok"
	local loaded = nil
	store:UpdateAsync(keyFor(userId), function(current, keyInfo)
		local metadata = keyInfo and keyInfo:GetMetadata() or nil
		if isLockedByOther(metadata) then
			status = "locked"
			return nil -- annule l'écriture
		end
		status = "ok"
		loaded = current or buildDefaultData()
		return loaded, { userId }, lockMetadata()
	end)
	return status, loaded
end

-- écrit les données ; `release` libère le verrou (départ du joueur, fermeture)
local function writeSession(player, session, release)
	if store == nil then
		return
	end
	local userId = player.UserId
	local stolen = false
	local ok, err = pcall(function()
		store:UpdateAsync(keyFor(userId), function(_current, keyInfo)
			local metadata = keyInfo and keyInfo:GetMetadata() or nil
			if isLockedByOther(metadata) then
				stolen = true
				return nil -- une autre session a repris la clé : ne pas l'écraser
			end
			stolen = false
			local newMetadata = if release then {} else lockMetadata()
			return session.data, { userId }, newMetadata
		end)
	end)
	if not ok then
		warn(("DataService : échec de sauvegarde pour %d : %s"):format(userId, tostring(err)))
	elseif stolen then
		warn(("DataService : verrou repris par une autre session pour %d, sauvegarde annulée"):format(userId))
	end
end

local function onPlayerAdded(player)
	if sessions[player] ~= nil then
		return
	end

	if store == nil then
		-- Studio sans accès aux API : données par défaut, jamais sauvegardées
		sessions[player] = { data = buildDefaultData(), released = true }
		player:SetAttribute("dataLoaded", true)
		DataService.Loaded:Fire(player, sessions[player].data)
		return
	end

	local lock = ProgressionConfig.SessionLock
	for attempt = 1, lock.LoadAttempts do
		if player.Parent == nil then
			return -- le joueur est parti pendant le chargement
		end
		local ok, status, data = pcall(tryAcquire, player.UserId)
		if ok and status == "ok" then
			local session = { data = Util.reconcile(data, buildDefaultData()), released = false }
			if player.Parent == nil then
				-- parti entre-temps : on rend le verrou tout de suite
				writeSession(player, session, true)
				return
			end
			sessions[player] = session
			player:SetAttribute("dataLoaded", true)
			DataService.Loaded:Fire(player, session.data)
			return
		end
		if not ok then
			warn(
				("DataService : échec de chargement pour %d (essai %d) : %s"):format(
					player.UserId,
					attempt,
					tostring(status)
				)
			)
		end
		if attempt < lock.LoadAttempts then
			task.wait(lock.LoadRetryDelay)
		end
	end

	-- TODO(BIBLE): que faire d'un joueur dont les données restent verrouillées ou illisibles ?
	-- En attendant : il joue sans données, et rien n'est sauvegardé pour lui.
	warn(
		("DataService : données indisponibles pour %d, aucune sauvegarde pendant cette session"):format(player.UserId)
	)
	player:SetAttribute("dataLoaded", false)
end

local function releaseSession(player)
	local session = sessions[player]
	if session == nil then
		return
	end
	sessions[player] = nil
	if session.released then
		return
	end
	session.released = true
	writeSession(player, session, true)
end

-- données du joueur, ou nil si pas (encore) chargées
function DataService:GetData(player)
	local session = sessions[player]
	return session and session.data or nil
end

function DataService:IsLoaded(player)
	return sessions[player] ~= nil
end

-- attend les données du joueur ; nil si le joueur part ou si le chargement échoue
function DataService:WaitForData(player)
	while player.Parent ~= nil and sessions[player] == nil and player:GetAttribute("dataLoaded") ~= false do
		task.wait()
	end
	return self:GetData(player)
end

-- sauvegarde immédiate en gardant le verrou
function DataService:Save(player)
	local session = sessions[player]
	if session ~= nil and not session.released then
		writeSession(player, session, false)
	end
end

function DataService:Init()
	local ok, result = pcall(function()
		return DataStoreService:GetDataStore(ProgressionConfig.DataStoreName)
	end)
	if ok then
		store = result
	else
		warn(
			"DataService : DataStore inaccessible (en Studio : activer l'accès aux API). Données non sauvegardées. "
				.. tostring(result)
		)
	end
end

function DataService:Start()
	Players.PlayerAdded:Connect(onPlayerAdded)
	for _, player in Players:GetPlayers() do
		task.spawn(onPlayerAdded, player)
	end
	Players.PlayerRemoving:Connect(releaseSession)

	-- sauvegarde périodique (16.2 : toutes les 120 s)
	task.spawn(function()
		while true do
			task.wait(ProgressionConfig.AutosaveInterval)
			for player in table.clone(sessions) do
				task.spawn(DataService.Save, DataService, player)
			end
		end
	end)

	-- sauvegarde à la fermeture du serveur
	game:BindToClose(function()
		local pending = 0
		for player in table.clone(sessions) do
			pending += 1
			task.spawn(function()
				releaseSession(player)
				pending -= 1
			end)
		end
		while pending > 0 do
			task.wait()
		end
	end)
end

return DataService
