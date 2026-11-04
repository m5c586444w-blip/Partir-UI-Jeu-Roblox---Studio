-- ServerScriptService/AI/Behaviors/BHV_Observe (Partie)
-- Section 9.5 : Observer : tension basse, cible inconsciente ; se poste à 40–90 studs derrière un tronc.
-- Score de 0 à 1 (interprétation de la colonne « Score élevé quand », à régler en phase B3).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local CreatureConfig = require(Config:WaitForChild("CreatureConfig"))
local MapConfig = require(Config:WaitForChild("MapConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local B = CreatureConfig.Behaviors.BHV_Observe
local Behavior = {}

local function target(brain)
	return brain.target
end

function Behavior.score(brain)
	local t = target(brain)
	if brain.id == "CRT_Female" or t == nil then
		return 0
	end
	if brain.ai.TensionDirector:IsPaused() then
		return 1 -- 9.12 : pic → les créatures passent en Observer ou Fuir
	end
	-- fuit si éclairée ou approchée à 25 studs
	if brain.litAt and os.clock() - brain.litAt < B.minDuration then
		return 0
	end
	if brain:DistanceTo(t) < B.fleeIfApproached then
		return 0
	end
	return B.baseScore * (1 - brain.ai.TensionDirector:Intensity() / 100)
end

function Behavior.step(brain)
	local t = target(brain)
	local root = t and Util.characterRoot(t)
	if root == nil then
		return
	end
	local here = brain:Position()
	local away = (here - root.Position) * Vector3.new(1, 0, 1)
	if away.Magnitude < 1 then
		away = Vector3.new(1, 0, 0)
	end
	local distance = (B.minDistance + B.maxDistance) / 2
	brain:MoveTo(root.Position + away.Unit * distance, "Sneak")
	brain:FaceTowards(root.Position)
end

local _ = { MapConfig, Util, B }

return Behavior
