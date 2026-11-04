-- ServerScriptService/AI/Behaviors/BHV_Mimic (Partie)
-- Section 9.5 : Imiter : éclaireur, une cible s'éloigne du groupe ; rejoue un son préenregistré (9.8).
-- Score de 0 à 1 (interprétation de la colonne « Score élevé quand », à régler en phase B3).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local CreatureConfig = require(Config:WaitForChild("CreatureConfig"))
local MapConfig = require(Config:WaitForChild("MapConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local B = CreatureConfig.Behaviors.BHV_Mimic
local Behavior = {}

function Behavior.score(brain)
	if brain.def.role ~= "Scout" or brain.target == nil then
		return 0
	end
	if
		os.clock() - (brain.lastMimicAt or -math.huge)
		< B.minDuration * CreatureConfig.Technical.MimicCooldownFactor
	then
		return 0
	end
	local isolation = brain.ai.FamilyBrain:Isolation(brain.target)
	local factor = if brain.personality == "Playful" then CreatureConfig.Personalities.Playful.mimic else 1
	return math.clamp(isolation * B.baseScore * factor, 0, 1)
end

function Behavior.start(brain)
	brain.lastMimicAt = os.clock()
	brain:Stop()
	brain.ai.MimicService:Play(brain, brain.target)
end

local _ = { MapConfig, Util, B }

return Behavior
