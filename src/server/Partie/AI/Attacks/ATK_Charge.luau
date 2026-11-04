-- ServerScriptService/AI/Attacks/ATK_Charge (Partie)
-- Section 9.10 : Charge : départ à 15–40 studs, signal 0,8 s (cri + pas), 40 + à terre 2 s ; aussi la fausse charge de 9.6. Chaque attaque a un signal sonore avant les dégâts.
-- Dégâts × difficulté (5.4 : dégâts de la créature).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local ActConfig = require(Config:WaitForChild("ActConfig"))
local CreatureConfig = require(Config:WaitForChild("CreatureConfig"))
local PlayerConfig = require(Config:WaitForChild("PlayerConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local A = CreatureConfig.Attacks.ATK_Charge
local Attack = {}

local function damageFactor(brain)
	return ActConfig.difficulty(brain.services.PartyLoaderService:GetMatchInfo().difficulty).creatureDamage
end

local function randomLimb()
	return PlayerConfig.Limbs[math.random(1, #PlayerConfig.Limbs)]
end

function Attack.canUse(brain, target)
	local d = brain:DistanceTo(target)
	return d >= A.minRange and d <= A.maxRange
end

-- fake = fausse charge (9.6, cran 7) : s'arrête à 4–8 studs, puis repart
function Attack.run(brain, target, fake)
	brain.ai.CreatureAnimator:PlaySoundAt(A.sound, brain:Position())
	brain.ai.CreatureAnimator:Play(brain.model, "ChargeStart")
	task.wait(A.signal)
	local intimidation = CreatureConfig.Intimidation
	local stopAt = if fake
		then intimidation.FakeChargeStopMin
			+ math.random() * (intimidation.FakeChargeStopMax - intimidation.FakeChargeStopMin)
		else CreatureConfig.Attacks.ATK_Strike.range / 2
	local started = os.clock()
	local limit = A.maxRange / CreatureConfig.Gaits.Sprint.speed * 2
	while os.clock() - started < limit do
		local root = Util.characterRoot(target)
		if root == nil or (brain.fleeUntil or 0) > os.clock() then
			return -- parade : fusée, lampe puissante, bombe anti-ours
		end
		brain:MoveTo(root.Position, "Sprint")
		if brain:DistanceTo(target) <= stopAt then
			break
		end
		task.wait(1 / CreatureConfig.Rates.Brain)
	end
	brain:Stop()
	if fake then
		brain.ai.CreatureAnimator:Play(brain.model, "ChargeStopBluff")
		return
	end
	if brain:DistanceTo(target) <= CreatureConfig.Attacks.ATK_Strike.range then
		brain.services.HealthService:Damage(target, "Torso", A.damage * damageFactor(brain), brain.model)
		local humanoid = target.Character and target.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.PlatformStand = true -- à terre 2 s (renversé)
			task.delay(A.knockdown, function()
				if not target:GetAttribute("isDowned") then
					humanoid.PlatformStand = false
				end
			end)
		end
	end
end

local _ = { damageFactor, randomLimb, Util, A }

return Attack
