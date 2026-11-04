-- ServerScriptService/Services/PartyLoaderService (Partie)
-- Section 16.2 : lit la configuration de partie écrite par le Lobby (MemoryStore,
-- clé Launch_<id>, 16.4), puis attend les joueurs, 60 s au plus.
-- Section 16.1 : si la version du Lobby diffère de celle de la Partie, la partie n'a pas lieu.
local MemoryStoreService = game:GetService("MemoryStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LaunchConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("LaunchConfig"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Signal = require(Shared:WaitForChild("Signal"))
local Util = require(Shared:WaitForChild("Util"))
local Version = require(Shared:WaitForChild("Version"))

local PartyLoaderService = {}

-- (launchData, players) : configuration lue et joueurs présents à la fin de l'attente.
-- launchData vaut nil hors serveur réservé (test dans Studio).
PartyLoaderService.Loaded = Signal.new()

local services = nil
local memory = LaunchConfig.MemoryStore
local launchMap = nil
local state = "loading" -- "loading", "ready" ou "rejecting"
local rejectKey = nil
local launchData = nil
local presentPlayers = {}
local waitingFor = nil -- [userId] = true pendant l'attente des joueurs

local function sendBack(player)
	services.ReturnService:ReturnPlayers({ player }, nil, rejectKey)
end

-- la partie ne peut pas avoir lieu : chaque joueur présent ou à venir repart au Lobby
-- avec le message `messageKey` (4.6)
local function reject(messageKey, reason)
	warn("PartyLoaderService : " .. reason)
	state = "rejecting"
	rejectKey = messageKey
	for _, player in Players:GetPlayers() do
		task.spawn(sendBack, player)
	end
end

local function finish(data, players)
	state = "ready"
	launchData = data
	presentPlayers = players
	PartyLoaderService.Loaded:Fire(data, players)
end

-- attend les joueurs annoncés dans la configuration, ArrivalTimeout secondes au plus
local function waitForPlayers(data)
	local expected = {}
	local expectedCount = 0
	for _, entry in data.players do
		expected[entry.userId] = true
		expectedCount += 1
	end
	waitingFor = expected
	-- 4.6 : MSG_WaitingPlayers aux joueurs déjà là (les suivants le reçoivent à l'arrivée)
	for _, player in Players:GetPlayers() do
		Util.notify(player, "MSG_WaitingPlayers")
	end

	local done = false
	local connection = nil

	local function complete()
		if done then
			return
		end
		done = true
		waitingFor = nil
		if connection ~= nil then
			connection:Disconnect()
		end
		local present = {}
		for userId in expected do
			local player = Players:GetPlayerByUserId(userId)
			if player ~= nil then
				table.insert(present, player)
			end
		end
		-- 4.6 : MSG_PlayerMissing pour chaque absent, envoyé aux présents
		for _, entry in data.players do
			if Players:GetPlayerByUserId(entry.userId) == nil then
				for _, player in present do
					Util.notify(player, "MSG_PlayerMissing", { player = entry.name })
				end
			end
		end
		-- TODO(J9): un joueur absent après 60 s — son rôle n'existe pas dans la partie (4.4, étape 3)
		print(("PartyLoaderService : %d/%d joueur(s) arrivé(s)"):format(#present, expectedCount))
		finish(data, present)
	end

	local function check()
		for userId in expected do
			if Players:GetPlayerByUserId(userId) == nil then
				return
			end
		end
		complete()
	end

	connection = Players.PlayerAdded:Connect(check)
	task.delay(LaunchConfig.ArrivalTimeout, complete)
	check()
end

local function load()
	if game.PrivateServerId == "" then
		-- DÉFAUT : hors serveur réservé (test dans Studio), aucune configuration de partie
		warn("PartyLoaderService : pas de serveur réservé (Studio ?), aucune configuration de partie")
		finish(nil, Players:GetPlayers())
		return
	end
	if launchMap == nil then
		-- DÉFAUT : configuration illisible → retour au Lobby avec MSG_ReturnToLobby
		reject("MSG_ReturnToLobby", "MemoryStore inaccessible")
		return
	end

	local key = memory.LaunchKeyPrefix .. game.PrivateServerId
	local ok, data = Util.retry(memory.Attempts, memory.RetryDelay, function()
		return launchMap:GetAsync(key)
	end)
	if not ok then
		reject("MSG_ReturnToLobby", "lecture de la configuration impossible : " .. tostring(data))
		return
	end
	if type(data) ~= "table" then
		reject("MSG_ReturnToLobby", "configuration de partie introuvable (" .. key .. ")")
		return
	end
	if data.version ~= Version.Number then
		-- 16.1 : la Partie compare les versions et renvoie le groupe au Lobby
		reject(
			"MSG_VersionMismatch",
			("version du Lobby %s, version de la Partie %d"):format(tostring(data.version), Version.Number)
		)
		return
	end

	-- 3.4 : graine écrite dans la console pour rejouer un bug
	print(("PartyLoaderService : graine %s, départ %s"):format(tostring(data.seed), tostring(data.start)))
	waitForPlayers(data)
end

-- configuration de la partie (nil tant qu'elle n'est pas lue, ou hors serveur réservé)
function PartyLoaderService:GetLaunchData()
	return launchData
end

-- attend la fin du chargement ; renvoie la configuration et les joueurs présents
function PartyLoaderService:WaitUntilLoaded()
	if state ~= "ready" then
		self.Loaded:Wait()
	end
	return launchData, presentPlayers
end

function PartyLoaderService:Init(allServices)
	services = allServices
	local ok, result = pcall(function()
		return MemoryStoreService:GetHashMap(memory.LaunchMapName)
	end)
	if ok then
		launchMap = result
	else
		warn("PartyLoaderService : MemoryStore inaccessible : " .. tostring(result))
	end
end

function PartyLoaderService:Start()
	Players.PlayerAdded:Connect(function(player)
		if state == "rejecting" then
			sendBack(player)
		elseif waitingFor ~= nil then
			Util.notify(player, "MSG_WaitingPlayers")
		end
		-- DÉFAUT : un joueur absent de la configuration, ou arrivé après les 60 s, peut rester
	end)

	task.spawn(load)
end

return PartyLoaderService
