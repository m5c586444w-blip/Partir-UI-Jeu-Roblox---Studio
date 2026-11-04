-- ServerScriptService/AI/Behaviors/BHV_Mark (Partie)
-- Section 9.5 : Marquer : hors combat, près d'un arbre à pierres ; ajoute des pierres, casse une branche à 3 m.
-- Score de 0 à 1 (interprétation de la colonne « Score élevé quand », à régler en phase B3).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local CreatureConfig = require(Config:WaitForChild("CreatureConfig"))
local MapConfig = require(Config:WaitForChild("MapConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local B = CreatureConfig.Behaviors.BHV_Mark
local Behavior = {}

local CollectionService = game:GetService("CollectionService")

local function nearestTree(brain)
	local best, bestDistance = nil, math.huge
	for _, tree in CollectionService:GetTagged(CreatureConfig.StoneTreeTag) do
		if tree:IsA("BasePart") then
			local d = (tree.Position - brain:Position()).Magnitude
			if d < bestDistance then
				best, bestDistance = tree, d
			end
		end
	end
	return best, bestDistance
end

function Behavior.score(brain)
	if brain.id == "CRT_Female" or brain.target ~= nil then
		return 0
	end
	local tree, distance = nearestTree(brain)
	if tree == nil then
		return 0
	end
	return math.clamp(1 - distance / CreatureConfig.Simulation.NodeSpacing, 0, 1) * B.baseScore
end

function Behavior.step(brain)
	local tree = nearestTree(brain)
	if tree == nil then
		return
	end
	brain:MoveTo(tree.Position, "Walk")
	if brain:Arrived(B.branchHeight * 2) then
		brain:Stop()
		brain.ai.CreatureAnimator:Play(brain.model, "StackStones")
		brain.ai.EventDirector:GrowStonePile(tree)
	end
end

local _ = { MapConfig, Util, B }

return Behavior
