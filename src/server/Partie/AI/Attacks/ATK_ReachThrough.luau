-- ServerScriptService/AI/Attacks/ATK_ReachThrough (Partie)
-- Section 9.10 : Bras par une barricade cassée : 5 studs dans la cabane, signal 0,5 s, saisie ; parade : reclouer, hache. Chaque attaque a un signal sonore avant les dégâts.
-- Dégâts × difficulté (5.4 : dégâts de la créature).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local ActConfig = require(Config:WaitForChild("ActConfig"))
local CreatureConfig = require(Config:WaitForChild("CreatureConfig"))
local PlayerConfig = require(Config:WaitForChild("PlayerConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local A = CreatureConfig.Attacks.ATK_ReachThrough
local Attack = {}

local function damageFactor(brain)
	return ActConfig.difficulty(brain.services.PartyLoaderService:GetMatchInfo().difficulty).creatureDamage
end

local function randomLimb()
	return PlayerConfig.Limbs[math.random(1, #PlayerConfig.Limbs)]
end

function Attack.canUse(_brain, target)
	return target:GetAttribute("grabbedBy") == nil
end

function Attack.run(brain, target)
	brain.ai.CreatureAnimator:Play(brain.model, "ReachThrough")
	task.wait(A.signal)
	-- la saisie elle-même suit les règles de ATK_Grab (10/s, parades)
	local grab = brain.attacks.ATK_Grab
	if grab then
		target:SetAttribute("grabbedBy", nil)
		grab.run(brain, target)
	end
end

local _ = { damageFactor, randomLimb, Util, A }

return Attack
