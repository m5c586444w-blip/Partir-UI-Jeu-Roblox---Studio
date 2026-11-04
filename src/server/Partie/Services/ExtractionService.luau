-- ServerScriptService/Services/ExtractionService (Partie)
-- Sections 3.3, 5.2 et 16.2 : voies d'extraction E1–E4.
-- Une voie principale est tirée parmi E1, E2, E3 ; E4 est ouverte si DOC_07 a été lu.
-- Préparation (acte 3) : E1 changer la roue (cric, 20 s / 10 s Mécanicienne) ; E2 réparer la radio
-- (câble + batterie, 30 s) ; E3 réparer le bulldozer (jerrican + relais, 40 s).
-- Déclenchement (acte 4, DÉFAUT) : E1 démarrer le van (clés) ; E2 appeler puis tenir 180 s sur l'aire ;
-- E3 conduire 650 studs à 8 studs/s ; E4 dégager le bouchon (60 s, DOC_07 + une lampe).
-- Ancres : Part de Workspace/Places nommées E1_Van, E2_Radio, E2_Pad, E3_Bulldozer, E4_Plug si
-- Gabriel les pose ; sinon ancres invisibles aux coordonnées de MapConfig (DÉFAUT).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = ReplicatedStorage:WaitForChild("Config")
local ActConfig = require(Config:WaitForChild("ActConfig"))
local ItemConfig = require(Config:WaitForChild("ItemConfig"))
local LoreConfig = require(Config:WaitForChild("LoreConfig"))
local MapConfig = require(Config:WaitForChild("MapConfig"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local NoiseTypes = require(Shared:WaitForChild("NoiseTypes"))
local Signal = require(Shared:WaitForChild("Signal"))
local Util = require(Shared:WaitForChild("Util"))

local ExtractionService = {}

ExtractionService.Prepared = Signal.new() -- (routeId) : la voie est prête (fin de l'acte 3)
ExtractionService.Extracted = Signal.new() -- (routeId, players) : extraction déclenchée
ExtractionService.Calling = Signal.new() -- (routeId, endTime) : E2, attente de l'hélicoptère

local services = nil
local routes = {} -- [routeId] = { prepared, triggered, prompts = {} }
local mainRoute = nil
local triggersOpen = false

local Routes = ActConfig.Routes

local function anchor(name, position)
	local places = workspace:FindFirstChild("Places")
	local found = places and places:FindFirstChild(name, true)
	if found and found:IsA("BasePart") then
		return found
	end
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.Size = ItemConfig.PlaceholderSize
	part.Position = position
	part.Parent = workspace
	return part
end

-- joueurs debout dans un rayon
local function playersNear(position, radius)
	local list = {}
	for _, player in Players:GetPlayers() do
		local root = Util.characterRoot(player)
		if root and services.HealthService:IsUp(player) and (root.Position - position).Magnitude <= radius then
			table.insert(list, player)
		end
	end
	return list
end

-- objets demandés : portés par le joueur ou par un coéquipier tout près
local function hasItems(player, position, items)
	local nearby = playersNear(position, ItemConfig.PickupDistance)
	if not table.find(nearby, player) then
		table.insert(nearby, player)
	end
	for _, id in items do
		local found = false
		for _, p in nearby do
			if services.InventoryService:Has(p, id) then
				found = true
			end
		end
		if not found then
			return false
		end
	end
	return true
end

local function consume(player, position, items)
	local nearby = playersNear(position, ItemConfig.PickupDistance)
	table.insert(nearby, 1, player)
	for _, id in items do
		for _, p in nearby do
			if services.InventoryService:Remove(p, id, 1) then
				break
			end
		end
	end
end

-- 8.1 : caisse à outils : réparations à vitesse normale ; sans elle, ×2 plus long ;
-- 5.2 et 7.7 : durée propre à la Mécanicienne
local function repairDuration(route, base)
	return function(player)
		local duration = (route.roleRepairTime and route.roleRepairTime[player:GetAttribute("role")]) or base
		if
			player:GetAttribute("role") == "Mechanic" and not (route.roleRepairTime and route.roleRepairTime.Mechanic)
		then
			duration /= require(Config:WaitForChild("PlayerConfig")).Abilities.Mechanic.RepairFactor
		end
		if not services.InventoryService:Has(player, "ITM_ToolBox") then
			duration *= ItemConfig.Items.ITM_ToolBox.withoutFactor
		end
		return duration
	end
end

local function prepared(routeId)
	routes[routeId].prepared = true
	ExtractionService.Prepared:Fire(routeId)
end

local function extract(routeId, players)
	local state = routes[routeId]
	if state.triggered then
		return
	end
	state.triggered = true
	ExtractionService.Extracted:Fire(routeId, players)
end

local function prompt(routeId, part, opts)
	local p = services.InteractionService:CreatePrompt(part, opts)
	table.insert(routes[routeId].prompts, p)
	return p
end

local SETUP = {}

SETUP.E1 = function(route)
	local part = anchor("E1_Van", MapConfig.Extractions.E1.pos)
	prompt("E1", part, {
		action = LoreConfig.Prompts.ChangeWheel,
		durationFor = repairDuration(route, route.repairTime),
		holdDuration = route.repairTime,
		canUse = function(player)
			return not routes.E1.prepared and hasItems(player, part.Position, { "ITM_Jack" })
		end,
		onTriggered = function()
			prepared("E1")
		end,
	})
	prompt("E1", part, {
		action = LoreConfig.Prompts.Drive,
		canUse = function(player)
			return routes.E1.prepared and triggersOpen and hasItems(player, part.Position, { "ITM_Keys" })
		end,
		onTriggered = function(player)
			-- 5.2 : démarrage bruyant ; les joueurs autour du van partent (P01, rayon 60)
			-- TODO(BIBLE): rayon du bruit du démarrage du van
			local noise = ActConfig.Routes.E1.startNoise
			if noise then
				services.NoiseService:Emit(part.Position, noise, NoiseTypes.Vehicle, player)
			end
			extract("E1", playersNear(MapConfig.Places.P01.pos, MapConfig.Places.P01.radius))
		end,
	})
end

SETUP.E2 = function(route)
	local p11 = MapConfig.Places.P11
	local radio = anchor("E2_Radio", p11.pos + Vector3.new(0, p11.cabinOffset, 0))
	local pad = MapConfig.Extractions.E2
	prompt("E2", radio, {
		action = LoreConfig.Prompts.Repair,
		durationFor = repairDuration(route, route.repairTime),
		holdDuration = route.repairTime,
		canUse = function(player)
			return not routes.E2.prepared and hasItems(player, radio.Position, route.needs)
		end,
		onTriggered = function(player)
			consume(player, radio.Position, route.needs)
			prepared("E2")
			-- 2.7 : DOC_09 rejoué quand la radio est réparée
			for _, listener in playersNear(radio.Position, p11.radius + p11.cabinOffset) do
				services.DocumentService:AddToJournal("DOC_09", listener)
				services.DocumentService:Open(listener, "DOC_09")
			end
		end,
	})
	prompt("E2", radio, {
		action = LoreConfig.Prompts.Call,
		canUse = function()
			return routes.E2.prepared and triggersOpen and not routes.E2.calling
		end,
		onTriggered = function()
			routes.E2.calling = true
			local endTime = workspace:GetServerTimeNow() + route.holdTime
			Util.getMatchState():SetAttribute("helicopterAt", endTime)
			ExtractionService.Calling:Fire("E2", endTime)
			task.delay(route.holdTime, function()
				local half = pad.area / 2
				local list = {}
				for _, player in Players:GetPlayers() do
					local root = Util.characterRoot(player)
					if root and services.HealthService:IsUp(player) then
						local d = root.Position - pad.pos
						if math.abs(d.X) <= half.X and math.abs(d.Z) <= half.Y then
							table.insert(list, player)
						end
					end
				end
				extract("E2", list)
			end)
		end,
	})
end

SETUP.E3 = function(route)
	local p10 = MapConfig.Places.P10
	local bulldozer = anchor("E3_Bulldozer", p10.pos)
	prompt("E3", bulldozer, {
		action = LoreConfig.Prompts.Repair,
		durationFor = repairDuration(route, route.repairTime),
		holdDuration = route.repairTime,
		canUse = function(player)
			return not routes.E3.prepared and hasItems(player, bulldozer.Position, route.needs)
		end,
		onTriggered = function(player)
			consume(player, bulldozer.Position, route.needs)
			prepared("E3")
		end,
	})
	prompt("E3", bulldozer, {
		action = LoreConfig.Prompts.Drive,
		canUse = function()
			return routes.E3.prepared and triggersOpen and not routes.E3.driving
		end,
		onTriggered = function()
			routes.E3.driving = true
			-- 5.2 : conduire 650 studs jusqu'à la barrière, lent (8 studs/s) ; la créature peut y grimper
			local target = MapConfig.Extractions.E3.pos
			local direction = (target - bulldozer.Position) * Vector3.new(1, 0, 1)
			local goal = bulldozer.Position + direction.Unit * route.driveDistance
			local duration = route.driveDistance / route.driveSpeed
			bulldozer:AddTag("Bulldozer")
			local tween =
				TweenService:Create(bulldozer, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Position = goal })
			tween:Play()
			tween.Completed:Wait()
			-- DÉFAUT : les joueurs à portée d'interaction du bulldozer partent avec lui
			extract("E3", playersNear(bulldozer.Position, ItemConfig.PickupDistance))
		end,
	})
end

SETUP.E4 = function(route)
	local plug = anchor("E4_Plug", MapConfig.Places.P07c.pos)
	prompt("E4", plug, {
		action = LoreConfig.Prompts.ClearPlug,
		holdDuration = route.clearTime,
		canUse = function(player)
			local hasLight = player:GetAttribute("lightOn") == true
			return triggersOpen and services.DocumentService:HasRead("DOC_07") and hasLight
		end,
		onTriggered = function()
			local p07c = MapConfig.Places.P07c
			-- DÉFAUT : les joueurs à portée d'interaction de la sortie partent
			extract("E4", playersNear(plug.Position, math.max(p07c.radius, ItemConfig.PickupDistance)))
		end,
	})
end

-- fin du siège : tirage de la voie principale (graine de la partie)
function ExtractionService:DrawMainRoute(seed)
	local random = Random.new(seed)
	mainRoute = ActConfig.MainRoutes[random:NextInteger(1, #ActConfig.MainRoutes)]
	Util.getMatchState():SetAttribute("mainRoute", mainRoute)
	return mainRoute
end

function ExtractionService:GetMainRoute()
	return mainRoute
end

-- acte 3 : active la voie principale, et E4 si DOC_07 a été lu
function ExtractionService:Activate()
	local list = { mainRoute }
	if services.DocumentService:HasRead(ActConfig.SecretRoute.requiresDocument) then
		table.insert(list, ActConfig.SecretRoute.id)
	end
	for _, routeId in list do
		if routes[routeId] == nil then
			routes[routeId] = { prompts = {} }
			SETUP[routeId](Routes[routeId])
		end
	end
	Util.getMatchState():SetAttribute("routes", Util.encode(list))
end

-- E4 ouverte dès que DOC_07 est lu pendant l'acte 3 ou 4
function ExtractionService:OnDocumentRead(docId)
	if docId == ActConfig.SecretRoute.requiresDocument and mainRoute ~= nil then
		self:Activate()
	end
end

-- acte 4 : les déclenchements deviennent possibles (DÉFAUT)
function ExtractionService:OpenTriggers()
	triggersOpen = true
end

function ExtractionService:IsPrepared(routeId)
	return routes[routeId] ~= nil and routes[routeId].prepared == true
end

function ExtractionService:Init(allServices)
	services = allServices
end

function ExtractionService:Start()
	services.DocumentService.Read:Connect(function(docId)
		self:OnDocumentRead(docId)
	end)
end

return ExtractionService
