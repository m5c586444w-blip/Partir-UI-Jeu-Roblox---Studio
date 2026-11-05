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

-- 19.5 (C10) : erreur de visée = 3 % de la distance, réduite en Difficile et Cauchemar
local function aimError(brain, distance)
	local difficulty = brain.services.PartyLoaderService:GetMatchInfo().difficulty
	local radius = distance * A.aimError * (A.aimErrorFactor[difficulty] or 1)
	local angle = math.random() * math.pi * 2
	local r = radius * math.sqrt(math.random())
	return Vector3.new(math.cos(angle) * r, 0, math.sin(angle) * r)
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
	if isPlayer then
		landing += aimError(brain, (landing - from).Magnitude)
	end
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
	-- la pierre file vers le point visé (au lâcher) : un joueur qui a bougé l'esquive ;
	-- couvert : un obstacle entre le point de lancer et la cible arrête la pierre
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { brain.model }
	local hit = workspace:Raycast(from, (landing - from).Unit * A.maxRange, params)
	if hit == nil or target.Character == nil or not hit.Instance:IsDescendantOf(target.Character) then
		return
	end
	local damage = A.damageMin + math.random() * (A.damageMax - A.damageMin)
	-- 19.5 (C2) : une pierre ne cause jamais d'hémorragie grave
	brain.services.HealthService:Damage(
		target,
		randomLimb(),
		damage * damageFactor(brain),
		brain.model,
		nil,
		PlayerConfig.BleedOnDamage.StoneMax
	)
end

local _ = { damageFactor, randomLimb, Util, A }

return Attack
