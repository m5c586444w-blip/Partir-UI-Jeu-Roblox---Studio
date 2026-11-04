-- ServerScriptService/AI/Attacks/ATK_Execution (Partie)
-- Section 9.10 : Mise à mort (Alpha, joueur à terre, profil Restricted seulement) : portée 3, signal 1,5 s ; noir à l'instant de la mort. Chaque attaque a un signal sonore avant les dégâts.
-- Dégâts × difficulté (5.4 : dégâts de la créature).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local ActConfig = require(Config:WaitForChild("ActConfig"))
local CreatureConfig = require(Config:WaitForChild("CreatureConfig"))
local PlayerConfig = require(Config:WaitForChild("PlayerConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local A = CreatureConfig.Attacks.ATK_Execution
local Attack = {}

local function damageFactor(brain)
	return ActConfig.difficulty(brain.services.PartyLoaderService:GetMatchInfo().difficulty).creatureDamage
end

local function randomLimb()
	return PlayerConfig.Limbs[math.random(1, #PlayerConfig.Limbs)]
end

function Attack.canUse(brain, target)
	local profile = require(Config:WaitForChild("GoreConfig")).Profile
	return brain.id == A.creature
		and profile == A.profile
		and target:GetAttribute("isDowned") == true
		and brain:DistanceTo(target) <= A.range
end

function Attack.run(brain, target)
	brain.ai.CreatureAnimator:Play(brain.model, "Execution")
	task.wait(A.signal)
	if target:GetAttribute("isDowned") and brain:DistanceTo(target) <= A.range then
		target:SetAttribute("blackoutAt", workspace:GetServerTimeNow()) -- 11.2 : noir à l'instant de la mort
		brain.services.HealthService:Kill(target, "Execution")
	end
end

local _ = { damageFactor, randomLimb, Util, A }

return Attack
