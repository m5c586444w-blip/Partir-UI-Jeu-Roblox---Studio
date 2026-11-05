-- ServerScriptService/AI/Behaviors/BHV_Avoid (Partie)
-- Section 9.5 : Éviter : feu ou fusée à moins de 40 studs, aube ; à 05 h 50, rentre au repaire.
-- Score de 0 à 1 (interprétation de la colonne « Score élevé quand », à régler en phase B3).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local CreatureConfig = require(Config:WaitForChild("CreatureConfig"))
local MapConfig = require(Config:WaitForChild("MapConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local B = CreatureConfig.Behaviors.BHV_Avoid
local Behavior = {}

local TaggedSet = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("TaggedSet"))
Behavior.urgent = true

local function nearFire(brain)
	for _, fire in TaggedSet.list("FireSource") do
		if fire:IsA("BasePart") then
			local keepAway = fire:GetAttribute("keepAway") or B.fireRange
			if (fire.Position - brain:Position()).Magnitude < keepAway then
				return fire, keepAway
			end
		end
	end
	return nil
end

local function dawn()
	local clock = Util.getMatchState():GetAttribute("clock") or 0
	return Util.getMatchState():GetAttribute("creatureRetreat") == true
		or (clock >= CreatureConfig.DawnRetreatHour and clock < require(Config:WaitForChild("ActConfig")).EndHour)
end

function Behavior.score(brain)
	if dawn() and brain.id ~= "CRT_Female" then
		return 1
	end
	-- 8.1 : la créature reste à plus de 40 studs d'une fusée sauf si elle est enragée
	if nearFire(brain) and not brain.enraged then
		return 1
	end
	return 0
end

function Behavior.step(brain)
	if dawn() and brain.id ~= "CRT_Female" then
		brain:MoveTo(MapConfig.Places.P07a.pos, "Run") -- rentre au repaire
		return
	end
	local fire, keepAway = nearFire(brain)
	if fire then
		local away = (brain:Position() - fire.Position) * Vector3.new(1, 0, 1)
		if away.Magnitude < 1 then
			away = Vector3.new(1, 0, 0)
		end
		brain:MoveTo(fire.Position + away.Unit * keepAway * 1.5, "Run") -- constante (marge)
	end
end

local _ = { MapConfig, Util, B }

return Behavior
