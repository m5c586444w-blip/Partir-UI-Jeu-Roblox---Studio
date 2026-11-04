-- Controllers/TabletController (Partie)
-- Sections 8.3 et 15.4 : TabletGui. Applis Carte (GPS, repères, couche « tunnels »), Objectifs,
-- Journal (documents lus, dans l'ordre), Preuves (preuves du groupe, qui les porte), Réseau.
-- Ouverte quand l'attribut tabletOpen est vrai (TabletService).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local ItemConfig = require(Config:WaitForChild("ItemConfig"))
local LoreConfig = require(Config:WaitForChild("LoreConfig"))
local MapConfig = require(Config:WaitForChild("MapConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local TabletController = {}

local player = Players.LocalPlayer
local root = nil
local remote = nil
local state = nil

local PAGES = {
	Btn_Map = "Page_Map",
	Btn_Objectives = "Page_Objectives",
	Btn_Journal = "Page_Journal",
	Btn_Evidence = "Page_Evidence",
	Btn_Network = "Page_Network",
}

local function find(path)
	return Util.findUI(root, "TabletGui/Device/" .. path)
end

local function showPage(pageName)
	for _, name in PAGES do
		local page = find("Screen/Pages/" .. name)
		if page then
			page.Visible = name == pageName
		end
	end
end

-- carte 8 000 × 8 000 studs → coordonnées de l'image (0..1)
local function toMap(x, z)
	local half = MapConfig.Size / 2
	return (x + half) / MapConfig.Size, (z + half) / MapConfig.Size
end

local function refreshMap()
	local dot = find("Screen/Pages/Page_Map/PlayerDot")
	local noSignal = find("Screen/Pages/Page_Map/NoSignal")
	local tunnels = find("Screen/Pages/Page_Map/TunnelLayer")
	local signal = player:GetAttribute("gpsSignal") ~= false
	if noSignal then
		noSignal.Visible = not signal
	end
	if dot then
		local x, z = player:GetAttribute("gpsX"), player:GetAttribute("gpsZ")
		-- 8.3 : dans les tunnels, seul le Géologue voit sa position sur le tracé
		local inTunnels = false
		local rootPart = Util.characterRoot(player)
		local p07 = MapConfig.Places.P07a
		if rootPart and rootPart.Position.Y < p07.pos.Y - p07.radius then
			inTunnels = true
		end
		dot.Visible = signal and x ~= nil and (not inTunnels or player:GetAttribute("role") == "Geologist")
		if x then
			local u, v = toMap(x, z)
			dot.Position = UDim2.new(u, 0, v, 0)
		end
	end
	if tunnels then
		tunnels.Visible = state:GetAttribute("tunnelLayer") == true
	end
	local template = find("Screen/Pages/Page_Map/Markers/Template")
	if template then
		Util.clearClones(template)
		for i, marker in Util.decode(state:GetAttribute("markers"), {}) do
			local clone = Util.cloneTemplate(template, i)
			local u, v = toMap(marker.x, marker.z)
			clone.Position = UDim2.new(u, 0, v, 0)
		end
	end
end

local function fillList(path, items, setup)
	local template = find(path)
	if template == nil then
		return
	end
	Util.clearClones(template)
	for i, item in items do
		setup(Util.cloneTemplate(template, i), item)
	end
end

local function refreshLists()
	fillList(
		"Screen/Pages/Page_Objectives/List/Template",
		Util.decode(state:GetAttribute("objectives"), {}),
		function(row, text)
			row.Text = text
		end
	)
	fillList(
		"Screen/Pages/Page_Journal/List/Template",
		Util.decode(state:GetAttribute("journal"), {}),
		function(row, docId)
			local doc = LoreConfig.Documents[docId]
			row.Text = doc and doc.title or docId
			row.Activated:Connect(function()
				local title = find("Screen/Pages/Page_Journal/Reader/Title")
				local body = find("Screen/Pages/Page_Journal/Reader/Body")
				if title and doc then
					title.Text = doc.title
				end
				if body and doc then
					body.Text = doc.body or table.concat(doc.pages or {}, "\n\n")
				end
			end)
		end
	)
	fillList(
		"Screen/Pages/Page_Evidence/List/Template",
		Util.decode(state:GetAttribute("evidence"), {}),
		function(row, e)
			local name = ""
			for _, def in ItemConfig.Items do
				if def.evidence and def.evidence.kind == e.kind then
					name = def.name
				end
			end
			-- DÉFAUT : « A · Carte mémoire · Theo »
			row.Text = ("%s · %s · %s"):format(e.class, name, e.holder)
		end
	)
end

local function refreshNetwork()
	local bars = find("Screen/Pages/Page_Network/Bars")
	local message = find("Screen/Pages/Page_Network/Message")
	local fill = bars and bars:FindFirstChild("Fill")
	if fill then
		fill.Size = UDim2.new(if player:GetAttribute("network") then 1 else 0, 0, 1, 0)
	end
	if message then
		message.Text = player:GetAttribute("tabletMessage") or LoreConfig.Tablet.NoNetwork
	end
end

local function refresh()
	local device = Util.findUI(root, "TabletGui/Device")
	if device then
		device.Visible = player:GetAttribute("tabletOpen") == true
	end
	local battery = find("BatteryText")
	if battery then
		battery.Text = ("%d %%"):format(math.floor((player:GetAttribute("tabletBattery") or 1) * 100))
	end
	refreshMap()
	refreshNetwork()
end

function TabletController:Start()
	local gui = Util.waitGui("TabletGui")
	if gui == nil then
		return
	end
	root = gui.Parent
	state = Util.getMatchState()
	remote = Util.getRemote("RE_TabletAction")
	for buttonName, pageName in PAGES do
		local button = find("Screen/AppBar/" .. buttonName)
		if button then
			button.Activated:Connect(function()
				showPage(pageName)
			end)
		end
	end
	local close = find("Close")
	if close and remote then
		close.Activated:Connect(function()
			remote:FireServer("Device", "Close")
		end)
	end
	local send = find("Screen/Pages/Page_Network/Send")
	if send and remote then
		send.Activated:Connect(function()
			remote:FireServer("Network", "Send")
		end)
	end
	-- repère : clic sur la carte
	local map = find("Screen/Pages/Page_Map/MapImage")
	if map and remote then
		map.InputBegan:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				local rel = (Vector2.new(input.Position.X, input.Position.Y) - map.AbsolutePosition) / map.AbsoluteSize
				local half = MapConfig.Size / 2
				remote:FireServer(
					"Map",
					"AddMarker",
					{ x = rel.X * MapConfig.Size - half, z = rel.Y * MapConfig.Size - half }
				)
			end
		end)
	end
	for _, name in { "tabletOpen", "tabletBattery", "gpsX", "gpsSignal", "network", "tabletMessage" } do
		player:GetAttributeChangedSignal(name):Connect(refresh)
	end
	for _, name in { "markers", "tunnelLayer" } do
		state:GetAttributeChangedSignal(name):Connect(refreshMap)
	end
	for _, name in { "objectives", "journal", "evidence" } do
		state:GetAttributeChangedSignal(name):Connect(refreshLists)
	end
	showPage("Page_Map")
	refresh()
	refreshLists()
end

return TabletController
