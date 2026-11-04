-- ServerScriptService/AI/Behaviors/BHV_Intimidate (Partie)
-- Section 9.5 : Intimider : joueurs près du territoire ou du repaire ; monte d'un cran sur l'échelle 9.6.
-- Score de 0 à 1 (interprétation de la colonne « Score élevé quand », à régler en phase B3).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local CreatureConfig = require(Config:WaitForChild("CreatureConfig"))
local MapConfig = require(Config:WaitForChild("MapConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local B = CreatureConfig.Behaviors.BHV_Intimidate
local Behavior = {}

local Intimidation = CreatureConfig.Intimidation

local function nearTerritory(brain)
	for _, player in brain:Candidates() do
		local root = Util.characterRoot(player)
		if root then
			local p05 = MapConfig.Places.P05
			local lair = MapConfig.Places[CreatureConfig.LairPlace]
			local territory = CreatureConfig.Personalities.Territorial.territoryRadius
			if
				(root.Position - p05.pos).Magnitude <= territory
				or (root.Position - lair.pos).Magnitude <= territory
			then
				return player
			end
		end
	end
	return nil
end

function Behavior.score(brain)
	if brain.id == "CRT_Female" then
		return 0
	end
	local player = brain.target or nearTerritory(brain)
	if player == nil then
		return 0
	end
	-- 9.6 : chaque cran attend le précédent ; un cran par activation
	if os.clock() - brain.ladder.lastStepAt < Intimidation.StepWithin / #Intimidation.Steps then
		return 0
	end
	local factor = if brain.personality then (CreatureConfig.Personalities[brain.personality].intimidation or 1) else 1
	return math.clamp(B.baseScore * factor, 0, 1)
end

function Behavior.start(brain)
	local player = brain.target or nearTerritory(brain)
	if player then
		brain.ai.FamilyBrain:IntimidationStep(brain, player)
	end
end

local _ = { MapConfig, Util, B }

return Behavior
