-- ServerScriptService/Services/WeaponService (Partie)
-- Sections 8.2 et 16.3 : validation des tirs (origine à moins de 5 studs de la tête, cadence,
-- munitions), dégâts sur la créature (corps / tête), tir allié en Difficile et Cauchemar,
-- rechargement balle par balle interruptible, mêlée.
-- Créatures : modèles tagués « Creature » ; un coup est signalé par CreatureHit (l'IA applique les PV).
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local ActConfig = require(Config:WaitForChild("ActConfig"))
local PlayerConfig = require(Config:WaitForChild("PlayerConfig"))
local WeaponConfig = require(Config:WaitForChild("WeaponConfig"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local NoiseTypes = require(Shared:WaitForChild("NoiseTypes"))
local RateLimiter = require(Shared:WaitForChild("RateLimiter"))
local Signal = require(Shared:WaitForChild("Signal"))
local Util = require(Shared:WaitForChild("Util"))

local WeaponService = {}

-- (creatureModel, damage, shooter, weaponId, isHead, hitPart) ; extra = { blind, flee, grabRelease }
WeaponService.CreatureHit = Signal.new()
WeaponService.Fired = Signal.new() -- (player, weaponId, origin)

local services = nil
local lastShot = {} -- [Player] = os.clock()
local reloading = {} -- [Player] = thread

-- DÉFAUT : portée maximale d'un rayon de tir (la diagonale de la carte)
local MAX_RANGE = WeaponConfig.Weapons.WPN_Rifle.noise

local function heldWeapon(player)
	local entry = services.InventoryService:Selected(player)
	if entry and WeaponConfig.Weapons[entry.id] then
		return entry, WeaponConfig.Weapons[entry.id]
	end
	return nil
end

local function creatureFrom(part)
	local node = part
	while node and node ~= workspace do
		if CollectionService:HasTag(node, "Creature") then
			return node
		end
		node = node.Parent
	end
	return nil
end

local function playerFrom(part)
	local model = part:FindFirstAncestorOfClass("Model")
	return model and Players:GetPlayerFromCharacter(model)
end

local function friendlyFireOn()
	local info = services.PartyLoaderService:GetMatchInfo()
	return ActConfig.difficulty(info.difficulty).friendlyFire
end

-- RaycastParams du tireur : construits une fois par personnage (8 plombs par tir au fusil à pompe)
local shooterParams = setmetatable({}, { __mode = "k" })
local function cast(shooter, origin, direction, range)
	local character = shooter.Character
	local params = character and shooterParams[character]
	if params == nil then
		params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = { character }
		if character then
			shooterParams[character] = params
		end
	end
	return workspace:Raycast(origin, direction.Unit * range, params)
end

-- `shot` : table propre à un tir (plusieurs plombs) ; un coéquipier à terre n'est pénalisé qu'une fois par tir
local function applyHit(shooter, weaponId, weapon, result, creatureDamage, friendlyDamage, shot)
	if result == nil then
		return
	end
	local creature = creatureFrom(result.Instance)
	if creature then
		local isHead = result.Instance.Name == "Head"
		local damage = creatureDamage
		if weapon.damageHead and isHead then
			damage = weapon.damageHead
		end
		WeaponService.CreatureHit:Fire(creature, damage, shooter, weaponId, isHead, result.Instance, {
			blind = weapon.blindDuration,
			flee = weapon.creatureFleeDuration,
			grabReleaseHits = weapon.grabReleaseHits,
		})
		return
	end
	local victim = playerFrom(result.Instance)
	if victim and victim ~= shooter and friendlyFireOn() then
		-- 19.6 (C3) : à terre, un tir allié retire 10 s une seule fois par tir, quel que soit le nombre de plombs
		if victim:GetAttribute("isDowned") and shot then
			if shot[victim] then
				return
			end
			shot[victim] = true
		end
		-- 8.2 : tir allié (torse) ; 19.6 (C14) : lance-fusées = brûlure, jamais d'hémorragie grave
		local maxBleed = if weapon.burnPerSecond then "Light" else nil
		services.HealthService:Damage(victim, "Torso", friendlyDamage, shooter, nil, maxBleed)
		if weapon.burnPerSecond then
			task.spawn(function()
				for _ = 1, weapon.burnDuration do
					task.wait(1) -- constante (une brûlure par seconde)
					services.HealthService:Damage(victim, "Torso", weapon.burnPerSecond, shooter, nil, "Light", "Burn")
				end
			end)
		end
	end
end

local function cancelReload(player)
	local thread = reloading[player]
	if thread then
		task.cancel(thread)
		reloading[player] = nil
		player:SetAttribute("isReloading", false)
	end
end

local function publishAmmo(player)
	local entry, weapon = heldWeapon(player)
	if entry and weapon.ammo then
		player:SetAttribute("ammo", entry.ammo or 0)
		player:SetAttribute("ammoReserve", services.InventoryService:Count(player, "AMMO_" .. entry.id))
	else
		player:SetAttribute("ammo", nil)
		player:SetAttribute("ammoReserve", nil)
	end
end

local function onFire(player, origin, direction, _timestamp)
	if typeof(origin) ~= "Vector3" or typeof(direction) ~= "Vector3" or direction.Magnitude < 0.01 then
		return
	end
	if not services.HealthService:IsUp(player) or player:GetAttribute("heavyHands") then
		return
	end
	local head = player.Character and player.Character:FindFirstChild("Head")
	local entry, weapon = heldWeapon(player)
	-- 19.5 (C6) : pas d'arme à feu pendant le portage
	if weapon and not weapon.melee and player:GetAttribute("carrying") ~= nil then
		return
	end
	if head == nil or entry == nil then
		return
	end
	-- 16.3 : origine à moins de 5 studs de la tête
	if (origin - head.Position).Magnitude > WeaponConfig.MaxOriginOffset then
		return
	end
	-- 7.7 : l'Opératrice ne peut pas porter d'arme à feu
	if not weapon.melee and player:GetAttribute("role") == WeaponConfig.NoFirearmRole then
		return
	end
	-- cadence
	local interval = weapon.fireInterval or weapon.reloadTime or 0
	if os.clock() - (lastShot[player] or -math.huge) < interval then
		return
	end
	if weapon.ammo and (entry.ammo or 0) <= 0 then
		return -- 8.2 : tir impossible sans munitions
	end
	cancelReload(player) -- le rechargement est interruptible
	lastShot[player] = os.clock()

	if weapon.melee then
		local result = cast(player, origin, direction, WeaponConfig.MeleeRange[entry.id])
		applyHit(player, entry.id, weapon, result, weapon.damage, weapon.friendlyDamage)
		services.NoiseService:Emit(head.Position, weapon.noise, NoiseTypes.Melee, player)
		return
	end

	entry.ammo -= 1
	services.NoiseService:Emit(head.Position, weapon.noise, NoiseTypes.Gunshot, player)
	WeaponService.Fired:Fire(player, entry.id, origin)
	if weapon.pellets then
		local shot = {}
		for _ = 1, weapon.pellets do
			local spread = math.rad(weapon.spreadDegrees or 0)
			local dir = (CFrame.lookAt(Vector3.zero, direction) * CFrame.Angles(
				(math.random() - 0.5) * spread,
				(math.random() - 0.5) * spread,
				0
			)).LookVector
			local result = cast(player, origin, dir, weapon.zeroBeyond or MAX_RANGE)
			if result then
				local distance = (result.Position - origin).Magnitude
				-- 19.5 (C13) : plein dégât jusqu'à 15 studs, baisse linéaire jusqu'à 30 % à 40 studs,
				-- 30 % jusqu'à 60 studs, 0 au-delà (portée du rayon)
				local factor = 1
				if distance > weapon.fullDamageRange then
					local t = math.clamp(
						(distance - weapon.fullDamageRange) / (weapon.reducedRange - weapon.fullDamageRange),
						0,
						1
					)
					factor = 1 - (1 - weapon.reducedFactor) * t
				end
				applyHit(
					player,
					entry.id,
					weapon,
					result,
					weapon.damagePerPellet * factor,
					weapon.friendlyPerPellet,
					shot
				)
			end
		end
	else
		local result = cast(player, origin, direction, MAX_RANGE)
		applyHit(
			player,
			entry.id,
			weapon,
			result,
			weapon.damageBody or weapon.damage,
			weapon.friendlyTorso or weapon.friendlyDamage
		)
	end
	publishAmmo(player)
end

-- 8.2 : rechargement manuel balle par balle, interruptible ; bras < 30 % : ×1,5 plus lent (7.3)
local function onReload(player)
	local entry, weapon = heldWeapon(player)
	if entry == nil or not weapon.ammo or reloading[player] then
		return
	end
	local ammoId = "AMMO_" .. entry.id
	if services.InventoryService:Count(player, ammoId) <= 0 then
		return -- 16.3 : réserve > 0
	end
	local perRound = weapon.reloadPerRound or weapon.reloadTime
	if services.HealthService:IsLow(player, "ArmL") or services.HealthService:IsLow(player, "ArmR") then
		perRound *= PlayerConfig.LowArmReloadFactor
	end
	player:SetAttribute("isReloading", true)
	reloading[player] = task.spawn(function()
		local capacity = weapon.magazine or weapon.ammo
		while (entry.ammo or 0) < capacity and services.InventoryService:Count(player, ammoId) > 0 do
			task.wait(perRound)
			local current = heldWeapon(player)
			if current ~= entry or not services.InventoryService:Remove(player, ammoId, 1) then
				break
			end
			entry.ammo += 1
			publishAmmo(player)
		end
		reloading[player] = nil
		player:SetAttribute("isReloading", false)
	end)
end

function WeaponService:Init(allServices)
	services = allServices
end

function WeaponService:Start()
	local fire = Util.getRemote("RE_FireWeapon")
	if fire then
		RateLimiter.connect(fire, onFire)
	end
	local reload = Util.getRemote("RE_Reload")
	if reload then
		RateLimiter.connect(reload, onReload)
	end
	services.InventoryService.Changed:Connect(function(player)
		local entry = heldWeapon(player)
		if reloading[player] and entry == nil then
			cancelReload(player)
		end
		publishAmmo(player)
	end)
	Players.PlayerRemoving:Connect(function(player)
		lastShot[player] = nil
		cancelReload(player)
	end)
end

return WeaponService
