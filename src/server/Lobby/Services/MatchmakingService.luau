-- ServerScriptService/Services/MatchmakingService (Lobby)
-- Sections 4.4 et 16.4 : file « Rejoindre un groupe » ; les groupes publics incomplets
-- sont publiés dans la carte triée MemoryStore « Parties » (durée de vie 900 s).
local MemoryStoreService = game:GetService("MemoryStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LaunchConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("LaunchConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local MatchmakingService = {}

local memory = LaunchConfig.MemoryStore
local partiesMap = nil

local function call(fn)
	if partiesMap == nil then
		return false, "carte MemoryStore indisponible"
	end
	return Util.retry(memory.Attempts, memory.RetryDelay, fn)
end

-- publie (ou retire) un groupe selon son état : seul un groupe public, incomplet et
-- pas en cours de départ reste dans la file
function MatchmakingService:Publish(party)
	local listed = not party.isPrivate and not party.launching and #party.members < LaunchConfig.Party.MaxSize
	local ok, err
	if listed then
		local entry = {
			jobId = game.JobId,
			count = #party.members,
		}
		ok, err = call(function()
			partiesMap:SetAsync(party.id, entry, memory.PartiesTTL)
		end)
	else
		ok, err = call(function()
			partiesMap:RemoveAsync(party.id)
		end)
	end
	if not ok then
		warn("MatchmakingService : publication du groupe impossible : " .. tostring(err))
	end
end

function MatchmakingService:Remove(partyId)
	local ok, err = call(function()
		partiesMap:RemoveAsync(partyId)
	end)
	if not ok then
		warn("MatchmakingService : retrait du groupe impossible : " .. tostring(err))
	end
end

-- id d'un groupe public incomplet de CE serveur, ou nil
function MatchmakingService:FindPublicParty(isLocalJoinable)
	local ok, entries = call(function()
		return partiesMap:GetRangeAsync(Enum.SortDirection.Ascending, memory.PartiesScanCount)
	end)
	if not ok then
		warn("MatchmakingService : lecture de la file impossible : " .. tostring(entries))
		return nil
	end
	for _, item in entries do
		local entry = item.value
		if type(entry) == "table" and entry.jobId == game.JobId and isLocalJoinable(item.key) then
			return item.key
		end
		-- TODO(BIBLE): un groupe public ouvert sur un AUTRE serveur du lobby est ignoré.
		-- Faut-il téléporter le joueur vers ce serveur (TeleportToPlaceInstance) pour qu'il le rejoigne ?
	end
	return nil
end

function MatchmakingService:Init()
	local ok, result = pcall(function()
		return MemoryStoreService:GetSortedMap(memory.PartiesMapName)
	end)
	if ok then
		partiesMap = result
	else
		warn("MatchmakingService : MemoryStore inaccessible : " .. tostring(result))
	end
end

function MatchmakingService:Start() end

return MatchmakingService
