-- ServerScriptService/AI/Behaviors/BHV_Roam (Partie)
-- Section 9.5 : Errance : parcourt son territoire (score fixe 0,2).
-- Score de 0 à 1 (interprétation de la colonne « Score élevé quand », à régler en phase B3).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local CreatureConfig = require(Config:WaitForChild("CreatureConfig"))
local MapConfig = require(Config:WaitForChild("MapConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local B = CreatureConfig.Behaviors.BHV_Roam
local Behavior = {}

function Behavior.score(_brain)
	return B.fixedScore
end

function Behavior.step(brain)
	if brain:Arrived() then
		-- DÉFAUT : un nœud CreatureNav voisin, tiré au hasard
		local here = brain:Position()
		local angle = math.random() * 2 * math.pi
		local spacing = CreatureConfig.Simulation.NodeSpacing
		local goal = here + Vector3.new(math.cos(angle) * spacing, 0, math.sin(angle) * spacing)
		if brain.id == "CRT_Female" then
			goal = MapConfig.Places[CreatureConfig.LairPlace].pos -- la femelle reste au repaire
		end
		brain:MoveTo(goal, "Walk")
	end
end

local _ = { MapConfig, Util, B }

return Behavior
