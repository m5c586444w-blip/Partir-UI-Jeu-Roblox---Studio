-- ServerScriptService/Services/ReturnService (Partie)
-- Section 16.2 : téléportation vers le Lobby avec les résultats.
-- Les résultats (fin obtenue, survivants, preuves sorties, XP : 4.4 étape 8) sont calculés au jalon J9.
-- Ils voyagent dans les données de téléportation pour l'affichage seulement (ResultsGui) :
-- les gains sont sauvegardés par DataService ici (au départ du joueur), jamais relus depuis ces données.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

local LaunchConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("LaunchConfig"))
local Version = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Version"))

local ReturnService = {}

-- renvoie les joueurs au Lobby ; `results` = table affichée à l'arrivée (peut être nil)
function ReturnService:ReturnPlayers(players, results)
	local placeId = LaunchConfig.PlaceIds.Lobby
	if placeId == 0 then
		warn(
			"ReturnService : LaunchConfig.PlaceIds.Lobby vaut 0 — TODO(BIBLE) : PlaceId de la place Lobby à renseigner"
		)
		return false
	end

	local travellers = {}
	for _, player in players do
		if player.Parent ~= nil then
			table.insert(travellers, player)
		end
	end
	if #travellers == 0 then
		return true
	end

	local options = Instance.new("TeleportOptions")
	options:SetTeleportData({ version = Version.Number, results = results })
	local ok, err = pcall(function()
		return TeleportService:TeleportAsync(placeId, travellers, options)
	end)
	if not ok then
		-- TODO(BIBLE): que faire si le retour au Lobby échoue (nouvel essai, délai) ?
		warn("ReturnService : retour au Lobby impossible (normal en Studio) : " .. tostring(err))
		return false
	end
	return true
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
