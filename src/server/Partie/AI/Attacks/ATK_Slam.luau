-- ServerScriptService/AI/Attacks/ATK_Slam (Partie)
-- Section 9.10 : Frappe au sol (joueur à terre) : portée 5, signal 1,0 s, 60 ; parade : relever le joueur avant. Chaque attaque a un signal sonore avant les dégâts.
-- Dégâts × difficulté (5.4 : dégâts de la créature).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local ActConfig = require(Config:WaitForChild("ActConfig"))
local CreatureConfig = require(Config:WaitForChild("CreatureConfig"))
local PlayerConfig = require(Config:WaitForChild("PlayerConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local A = CreatureConfig.Attacks.ATK_Slam
local Attack = {}

local function damageFactor(brain)
	return ActConfig.difficulty(brain.services.PartyLoaderService:GetMatchInfo().difficulty).creatureDamage
end

local function randomLimb()
	return PlayerConfig.Limbs[math.random(1, #PlayerConfig.Limbs)]
end

function Attack.canUse(brain, target)
	return target:GetAttribute("isDowned") == true and brain:DistanceTo(target) <= A.range
end

function Attack.run(brain, target)
	brain.ai.CreatureAnimator:Play(brain.model, "Slam")
	brain.ai.CreatureAnimator:PlaySoundAt("SFX_Growl_Close", brain:Position())
	task.wait(A.signal)
	if target:GetAttribute("isDowned") and brain:DistanceTo(target) <= A.range then
		brain.services.HealthService:Damage(target, "Torso", A.damage * damageFactor(brain), brain.model)
	end
end

local _ = { damageFactor, randomLimb, Util, A }

return Attack
