-- ServerScriptService/Services/RecordsService (Lobby)
-- Section 4.5 : records du serveur (plus grand nombre de survivants, preuves de classe A, fins
-- débloquées). DÉFAUT : « du serveur » = joueurs présents sur ce serveur du lobby, classés d'après
-- leurs données (survivals, preuves A, fins). Publiés en JSON dans ReplicatedStorage/LobbyState.records.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local RecordsService = {}

local services = nil
local state = nil

local function compute()
	local rows = { Survivors = {}, EvidenceA = {}, Endings = {} }
	for _, player in Players:GetPlayers() do
		local data = services.DataService:GetData(player)
		if data then
			local classA, endings = 0, 0
			for _, e in data.evidence do
				if e.class == "A" then
					classA += 1
				end
			end
			for _, done in data.endings do
				if done then
					endings += 1
				end
			end
			table.insert(rows.Survivors, { group = player.DisplayName, value = data.survivals })
			table.insert(rows.EvidenceA, { group = player.DisplayName, value = classA })
			table.insert(rows.Endings, { group = player.DisplayName, value = endings })
		end
	end
	for _, list in rows do
		table.sort(list, function(a, b)
			return a.value > b.value
		end)
	end
	state:SetAttribute("records", Util.encode(rows))
end

function RecordsService:Init(allServices)
	services = allServices
	state = Instance.new("Folder")
	state.Name = "LobbyState"
	state.Parent = ReplicatedStorage
end

function RecordsService:Start()
	services.DataService.Loaded:Connect(compute)
	Players.PlayerRemoving:Connect(function()
		task.defer(compute)
	end)
end

return RecordsService
