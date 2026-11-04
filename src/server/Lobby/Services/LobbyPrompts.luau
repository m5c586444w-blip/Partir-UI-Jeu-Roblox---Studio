-- ServerScriptService/Services/LobbyPrompts (Lobby)
-- DÉFAUT : module ajouté. Invites ProximityPrompt du lobby (ranger, panneaux du musée, magasin, diner).
-- Ancres : Part taguées dans Studio (RangerHollis, MuseumPanel + attribut panelId, SkinShop,
-- RecordsBoard, EvidenceBoard) ; sans elles, ancres invisibles aux positions de 4.1 (MapConfig.Lobby).
-- Le client ouvre l'interface quand l'invite est déclenchée (attribut lobbyAction de l'invite).
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local ItemConfig = require(Config:WaitForChild("ItemConfig"))
local LoreConfig = require(Config:WaitForChild("LoreConfig"))
local MapConfig = require(Config:WaitForChild("MapConfig"))

local LobbyPrompts = {}

-- DÉFAUT : libellés courts des invites (15.6 : « Parle au ranger » vient de 4.2)
local ACTIONS = {
	RangerHollis = { action = LoreConfig.Dialogue.Prompt, place = "L02", lobbyAction = "Dialogue" },
	SkinShop = { action = LoreConfig.Prompts.SkinShop, place = "L04", lobbyAction = "SkinShop" },
	RecordsBoard = { action = LoreConfig.Prompts.Records, place = "L05", lobbyAction = "Records" },
	EvidenceBoard = { action = LoreConfig.Prompts.EvidenceBoard, place = "L03", lobbyAction = "EvidenceBoard" }, -- 4.5 : au musée
}

local function anchor(tag, position)
	local tagged = CollectionService:GetTagged(tag)
	if #tagged > 0 then
		return tagged
	end
	local part = Instance.new("Part")
	part.Name = tag
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.Size = ItemConfig.PlaceholderSize
	part.Position = position
	part.Parent = workspace
	return { part }
end

local function prompt(parent, action, lobbyAction, panelId)
	local p = Instance.new("ProximityPrompt")
	p.ActionText = action
	p.MaxActivationDistance = ItemConfig.PickupDistance
	p.RequiresLineOfSight = false
	p:SetAttribute("lobbyAction", lobbyAction)
	if panelId then
		p:SetAttribute("panelId", panelId)
	end
	p.Parent = parent
	return p
end

function LobbyPrompts:Init() end

function LobbyPrompts:Start()
	for tag, spec in ACTIONS do
		for _, part in anchor(tag, MapConfig.Lobby[spec.place].pos) do
			prompt(part, spec.action, spec.lobbyAction)
		end
	end
	-- 4.3 : 8 panneaux ; sans Part taguées, ancres alignées dans le musée (DÉFAUT)
	local panels = CollectionService:GetTagged("MuseumPanel")
	if #panels == 0 then
		local museum = MapConfig.Lobby.L03.pos
		for i = 1, #require(Config:WaitForChild("ProgressionConfig")).MuseumPanelIds do
			local part = Instance.new("Part")
			part.Name = "MuseumPanel_M" .. i
			part.Anchored = true
			part.CanCollide = false
			part.Transparency = 1
			part.Size = ItemConfig.PlaceholderSize
			part.Position = museum + Vector3.new((i - 1) * ItemConfig.PickupDistance / 2, 0, 0)
			part:SetAttribute("panelId", "M" .. i)
			part.Parent = workspace
			table.insert(panels, part)
		end
	end
	for _, part in panels do
		local id = part:GetAttribute("panelId")
		if id and LoreConfig.Museum[id] then
			prompt(part, LoreConfig.Prompts.Read, "Museum", id)
		end
	end
end

return LobbyPrompts
