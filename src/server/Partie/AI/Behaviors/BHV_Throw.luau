-- ServerScriptService/AI/Behaviors/BHV_Throw (Partie)
-- Section 9.5 : Lancer : en hauteur, cible à 20–120 studs ; pierres sur les joueurs, les lampes, les planches.
-- Score de 0 à 1 (interprétation de la colonne « Score élevé quand », à régler en phase B3).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local CreatureConfig = require(Config:WaitForChild("CreatureConfig"))
local MapConfig = require(Config:WaitForChild("MapConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local B = CreatureConfig.Behaviors.BHV_Throw
local Behavior = {}

function Behavior.score(brain)
	local t = brain.target
	if t == nil or brain.id == "CRT_Female" then
		return 0
	end
	local root = Util.characterRoot(t)
	local distance = brain:DistanceTo(t)
	if root == nil or distance < B.minDistance or distance > B.maxDistance then
		return 0
	end
	-- « en hauteur » : au-dessus de la cible (DÉFAUT : d'au moins la hauteur de la créature)
	if brain:Position().Y - root.Position.Y < brain.def.height then
		return 0
	end
	local factor = if brain.personality == "Playful" then CreatureConfig.Personalities.Playful.stones else 1
	if brain.memory.shotsTaken >= CreatureConfig.Memory.ShotsToAdapt then
		factor *= CreatureConfig.Memory.ThrowMoreFactor -- 9.8 : « lance plus »
	end
	return math.clamp(B.baseScore * factor, 0, 1)
end

function Behavior.step(brain)
	local t = brain.target
	if t == nil then
		return
	end
	brain:Stop()
	local interval = require(Config:WaitForChild("ActConfig")).Siege.StoneInterval
	if os.clock() - (brain.lastThrowAt or -math.huge) >= interval then
		brain.lastThrowAt = os.clock()
		brain:Attack("ATK_Throw", t)
	end
end

local _ = { MapConfig, Util, B }

return Behavior
