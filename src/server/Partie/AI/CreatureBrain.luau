-- ServerScriptService/AI/CreatureBrain (Partie)
-- Sections 9.2, 9.3, 9.5 et 9.11 : une créature. Choisit un comportement (IA à utilité, 5 fois/s),
-- l'exécute (machine à états), se déplace (PathfindingService, ou graphe CreatureNav quand aucun
-- joueur n'est à moins de 600 studs : plus de corps physique). Modèle : ServerStorage/Creatures ;
-- absent → capsule de la taille de 9.2 (J10), nommée MANQUANT_<ID>.
local CollectionService = game:GetService("CollectionService")
local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local ActConfig = require(Config:WaitForChild("ActConfig"))
local CreatureConfig = require(Config:WaitForChild("CreatureConfig"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local NoiseTypes = require(Shared:WaitForChild("NoiseTypes"))
local Util = require(Shared:WaitForChild("Util"))

local CreatureBrain = {}
CreatureBrain.__index = CreatureBrain

local behaviors = {} -- [id] = module
local attacks = {} -- [id] = module
local ai = nil -- modules du dossier AI
local services = nil

local REPATH_DISTANCE = CreatureConfig.Technical.RepathDistance
local CAPSULE_WIDTH = CreatureConfig.Technical.CapsuleWidth
local CAPSULE_COLOR = CreatureConfig.Technical.CapsuleColor

function CreatureBrain.Setup(allServices, aiModules)
	services = allServices
	ai = aiModules
	local folder = script.Parent
	for _, module in folder:WaitForChild("Behaviors"):GetChildren() do
		if module:IsA("ModuleScript") then
			behaviors[module.Name] = require(module)
		end
	end
	for _, module in folder:WaitForChild("Attacks"):GetChildren() do
		if module:IsA("ModuleScript") then
			attacks[module.Name] = require(module)
		end
	end
end

local function buildBody(id, def)
	local folder = ServerStorage:FindFirstChild("Creatures")
	local template = folder and folder:FindFirstChild(def.model)
	if template then
		return template:Clone()
	end
	-- J10 : capsule de 10 studs (8 pour un éclaireur, 9 pour la femelle)
	local model = Instance.new("Model")
	model.Name = "MANQUANT_" .. id
	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Shape = Enum.PartType.Cylinder
	root.Size = Vector3.new(def.height, CAPSULE_WIDTH * 2, CAPSULE_WIDTH * 2)
	root.CFrame = CFrame.Angles(0, 0, math.pi / 2)
	root.Color = CAPSULE_COLOR
	root.Parent = model
	local head = Instance.new("Part")
	head.Name = "Head"
	head.Shape = Enum.PartType.Ball
	head.Size = Vector3.one * CAPSULE_WIDTH
	head.Color = CAPSULE_COLOR
	head.CFrame = CFrame.new(0, def.height / 2, 0)
	head.Parent = model
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = root
	weld.Part1 = head
	weld.Parent = root
	local humanoid = Instance.new("Humanoid")
	humanoid.HipHeight = def.height / 2
	humanoid.Parent = model
	Instance.new("Animator").Parent = humanoid
	model.PrimaryPart = root
	return model
end

function CreatureBrain.new(id, spawnPosition, family)
	local def = CreatureConfig.Family[id]
	local info = services.PartyLoaderService:GetMatchInfo()
	local healthFactor = ActConfig.difficulty(info.difficulty).creatureHealth
	local self = setmetatable({
		id = id,
		def = def,
		family = family,
		services = services,
		ai = ai,
		attacks = attacks,
		maxHealth = def.health * healthFactor,
		vigilance = {},
		knownPosition = {},
		lastSeen = {},
		lastHeard = nil,
		memory = { litCount = 0, shotsTaken = 0, flares = 0, grudge = {}, hidingSpots = {}, pathCells = {} },
		ladder = { step = 0, lastStepAt = -math.huge, lastContact = os.clock() },
		hunger = 0,
		enraged = false,
		behavior = nil,
		behaviorId = nil,
		behaviorStartedAt = 0,
		scores = {},
		damageLog = {},
		lastDamageAt = -math.huge,
		virtualPosition = spawnPosition,
		gait = "Walk",
		path = nil,
		goal = nil,
	}, CreatureBrain)
	self.health = self.maxHealth
	local model = buildBody(id, def)
	model:AddTag("Creature")
	model:SetAttribute("creatureId", id)
	model:SetAttribute("health", self.health)
	self.model = model
	self.root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
	self.head = model:FindFirstChild("Head") or self.root
	self.humanoid = model:FindFirstChildOfClass("Humanoid")
	return self
end

function CreatureBrain:Position()
	if self.model.Parent == workspace and self.root then
		return self.root.Position
	end
	return self.virtualPosition
end

function CreatureBrain:HasBody()
	return self.model.Parent == workspace
end

-- paramètres de rayon construits une seule fois (aucune exclusion), au lieu d'un RaycastParams par appel
local SEEN_PARAMS = RaycastParams.new()

-- vrai si un joueur voit ce point (pour faire apparaître le corps hors de vue, 9.3 et 10.1)
function CreatureBrain:IsPointSeen(position)
	for _, player in Players:GetPlayers() do
		local head = player.Character and player.Character:FindFirstChild("Head")
		if head and (head.Position - position).Magnitude < CreatureConfig.Simulation.BodyRange then
			local hit = workspace:Raycast(head.Position, position - head.Position, SEEN_PARAMS)
			if hit == nil or (hit.Position - position).Magnitude < CAPSULE_WIDTH then
				local look = head.CFrame.LookVector
				if look:Dot((position - head.Position).Unit) > 0 then
					return true
				end
			end
		end
	end
	return false
end

local function nearestPlayerDistance(position)
	local best = math.huge
	for _, player in Players:GetPlayers() do
		local root = Util.characterRoot(player)
		if root then
			best = math.min(best, (root.Position - position).Magnitude)
		end
	end
	return best
end

-- 9.3 : corps physique seulement si un joueur est à moins de 600 studs
function CreatureBrain:UpdateBody()
	local position = self:Position()
	local near = nearestPlayerDistance(position) < CreatureConfig.Simulation.BodyRange
	if near and not self:HasBody() then
		if not self:IsPointSeen(position) then
			self.model:PivotTo(CFrame.new(position))
			self.model.Parent = workspace
			if self.root then
				self.root:SetNetworkOwner(nil)
			end
		end
	elseif not near and self:HasBody() then
		self.virtualPosition = self.root.Position
		self.model.Parent = nil
	end
end

function CreatureBrain:SetGait(gait)
	local now = os.clock()
	if gait == "Sprint" then
		local sprint = CreatureConfig.Gaits.Sprint
		if (self.sprintRecoverUntil or 0) > now then
			gait = "Run"
		elseif self.gait ~= "Sprint" then
			self.sprintUntil = now + sprint.duration
		end
	end
	if self.gait == "Sprint" and gait == "Sprint" and (self.sprintUntil or 0) <= now then
		self.sprintRecoverUntil = now + CreatureConfig.Gaits.Sprint.recovery
		gait = "Run"
	end
	self.gait = gait
	if self.humanoid then
		self.humanoid.WalkSpeed = CreatureConfig.Gaits[gait].speed
	end
end

function CreatureBrain:Stop()
	self.goal = nil
	self.path = nil
	if self:HasBody() and self.humanoid and self.root then
		self.humanoid:MoveTo(self.root.Position)
	end
end

function CreatureBrain:FaceTowards(position)
	if self:HasBody() and self.root then
		local flat = Vector3.new(position.X, self.root.Position.Y, position.Z)
		if (flat - self.root.Position).Magnitude > 0.1 then
			self.root.CFrame = CFrame.lookAt(self.root.Position, flat)
		end
	end
end

local function pathParams()
	local p = CreatureConfig.Path
	return {
		AgentRadius = p.AgentRadius,
		AgentHeight = p.AgentHeight,
		AgentCanJump = p.AgentCanJump,
		Costs = {
			Water = p.Costs.Water,
			Sand = p.Costs.Sand,
			Pebble = p.Costs.Pebble,
			Rock = p.Costs.Rock,
			Grass = p.Costs.Grass,
			LeafyGrass = p.Costs.LeafyGrass,
			Cover = p.Modifiers.Cover,
			Trail = p.Modifiers.Trail,
			Forbidden = p.Modifiers.Forbidden,
		},
	}
end

-- se déplace vers `goal` avec une allure (9.2) ; à pas de pathfinding près de la cible (9.11)
function CreatureBrain:MoveTo(goal, gait)
	self:SetGait(gait or self.gait)
	if self.goal and (self.goal - goal).Magnitude < REPATH_DISTANCE and self.path then
		return
	end
	self.goal = goal
	self.path = nil
	self.waypointIndex = 1
	if not self:HasBody() then
		self.path = ai.NavGraph:Path(self.virtualPosition, goal)
		return
	end
	if (goal - self.root.Position).Magnitude <= CreatureConfig.Path.DirectRange then
		self.humanoid:MoveTo(goal)
		return
	end
	local path = PathfindingService:CreatePath(pathParams())
	local ok = pcall(function()
		path:ComputeAsync(self.root.Position, goal)
	end)
	if ok and path.Status == Enum.PathStatus.Success then
		self.path = {}
		for _, waypoint in path:GetWaypoints() do
			table.insert(self.path, waypoint.Position)
		end
	else
		self.humanoid:MoveTo(goal) -- repli : déplacement direct
	end
end

function CreatureBrain:Arrived(tolerance)
	return self.goal == nil or (self:Position() - self.goal).Magnitude <= (tolerance or CAPSULE_WIDTH * 2)
end

local function followPath(self, dt)
	if self.path == nil then
		return
	end
	local target = self.path[self.waypointIndex or 1]
	if target == nil then
		self.path = nil
		return
	end
	if self:HasBody() then
		self.humanoid:MoveTo(target)
		if (self.root.Position - target).Magnitude < CAPSULE_WIDTH * 2 then
			self.waypointIndex += 1
		end
	else
		-- simulation à distance : déplacement sur le graphe à l'allure courante
		local speed = CreatureConfig.Gaits[self.gait].speed
		local delta = target - self.virtualPosition
		local stepLength = speed * dt
		if delta.Magnitude <= stepLength then
			self.virtualPosition = target
			self.waypointIndex += 1
		else
			self.virtualPosition += delta.Unit * stepLength
		end
	end
	-- bruit de pas (9.2) selon l'allure
	local noise = CreatureConfig.Gaits[self.gait].noise
	if noise and self:HasBody() then
		services.NoiseService:Emit(self.root.Position, noise, NoiseTypes.Footstep, self.model)
	end
end

-- 9.2 : régénération hors combat, jusqu'à 70 % ; 19.6 (C29) : 10 s sans dégâts reçus ni attaque lancée
local function regen(self, dt)
	local lastCombat = math.max(self.lastDamageAt, self.lastAttackAt or -math.huge)
	if os.clock() - lastCombat >= CreatureConfig.OutOfCombatAfter then
		local cap = self.maxHealth * CreatureConfig.Regen.MaxFraction
		if self.health < cap then
			self.health = math.min(cap, self.health + CreatureConfig.Regen.PerSecond * dt)
			self.model:SetAttribute("health", self.health)
		end
	end
end

function CreatureBrain:TakeDamage(amount, shooter, weaponId)
	if self.dead then
		return
	end
	self.health -= amount
	self.lastDamageAt = os.clock()
	table.insert(self.damageLog, { time = os.clock(), amount = amount })
	self.model:SetAttribute("health", self.health)
	if shooter then
		-- 9.7 : rancune = dégâts ÷ 200 ; tirs du Pisteur comptés double
		local factor = if shooter:GetAttribute("role") == "Tracker" then CreatureConfig.Target.TrackerShotFactor else 1
		self.memory.grudge[shooter] = (self.memory.grudge[shooter] or 0) + amount * factor
		self.memory.shotsTaken += 1
		self.vigilance[shooter] = CreatureConfig.Vision.TargetAt
	end
	if self.health <= 0 then
		self.dead = true
		self.family:OnDeath(self, shooter, weaponId)
	end
end

-- dégâts perdus dans la fenêtre (9.5 : 15 % en 10 s → fuite)
function CreatureBrain:RecentDamage(window)
	local total = 0
	local now = os.clock()
	for _, entry in self.damageLog do
		if now - entry.time <= window then
			total += entry.amount
		end
	end
	return total
end

-- lance une attaque de 9.10 (signal sonore avant les dégâts)
function CreatureBrain:Attack(attackId, target)
	local attack = attacks[attackId]
	if attack == nil or self.busy then
		return false
	end
	if attack.canUse and not attack.canUse(self, target) then
		return false
	end
	self.busy = true
	self.lastAttackAt = os.clock() -- 19.6 (C29) : une attaque lancée compte comme combat
	ai.TensionDirector:RegisterAttackAttempt(self, target)
	task.spawn(function()
		local ok, err = pcall(attack.run, self, target)
		if not ok then
			warn("CreatureBrain : " .. attackId .. " : " .. tostring(err))
		end
		self.busy = false
	end)
	return true
end

-- choix du comportement (9.5) : garde le comportement en cours sauf si un autre dépasse son score ×1,25,
-- et chaque comportement a une durée minimale
local function choose(self)
	local best, bestScore = nil, -1
	self.scores = {}
	for id, module in behaviors do
		local ok, score = pcall(module.score, self)
		score = if ok and type(score) == "number" then math.clamp(score, 0, 1) else 0
		self.scores[id] = score
		if score > bestScore then
			best, bestScore = id, score
		end
	end
	local current = self.behaviorId
	if current then
		local def = CreatureConfig.Behaviors[current]
		local minDuration = def and def.minDuration or 0
		local currentScore = self.scores[current] or 0
		local module = behaviors[best]
		local urgent = module.urgent == true or (module.isUrgent ~= nil and module.isUrgent(self) == true)
		if not urgent and os.clock() - self.behaviorStartedAt < minDuration and currentScore > 0 then
			return
		end
		if best ~= current and bestScore <= currentScore * CreatureConfig.SwitchFactor then
			return
		end
	end
	if best and best ~= current then
		if current and behaviors[current].stop then
			behaviors[current].stop(self)
		end
		self.behaviorId = best
		self.behavior = behaviors[best]
		self.behaviorStartedAt = os.clock()
		self.model:SetAttribute("behavior", best)
		if self.behavior.start then
			self.behavior.start(self)
		end
	end
end

function CreatureBrain:Tick(dt)
	if self.dead then
		return
	end
	self:UpdateBody()
	regen(self, dt)
	self.hunger =
		math.min(1, self.hunger + CreatureConfig.Behaviors.BHV_Feed.hungerPerMinute * dt / Util.SECONDS_PER_MINUTE)
	if not self.busy then
		choose(self)
		if self.behavior and self.behavior.step then
			local ok, err = pcall(self.behavior.step, self, dt)
			if not ok then
				warn("CreatureBrain : " .. tostring(self.behaviorId) .. " : " .. tostring(err))
			end
		end
	end
	followPath(self, dt)
	self.model:SetAttribute("targetUserId", if self.target then self.target.UserId else nil)
end

-- joueurs que la créature peut cibler (pas en cinématique, vivants, pas extraits)
function CreatureBrain:Candidates()
	local list = {}
	for _, player in Players:GetPlayers() do
		if
			services.HealthService:IsAlive(player)
			and not services.CinematicService:IsProtected(player)
			and player:GetAttribute("extracted") == nil
		then
			table.insert(list, player)
		end
	end
	return list
end

function CreatureBrain:DistanceTo(player)
	local root = Util.characterRoot(player)
	return if root then (root.Position - self:Position()).Magnitude else math.huge
end

function CreatureBrain:IsTagged(tag)
	return CollectionService:HasTag(self.model, tag)
end

function CreatureBrain:Destroy()
	self.model:Destroy()
end

return CreatureBrain
