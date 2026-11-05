-- ServerScriptService/Services/HiddenClueService (Partie)
-- 19.5 (C7) : 4 « marques de mineurs » (MapConfig.HiddenClues), visibles seulement par la Descendante
-- à 8 studs et seulement si elle est dans le groupe. Elle les découvre en s'approchant (serveur) ;
-- HiddenClueController les affiche pour elle seule. DÉFAUT : service à part (les effets touchent la
-- tablette, la cabane, le gué et le puits).
-- Effets : HC1 repère de la boîte de munitions sur la tablette ; HC2 trappe vers un vide sanitaire
-- (2 joueurs, attribut hiddenFromSight) ; HC3 gué silencieux (attribut noiseFactor) ; HC4 descente du
-- puits P21 sans corde (sinon ITM_Rope, 8.1).
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local LoreConfig = require(Config:WaitForChild("LoreConfig"))
local MapConfig = require(Config:WaitForChild("MapConfig"))
local PlayerConfig = require(Config:WaitForChild("PlayerConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local HiddenClueService = {}

local DESCENDANT = "Descendant"
local RANGE = PlayerConfig.Abilities.Descendant.HiddenClueRange

local services = nil
local marks = {} -- [id] = Part
local found = {} -- [id] = true
local crawlers = {} -- joueurs dans le vide sanitaire (HC2)

local function positionOf(spec)
	return spec.pos or MapConfig.resolve(spec.place)
end

-- première partie taguée (posée à la main en B1), sinon le point de repli
local function taggedPart(tag)
	return CollectionService:GetTagged(tag)[1]
end

local function inside(part, position)
	local p = part.CFrame:PointToObjectSpace(position)
	local half = part.Size / 2
	return math.abs(p.X) <= half.X and math.abs(p.Y) <= half.Y and math.abs(p.Z) <= half.Z
end

function HiddenClueService:IsFound(id)
	return found[id] == true
end

-- HC2 : entrer dans le vide sanitaire ou en sortir
local function toggleCrawl(player, mark, spec)
	local root = Util.characterRoot(player)
	if root == nil then
		return
	end
	local index = table.find(crawlers, player)
	if index then
		table.remove(crawlers, index)
		player:SetAttribute("hiddenFromSight", nil)
		root.CFrame = CFrame.new(mark.Position + Vector3.new(0, PlayerConfig.Technical.SpawnLift, 0))
		return
	end
	if #crawlers >= spec.capacity then
		return
	end
	table.insert(crawlers, player)
	player:SetAttribute("hiddenFromSight", true)
	local space = taggedPart(spec.tag)
	root.CFrame = CFrame.new(if space then space.Position else mark.Position)
end

local EFFECTS = {}

EFFECTS.AmmoBoxMarker = function()
	local draw = services.ItemSpawnService:GetDraw()
	local index = draw and draw.AmmoBox
	if index == nil then
		return -- pas de boîte (Cauchemar)
	end
	local position = MapConfig.resolve(MapConfig.KeyItems.AmmoBox.spots[index])
	if position then
		services.TabletService:AddMarker(position)
	end
end

EFFECTS.CrawlSpace = function(id, spec)
	local mark = marks[id]
	services.InteractionService:CreatePrompt(mark, {
		action = LoreConfig.Prompts.Open,
		canUse = function(player)
			return services.HealthService:IsAlive(player)
				and (table.find(crawlers, player) ~= nil or #crawlers < spec.capacity)
		end,
		onTriggered = function(player)
			toggleCrawl(player, mark, spec)
		end,
	})
end

EFFECTS.Ford = function(id, spec)
	local ford = taggedPart(spec.tag)
	services.TabletService:AddMarker(if ford then ford.Position else marks[id].Position)
	if ford == nil then
		warn("HiddenClueService : Part taguée « " .. spec.tag .. " » absente (gué de " .. id .. ", à poser en B1)")
		return
	end
	task.spawn(function()
		while true do
			for _, player in Players:GetPlayers() do
				local root = Util.characterRoot(player)
				local onFord = root ~= nil and inside(ford, root.Position)
				player:SetAttribute("noiseFactor", if onFord then spec.noiseFactor else nil)
			end
			task.wait(PlayerConfig.Technical.Tick)
		end
	end)
end

EFFECTS.Ring = function() end -- lu par l'invite du puits (HiddenClueService:IsFound)

local function discover(id)
	if found[id] then
		return
	end
	found[id] = true
	marks[id]:SetAttribute("found", true)
	local spec = MapConfig.HiddenClues[id]
	EFFECTS[spec.effect](id, spec)
end

-- 8.1 : descendre dans le puits P21 avec une corde ; 19.5 (HC4) : sans corde une fois l'anneau trouvé
local function setupWell()
	local well = MapConfig.Places.P21
	local anchor = Instance.new("Part")
	anchor.Name = "P21_Well"
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.Transparency = 1
	anchor.Size = MapConfig.HiddenClueMarkSize
	anchor.Position = well.pos
	anchor.Parent = workspace
	services.InteractionService:CreatePrompt(anchor, {
		action = LoreConfig.Prompts.Descend,
		canUse = function(player)
			return services.HealthService:IsUp(player)
				and (services.InventoryService:Has(player, "ITM_Rope") or found.HC4 == true)
		end,
		onTriggered = function(player)
			local root = Util.characterRoot(player)
			if root then
				root.CFrame = CFrame.new(well.pos.X, well.tubeY + MapConfig.WellDescentLift, well.pos.Z)
			end
		end,
	})
end

function HiddenClueService:Init(allServices)
	services = allServices
end

function HiddenClueService:Start()
	local folder = Instance.new("Folder")
	folder.Name = "HiddenClues"
	folder.Parent = workspace
	for _, id in Util.sortedKeys(MapConfig.HiddenClues) do
		local mark = Instance.new("Part")
		mark.Name = "HiddenClue_" .. id -- MANQUANT_HiddenMark : décalque de la marque (13.5)
		mark.Anchored = true
		mark.CanCollide = false
		mark.CanQuery = false
		mark.Transparency = 1 -- affichée par HiddenClueController pour la Descendante seulement
		mark.Size = MapConfig.HiddenClueMarkSize
		mark.Position = positionOf(MapConfig.HiddenClues[id])
		mark:SetAttribute("clueId", id)
		mark:AddTag("HiddenClue")
		mark.Parent = folder
		marks[id] = mark
	end
	setupWell()
	Players.PlayerRemoving:Connect(function(player)
		local index = table.find(crawlers, player)
		if index then
			table.remove(crawlers, index)
		end
	end)
	services.HealthService.Died:Connect(function(player)
		local index = table.find(crawlers, player)
		if index then
			table.remove(crawlers, index)
			player:SetAttribute("hiddenFromSight", nil)
		end
	end)
	-- découverte : la Descendante (vivante, debout) passe à 8 studs d'une marque
	task.spawn(function()
		while true do
			task.wait(PlayerConfig.Technical.Tick)
			for _, player in Players:GetPlayers() do
				local root = Util.characterRoot(player)
				if player:GetAttribute("role") == DESCENDANT and root and services.HealthService:IsUp(player) then
					for id, mark in marks do
						if not found[id] and (mark.Position - root.Position).Magnitude <= RANGE then
							discover(id)
						end
					end
				end
			end
		end
	end)
end

return HiddenClueService
