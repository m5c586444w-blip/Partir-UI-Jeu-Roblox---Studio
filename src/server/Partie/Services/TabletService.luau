-- ServerScriptService/Services/TabletService (Partie)
-- DÉFAUT : module ajouté — 16.2 ne nomme pas le service qui traite RE_TabletAction (16.3).
-- Section 8.3 : une tablette par groupe (Meneur, sinon le premier joueur), écran = visibilité ×1,5,
-- batterie de 30 min d'écran allumé, GPS à ±30 studs toutes les 10 s (50 % « Pas de signal GPS »
-- sous forêt dense), 8 repères, Réseau : une barre au sommet de P11 et à P23, SMS au ranger Hollis.
-- RE_TabletAction (C → S) : (app, action, data). Contrôle : porte la tablette.
-- Attributs : tabletOpen, tabletBattery, gpsX, gpsZ, gpsSignal, tabletMessage (joueur) ;
-- markers (MatchState, JSON).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local ItemConfig = require(Config:WaitForChild("ItemConfig"))
local LoreConfig = require(Config:WaitForChild("LoreConfig"))
local MapConfig = require(Config:WaitForChild("MapConfig"))
local PlayerConfig = require(Config:WaitForChild("PlayerConfig"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local RateLimiter = require(Shared:WaitForChild("RateLimiter"))
local Util = require(Shared:WaitForChild("Util"))

local TabletService = {}

local services = nil
local Tablet = ItemConfig.Tablet
local markers = {}
local random = Random.new()

local function tabletEntry(player)
	local inv = services.InventoryService:Get(player)
	if inv == nil then
		return nil
	end
	for _, list in { inv.quick, inv.bag } do
		for _, entry in list do
			if entry and entry.id == "ITM_TabletField" then
				return entry
			end
		end
	end
	return nil
end

local function setOpen(player, open)
	local entry = tabletEntry(player)
	if entry == nil or (open and (entry.battery or 1) <= 0) then
		open = false
	end
	player:SetAttribute("tabletOpen", open)
end

local function inDenseForest(position)
	local zone = MapConfig.Places.P04.zone
	return position.X >= zone.minX and position.X <= zone.maxX and position.Z >= zone.minZ and position.Z <= zone.maxZ
end

-- 8.3 : une barre au sommet de P11 et à P23 (DÉFAUT : « sommet » = dans le rayon et au niveau de la cabine)
local function hasNetwork(position)
	for _, code in Tablet.NetworkPlaces do
		local place = MapConfig.Places[code]
		local flat = Vector2.new(position.X - place.pos.X, position.Z - place.pos.Z).Magnitude
		local minY = place.pos.Y + (place.cabinOffset or 0) / 2
		if flat <= place.radius and position.Y >= minY then
			return true
		end
	end
	return false
end

local function updateGps(player)
	local root = Util.characterRoot(player)
	if root == nil or tabletEntry(player) == nil then
		return
	end
	if inDenseForest(root.Position) and random:NextNumber() < Tablet.DenseForestNoSignalChance then
		player:SetAttribute("gpsSignal", false)
		return
	end
	local e = Tablet.GpsError
	player:SetAttribute("gpsSignal", true)
	player:SetAttribute("gpsX", root.Position.X + random:NextNumber(-e, e))
	player:SetAttribute("gpsZ", root.Position.Z + random:NextNumber(-e, e))
	player:SetAttribute("network", hasNetwork(root.Position))
end

local ACTIONS = {
	Device = {
		Toggle = function(player)
			setOpen(player, not player:GetAttribute("tabletOpen"))
		end,
		Close = function(player)
			setOpen(player, false)
		end,
	},
	Map = {
		AddMarker = function(_player, data)
			if type(data) ~= "table" or type(data.x) ~= "number" or type(data.z) ~= "number" then
				return
			end
			if #markers >= Tablet.MaxMarkers then
				return
			end
			table.insert(markers, { x = data.x, z = data.z })
			Util.getMatchState():SetAttribute("markers", Util.encode(markers))
		end,
		RemoveMarker = function(_player, data)
			if type(data) == "table" and type(data.index) == "number" and markers[data.index] then
				table.remove(markers, data.index)
				Util.getMatchState():SetAttribute("markers", Util.encode(markers))
			end
		end,
	},
	Network = {
		Send = function(player)
			local root = Util.characterRoot(player)
			if root and hasNetwork(root.Position) then
				-- 8.3 : réponse automatique du ranger Hollis
				player:SetAttribute("tabletMessage", LoreConfig.Tablet.HollisReply)
			else
				player:SetAttribute("tabletMessage", LoreConfig.Tablet.NoNetwork)
			end
		end,
	},
}

local function onAction(player, app, action, data)
	if type(app) ~= "string" or type(action) ~= "string" then
		return
	end
	if tabletEntry(player) == nil then
		return -- 16.3 : porte la tablette
	end
	local handlers = ACTIONS[app]
	local handler = handlers and handlers[action]
	if handler then
		handler(player, data)
	end
end

local function tick(dt)
	for _, player in Players:GetPlayers() do
		local entry = tabletEntry(player)
		if entry == nil and player:GetAttribute("tabletOpen") then
			player:SetAttribute("tabletOpen", false)
		end
		if entry and player:GetAttribute("tabletOpen") then
			entry.battery = math.max(0, (entry.battery or 1) - dt / (Tablet.BatteryMinutes * Util.SECONDS_PER_MINUTE))
			player:SetAttribute("tabletBattery", entry.battery)
			if entry.battery <= 0 then
				setOpen(player, false)
			end
		elseif entry then
			player:SetAttribute("tabletBattery", entry.battery or 1)
		end
	end
end

-- repère posé par le jeu (19.5, C7 : indice caché HC1, gué de HC3) ; hors de la limite des joueurs
function TabletService:AddMarker(position)
	table.insert(markers, { x = position.X, z = position.Z })
	Util.getMatchState():SetAttribute("markers", Util.encode(markers))
end

function TabletService:Init(allServices)
	services = allServices
end

function TabletService:Start()
	local remote = Util.getRemote("RE_TabletAction")
	if remote then
		RateLimiter.connect(remote, onAction)
	end
	services.InventoryService.ItemUsed:Connect(function(player, itemId)
		if itemId == "ITM_TabletField" then
			setOpen(player, not player:GetAttribute("tabletOpen"))
		end
	end)
	-- 8.3 : sans Meneur, la tablette va au premier joueur du groupe
	task.spawn(function()
		local _, players = services.PartyLoaderService:WaitUntilLoaded()
		task.wait(PlayerConfig.Technical.Tick * 2)
		local hasLeader = false
		for _, player in Players:GetPlayers() do
			if player:GetAttribute("role") == "Leader" then
				hasLeader = true
			end
		end
		local first = players[1] or Players:GetPlayers()[1]
		if not hasLeader and first then
			services.InventoryService:Add(first, "ITM_TabletField", 1)
		end
	end)
	task.spawn(function()
		local elapsed = 0
		local step = PlayerConfig.Technical.Tick
		while true do
			task.wait(step)
			tick(step)
			elapsed += step
			if elapsed >= Tablet.GpsInterval then
				elapsed = 0
				for _, player in Players:GetPlayers() do
					updateGps(player)
				end
			end
		end
	end)
end

return TabletService
