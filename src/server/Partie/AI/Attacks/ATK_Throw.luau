-- ServerScriptService/AI/Attacks/ATK_Throw (Partie)
-- Section 9.10 : Pierre : 20–120 studs, signal = sifflement de la pierre, 15–30 ; parade : couvert. Chaque attaque a un signal sonore avant les dégâts.
-- Dégâts × difficulté (5.4 : dégâts de la créature).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local ActConfig = require(Config:WaitForChild("ActConfig"))
local CreatureConfig = require(Config:WaitForChild("CreatureConfig"))
local PlayerConfig = require(Config:WaitForChild("PlayerConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local A = CreatureConfig.Attacks.ATK_Throw
local Attack = {}

local function damageFactor(brain)
	return ActConfig.difficulty(brain.services.PartyLoaderService:GetMatchInfo().difficulty).creatureDamage
end

local function randomLimb()
	return PlayerConfig.Limbs[math.random(1, #PlayerConfig.Limbs)]
end

-- cible : un joueur, ou une Part (planche d'une ouverture, lampe)
function Attack.canUse(brain, target)
	local position = if typeof(target) == "Instance" and target:IsA("Player")
		then (Util.characterRoot(target) and Util.characterRoot(target).Position)
		else target.Position
	if position == nil then
		return false
	end
	local d = (position - brain:Position()).Magnitude
	return d >= A.minRange and d <= A.maxRange or not target:IsA("Player")
end

function Attack.run(brain, target)
	local isPlayer = target:IsA("Player")
	local root = if isPlayer then Util.characterRoot(target) else target
	if root == nil then
		return
	end
	local from = brain:Position() + Vector3.new(0, brain.def.height, 0)
	local landing = root.Position
	brain.ai.CreatureAnimator:Play(brain.model, "ThrowOverhand")
	local flight = (landing - from).Magnitude / CreatureConfig.StoneSpeed
	-- signal : sifflement de la pierre, audible avant l'impact
	brain.ai.CreatureAnimator:PlaySoundAt(A.sound, landing)
	task.wait(flight)
	if not isPlayer then
		brain.services.GameStateService:HitBarricade(target)
		brain.services.NoiseService:Emit(
			landing,
			require(Config:WaitForChild("ItemConfig")).Items.ITM_Stone.impactNoise,
			"Impact",
			brain.model
		)
		return
	end
	-- couvert : un obstacle entre le point de lancer et la cible arrête la pierre
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { brain.model }
	local hit = workspace:Raycast(from, root.Position - from, params)
	if hit and not hit.Instance:IsDescendantOf(target.Character) then
		return
	end
	local damage = A.damageMin + math.random() * (A.damageMax - A.damageMin)
	brain.services.HealthService:Damage(target, randomLimb(), damage * damageFactor(brain), brain.model)
end

local _ = { damageFactor, randomLimb, Util, A }

return Attack
