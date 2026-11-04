-- ServerScriptService/AI/Behaviors/BHV_Drag (Partie)
-- Section 9.5 : Traîner : joueur à terre ou mort ; emporte le corps vers une réserve (P20, P04, P07b).
-- Score de 0 à 1 (interprétation de la colonne « Score élevé quand », à régler en phase B3).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local CreatureConfig = require(Config:WaitForChild("CreatureConfig"))
local MapConfig = require(Config:WaitForChild("MapConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local B = CreatureConfig.Behaviors.BHV_Drag
local Behavior = {}

local function victim(brain)
	for _, player in brain:Candidates() do
		if
			player:GetAttribute("isDowned")
			and (player:GetAttribute("grabbedBy") == nil or player:GetAttribute("grabbedBy") == brain.id)
		then
			return player
		end
	end
	return nil
end

local function nearestReserve(position)
	local best, bestDistance = nil, math.huge
	for _, code in B.reserves do
		local place = MapConfig.Places[code]
		local pos = place.pos
			or Vector3.new((place.zone.minX + place.zone.maxX) / 2, place.yLow, (place.zone.minZ + place.zone.maxZ) / 2)
		local d = (pos - position).Magnitude
		if d < bestDistance then
			best, bestDistance = pos, d
		end
	end
	return best
end

function Behavior.score(brain)
	if brain.id == "CRT_Female" then
		return 0
	end
	return if victim(brain) then B.baseScore else 0
end

function Behavior.step(brain)
	local player = victim(brain)
	local root = player and Util.characterRoot(player)
	if root == nil then
		return
	end
	if brain:DistanceTo(player) > CreatureConfig.Attacks.ATK_Grab.range then
		brain:MoveTo(root.Position, "Run")
		return
	end
	-- 7.3 : traîné à 10 studs/s vers une réserve ; le groupe a jusqu'à la fin du compte à rebours
	player:SetAttribute("grabbedBy", brain.id)
	local reserve = nearestReserve(brain:Position())
	brain:MoveTo(reserve, "Walk")
	if brain.humanoid then
		brain.humanoid.WalkSpeed = CreatureConfig.DragSpeed
	end
	if brain:HasBody() and brain.root then
		root.CFrame = brain.root.CFrame * CFrame.new(0, 0, brain.def.height * CreatureConfig.Technical.DragOffset)
	end
	if brain:Arrived(MapConfig.Places.P07b.radius) then
		player:SetAttribute("grabbedBy", nil)
	end
end

function Behavior.stop(brain)
	for _, player in brain:Candidates() do
		if player:GetAttribute("grabbedBy") == brain.id then
			player:SetAttribute("grabbedBy", nil)
		end
	end
end

local _ = { MapConfig, Util, B }

return Behavior
