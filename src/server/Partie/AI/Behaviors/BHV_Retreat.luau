-- ServerScriptService/AI/Behaviors/BHV_Retreat (Partie)
-- Section 9.5 : Fuir blessée : 15 % de PV perdus en 10 s, fusée, bombe anti-ours ; revient enragée.
-- Score de 0 à 1 (interprétation de la colonne « Score élevé quand », à régler en phase B3).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local CreatureConfig = require(Config:WaitForChild("CreatureConfig"))
local MapConfig = require(Config:WaitForChild("MapConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local B = CreatureConfig.Behaviors.BHV_Retreat
local Behavior = {}

Behavior.urgent = true

function Behavior.score(brain)
	if (brain.fleeUntil or 0) > os.clock() then
		return 1
	end
	if brain:RecentDamage(B.window) >= brain.maxHealth * B.healthLost then
		return 1
	end
	if brain.ai.TensionDirector:IsPaused() and brain.behaviorId == "BHV_Retreat" then
		return B.baseScore
	end
	return 0
end

function Behavior.start(brain)
	brain.retreatUntil = os.clock() + B.minDuration + math.random() * (B.maxDuration - B.minDuration)
	-- vers la forêt dense ou les tunnels (DÉFAUT : le plus proche des deux)
	local forest = MapConfig.Places.P04.zone
	local forestCenter =
		Vector3.new((forest.minX + forest.maxX) / 2, MapConfig.Places.P04.yLow, (forest.minZ + forest.maxZ) / 2)
	local tunnels = MapConfig.Places.P07a.pos
	local here = brain:Position()
	brain:MoveTo(
		if (forestCenter - here).Magnitude < (tunnels - here).Magnitude then forestCenter else tunnels,
		"Sprint"
	)
end

function Behavior.step(brain)
	if os.clock() >= (brain.retreatUntil or 0) then
		brain.enraged = true -- revient enragée
		brain.fleeUntil = nil
		brain.damageLog = {}
	end
end

local _ = { MapConfig, Util, B }

return Behavior
