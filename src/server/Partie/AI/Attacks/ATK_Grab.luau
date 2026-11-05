-- ServerScriptService/AI/Attacks/ATK_Grab (Partie)
-- Section 9.10 : Saisie : portée 6, signal 0,4 s ; 10/s tant que tenu ; traîné après 3 s. Chaque attaque a un signal sonore avant les dégâts.
-- Dégâts × difficulté (5.4 : dégâts de la créature).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local ActConfig = require(Config:WaitForChild("ActConfig"))
local CreatureConfig = require(Config:WaitForChild("CreatureConfig"))
local PlayerConfig = require(Config:WaitForChild("PlayerConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local A = CreatureConfig.Attacks.ATK_Grab
local Attack = {}

local function damageFactor(brain)
	return ActConfig.difficulty(brain.services.PartyLoaderService:GetMatchInfo().difficulty).creatureDamage
end

local function randomLimb()
	return PlayerConfig.Limbs[math.random(1, #PlayerConfig.Limbs)]
end

function Attack.canUse(brain, target)
	return brain:DistanceTo(target) <= A.range and target:GetAttribute("grabbedBy") == nil
end

function Attack.run(brain, target)
	brain.ai.CreatureAnimator:Play(brain.model, "Grab")
	task.wait(A.signal)
	if brain:DistanceTo(target) > A.range then
		return
	end
	target:SetAttribute("grabbedBy", brain.id)
	brain.grabbed = target
	brain.grabHits = 0
	local heldFor = 0
	local step = 1 / CreatureConfig.Rates.Brain
	-- parade : un coéquipier frappe (hache 1 coup, machette 2), bombe, tir (FamilyBrain relâche)
	while
		brain.grabbed == target
		and target:GetAttribute("grabbedBy") == brain.id
		and brain.services.HealthService:IsUp(target)
	do
		brain.services.HealthService:Damage(
			target,
			"Torso",
			A.damagePerSecond * step * damageFactor(brain),
			brain.model
		)
		heldFor += step
		-- 19.5 (C2) : saisie tenue plus de 2 s → hémorragie légère
		if heldFor > PlayerConfig.BleedOnDamage.GrabLightAfter then
			brain.services.HealthService:StartBleed(target, "Light")
		end
		if heldFor >= A.dragAfter then
			break -- BHV_Drag prend le relais
		end
		local root, creatureRoot = Util.characterRoot(target), brain.root
		if root and creatureRoot and brain:HasBody() then
			root.CFrame = creatureRoot.CFrame * CFrame.new(0, 0, -A.range / 2)
		end
		task.wait(step)
	end
	if brain.grabbed == target and heldFor < A.dragAfter then
		target:SetAttribute("grabbedBy", nil)
	end
	brain.grabbed = nil
end

local _ = { damageFactor, randomLimb, Util, A }

return Attack
