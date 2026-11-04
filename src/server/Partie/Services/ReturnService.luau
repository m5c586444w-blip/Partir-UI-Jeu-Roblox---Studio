-- ServerScriptService/Services/ReturnService (Partie)
-- Section 16.2 : téléportation vers le Lobby avec les résultats.
-- Les résultats (fin obtenue, survivants, preuves sorties, XP : 4.4 étape 8) sont calculés au jalon J9.
-- Ils voyagent dans les données de téléportation pour l'affichage seulement (ResultsGui) :
-- les gains sont sauvegardés par DataService ici (au départ du joueur), jamais relus depuis ces données.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

local LaunchConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("LaunchConfig"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Util = require(Shared:WaitForChild("Util"))
local Version = require(Shared:WaitForChild("Version"))

local ReturnService = {}

-- renvoie les joueurs au Lobby (MSG_ReturnToLobby, 4.6) ; `results` = table affichée à l'arrivée (peut être nil)
function ReturnService:ReturnPlayers(players, results, messageKey)
	local placeId = LaunchConfig.PlaceIds.Lobby
	local travellers = {}
	for _, player in players do
		if player.Parent ~= nil then
			table.insert(travellers, player)
			Util.notify(player, messageKey or "MSG_ReturnToLobby")
		end
	end
	if #travellers == 0 then
		return true
	end

	local options = Instance.new("TeleportOptions")
	options:SetTeleportData({ version = Version.Number, results = results })

	-- DÉFAUT : nouvel essai après un échec, comme au départ (LaunchConfig.Teleport)
	local teleport = LaunchConfig.Teleport
	for attempt = 1, teleport.Attempts do
		local ok, err = pcall(function()
			return TeleportService:TeleportAsync(placeId, travellers, options)
		end)
		if ok then
			return true
		end
		warn(
			("ReturnService : retour au Lobby impossible (essai %d, normal en Studio) : %s"):format(
				attempt,
				tostring(err)
			)
		)
		if attempt < teleport.Attempts then
			task.wait(teleport.RetryDelay)
		end
	end
	return false
end

function ReturnService:ReturnAll(results)
	return self:ReturnPlayers(Players:GetPlayers(), results)
end

function ReturnService:Init() end

function ReturnService:Start()
	TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)
		warn(
			("ReturnService : téléportation échouée pour %s (%s) : %s"):format(
				player.Name,
				tostring(teleportResult),
				tostring(errorMessage)
			)
		)
	end)
end

return ReturnService
