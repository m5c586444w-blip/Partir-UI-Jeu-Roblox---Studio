-- ServerScriptService/AI/FamilyBrain (Partie)
-- Sections 9.2, 9.7, 9.8 et 9.9 : crée la famille (5.5 : Alpha, éclaireurs selon la taille du groupe ;
-- femelle dans les tunnels), tire la personnalité de l'Alpha, choisit les cibles (toutes les 2 s),
-- coordonne (pince, rabattage, séparation ; jamais plus de 2 créatures visibles par joueur),
-- applique les coups reçus, les parades et l'échelle d'intimidation (9.6). 2 fois/s.
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local ActConfig = require(Config:WaitForChild("ActConfig"))
local CreatureConfig = require(Config:WaitForChild("CreatureConfig"))
local DirectorConfig = require(Config:WaitForChild("DirectorConfig"))
local MapConfig = require(Config:WaitForChild("MapConfig"))
local PlayerConfig = require(Config:WaitForChild("PlayerConfig"))
local ItemConfig = require(Config:WaitForChild("ItemConfig"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local NoiseTypes = require(Shared:WaitForChild("NoiseTypes"))
local Util = require(Shared:WaitForChild("Util"))

local CreatureBrain = require(script.Parent:WaitForChild("CreatureBrain"))

local FamilyBrain = {}

local services = nil
local ai = nil
local brains = {} -- liste de CreatureBrain
local byModel = {} -- [Model] = brain
local tightSince = nil
local Target = CreatureConfig.Target

function FamilyBrain:GetBrains()
	return brains
end

-- 9.7 I : distance au coéquipier le plus proche ÷ 60, plafonné à 1
function FamilyBrain:Isolation(player)
	local root = Util.characterRoot(player)
	if root == nil then
		return 0
	end
	local best = math.huge
	for _, other in Players:GetPlayers() do
		if other ~= player and services.HealthService:IsAlive(other) then
			local otherRoot = Util.characterRoot(other)
			if otherRoot then
				best = math.min(best, (otherRoot.Position - root.Position).Magnitude)
			end
		end
	end
	return math.min(1, best / Target.IsolationDistance)
end

-- 9.8 : groupe dans un rayon de 25 studs pendant 120 s
function FamilyBrain:GroupTight()
	return tightSince ~= nil and os.clock() - tightSince >= CreatureConfig.Memory.TightGroupFor
end

-- 9.8 : personnalité de l'Alpha : fréquence d'attaque
function FamilyBrain:AttackFactor(brain)
	if brain.personality == nil then
		return 1
	end
	local p = CreatureConfig.Personalities[brain.personality]
	local factor = p.attackFrequency or 1
	if brain.personality == "Territorial" then
		local inside = (brain:Position() - MapConfig.Places[p.territoryPlace].pos).Magnitude <= p.territoryRadius
		factor = if inside then p.attackFrequency else 1
	end
	return factor
end

local function averageHealth(player)
	local total = 0
	for _, limb in PlayerConfig.Limbs do
		total += services.HealthService:GetFraction(player, limb)
	end
	return total / #PlayerConfig.Limbs
end

-- 9.7 : S = 3,0 I + 1,5 B + 1,0 N + 1,2 L + 2,0 R + 0,8 P + 0,5 C
function FamilyBrain:Score(brain, player)
	local w = Target.Weights
	local I = self:Isolation(player)
	local B = math.clamp(
		1 - averageHealth(player) + (if player:GetAttribute("bleed") ~= "None" then Target.BleedBonus else 0),
		0,
		1
	)
	local N = math.clamp(services.NoiseService:RecentNoise(player, Target.NoiseWindow) / Target.NoiseDivisor, 0, 1)
	local L = if player:GetAttribute("lightOn")
		then Target.LampOn
		elseif player:GetAttribute("tabletOpen") then Target.TabletOpen
		else 0
	local R = math.clamp(
		(brain.memory.grudge[player] or 0) / Target.GrudgeDamageDivisor
			+ (brain.memory.grudgeBonus and brain.memory.grudgeBonus[player] or 0),
		0,
		1
	)
	local P = math.clamp(1 - brain:DistanceTo(player) / Target.ProximityDistance, 0, 1)
	local C = if services.EvidenceService:CarriesClassA(player) then 1 else 0
	-- 19.5 (C6) : le porteur d'un blessé a +0,5
	local carrier = if player:GetAttribute("carrying") ~= nil then Target.CarrierBonus else 0
	return w.I * I + w.B * B + w.N * N + w.L * L + w.R * R + w.P * P + w.C * C + carrier
end

-- la cible change seulement si un autre joueur dépasse le score actuel de 20 %
local function updateTarget(brain)
	local best, bestScore = nil, -1
	local currentScore = -1
	for _, player in brain:Candidates() do
		if (brain.vigilance[player] or 0) >= CreatureConfig.Vision.KnowsPositionAt or brain.knownPosition[player] then
			local score = FamilyBrain:Score(brain, player)
			-- 5.2 : un joueur resté dehors pendant le siège est la cible prioritaire (BHV_Siege)
			if player == brain.target then
				currentScore = score
			end
			if score > bestScore then
				best, bestScore = player, score
			end
		end
	end
	if
		brain.target
		and brain.target.Parent
		and currentScore >= 0
		and bestScore <= currentScore * (1 + Target.SwitchMargin)
	then
		return
	end
	brain.target = best
end

-- 9.6 : échelle d'intimidation
function FamilyBrain:IntimidationStep(brain, player)
	local ladder = brain.ladder
	local steps = CreatureConfig.Intimidation.Steps
	if os.clock() - ladder.lastStepAt > CreatureConfig.Intimidation.StepWithin then
		ladder.step = 0 -- trop longtemps : on recommence en bas
	end
	ladder.step = math.min(#steps, ladder.step + 1)
	ladder.lastStepAt = os.clock()
	ladder.lastContact = os.clock()
	local root = Util.characterRoot(player)
	local position = brain:Position()
	local kind = steps[ladder.step]
	local animator = ai.CreatureAnimator
	if kind == "FaunaSilence" then
		ai.EventDirector:FaunaSilence(position, CreatureConfig.Intimidation.FaunaSilenceRadius)
	elseif kind == "WoodKnock" then
		animator:Play(brain.model, "WoodKnock")
		animator:PlaySoundAt("SFX_WoodKnock", position)
		for _, other in Players:GetPlayers() do
			-- 19.6 (C33) : un coup « au loin » s'entend jusqu'à la distance « au loin » la plus grande
			if brain:DistanceTo(other) <= DirectorConfig.Far.max then
				services.FearService:OnWoodKnock(other)
			end
		end
	elseif kind == "Call" then
		animator:Play(brain.model, "Call")
		animator:PlaySoundAt("SFX_Call_Long", position)
		services.FearService:OnScream(position)
		services.EvidenceService:OnCreatureCall(position)
	elseif kind == "NearThrow" and root then
		-- branche ou pierre qui tombe à côté du joueur, pas sur lui
		local landing = root.Position
			+ Vector3.new(math.random() - 0.5, 0, math.random() - 0.5).Unit * DirectorConfig.nearDistance()
		animator:PlaySoundAt("SFX_StoneGround", landing)
		services.NoiseService:Emit(
			landing,
			require(Config:WaitForChild("ItemConfig")).Items.ITM_Stone.impactNoise,
			NoiseTypes.Impact,
			brain.model
		)
	elseif kind == "BranchSnap" and root then
		animator:PlaySoundAt(
			"SFX_BranchSnap",
			root.Position + (position - root.Position).Unit * DirectorConfig.nearDistance()
		)
	elseif kind == "ChestBeat" then
		if brain.id == "CRT_Alpha" then
			animator:Play(brain.model, "ChestBeat")
			animator:PlaySoundAt("SFX_ChestBeat", position)
		end
	elseif kind == "FakeCharge" then
		-- 60 % des cas si le joueur ne fuit pas et n'éclaire pas ; sinon vraie charge (DÉFAUT)
		local fake = not player:GetAttribute("lightOn") and math.random() < CreatureConfig.Intimidation.FakeChargeChance
		local charge = brain.attacks.ATK_Charge
		if charge and charge.canUse(brain, player) then
			task.spawn(charge.run, brain, player, fake)
		end
	elseif kind == "Attack" then
		brain.vigilance[player] = CreatureConfig.Vision.TargetAt
		brain.target = player
	end
end

-- dégâts reçus (WeaponService.CreatureHit)
local function onHit(model, damage, shooter, weaponId, _isHead, _part, extra)
	local brain = byModel[model]
	if brain == nil then
		return
	end
	brain:TakeDamage(damage, shooter, weaponId)
	-- parades de la saisie : hache 1 coup, machette 2, tir
	if brain.grabbed then
		brain.grabHits = (brain.grabHits or 0) + 1
		if extra.grabReleaseHits == nil or brain.grabHits >= extra.grabReleaseHits then
			brain.grabbed:SetAttribute("grabbedBy", nil)
			brain.grabbed = nil
		end
	end
	-- pistolet lance-fusées : éblouit, la créature fuit 8 s
	if extra.flee then
		brain.fleeUntil = os.clock() + extra.flee
	end
end

function FamilyBrain:OnDeath(brain, shooter)
	brain.model:SetAttribute("dead", true)
	brain.model:AddTag("CreatureCorpse")
	if brain.humanoid then
		brain.humanoid.Health = 0
	end
	ai.CreatureAnimator:Play(brain.model, "DeathFall")
	if brain.id == "CRT_Alpha" then
		services.GameStateService:OnAlphaKilled() -- 5.3 : fin « Ordonnance 69-01 »
	end
	ai.TensionDirector:StrongEvent(shooter)
end

local function spawnFamily()
	local info = services.PartyLoaderService:GetMatchInfo()
	local random = Random.new(info.seed)
	local group = ActConfig.groupSize(info.playerCount)
	local list = table.clone(group.creatures)
	table.insert(list, "CRT_Female") -- tunnels uniquement, quelle que soit la taille du groupe
	-- DÉFAUT : départ de la famille au repaire (P07a pour la surface, P07b pour la femelle)
	for _, id in list do
		local spawnAt = if id == "CRT_Female"
			then MapConfig.Places[CreatureConfig.LairPlace].pos
			else MapConfig.Places.P07a.pos
		local brain = CreatureBrain.new(id, spawnAt, FamilyBrain)
		if id == "CRT_Alpha" then
			brain.personality = CreatureConfig.PersonalityOrder[random:NextInteger(1, #CreatureConfig.PersonalityOrder)]
			print("FamilyBrain : personnalité de l'Alpha : " .. brain.personality)
			brain.model:SetAttribute("personality", brain.personality)
		end
		table.insert(brains, brain)
		byModel[brain.model] = brain
	end
end

-- 9.9 : jamais plus de 2 créatures visibles en même temps par un joueur
local function enforceReadability()
	for _, player in Players:GetPlayers() do
		local visible = {}
		for _, brain in brains do
			if brain:HasBody() and not brain.dead then
				local seen = ai.Perception:CanSee(brain, player)
				if seen then
					table.insert(visible, brain)
				end
			end
		end
		if #visible > CreatureConfig.MaxVisiblePerPlayer then
			table.sort(visible, function(a, b)
				return a:DistanceTo(player) < b:DistanceTo(player)
			end)
			for i = CreatureConfig.MaxVisiblePerPlayer + 1, #visible do
				visible[i].fleeUntil = os.clock() + CreatureConfig.Behaviors.BHV_Retreat.minDuration / 10
			end
		end
	end
end

local function updateTightGroup()
	local players = {}
	for _, player in Players:GetPlayers() do
		if services.HealthService:IsAlive(player) and Util.characterRoot(player) then
			table.insert(players, Util.characterRoot(player).Position)
		end
	end
	local tight = #players > 1
	for i = 1, #players do
		for j = i + 1, #players do
			if (players[i] - players[j]).Magnitude > CreatureConfig.Memory.TightGroupRadius * 2 then
				tight = false
			end
		end
	end
	if tight then
		tightSince = tightSince or os.clock()
	else
		tightSince = nil
	end
end

-- 9.9 : pince et rabattage — les éclaireurs suivent la cible de l'Alpha
local function coordinate()
	local alpha = nil
	for _, brain in brains do
		if brain.id == "CRT_Alpha" and not brain.dead then
			alpha = brain
		end
	end
	for _, brain in brains do
		if brain.def.role == "Scout" and not brain.dead and alpha and alpha.target then
			brain.target = alpha.target
			brain.vigilance[alpha.target] =
				math.max(brain.vigilance[alpha.target] or 0, CreatureConfig.Vision.KnowsPositionAt)
		end
	end
end

-- empreinte fraîche (attribut createdAt = os.clock() côté serveur, createdTime = heure serveur)
function FamilyBrain:PlaceFootprint(position)
	local spec = CreatureConfig.Footprints
	local part = Instance.new("Part")
	part.Name = "Footprint"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.Color = ItemConfig.PlaceholderColor -- Decal_Footprint_Big à créer (13.5)
	part.Size = spec.Size
	part.Position = position
	part:SetAttribute("createdAt", os.clock())
	part:SetAttribute("createdTime", workspace:GetServerTimeNow())
	part:AddTag("Footprint")
	part.Parent = workspace
	game:GetService("Debris"):AddItem(part, spec.Lifetime)
	return part
end

local function footprints()
	for _, brain in brains do
		if brain:HasBody() and brain.root and not brain.dead then
			local position = brain.root.Position - Vector3.new(0, brain.def.height / 2, 0)
			if
				brain.lastFootprint == nil
				or (position - brain.lastFootprint).Magnitude >= CreatureConfig.Footprints.Spacing
			then
				brain.lastFootprint = position
				FamilyBrain:PlaceFootprint(position)
			end
		end
	end
end

-- 7.7 : le Pisteur devine la direction de la créature (±45°, recharge 60 s) ; attribut trackerDirection
local trackerCooldown = {}
local function trackerAbility(player)
	local ability = PlayerConfig.Abilities.Tracker
	local root = Util.characterRoot(player)
	if root == nil or os.clock() - (trackerCooldown[player] or -math.huge) < ability.DirectionCooldown then
		return
	end
	trackerCooldown[player] = os.clock()
	local nearest, best = nil, math.huge
	for _, brain in brains do
		if not brain.dead then
			local d = (brain:Position() - root.Position).Magnitude
			if d < best then
				nearest, best = brain, d
			end
		end
	end
	if nearest then
		local offset = nearest:Position() - root.Position
		local angle = math.deg(math.atan2(offset.X, -offset.Z))
		angle += (math.random() * 2 - 1) * ability.DirectionErrorDegrees
		player:SetAttribute("trackerDirection", angle)
		player:SetAttribute("trackerDirectionAt", workspace:GetServerTimeNow())
	end
end

-- 9.9 : la femelle garde P07b ; l'Alpha ne suit les joueurs dans les tunnels qu'à partir de l'acte 4
function FamilyBrain:CanEnterTunnels(brain)
	if brain.id == "CRT_Female" then
		return true
	end
	return brain.id == "CRT_Alpha"
		and (Util.getMatchState():GetAttribute("act") or 0) >= CreatureConfig.AlphaInTunnelsFromAct
end

function FamilyBrain:Init(allServices, aiModules)
	services = allServices
	ai = aiModules
	CreatureBrain.Setup(allServices, aiModules)
end

function FamilyBrain:Start()
	services.WeaponService.CreatureHit:Connect(onHit)
	services.InventoryService.AbilityUsed:Connect(function(player, role)
		if role == "Tracker" then
			trackerAbility(player)
		end
	end)
	services.InventoryService.BearSpray:Connect(function(_player, origin, direction, cone)
		for _, brain in brains do
			local toCreature = brain:Position() - origin
			if toCreature.Magnitude <= cone and direction:Dot(toCreature.Unit) > 0 then
				-- lâche sa prise et recule 4 s
				if brain.grabbed then
					brain.grabbed:SetAttribute("grabbedBy", nil)
					brain.grabbed = nil
				end
				brain.fleeUntil = os.clock() + CreatureConfig.Repellents.BearSprayRecoil
			end
		end
	end)
	-- 9.7 R : +0,5 si filmée à moins de 30 studs ; +0,3 par fusée
	services.EvidenceService.Filmed:Connect(function(player, model, distance)
		local brain = byModel[model]
		if brain and distance <= Target.GrudgeFilmedDistance then
			brain.memory.grudgeBonus = brain.memory.grudgeBonus or {}
			brain.memory.grudgeBonus[player] = math.max(brain.memory.grudgeBonus[player] or 0, Target.GrudgeFilmed)
		end
	end)
	CollectionService:GetInstanceAddedSignal("FireSource"):Connect(function(source)
		if source.Name ~= "Flare" then
			return
		end
		for _, brain in brains do
			brain.memory.flares += 1
			-- 9.8 : fuite réduite de 8 à 4 s à partir de la 2e fusée
			local flee = if brain.memory.flares >= 2
				then CreatureConfig.Memory.FlareFleeLater
				else CreatureConfig.Memory.FlareFleeFirst
			if
				source:IsA("BasePart")
				and (source.Position - brain:Position()).Magnitude <= CreatureConfig.Repellents.FlareKeepAway
				and not brain.enraged
			then
				brain.fleeUntil = os.clock() + flee
			end
		end
	end)
	task.spawn(function()
		services.PartyLoaderService:WaitUntilLoaded()
		spawnFamily()
		local brainStep = 1 / CreatureConfig.Rates.Brain
		local familyEvery = math.max(1, math.floor(CreatureConfig.Rates.Brain / CreatureConfig.Rates.Family))
		local targetEvery = Target.Interval * CreatureConfig.Rates.Brain
		local perceptionNear = 1 / CreatureConfig.Rates.PerceptionNear
		local tick = 0
		-- perception : 10 fois/s à moins de 150 studs, 2 fois/s au-delà
		task.spawn(function()
			local farCounter = 0
			local farEvery = CreatureConfig.Rates.PerceptionNear / CreatureConfig.Rates.PerceptionFar
			while true do
				task.wait(perceptionNear)
				farCounter += 1
				for _, brain in brains do
					if not brain.dead then
						for _, player in Players:GetPlayers() do
							local near = brain:DistanceTo(player) <= CreatureConfig.Rates.PerceptionNearRange
							if near then
								ai.Perception:UpdatePlayer(brain, player, perceptionNear)
							elseif farCounter % farEvery == 0 then
								ai.Perception:UpdatePlayer(brain, player, perceptionNear * farEvery)
							end
						end
					end
				end
			end
		end)
		services.NoiseService.Emitted:Connect(function(noise)
			for _, brain in brains do
				if not brain.dead and noise.source ~= brain.model then
					ai.Perception:OnNoise(brain, noise)
				end
			end
		end)
		while true do
			task.wait(brainStep)
			tick += 1
			for _, brain in brains do
				if not brain.dead then
					if tick % targetEvery == 0 then
						updateTarget(brain)
					end
					brain:Tick(brainStep)
				end
			end
			footprints()
			if tick % familyEvery == 0 then
				updateTightGroup()
				coordinate()
				enforceReadability()
			end
		end
	end)
end

return FamilyBrain
