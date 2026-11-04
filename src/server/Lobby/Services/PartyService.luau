-- ServerScriptService/Services/PartyService (Lobby)
-- Section 4.4 : créer un groupe public ou privé (code à 4 chiffres), le rejoindre par code
-- ou par la file rapide, le quitter, se déclarer prêt. Tous « Prêt » → compte à rebours
-- de 10 s → départ (LaunchService).
-- Jalon J1 : le groupe et le départ. Rôles, armes et votes viennent au jalon J9.
--
-- L'état du groupe est publié en attributs du joueur (répliqués automatiquement, 16.3) :
--   partyId (string), partyCode (string, groupe privé), isReady (bool),
--   partyCountdownEnd (number : heure serveur de fin du compte à rebours, workspace:GetServerTimeNow()).
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LaunchConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("LaunchConfig"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local RateLimiter = require(Shared:WaitForChild("RateLimiter"))
local Util = require(Shared:WaitForChild("Util"))

local PartyService = {}

local services = nil
local parties = {} -- [partyId] = party
local partyOf = {} -- [Player] = partyId
local random = Random.new()
local notifyRemote = nil

local function notify(player, textKey)
	if notifyRemote ~= nil then
		notifyRemote:FireClient(player, textKey)
	end
end

local function findByCode(code)
	for _, party in parties do
		if party.code == code then
			return party
		end
	end
	return nil
end

-- code privé unique sur ce serveur, à PrivateCodeDigits chiffres
local function newCode()
	local digits = LaunchConfig.Party.PrivateCodeDigits
	local maxValue = 10 ^ digits - 1
	local format = "%0" .. tostring(digits) .. "d"
	local code
	repeat
		code = string.format(format, random:NextInteger(0, maxValue))
	until findByCode(code) == nil
	return code
end

local function setAttributes(player, party)
	player:SetAttribute("partyId", party and party.id or nil)
	player:SetAttribute("partyCode", party and party.code or nil)
	player:SetAttribute("isReady", if party then party.ready[player] == true else nil)
	player:SetAttribute("partyCountdownEnd", party and party.countdownEnd or nil)
end

local function refreshAll(party)
	for _, member in party.members do
		setAttributes(member, party)
	end
end

local function publish(party)
	task.spawn(services.MatchmakingService.Publish, services.MatchmakingService, party)
end

local function cancelCountdown(party)
	if party.countdownThread ~= nil then
		task.cancel(party.countdownThread)
		party.countdownThread = nil
		party.countdownEnd = nil
	end
end

local function allReady(party)
	if #party.members < LaunchConfig.Party.MinSize then
		return false
	end
	for _, member in party.members do
		if party.ready[member] ~= true then
			return false
		end
	end
	return true
end

local function launch(party)
	party.countdownThread = nil
	party.countdownEnd = nil
	if not allReady(party) then
		refreshAll(party)
		return
	end
	party.launching = true
	refreshAll(party)
	publish(party)
	-- TODO(J9): cinématique CS_01 (les joueurs montent dans le van) avant la téléportation (4.4, étape 6)
	local ok = services.LaunchService:Launch(party)
	if not ok then
		PartyService:LaunchFailed(party)
	end
end

-- relance ou annule le compte à rebours selon l'état du groupe
local function updateCountdown(party)
	if party.launching then
		return
	end
	if allReady(party) then
		if party.countdownThread == nil then
			local duration = LaunchConfig.Party.ReadyCountdown
			party.countdownEnd = workspace:GetServerTimeNow() + duration
			party.countdownThread = task.delay(duration, launch, party)
		end
	else
		cancelCountdown(party)
	end
	refreshAll(party)
end

local function addMember(party, player)
	table.insert(party.members, player)
	partyOf[player] = party.id
	-- un nouveau membre n'est pas prêt : le compte à rebours s'arrête
	updateCountdown(party)
	publish(party)
end

local function removeMember(player)
	local partyId = partyOf[player]
	local party = partyId and parties[partyId]
	partyOf[player] = nil
	if player.Parent ~= nil then
		setAttributes(player, nil)
	end
	if party == nil then
		return
	end
	local index = table.find(party.members, player)
	if index then
		table.remove(party.members, index)
	end
	party.ready[player] = nil
	if #party.members == 0 then
		cancelCountdown(party)
		parties[party.id] = nil
		task.spawn(services.MatchmakingService.Remove, services.MatchmakingService, party.id)
		return
	end
	updateCountdown(party)
	publish(party)
end

local function canJoin(party)
	return party ~= nil and not party.launching and #party.members < LaunchConfig.Party.MaxSize
end

local function onCreate(player, isPrivate)
	if type(isPrivate) ~= "boolean" then
		return
	end
	if partyOf[player] ~= nil then
		notify(player, "AlreadyInParty")
		return
	end
	local party = {
		id = HttpService:GenerateGUID(false),
		isPrivate = isPrivate,
		-- TODO(BIBLE): un groupe public a-t-il aussi un code ? (4.4 ne cite le code que pour le privé)
		code = if isPrivate then newCode() else nil,
		members = {},
		ready = {},
		launching = false,
		countdownThread = nil,
		countdownEnd = nil,
	}
	parties[party.id] = party
	addMember(party, player)
end

local function onJoin(player, code)
	if type(code) ~= "string" or #code ~= LaunchConfig.Party.PrivateCodeDigits or code:match("^%d+$") == nil then
		return
	end
	if partyOf[player] ~= nil then
		notify(player, "AlreadyInParty")
		return
	end
	-- TODO(BIBLE): un code ne trouve que les groupes de ce serveur du lobby
	local party = findByCode(code)
	if party == nil then
		notify(player, "PartyNotFound")
		return
	end
	if not canJoin(party) then
		notify(player, "PartyFull")
		return
	end
	addMember(party, player)
end

local function onQuickJoin(player)
	if partyOf[player] ~= nil then
		notify(player, "AlreadyInParty")
		return
	end
	local partyId = services.MatchmakingService:FindPublicParty(function(candidateId)
		local candidate = parties[candidateId]
		return candidate ~= nil and not candidate.isPrivate and canJoin(candidate)
	end)
	-- le joueur a pu rejoindre un groupe ou partir pendant la lecture MemoryStore
	if player.Parent == nil or partyOf[player] ~= nil then
		return
	end
	local party = partyId and parties[partyId]
	if party == nil or not canJoin(party) then
		-- TODO(BIBLE): sans groupe public disponible, la file doit-elle créer un groupe ?
		notify(player, "NoPublicParty")
		return
	end
	addMember(party, player)
end

local function onLeave(player)
	local party = parties[partyOf[player] or ""]
	if party ~= nil and party.launching then
		return
	end
	removeMember(player)
end

local function onReady(player, isReady)
	if type(isReady) ~= "boolean" then
		return
	end
	local party = parties[partyOf[player] or ""]
	if party == nil or party.launching then
		return
	end
	party.ready[player] = if isReady then true else nil
	updateCountdown(party)
end

-- départ raté (réservation, MemoryStore ou téléportation) : le groupe reste ouvert,
-- chacun doit se redéclarer prêt
function PartyService:LaunchFailed(party)
	if parties[party.id] ~= party or not party.launching then
		return
	end
	party.launching = false
	for _, member in party.members do
		party.ready[member] = nil
		notify(member, "LaunchFailed")
	end
	refreshAll(party)
	publish(party)
end

-- groupe d'un joueur (lecture seule pour les autres services)
function PartyService:GetParty(player)
	local partyId = partyOf[player]
	return partyId and parties[partyId] or nil
end

function PartyService:Init(allServices)
	services = allServices
end

function PartyService:Start()
	notifyRemote = Util.getRemote("RE_Notify")

	local handlers = {
		RE_PartyCreate = onCreate,
		RE_PartyJoin = onJoin,
		RE_PartyQuickJoin = onQuickJoin,
		RE_PartyLeave = onLeave,
		RE_Ready = onReady,
	}
	for remoteName, handler in handlers do
		local remote = Util.getRemote(remoteName)
		if remote ~= nil then
			RateLimiter.connect(remote, handler)
		end
	end

	Players.PlayerRemoving:Connect(removeMember)
end

return PartyService
