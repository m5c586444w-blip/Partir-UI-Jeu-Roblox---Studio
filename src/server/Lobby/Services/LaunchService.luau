-- ServerScriptService/Services/LaunchService (Lobby)
-- Sections 4.4 et 16.2 : écrit la configuration de partie dans MemoryStore, réserve un
-- serveur de la place « Partie », téléporte le groupe.
-- Données transmises (4.4, 16.4) : joueurs, rôles, armes, difficulté, météo, départ tiré, graine.
local MemoryStoreService = game:GetService("MemoryStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

local Config = ReplicatedStorage:WaitForChild("Config")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local LaunchConfig = require(Config:WaitForChild("LaunchConfig"))
local MapConfig = require(Config:WaitForChild("MapConfig"))
local Util = require(Shared:WaitForChild("Util"))
local Version = require(Shared:WaitForChild("Version"))

local LaunchService = {}

local services = nil
local memory = LaunchConfig.MemoryStore
local launchMap = nil

local function buildLaunchData(party, members)
	-- 3.4 : graine = os.time(), écrite dans la console pour rejouer un bug.
	-- La bible dit « au lancement du serveur » ; elle est tirée ici, au départ du groupe,
	-- puisque 16.4 la range dans la configuration transmise.
	local seed = os.time()
	local random = Random.new(seed)

	-- 4.4 : départ tiré parmi S1, S2, S3, une chance sur trois chacun
	local starts = Util.sortedKeys(MapConfig.Spawns)
	local start = starts[random:NextInteger(1, #starts)]

	local playersData = {}
	for _, member in members do
		table.insert(playersData, {
			userId = member.UserId,
			name = member.DisplayName, -- pour MSG_PlayerMissing (4.6) dans la Partie
			role = party.roles and party.roles[member] or nil, -- RoleService (J9)
			weapon = party.weapons and party.weapons[member] or nil, -- WeaponBoardService (J9)
		})
	end

	return {
		version = Version.Number,
		players = playersData,
		-- 5.4 : sans vote, difficulté Normal et météo aléatoire (résultat de VoteService)
		difficulty = party.difficulty or LaunchConfig.Votes.DefaultDifficulty,
		weather = party.weather or LaunchConfig.Votes.DefaultWeather,
		start = start,
		seed = seed,
	}
end

-- une tentative de départ ; renvoie true si la téléportation est lancée
local function tryLaunch(party, placeId)
	local members = {}
	for _, member in party.members do
		if member.Parent ~= nil then
			table.insert(members, member)
		end
	end
	if #members < LaunchConfig.Party.MinSize then
		return false
	end

	-- réserve le serveur : ReserveServer renvoie le code d'accès et le PrivateServerId
	local okReserve, accessCode, privateServerId = pcall(function()
		return TeleportService:ReserveServer(placeId)
	end)
	if not okReserve then
		warn("LaunchService : réservation impossible (normal en Studio) : " .. tostring(accessCode))
		return false
	end

	-- 16.4 : clé Launch_<PrivateServerId>, 600 s (la Partie lit game.PrivateServerId)
	local launchData = buildLaunchData(party, members)
	local key = memory.LaunchKeyPrefix .. privateServerId
	local okWrite, writeErr = Util.retry(memory.Attempts, memory.RetryDelay, function()
		launchMap:SetAsync(key, launchData, memory.LaunchTTL)
	end)
	if not okWrite then
		warn("LaunchService : écriture de la configuration impossible : " .. tostring(writeErr))
		return false
	end
	print(("LaunchService : départ %s, graine %d, %d joueur(s)"):format(launchData.start, launchData.seed, #members))

	local options = Instance.new("TeleportOptions")
	options.ReservedServerAccessCode = accessCode
	local okTeleport, teleportErr = pcall(function()
		return TeleportService:TeleportAsync(placeId, members, options)
	end)
	if not okTeleport then
		warn("LaunchService : téléportation impossible : " .. tostring(teleportErr))
		return false
	end
	return true
end

-- lance la partie pour le groupe, avec nouvel essai (MSG_TeleportRetry, 4.6) ;
-- renvoie false si tous les essais ont échoué (PartyService envoie alors MSG_TeleportAbort)
function LaunchService:Launch(party)
	local placeId = LaunchConfig.PlaceIds.Partie
	if launchMap == nil then
		warn("LaunchService : MemoryStore inaccessible, départ impossible")
		return false
	end

	for _, member in party.members do
		Util.notify(member, "MSG_Teleporting")
	end

	local teleport = LaunchConfig.Teleport
	for attempt = 1, teleport.Attempts do
		if tryLaunch(party, placeId) then
			return true
		end
		if attempt < teleport.Attempts then
			for _, member in party.members do
				Util.notify(member, "MSG_TeleportRetry")
			end
			task.wait(teleport.RetryDelay)
		end
	end
	return false
end

function LaunchService:Init(allServices)
	services = allServices
	local ok, result = pcall(function()
		return MemoryStoreService:GetHashMap(memory.LaunchMapName)
	end)
	if ok then
		launchMap = result
	else
		warn("LaunchService : MemoryStore inaccessible : " .. tostring(result))
	end
end

function LaunchService:Start()
	-- échec de téléportation signalé après coup : le groupe redevient ouvert
	TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)
		warn(
			("LaunchService : téléportation échouée pour %s (%s) : %s"):format(
				player.Name,
				tostring(teleportResult),
				tostring(errorMessage)
			)
		)
		local party = services.PartyService:GetParty(player)
		if party ~= nil then
			services.PartyService:LaunchFailed(party)
		end
	end)
end

return LaunchService
