-- ServerScriptService/AI/Behaviors/BHV_Stalk (Partie)
-- Section 9.5 : Traquer : cible choisie, pas encore isolée ; suit à 50–80 studs sans être vue.
-- Score de 0 à 1 (interprétation de la colonne « Score élevé quand », à régler en phase B3).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local CreatureConfig = require(Config:WaitForChild("CreatureConfig"))
local MapConfig = require(Config:WaitForChild("MapConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local B = CreatureConfig.Behaviors.BHV_Stalk
local Behavior = {}

function Behavior.score(brain)
	local t = brain.target
	if brain.id == "CRT_Female" or t == nil then
		return 0
	end
	if brain.ai.FamilyBrain:Isolation(t) >= 1 then
		return 0 -- isolée : place à l'attaque
	end
	return B.baseScore
end

function Behavior.step(brain)
	local t = brain.target
	local root = t and Util.characterRoot(t)
	if root == nil then
		return
	end
	local away = (brain:Position() - root.Position) * Vector3.new(1, 0, 1)
	if away.Magnitude < 1 then
		away = Vector3.new(0, 0, 1)
	end
	local distance = (B.minDistance + B.maxDistance) / 2
	-- 9.4 : piste de sang suivie au pas
	brain:MoveTo(root.Position + away.Unit * distance, if t:GetAttribute("bleed") ~= "None" then "Walk" else "Sneak")
end

local _ = { MapConfig, Util, B }

return Behavior
