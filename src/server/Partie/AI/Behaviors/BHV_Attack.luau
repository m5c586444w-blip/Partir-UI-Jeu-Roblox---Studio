-- ServerScriptService/AI/Behaviors/BHV_Attack (Partie)
-- Section 9.5 : Attaquer : cible isolée, directeur d'accord ; une attaque de la table 9.10.
-- Score de 0 à 1 (interprétation de la colonne « Score élevé quand », à régler en phase B3).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local CreatureConfig = require(Config:WaitForChild("CreatureConfig"))
local MapConfig = require(Config:WaitForChild("MapConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local B = CreatureConfig.Behaviors.BHV_Attack
local Behavior = {}

local Attacks = CreatureConfig.Attacks

function Behavior.score(brain)
	local t = brain.target
	if t == nil or brain.id == "CRT_Female" then
		return 0
	end
	if not brain.ai.TensionDirector:AllowAttack(brain, t) then
		return 0
	end
	local downed = t:GetAttribute("isDowned") == true
	if not downed and brain.ai.FamilyBrain:Isolation(t) < 1 and not brain.ai.TensionDirector:IsFinalAssault() then
		return 0
	end
	if (brain.vigilance[t] or 0) < CreatureConfig.Vision.TargetAt then
		return 0
	end
	return B.baseScore * brain.ai.FamilyBrain:AttackFactor(brain)
end

function Behavior.step(brain)
	local t = brain.target
	local root = t and Util.characterRoot(t)
	if root == nil then
		return
	end
	local distance = brain:DistanceTo(t)
	if t:GetAttribute("isDowned") then
		local profile = require(Config:WaitForChild("GoreConfig")).Profile
		if
			brain.id == Attacks.ATK_Execution.creature
			and profile == Attacks.ATK_Execution.profile
			and distance <= Attacks.ATK_Execution.range
		then
			brain:Attack("ATK_Execution", t)
		elseif distance <= Attacks.ATK_Slam.range then
			brain:Attack("ATK_Slam", t)
		end
	elseif distance <= Attacks.ATK_Grab.range then
		brain:Attack("ATK_Grab", t)
	elseif distance <= Attacks.ATK_Strike.range then
		brain:Attack("ATK_Strike", t)
	elseif distance >= Attacks.ATK_Charge.minRange and distance <= Attacks.ATK_Charge.maxRange then
		brain:Attack("ATK_Charge", t)
	end
	brain:MoveTo(root.Position, "Run")
end

local _ = { MapConfig, Util, B }

return Behavior
