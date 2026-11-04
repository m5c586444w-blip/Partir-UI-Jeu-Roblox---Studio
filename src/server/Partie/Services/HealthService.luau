-- ServerScriptService/Services/HealthService (Partie)
-- Section 7.3 : santé par membre, sang, hémorragies, à terre, relever, mort définitive, ragdoll.
-- Attributs du joueur (16.3) : hpHead, hpTorso, hpArmL, hpArmR, hpLegL, hpLegR, blood,
-- bleed ("None", "Light", "Heavy"), splinted, isDowned, downedEnd (heure serveur), isDead.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local PlayerConfig = require(Config:WaitForChild("PlayerConfig"))
local ActConfig = require(Config:WaitForChild("ActConfig"))
local GoreConfig = require(Config:WaitForChild("GoreConfig"))
local CreatureConfig = require(Config:WaitForChild("CreatureConfig"))
local LoreConfig = require(Config:WaitForChild("LoreConfig"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Signal = require(Shared:WaitForChild("Signal"))

local HealthService = {}

HealthService.Damaged = Signal.new() -- (player, limb, amount, source)
HealthService.Downed = Signal.new() -- (player)
HealthService.Revived = Signal.new() -- (player, rescuer)
HealthService.Died = Signal.new() -- (player, cause)

-- 9.4 : points de piste laissés par une hémorragie { position, time }
HealthService.BloodTrail = {}

local services = nil
local state = {} -- [Player] = { downedLimb, lastTrail, revivePrompt, downedThread }

local function attr(limb)
	return "hp" .. limb
end

local function maxHealth(player, limb)
	local role = player:GetAttribute("role")
	local override = PlayerConfig.RoleLimbHealth[role]
	return (override and override[limb]) or PlayerConfig.LimbHealth[limb]
end

local function fraction(player, limb)
	return (player:GetAttribute(attr(limb)) or 0) / maxHealth(player, limb)
end

function HealthService:GetFraction(player, limb)
	return fraction(player, limb)
end

function HealthService:IsAlive(player)
	return player:GetAttribute("isDead") ~= true and player:GetAttribute("hpTorso") ~= nil
end

function HealthService:IsUp(player)
	return self:IsAlive(player) and player:GetAttribute("isDowned") ~= true
end

-- 7.3 : membre sous 30 %
function HealthService:IsLow(player, limb)
	return fraction(player, limb) < PlayerConfig.LowLimbThreshold
end

-- 7.2 : boiter (jambe < 30 %, sauf attelle)
function HealthService:IsLimping(player)
	if player:GetAttribute("splinted") then
		return false
	end
	return self:IsLow(player, "LegL") or self:IsLow(player, "LegR")
end

function HealthService:Setup(player)
	for _, limb in PlayerConfig.Limbs do
		player:SetAttribute(attr(limb), maxHealth(player, limb))
	end
	player:SetAttribute("blood", PlayerConfig.Blood.Max)
	player:SetAttribute("bleed", "None")
	player:SetAttribute("splinted", false)
	player:SetAttribute("isDowned", false)
	player:SetAttribute("downedEnd", nil)
	player:SetAttribute("isDead", false)
	state[player] = { lastTrail = nil }
end

-- 11.5 : ragdoll — chaque Motor6D devient un BallSocketConstraint ; ancré après 10 s immobile
local function ragdoll(character)
	for _, motor in character:GetDescendants() do
		if motor:IsA("Motor6D") and motor.Part0 and motor.Part1 then
			local a0 = Instance.new("Attachment")
			a0.CFrame = motor.C0
			a0.Parent = motor.Part0
			local a1 = Instance.new("Attachment")
			a1.CFrame = motor.C1
			a1.Parent = motor.Part1
			local socket = Instance.new("BallSocketConstraint")
			socket.Attachment0 = a0
			socket.Attachment1 = a1
			socket.Parent = motor.Parent
			motor.Enabled = false
		end
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	end
	task.spawn(function()
		local root = character:FindFirstChild("HumanoidRootPart")
		local still = 0
		local step = 1
		while character.Parent ~= nil and root and still < GoreConfig.Ragdoll.AnchorAfterStill do
			task.wait(step)
			if root.AssemblyLinearVelocity.Magnitude < 0.5 then
				still += step
			else
				still = 0
			end
		end
		for _, part in character:GetDescendants() do
			if part:IsA("BasePart") then
				part.Anchored = true
			end
		end
	end)
end

local function clearRevivePrompt(player)
	local s = state[player]
	if s and s.revivePrompt then
		s.revivePrompt:Destroy()
		s.revivePrompt = nil
	end
	if s and s.downedThread then
		task.cancel(s.downedThread)
		s.downedThread = nil
	end
end

function HealthService:Kill(player, cause)
	if player:GetAttribute("isDead") then
		return
	end
	clearRevivePrompt(player)
	player:SetAttribute("isDead", true)
	player:SetAttribute("isDowned", false)
	player:SetAttribute("downedEnd", nil)
	local character = player.Character
	if character then
		local root = character:FindFirstChild("HumanoidRootPart")
		-- 7.3 : l'inventaire tombe dans un sac ramassable
		if root and services.InventoryService then
			services.InventoryService:DropAllAsBag(player, root.Position)
		end
		character:AddTag("Corpse")
		ragdoll(character)
	end
	self.Died:Fire(player, cause)
end

function HealthService:Revive(player, rescuer)
	if not player:GetAttribute("isDowned") or player:GetAttribute("isDead") then
		return
	end
	local s = state[player]
	clearRevivePrompt(player)
	-- 7.3 : le joueur revient avec 20 % sur le membre touché
	local limb = s and s.downedLimb
	if limb == "Blood" then
		player:SetAttribute("blood", PlayerConfig.ReviveBlood)
	elseif limb ~= nil then
		player:SetAttribute(attr(limb), maxHealth(player, limb) * PlayerConfig.Downed.ReviveLimbFraction)
	end
	player:SetAttribute("isDowned", false)
	player:SetAttribute("downedEnd", nil)
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.PlatformStand = false
	end
	self.Revived:Fire(player, rescuer)
end

function HealthService:SetDowned(player, limb)
	if player:GetAttribute("isDowned") or player:GetAttribute("isDead") then
		return
	end
	local info = services.PartyLoaderService:GetMatchInfo()
	local duration = ActConfig.difficulty(info.difficulty).downedTime
	local s = state[player]
	s.downedLimb = limb
	player:SetAttribute("isDowned", true)
	player:SetAttribute("downedEnd", workspace:GetServerTimeNow() + duration)
	self.Downed:Fire(player)

	-- relever : un coéquipier maintient l'invite 6 s (3 s pour la Médecin)
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if root and services.InteractionService then
		s.revivePrompt = services.InteractionService:CreatePrompt(root, {
			action = LoreConfig.Prompts.Revive,
			holdDuration = PlayerConfig.Downed.ReviveTime,
			roleHoldDuration = PlayerConfig.Downed.RoleReviveTime,
			canUse = function(rescuer)
				return rescuer ~= player and HealthService:IsUp(rescuer)
			end,
			onTriggered = function(rescuer)
				HealthService:Revive(player, rescuer)
			end,
		})
	end
	s.downedThread = task.delay(duration, function()
		s.downedThread = nil
		HealthService:Kill(player, "DownedTimeout")
	end)
end

local function setBleed(player, level)
	local order = { None = 0, Light = 1, Heavy = 2 }
	if order[level] > order[player:GetAttribute("bleed") or "None"] then
		player:SetAttribute("bleed", level)
	end
end

function HealthService:StartBleed(player, level)
	if self:IsAlive(player) then
		setBleed(player, level)
	end
end

-- bandage : arrête une hémorragie légère ; grave → légère. Médecin avec trousse : arrête la grave.
function HealthService:TreatBleed(player, canStopHeavy)
	local bleed = player:GetAttribute("bleed")
	if bleed == "Heavy" then
		player:SetAttribute("bleed", if canStopHeavy then "None" else "Light")
	elseif bleed == "Light" then
		player:SetAttribute("bleed", "None")
	end
end

-- membre le plus abîmé (proportion), voir PlayerConfig.HealTarget
function HealthService:MostDamagedLimb(player)
	local worst, worstFraction = PlayerConfig.Limbs[1], math.huge
	for _, limb in PlayerConfig.Limbs do
		local f = fraction(player, limb)
		if f < worstFraction then
			worst, worstFraction = limb, f
		end
	end
	return worst
end

function HealthService:Heal(player, limb, amount)
	limb = limb or self:MostDamagedLimb(player)
	local value = math.min(maxHealth(player, limb), (player:GetAttribute(attr(limb)) or 0) + amount)
	player:SetAttribute(attr(limb), value)
end

function HealthService:Splint(player)
	player:SetAttribute("splinted", true)
end

-- dégâts sur un membre ; `bleed` optionnel ("Light" / "Heavy")
function HealthService:Damage(player, limb, amount, source, bleed)
	if not self:IsAlive(player) or amount <= 0 then
		return
	end
	if player:GetAttribute("isDowned") then
		if PlayerConfig.Technical.DownedDamageKills then
			self:Kill(player, source)
		end
		return
	end
	local value = math.max(0, (player:GetAttribute(attr(limb)) or 0) - amount)
	player:SetAttribute(attr(limb), value)
	if bleed then
		setBleed(player, bleed)
	elseif PlayerConfig.BleedOnDamage.HeavyAt and amount >= PlayerConfig.BleedOnDamage.HeavyAt then
		setBleed(player, "Heavy")
	elseif PlayerConfig.BleedOnDamage.LightAt and amount >= PlayerConfig.BleedOnDamage.LightAt then
		setBleed(player, "Light")
	end
	if player:GetAttribute("splinted") and (limb == "LegL" or limb == "LegR") then
		player:SetAttribute("splinted", false)
	end
	self.Damaged:Fire(player, limb, amount, source)
	-- 7.3 : à terre quand la tête ou le torse tombe à 0
	if value <= 0 and (limb == "Head" or limb == "Torso") then
		self:SetDowned(player, limb)
	end
end

local function rootOf(player)
	local character = player.Character
	return character and character:FindFirstChild("HumanoidRootPart")
end

local function tick(dt)
	for _, player in Players:GetPlayers() do
		if HealthService:IsAlive(player) then
			local bleed = player:GetAttribute("bleed")
			if bleed ~= "None" then
				local rate = if bleed == "Heavy"
					then PlayerConfig.Blood.HeavyBleedPerSecond
					else PlayerConfig.Blood.LightBleedPerSecond
				local blood = math.max(0, player:GetAttribute("blood") - rate * dt)
				player:SetAttribute("blood", blood)
				if blood <= 0 then
					HealthService:Kill(player, "Blood")
				elseif blood < PlayerConfig.Blood.DownedBelow then
					HealthService:SetDowned(player, "Blood")
				end
				-- 9.4 : un point de piste tous les n studs, actif n secondes
				local smell = CreatureConfig.Smell
				local root = rootOf(player)
				if smell and smell.TrailSpacing and root then
					local s = state[player]
					if s.lastTrail == nil or (root.Position - s.lastTrail).Magnitude >= smell.TrailSpacing then
						s.lastTrail = root.Position
						table.insert(HealthService.BloodTrail, { position = root.Position, time = os.clock() })
					end
				end
			end
		end
	end
	-- purge des points de piste expirés
	local smell = CreatureConfig.Smell
	if smell and smell.TrailLifetime then
		local now = os.clock()
		local trail = HealthService.BloodTrail
		while #trail > 0 and now - trail[1].time > smell.TrailLifetime do
			table.remove(trail, 1)
		end
	end
end

function HealthService:Init(allServices)
	services = allServices
end

function HealthService:Start()
	services.CharacterService.Spawned:Connect(function(player)
		HealthService:Setup(player)
	end)
	Players.PlayerRemoving:Connect(function(player)
		clearRevivePrompt(player)
		state[player] = nil
	end)
	task.spawn(function()
		local step = PlayerConfig.Technical.Tick
		while true do
			task.wait(step)
			tick(step)
		end
	end)
end

return HealthService
