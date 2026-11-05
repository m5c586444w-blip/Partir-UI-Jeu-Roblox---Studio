-- ServerScriptService/AI/Perception (Partie)
-- Section 9.4 : vue (portée Rv, cône 120°, périphérie 200° ×0,4, deux rayons tête et torse, feuillages
-- tagués « Foliage » transparents), vigilance par joueur, ouïe (atténuations), odorat (vent), lumière.
-- Section 7.6 : coefficient de visibilité du joueur. Rafraîchie 10 fois/s à moins de 150 studs, 2 fois/s au-delà.
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local ActConfig = require(Config:WaitForChild("ActConfig"))
local CreatureConfig = require(Config:WaitForChild("CreatureConfig"))
local MapConfig = require(Config:WaitForChild("MapConfig"))
local PlayerConfig = require(Config:WaitForChild("PlayerConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local Perception = {}

local services = nil
local Vision = CreatureConfig.Vision
local Hearing = CreatureConfig.Hearing
local Visibility = PlayerConfig.Visibility
local riverSamples = {} -- points le long de R1, R2, R3 (atténuation près d'un ruisseau)
local OPEN_PLACES = { "P02", "P06", "P08", "P12" } -- 7.6 « à découvert » : lahar, plateau, zone interdite, prairie

local function flat(a, b)
	return Vector2.new(a.X - b.X, a.Z - b.Z).Magnitude
end

local function inPlace(position, code)
	local place = MapConfig.Places[code]
	if place == nil then
		return false
	end
	if place.zone then
		local z = place.zone
		return position.X >= z.minX and position.X <= z.maxX and position.Z >= z.minZ and position.Z <= z.maxZ
	end
	if place.corridor then
		local c = place.corridor
		local a, b = c.from, c.to
		local p = Vector2.new(position.X, position.Z)
		local t = math.clamp((p - a):Dot(b - a) / (b - a):Dot(b - a), 0, 1)
		return (p - (a + (b - a) * t)).Magnitude <= c.width / 2
	end
	return place.pos ~= nil and place.radius ~= nil and flat(position, place.pos) <= place.radius
end

function Perception:InPlace(position, code)
	return inPlace(position, code)
end

local function isOpenGround(position)
	for _, code in OPEN_PLACES do
		if inPlace(position, code) then
			return true
		end
	end
	return false
end

local function weather()
	return Util.getMatchState():GetAttribute("weather") or "Clear"
end

-- 7.6 et 8.3 : coefficient de visibilité du joueur
function Perception:VisibilityOf(player, distance)
	local root = Util.characterRoot(player)
	-- 19.5 (C7, HC2) : dans le vide sanitaire, invisible à la vue (pas à l'ouïe ni à l'odorat)
	if root == nil or player:GetAttribute("hiddenFromSight") then
		return 0
	end
	local stance = player:GetAttribute("stance")
	local open = isOpenGround(root.Position)
	local value = if open then Visibility.StandingOpen else Visibility.StandingForest
	if stance == "Crouch" then
		value *= Visibility.CrouchFactor
	elseif stance == "Prone" and not open then
		value *= Visibility.ProneInFernsFactor
		if distance > Visibility.ProneInFernsMaxDistance then
			return 0
		end
	end
	if player:GetAttribute("lightOn") then
		value *= Visibility.LightOnFactor
	end
	if (player:GetAttribute("flashUntil") or 0) > workspace:GetServerTimeNow() then
		value *= require(Config:WaitForChild("ItemConfig")).Items.ITM_PhotoCamera.flashLightFactor
	end
	if player:GetAttribute("tabletOpen") then
		value *= Visibility.TabletOpenFactor
	end
	local w = weather()
	if w == "Rain" or w == "Fog" then
		value *= Visibility.RainOrFogFactor
	end
	return value
end

-- 9.4 : portée de vue de base (sans le coefficient du joueur)
function Perception:BaseRange()
	local state = Util.getMatchState()
	local clock = state:GetAttribute("clock") or 0
	local dawn = (state:GetAttribute("act") or 0) >= #ActConfig.Acts
		or (clock >= ActConfig.Dawn.FinalAssaultHour and clock < ActConfig.EndHour)
	local range = if dawn then Vision.RangeDawn else Vision.RangeNight
	range *= ActConfig.difficulty(services.PartyLoaderService:GetMatchInfo().difficulty).perception
	range *= Vision.WeatherFactor[weather()] or 1
	return range
end

local function rayParams(brain, player)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local filter = { brain.model }
	for _, foliage in CollectionService:GetTagged("Foliage") do
		table.insert(filter, foliage)
	end
	params.FilterDescendantsInstances = filter
	return params, player.Character
end

-- vrai si la créature voit le joueur ; renvoie aussi le facteur de périphérie
function Perception:CanSee(brain, player)
	local head = brain.head
	local character = player.Character
	if head == nil or character == nil then
		return false, 0
	end
	local target = character:FindFirstChild("Head")
	local torso = character:FindFirstChild("UpperTorso")
		or character:FindFirstChild("Torso")
		or character:FindFirstChild("HumanoidRootPart")
	if target == nil or torso == nil then
		return false, 0
	end
	local toTarget = target.Position - head.Position
	local angle = math.deg(math.acos(math.clamp(head.CFrame.LookVector:Dot(toTarget.Unit), -1, 1)))
	local factor
	if angle <= Vision.Cone / 2 then
		factor = 1
	elseif angle <= Vision.Peripheral / 2 then
		factor = Vision.PeripheralFactor
	else
		return false, 0
	end
	local params = rayParams(brain, player)
	for _, part in { target, torso } do
		local hit = workspace:Raycast(head.Position, part.Position - head.Position, params)
		if hit == nil or hit.Instance:IsDescendantOf(character) then
			return true, factor
		end
	end
	return false, 0
end

-- mise à jour de la vigilance d'un joueur pour une créature
function Perception:UpdatePlayer(brain, player, dt)
	local root = Util.characterRoot(player)
	local vigilance = brain.vigilance[player] or 0
	if root == nil or not services.HealthService:IsAlive(player) or services.CinematicService:IsProtected(player) then
		brain.vigilance[player] = math.max(0, vigilance - Vision.DecayRate * dt)
		return
	end
	local position = brain:Position()
	local distance = (root.Position - position).Magnitude
	local visibility = self:VisibilityOf(player, distance)
	local rv = self:BaseRange() * visibility
	if player:GetAttribute("lightOn") then
		rv = math.min(rv, Visibility.LightOnMaxDistance) -- 7.6 : lampe : visible jusqu'à 600 studs
		if distance <= Visibility.LightOnMaxDistance then
			rv = math.max(rv, distance + 1)
		end
	end
	local seen, factor = false, 0
	if brain.model.Parent == workspace and distance <= rv and rv > 0 then
		seen, factor = self:CanSee(brain, player)
	end
	if seen then
		vigilance += Vision.GainRate * (1 - distance / rv) * visibility * factor * dt
		brain.knownPosition[player] = root.Position
		brain.lastSeen[player] = os.clock()
	else
		vigilance -= Vision.DecayRate * dt
	end
	-- odorat (9.4) : selon le vent, joueur au vent senti à 80 studs, de travers 30, sous le vent 10
	local wind = workspace.GlobalWind
	if wind.Magnitude > 0 then
		local fromPlayer = (position - root.Position).Unit
		local cos = wind.Unit:Dot(fromPlayer)
		local smell = CreatureConfig.Smell
		local range = if cos > 0.5 then smell.Upwind elseif cos < -0.5 then smell.Downwind else smell.Crosswind -- constante (cos 60°)
		if distance <= range then
			vigilance = math.max(vigilance, Vision.KnowsPositionAt)
			brain.knownPosition[player] = root.Position
		end
	end
	-- lumière (9.4) : un faisceau qui touche la créature dans sa portée → vigilance du porteur à 1
	if player:GetAttribute("lightOn") and brain.head then
		local head = player.Character and player.Character:FindFirstChild("Head")
		local range = player:GetAttribute("lightRange") or 0
		if head and distance <= range then
			local toCreature = (brain.head.Position - head.Position).Unit
			local angle = math.deg(math.acos(math.clamp(head.CFrame.LookVector:Dot(toCreature), -1, 1)))
			if angle <= require(Config:WaitForChild("AmbienceConfig")).Lamp.Angle / 2 then
				if vigilance < Vision.TargetAt then
					brain.memory.litCount += 1
				end
				vigilance = Vision.TargetAt
				brain.knownPosition[player] = root.Position
				brain.litAt = os.clock()
			end
		end
	end
	brain.vigilance[player] = math.clamp(vigilance, 0, Vision.TargetAt)
end

-- atténuation d'un bruit à sa source (9.4)
local function attenuation(position)
	local value = 1
	if weather() == "Rain" then
		value *= Hearing.Attenuation.Rain
	end
	for _, sample in riverSamples do
		if flat(position, sample) <= Hearing.StreamRange then
			value *= Hearing.Attenuation.Stream
			break
		end
	end
	if inPlace(position, Hearing.WaterfallPlace) then
		value *= Hearing.Attenuation.Waterfall
	end
	if inPlace(position, Hearing.CabinPlace) then
		value *= Hearing.Attenuation.CabinWalls
	end
	return value
end

-- 9.4 : un bruit est entendu si distance ≤ rayon × ouïe × atténuation
function Perception:OnNoise(brain, noise)
	local position = brain:Position()
	local distance = (noise.position - position).Magnitude
	if distance > noise.radius * brain.def.hearing * attenuation(noise.position) then
		return false
	end
	local errorRadius = distance * Hearing.PositionError
	local offset = Vector3.new(math.random() * 2 - 1, 0, math.random() * 2 - 1) * errorRadius
	brain.lastHeard =
		{ position = noise.position + offset, time = os.clock(), kind = noise.kind, source = noise.source }
	local source = noise.source
	if typeof(source) == "Instance" and source:IsA("Player") then
		if noise.kind == "Gunshot" then
			brain.vigilance[source] = Vision.TargetAt -- un coup de feu met la vigilance du tireur à 1,0
			brain.knownPosition[source] = noise.position
		else
			-- DÉFAUT : un bruit entendu fait tourner la tête (vigilance au moins 0,3)
			brain.vigilance[source] = math.max(brain.vigilance[source] or 0, Vision.TurnHeadAt)
		end
	end
	return true
end

-- échantillons des ruisseaux (ancres et contrôles des tracés R1–R3)
local function sampleRivers()
	for _, path in MapConfig.Paths do
		if path.kind == "River" then
			local previous = nil
			for _, point in path.points do
				local xz = point.c or point
				local current = Vector3.new(xz[1], 0, xz[2])
				if previous then
					local steps = math.ceil((current - previous).Magnitude / Hearing.StreamRange)
					for i = 0, steps do
						table.insert(riverSamples, previous:Lerp(current, i / steps))
					end
				end
				previous = current
			end
		end
	end
end

function Perception:Init(allServices)
	services = allServices
	sampleRivers()
end

function Perception:Start()
	local _ = Players
end

return Perception
