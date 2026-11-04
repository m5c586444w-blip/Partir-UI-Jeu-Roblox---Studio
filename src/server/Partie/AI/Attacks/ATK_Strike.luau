-- ServerScriptService/AI/Attacks/ATK_Strike (Partie)
-- Section 9.10 : Coup : portée 7, signal 0,6 s (grognement), 35 sur un membre, recul. Chaque attaque a un signal sonore avant les dégâts.
-- Dégâts × difficulté (5.4 : dégâts de la créature).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local ActConfig = require(Config:WaitForChild("ActConfig"))
local CreatureConfig = require(Config:WaitForChild("CreatureConfig"))
local PlayerConfig = require(Config:WaitForChild("PlayerConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local A = CreatureConfig.Attacks.ATK_Strike
local Attack = {}

local function damageFactor(brain)
	return ActConfig.difficulty(brain.services.PartyLoaderService:GetMatchInfo().difficulty).creatureDamage
end

local function randomLimb()
	return PlayerConfig.Limbs[math.random(1, #PlayerConfig.Limbs)]
end

function Attack.canUse(brain, target)
	return brain:DistanceTo(target) <= A.range
end

function Attack.run(brain, target)
	brain.ai.CreatureAnimator:PlaySoundAt(A.sound, brain:Position())
	brain.ai.CreatureAnimator:Play(brain.model, "StrikeLeft")
	task.wait(A.signal)
	if brain:DistanceTo(target) > A.range then
		return -- esquive
	end
	brain.services.HealthService:Damage(target, randomLimb(), A.damage * damageFactor(brain), brain.model)
	local root = Util.characterRoot(target)
	if root and A.knockback then
		local push = (root.Position - brain:Position()) * Vector3.new(1, 0, 1)
		if push.Magnitude > 0 then
			root.AssemblyLinearVelocity += push.Unit * CreatureConfig.KnockbackForce
		end
	end
end

local _ = { damageFactor, randomLimb, Util, A }

return Attack
