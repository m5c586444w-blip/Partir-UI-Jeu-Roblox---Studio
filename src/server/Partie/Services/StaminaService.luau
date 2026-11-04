-- ServerScriptService/Services/StaminaService (Partie)
-- Sections 7.2 et 7.4 : postures (RE_SetStance), vitesses, endurance, bruits de pas et de saut.
-- Attributs : stance ("Stand", "Crouch", "Prone", "Run"), stamina, isExhausted.
-- Le serveur fixe Humanoid.WalkSpeed ; il compare la vitesse réelle à la posture (16.3).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local PlayerConfig = require(Config:WaitForChild("PlayerConfig"))
local AmbienceConfig = require(Config:WaitForChild("AmbienceConfig"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local NoiseTypes = require(Shared:WaitForChild("NoiseTypes"))
local RateLimiter = require(Shared:WaitForChild("RateLimiter"))
local Util = require(Shared:WaitForChild("Util"))

local StaminaService = {}

local VOXEL = 4 -- constante (résolution des voxels du terrain Roblox)

local services = nil
local state = {} -- [Player] = { lastEffort, exhaustedUntil, lastStep, moving }
local Movement = PlayerConfig.Movement
local Stamina = PlayerConfig.Stamina

local function maxStamina(player)
	local role = player:GetAttribute("role")
	local value = Stamina.RoleMax[role] or Stamina.Max
	if services.HealthService:IsLow(player, "Torso") then
		value *= PlayerConfig.LowTorsoStaminaFactor
	end
	return value
end

-- matériau sous les pieds : "Water" (eau aux genoux), "Ash" (Sand = cendre, 3.6), "Snow", ou nil
local function terrainKind(character, humanoid)
	local root = character:FindFirstChild("HumanoidRootPart")
	if root then
		local knee = root.Position - Vector3.new(0, VOXEL / 2, 0)
		local half = Vector3.one * (VOXEL / 2)
		local region = Region3.new(knee - half, knee + half):ExpandToGrid(VOXEL)
		local ok, materials, occupancies = pcall(function()
			return workspace.Terrain:ReadVoxels(region, VOXEL)
		end)
		if ok and materials[1] and materials[1][1] and materials[1][1][1] == Enum.Material.Water then
			if occupancies[1][1][1] > 0 then
				return "Water"
			end
		end
	end
	local floor = humanoid.FloorMaterial
	if floor == Enum.Material.Sand then
		return "Ash"
	elseif floor == Enum.Material.Snow then
		return "Snow"
	end
	return nil
end

local function canRun(player)
	local s = state[player]
	return not (s and s.exhaustedUntil and os.clock() < s.exhaustedUntil)
		and (player:GetAttribute("stamina") or 0) > 0
		and not services.HealthService:IsLimping(player)
		and player:GetAttribute("heavyHands") ~= true -- 8 : objet lourd à deux mains : pas de course
		and (player:GetAttribute("carrying") == nil or Movement.RoleCanRunCarrying[player:GetAttribute("role")])
end

-- mode de déplacement effectif et vitesse
local function movementFor(player)
	local stance = player:GetAttribute("stance") or "Stand"
	local role = player:GetAttribute("role")
	if player:GetAttribute("isDowned") then
		return "Downed", PlayerConfig.Downed.CrawlSpeed, 0
	end
	local mode = PlayerConfig.Stances[stance] or "Walk"
	if mode == "Run" and not canRun(player) then
		mode = "Walk"
	end
	if player:GetAttribute("carrying") ~= nil and mode ~= "Run" then
		mode = "Carry"
	end
	local entry = Movement[mode]
	local speed = entry.speed
	local noise = entry.noise
	if mode == "Run" then
		speed = Movement.RoleRunSpeed[role] or speed
		noise = Movement.RoleRunNoise[role] or noise
	elseif mode == "Carry" then
		speed = Movement.RoleCarrySpeed[role] or speed
	end
	if services.HealthService:IsLimping(player) then
		speed *= Movement.LimpSpeedFactor
		noise += Movement.LimpNoiseBonus
	end
	return mode, speed, noise
end

local function tick(dt)
	local weather = services.PartyLoaderService:GetMatchInfo().weather
	local weatherEntry = AmbienceConfig.Weathers[weather]
	for _, player in Players:GetPlayers() do
		local s = state[player]
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if s and humanoid and services.HealthService:IsAlive(player) then
			local mode, speed, noise = movementFor(player)
			local kind = terrainKind(character, humanoid)
			if kind then
				speed *= Movement.TerrainSpeedFactor[kind]
				if kind == "Water" then
					noise *= Movement.WaterNoiseFactor
				end
			end
			humanoid.WalkSpeed = speed

			local root = character:FindFirstChild("HumanoidRootPart")
			local velocity = root and root.AssemblyLinearVelocity or Vector3.zero
			local horizontal = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
			local moving = humanoid.MoveDirection.Magnitude > 0.1 and horizontal > 0.5
			if
				horizontal > speed * PlayerConfig.Technical.StanceSpeedTolerance + 1
				and humanoid.FloorMaterial ~= Enum.Material.Air
			then
				warn(("StaminaService : vitesse anormale pour %s (%.1f > %.1f)"):format(player.Name, horizontal, speed))
			end

			-- endurance (7.4)
			local stamina = player:GetAttribute("stamina") or maxStamina(player)
			local cost = 0
			if moving and mode == "Run" then
				cost += Stamina.RunCostPerSecond
			end
			if player:GetAttribute("carrying") ~= nil and moving then
				cost += Stamina.CarryCostPerSecond
			end
			if cost > 0 then
				stamina -= cost * dt
				s.lastEffort = os.clock()
			elseif os.clock() - (s.lastEffort or 0) >= Stamina.RegenDelay then
				local regen = if moving then Stamina.RegenWalkingPerSecond else Stamina.RegenIdlePerSecond
				if (player:GetAttribute("fear") or 0) >= PlayerConfig.Fear.MisplacedSoundsAt then
					regen *= PlayerConfig.Fear.StaminaRegenFactorAt80
				end
				-- TODO(BIBLE): 12.3 « endurance ×0,85 » par neige — PROVISOIRE : appliqué à la récupération
				if weatherEntry and weatherEntry.staminaFactor then
					regen *= weatherEntry.staminaFactor
				end
				stamina += regen * dt
			end
			stamina = math.clamp(stamina, 0, maxStamina(player))
			if stamina <= 0 and not (s.exhaustedUntil and os.clock() < s.exhaustedUntil) then
				s.exhaustedUntil = os.clock() + Stamina.ExhaustedDuration
			end
			local exhausted = s.exhaustedUntil ~= nil and os.clock() < s.exhaustedUntil
			player:SetAttribute("stamina", stamina)
			player:SetAttribute("isExhausted", exhausted)
			if exhausted and root then
				services.NoiseService:Emit(root.Position, Stamina.ExhaustedPantNoise, NoiseTypes.Pant, player)
			end

			-- bruits de pas
			if
				moving
				and root
				and noise > 0
				and os.clock() - (s.lastStep or 0) >= PlayerConfig.Technical.FootstepNoiseInterval
			then
				s.lastStep = os.clock()
				services.NoiseService:Emit(root.Position, noise, NoiseTypes.Footstep, player)
			end
		end
	end
end

local function onCharacter(player, character)
	state[player] = { lastEffort = 0 }
	player:SetAttribute("stance", "Stand")
	player:SetAttribute("stamina", maxStamina(player))
	player:SetAttribute("isExhausted", false)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid == nil then
		return
	end
	humanoid.StateChanged:Connect(function(_, new)
		local root = character:FindFirstChild("HumanoidRootPart")
		if new == Enum.HumanoidStateType.Jumping then
			player:SetAttribute("stamina", math.max(0, (player:GetAttribute("stamina") or 0) - Stamina.JumpCost))
			state[player].lastEffort = os.clock()
		elseif new == Enum.HumanoidStateType.Landed and root then
			services.NoiseService:Emit(root.Position, Movement.JumpLandNoise, NoiseTypes.Jump, player)
		end
	end)
end

function StaminaService:Init(allServices)
	services = allServices
end

function StaminaService:Start()
	services.CharacterService.Spawned:Connect(onCharacter)
	local remote = Util.getRemote("RE_SetStance")
	if remote then
		RateLimiter.connect(remote, function(player, stance)
			if type(stance) == "string" and PlayerConfig.Stances[stance] then
				player:SetAttribute("stance", stance)
			end
		end)
	end
	Players.PlayerRemoving:Connect(function(player)
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

return StaminaService
