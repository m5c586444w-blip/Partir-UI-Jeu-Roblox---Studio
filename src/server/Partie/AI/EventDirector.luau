-- ServerScriptService/AI/EventDirector (Partie)
-- Section 10 : événements inexpliqués EVT_01 à EVT_22. Règles de 10.1 : le son avant l'image ; rien
-- n'apparaît sous les yeux (hors du champ de tous les joueurs ou à plus de 80 studs) ; 1 événement au
-- plus toutes les 45 s par joueur ; le même jamais deux fois en 10 min. Fréquence × taille du groupe (5.5).
-- Modèles : ServerStorage/Props (16.1) ; absent → bloc gris MANQUANT_<ID>. Sons : AudioConfig (13.7).
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local ActConfig = require(Config:WaitForChild("ActConfig"))
local CinematicConfig = require(Config:WaitForChild("CinematicConfig"))
local DirectorConfig = require(Config:WaitForChild("DirectorConfig"))
local ItemConfig = require(Config:WaitForChild("ItemConfig"))
local MapConfig = require(Config:WaitForChild("MapConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local EventDirector = {}

local services = nil
local ai = nil
local lastForPlayer = {} -- [Player] = os.clock()
local lastEvent = {} -- [EVT_xx] = os.clock()
local guarantees = { sightings = 0, signs = 0 }
local Staging = DirectorConfig.Staging
-- DÉFAUT (technique) : durée de vie d'un décor posé par un événement (s)
local PROP_LIFETIME = Staging.NoRepeatFor

-- 10.1 : un point est-il sous les yeux d'un joueur (dans son champ, à moins de 80 studs) ?
local function inViewOfAnyone(position)
	for _, player in Players:GetPlayers() do
		local head = player.Character and player.Character:FindFirstChild("Head")
		if head then
			local offset = position - head.Position
			if offset.Magnitude <= Staging.OutOfViewOrBeyond and head.CFrame.LookVector:Dot(offset.Unit) > 0 then
				return true
			end
		end
	end
	return false
end

local function spawnProp(propId, position)
	if inViewOfAnyone(position) then
		return nil
	end
	local folder = ServerStorage:FindFirstChild("Props")
	local base = string.gsub(propId, "^Prop_", "")
	base = string.gsub(base, "_%u$", "")
	local template = folder and (folder:FindFirstChild(propId) or folder:FindFirstChild(base))
	local prop
	if template then
		prop = template:Clone()
		prop:PivotTo(CFrame.new(position))
	else
		prop = Instance.new("Part")
		prop.Name = "MANQUANT_" .. propId
		prop.Size = ItemConfig.PlaceholderSize
		prop.Color = ItemConfig.PlaceholderColor
		prop.Anchored = true
		prop.Position = position
	end
	prop.Parent = workspace
	Debris:AddItem(prop, PROP_LIFETIME)
	return prop
end

-- point au loin ou tout près d'un joueur, hors de sa vue (derrière lui)
local function pointNear(player, distance)
	local root = Util.characterRoot(player)
	if root == nil then
		return nil
	end
	local back = -root.CFrame.LookVector
	local side = root.CFrame.RightVector * (math.random() - 0.5)
	return root.Position + (back + side).Unit * distance
end

-- 9.6 et EVT_01 : la faune se tait autour d'un point (lu par AmbienceController)
function EventDirector:FaunaSilence(position, radius)
	Util.getMatchState():SetAttribute(
		"faunaSilence",
		Util.encode({ x = position.X, z = position.Z, r = radius, at = workspace:GetServerTimeNow() })
	)
end

-- 9.5 BHV_Mark et EVT_04 : le tas de pierres grandit d'un niveau
function EventDirector:GrowStonePile(tree)
	local pile = tree:FindFirstChild("StonePile")
	if pile == nil then
		pile = spawnProp("Prop_StonePile_A", tree.Position)
		if pile then
			pile.Name = "StonePile"
			pile.Parent = tree
		end
	end
	if pile then
		pile:SetAttribute("level", (pile:GetAttribute("level") or 0) + 1)
	end
end

local HANDLERS = {}

HANDLERS.FaunaSilence = function(def, player)
	local root = Util.characterRoot(player)
	if root then
		EventDirector:FaunaSilence(root.Position, def.radius)
		return true
	end
	return false
end

HANDLERS.Sound = function(def, player)
	local far = pointNear(player, if def.nearWater then DirectorConfig.NearDistance else DirectorConfig.FarDistance)
	if far == nil then
		return false
	end
	ai.CreatureAnimator:PlaySoundAt(def.sounds[1], far)
	if def.pair then
		-- puis la réponse de l'autre côté
		local root = Util.characterRoot(player)
		task.delay(Staging.PerPlayerInterval / 10, function()
			if root then
				ai.CreatureAnimator:PlaySoundAt(def.sounds[#def.sounds], root.Position + (root.Position - far))
			end
		end)
	end
	return true
end

HANDLERS.Prop = function(def, player)
	local place = def.places and MapConfig.Places[def.places[1]]
	local position = if place then place.pos else pointNear(player, Staging.OutOfViewOrBeyond)
	if position == nil then
		return false
	end
	local prop = spawnProp(def.props[math.random(1, #def.props)], position)
	if prop and def.tag then
		CollectionService:AddTag(prop, def.tag)
	end
	return prop ~= nil
end

HANDLERS.Footprints = function(def)
	local place = MapConfig.Places[def.places[math.random(1, #def.places)]]
	local position = place.pos
		+ Vector3.new(math.random(-place.radius, place.radius), 0, math.random(-place.radius, place.radius))
	if inViewOfAnyone(position) then
		return false
	end
	ai.FamilyBrain:PlaceFootprint(position)
	return true
end

HANDLERS.Mimic = function(_def, player)
	for _, brain in ai.FamilyBrain:GetBrains() do
		if brain.def.role == "Scout" and not brain.dead then
			ai.MimicService:Play(brain, player)
			return true
		end
	end
	return false
end

HANDLERS.Smell = function(_def, player)
	player:SetAttribute("smellAt", workspace:GetServerTimeNow()) -- vignettage vert très léger (client)
	return true
end

HANDLERS.EyeShine = function(def, player)
	local position = pointNear(player, def.distance)
	if position and player:GetAttribute("lightOn") then
		local marker = spawnProp(def.effect, position)
		if marker then
			Debris:AddItem(marker, def.duration)
			return true
		end
	end
	return false
end

HANDLERS.TabletBar = function(_def, player)
	if player:GetAttribute("tabletOpen") then
		player:SetAttribute("network", true)
		task.delay(require(Config:WaitForChild("CreatureConfig")).Technical.TabletBarDuration, function()
			player:SetAttribute("network", false)
		end)
		return true
	end
	return false
end

HANDLERS.EchoSteps = function(def, player)
	local root = Util.characterRoot(player)
	if root then
		task.delay(def.delay, function()
			ai.CreatureAnimator:PlaySoundAt(
				def.sounds[1],
				root.Position - root.CFrame.LookVector * DirectorConfig.NearDistance
			)
		end)
		return true
	end
	return false
end

HANDLERS.Radio = function(def, player)
	if services.InventoryService:Has(player, "ITM_Walkie") then
		local root = Util.characterRoot(player)
		if root then
			ai.CreatureAnimator:PlaySoundAt(def.sounds[1], root.Position)
			return true
		end
	end
	return false
end

-- événements qui demandent un décor précis posé dans Studio (porte P17, corps de Leah, sac, silhouette) :
-- ils ne se déclenchent que si l'objet existe (Workspace/Places/<lieu>/<nom>)
local function placed(code, name)
	local places = workspace:FindFirstChild("Places")
	local folder = places and places:FindFirstChild(code, true)
	return folder and folder:FindFirstChild(name, true)
end

HANDLERS.Door = function(def)
	local door = placed(def.places[1], "Door")
	if door and door:IsA("BasePart") and not inViewOfAnyone(door.Position) then
		door.CFrame *= CFrame.Angles(0, math.rad(90), 0) -- constante (porte ouverte d'un quart de tour)
		ai.CreatureAnimator:PlaySoundAt(def.sounds[1], door.Position)
		return true
	end
	return false
end

HANDLERS.MoveBody = function()
	local body = placed("P09", "Body_LeahBrandt")
	local camp = MapConfig.Places.P09
	if body and not inViewOfAnyone(body:GetPivot().Position) then
		body:PivotTo(
			CFrame.new(
				camp.pos
					+ Vector3.new(
						math.random(-camp.radius, camp.radius) / 2,
						0,
						math.random(-camp.radius, camp.radius) / 2
					)
			)
		)
		return true
	end
	return false
end

HANDLERS.AlignBag = function()
	for _, bag in workspace:FindFirstChild("WorldItems") and workspace.WorldItems:GetChildren() or {} do
		if bag.Name == "DeadBag" and bag:IsA("BasePart") and not inViewOfAnyone(bag.Position) then
			bag:SetAttribute("aligned", true)
			return true
		end
	end
	return false
end

HANDLERS.Silhouette = function(def)
	for _, brain in ai.FamilyBrain:GetBrains() do
		if brain.id == "CRT_Alpha" and not brain.dead and not brain:HasBody() then
			local lake = MapConfig.Places[def.places[1]].pos
			brain.virtualPosition = lake
			return true
		end
	end
	return false
end

local function eligible(id, def, act, player)
	if act < def.acts[1] or act > def.acts[2] then
		return false
	end
	if os.clock() - (lastEvent[id] or -math.huge) < Staging.NoRepeatFor then
		return false
	end
	return os.clock() - (lastForPlayer[player] or -math.huge) >= Staging.PerPlayerInterval
end

-- tire un événement du catalogue « bas » pour un joueur
function EventDirector:RequestLow(player)
	local state = Util.getMatchState()
	local act = state:GetAttribute("act") or 0
	local players = if player then { player } else Players:GetPlayers()
	local info = services.PartyLoaderService:GetMatchInfo()
	-- 5.5 : événements du directeur ×0,8 / ×1,0 / ×1,2 selon la taille du groupe
	if math.random() > ActConfig.groupSize(info.playerCount).directorEvents then
		return false
	end
	for _, p in players do
		local ids = DirectorConfig.LowCatalog or Util.sortedKeys(DirectorConfig.Events)
		for i = #ids, 2, -1 do
			local j = math.random(1, i)
			ids[i], ids[j] = ids[j], ids[i]
		end
		for _, id in ids do
			local def = DirectorConfig.Events[id]
			local handler = HANDLERS[def.kind]
			if handler and eligible(id, def, act, p) and handler(def, p) then
				lastEvent[id] = os.clock()
				lastForPlayer[p] = os.clock()
				guarantees.signs += 1
				return true
			end
		end
	end
	return false
end

-- 9.12 acte 1 : garantis 1 aperçu lointain (CS_03) et 2 signes ; au-delà de la moitié de l'acte
function EventDirector:EnsureAct1Guarantees()
	local act = ActConfig.Acts[1]
	local started = services.GameStateService and Util.getMatchState():GetAttribute("act") == 1
	if not started then
		return
	end
	self.act1Start = self.act1Start or os.clock()
	if os.clock() - self.act1Start < act.minDuration / 2 then
		return
	end
	if guarantees.signs < DirectorConfig.Act1.GuaranteedSigns then
		self:RequestLow()
	end
	if guarantees.sightings < DirectorConfig.Act1.GuaranteedSightings then
		local players = Players:GetPlayers()
		local player = players[math.random(1, math.max(1, #players))]
		if player then
			guarantees.sightings += 1
			services.CinematicService:Play("CS_03", { player })
			local def = CinematicConfig.Cinematics.CS_03
			self:FaunaSilence(
				Util.characterRoot(player) and Util.characterRoot(player).Position or Vector3.zero,
				DirectorConfig.Events.EVT_01.radius
			)
			for _, brain in ai.FamilyBrain:GetBrains() do
				if brain.id == "CRT_Alpha" then
					local point = pointNear(player, (def.silhouetteMin + def.silhouetteMax) / 2)
					if point then
						brain.virtualPosition = point
					end
				end
			end
		end
	end
end

function EventDirector:Init(allServices, aiModules)
	services = allServices
	ai = aiModules
end

function EventDirector:Start() end

return EventDirector
