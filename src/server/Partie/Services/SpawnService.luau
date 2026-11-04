-- ServerScriptService/Services/SpawnService (Partie)
-- Sections 3.3 et 16.2 : départs S1–S3 ; autour du point, 10 points espacés de 6 studs.
-- Workspace/SpawnPoints peut contenir des Part nommées S1_1 … S3_10 (posées à la main en phase B) :
-- elles remplacent le calcul.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MapConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("MapConfig"))
local PlayerConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("PlayerConfig"))

local SpawnService = {}

-- DÉFAUT : les 10 points sont alignés d'ouest en est, centrés sur le départ
local SPAWN_LIFT = PlayerConfig.Technical.SpawnLift

local function computedPoint(start, index)
	local base = MapConfig.Spawns[start] or MapConfig.Spawns.S1
	local count = MapConfig.SpawnPointCount
	local slot = ((index - 1) % count) - (count - 1) / 2
	return base + Vector3.new(slot * MapConfig.SpawnPointSpacing, SPAWN_LIFT, 0)
end

function SpawnService:GetPoint(start, index)
	local folder = workspace:FindFirstChild("SpawnPoints")
	local marker = folder and folder:FindFirstChild(("%s_%d"):format(start, index))
	if marker and marker:IsA("BasePart") then
		return marker.Position + Vector3.new(0, SPAWN_LIFT, 0)
	end
	return computedPoint(start, index)
end

function SpawnService:Place(_player, character, start, index)
	local point = self:GetPoint(start, index or 1)
	character:PivotTo(CFrame.new(point))
end

function SpawnService:Init() end

function SpawnService:Start() end

return SpawnService
