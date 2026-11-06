-- ServerScriptService/Services/ItemSpawnService (Partie)
-- Sections 3.4, 8.1 et 2.7 : tirages avec la graine de la partie (écrite dans la console) :
-- 6 points d'indice sur 12, un emplacement par objet clé, objets et documents à lieu fixe.
-- Modèles : ReplicatedStorage/Items/Item_<Nom> (13.3) ; absent → bloc gris MANQUANT_<ID>.
-- Workspace/CluePoints peut contenir des Part nommées comme les codes (C01, K1, A3…) : elles
-- remplacent les coordonnées de MapConfig (réglage à la main en phase B).
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local ActConfig = require(Config:WaitForChild("ActConfig"))
local ItemConfig = require(Config:WaitForChild("ItemConfig"))
local LoreConfig = require(Config:WaitForChild("LoreConfig"))
local MapConfig = require(Config:WaitForChild("MapConfig"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Signal = require(Shared:WaitForChild("Signal"))
local Util = require(Shared:WaitForChild("Util"))

local ItemSpawnService = {}

ItemSpawnService.ClueFound = Signal.new() -- (clueId, player)

local services = nil
local spawnGroundItems -- défini plus bas (19.6, C17)
local folder = nil
local drawn = {} -- résultat du tirage, pour la console et les tests

local PLACEHOLDER_SIZE = ItemConfig.PlaceholderSize
local SPAWN_LIFT = ItemConfig.SpawnLift

local function modelName(id)
	return (string.gsub(id, "^ITM_", "Item_"))
end

local function makeVisual(id, position)
	local itemsFolder = ReplicatedStorage:FindFirstChild(ItemConfig.ModelsFolder)
	local template = itemsFolder and itemsFolder:FindFirstChild(modelName(id))
	if template then
		local clone = template:Clone()
		local part = clone:IsA("BasePart") and clone
			or clone.PrimaryPart
			or clone:FindFirstChildWhichIsA("BasePart", true)
		clone:PivotTo(CFrame.new(position))
		return clone, part
	end
	local part = Instance.new("Part")
	part.Name = "MANQUANT_" .. modelName(id)
	part.Size = PLACEHOLDER_SIZE
	part.Color = ItemConfig.PlaceholderColor
	part.Material = Enum.Material.SmoothPlastic
	part.Position = position
	return part, part
end

-- objet posé dans le monde, ramassable (ProximityPrompt « Ramasser »)
function ItemSpawnService:SpawnWorldItem(id, count, position, payload, clueId)
	local visual, part = makeVisual(id, position + Vector3.new(0, SPAWN_LIFT, 0))
	if part == nil then
		visual:Destroy()
		visual, part = makeVisual("MANQUANT", position)
	end
	for _, p in visual:IsA("BasePart") and { visual } or visual:GetDescendants() do
		if p:IsA("BasePart") then
			p.Anchored = true
		end
	end
	visual:SetAttribute("itemId", id)
	visual:SetAttribute("count", count or 1)
	if payload and next(payload) then
		visual:SetAttribute("payload", Util.encode(payload))
	end
	if clueId then
		visual:SetAttribute("clueId", clueId)
		CollectionService:AddTag(visual, "Clue")
	end
	CollectionService:AddTag(visual, "WorldItem")
	visual.Parent = folder
	local def = ItemConfig.Items[id]
	services.InteractionService:CreatePrompt(part, {
		action = LoreConfig.Prompts.Pickup,
		object = def and def.name or "",
		onTriggered = function(player)
			services.InventoryService:Pickup(player, visual)
		end,
	})
	return visual
end

-- sac d'un joueur mort (7.3)
function ItemSpawnService:SpawnBag(contents, position)
	local visual, part = makeVisual("ITM_Bag", position)
	visual.Name = "DeadBag"
	for _, p in visual:IsA("BasePart") and { visual } or visual:GetDescendants() do
		if p:IsA("BasePart") then
			p.Anchored = true
		end
	end
	visual:SetAttribute("contents", Util.encode(contents))
	visual.Parent = folder
	services.InteractionService:CreatePrompt(part, {
		action = LoreConfig.Prompts.Open,
		onTriggered = function(player)
			services.InventoryService:TakeBag(player, visual)
		end,
	})
	return visual
end

function ItemSpawnService:OnPickedUp(player, part)
	local clueId = part:GetAttribute("clueId")
	if clueId then
		self.ClueFound:Fire(clueId, player)
	end
end

local function markerOr(code, fallback)
	local markers = workspace:FindFirstChild("CluePoints")
	local marker = markers and markers:FindFirstChild(code)
	if marker and marker:IsA("BasePart") then
		return marker.Position
	end
	return fallback
end

local function shuffle(list, random)
	for i = #list, 2, -1 do
		local j = random:NextInteger(1, i)
		list[i], list[j] = list[j], list[i]
	end
	return list
end

-- 3.4 : 6 points sur 12. DÉFAUT (algorithme) : chacun des 4 documents tirés (DOC_03 à DOC_06)
-- reçoit un point distinct parmi ceux qui peuvent le contenir ; les points restants sont tirés
-- parmi C09–C12 (objets). Chaque point tiré contient donc quelque chose.
local function drawCluePoints(random)
	local documents = { "DOC_03", "DOC_04", "DOC_05", "DOC_06" }
	local docPoints, itemPoints = {}, {}
	for code, point in MapConfig.CluePoints do
		if string.match(point.contents[1], "^DOC_") then
			table.insert(docPoints, code)
		else
			table.insert(itemPoints, code)
		end
	end
	table.sort(docPoints)
	table.sort(itemPoints)
	local assignment
	-- appariement aléatoire document → point compatible (recommencé jusqu'à réussir)
	for _ = 1, 100 do
		assignment = {}
		local used = {}
		local ok = true
		for _, doc in shuffle(table.clone(documents), random) do
			local options = {}
			for _, code in docPoints do
				if not used[code] and table.find(MapConfig.CluePoints[code].contents, doc) then
					table.insert(options, code)
				end
			end
			if #options == 0 then
				ok = false
				break
			end
			local code = options[random:NextInteger(1, #options)]
			used[code] = true
			assignment[code] = { doc }
		end
		if ok then
			break
		end
	end
	local remaining = MapConfig.CluePointsDrawn - #documents
	for _, code in shuffle(table.clone(itemPoints), random) do
		if remaining <= 0 then
			break
		end
		assignment[code] = MapConfig.CluePoints[code].contents
		remaining -= 1
	end
	return assignment
end

-- 19.6 (C17), DÉFAUT : branches et pierres au sol, par blocs de Terrain.ChunkSize, sans réapparition
local function groundHit(x, z, params)
	local top = MapConfig.HighestPlayableY * 2 -- constante (au-dessus du point le plus haut)
	return workspace:Raycast(Vector3.new(x, top, z), Vector3.new(0, -top * 2, 0), params)
end

local function inForbiddenZone(x, z)
	local zone = MapConfig.Places.P08.zone
	return x >= zone.minX and x <= zone.maxX and z >= zone.minZ and z <= zone.maxZ
end

local function materialSet(names)
	local set = {}
	for _, name in names do
		set[Enum.Material[name]] = true
	end
	return set
end

spawnGroundItems = function(random)
	local cfg = MapConfig.GroundItems
	local chunkSize = MapConfig.Terrain.ChunkSize
	local half = MapConfig.PlayableHalf
	local forest = materialSet(cfg.Branch.forestMaterials)
	local excluded = materialSet(cfg.Stone.excludedMaterials)
	local groundParams = RaycastParams.new()
	groundParams.FilterType = Enum.RaycastFilterType.Include
	groundParams.FilterDescendantsInstances = { workspace.Terrain }
	local trunkParams = OverlapParams.new()
	trunkParams.FilterType = Enum.RaycastFilterType.Include
	local vegetation = workspace:FindFirstChild("Vegetation")
	trunkParams.FilterDescendantsInstances = if vegetation then { vegetation } else {}
	local function nearTrunk(position)
		return vegetation ~= nil
			and #workspace:GetPartBoundsInRadius(position, cfg.Branch.trunkClearance, trunkParams) > 0
	end
	-- catégorie d'une branche en ce point : "Forest", "ForbiddenZone" ou nil
	local function branchCategory(x, z, hit)
		if inForbiddenZone(x, z) then
			return "ForbiddenZone"
		end
		return if forest[hit.Material] then "Forest" else nil
	end
	local count = { ITM_Branch = 0, ITM_Stone = 0 }
	for cx = -half, half - 1, chunkSize do
		for cz = -half, half - 1, chunkSize do
			local quota = { Forest = cfg.Branch.perChunk.Forest, ForbiddenZone = cfg.Branch.perChunk.ForbiddenZone }
			local stones = cfg.Stone.perChunk
			local attempts = (quota.Forest + quota.ForbiddenZone + stones) * cfg.AttemptsPerItem
			-- branches
			for _ = 1, attempts do
				local x = cx + random:NextNumber() * chunkSize
				local z = cz + random:NextNumber() * chunkSize
				local hit = groundHit(x, z, groundParams)
				local category = hit and branchCategory(x, z, hit)
				if category and quota[category] > 0 and not nearTrunk(hit.Position) then
					quota[category] -= 1
					count.ITM_Branch += 1
					ItemSpawnService:SpawnWorldItem(cfg.Branch.item, 1, hit.Position)
				end
			end
			-- pierres
			for _ = 1, stones * cfg.AttemptsPerItem do
				if stones <= 0 then
					break
				end
				local x = cx + random:NextNumber() * chunkSize
				local z = cz + random:NextNumber() * chunkSize
				local hit = groundHit(x, z, groundParams)
				if hit and not excluded[hit.Material] then
					stones -= 1
					count.ITM_Stone += 1
					ItemSpawnService:SpawnWorldItem(cfg.Stone.item, 1, hit.Position)
				end
			end
			task.wait()
		end
	end
	-- garantis près des abris (cabane P05c, camp P09, poste P17)
	local shelters = cfg.Shelters
	for _, code in shelters.places do
		local center = MapConfig.resolve(MapConfig.Places[code])
		if center then
			for _, spec in { { cfg.Branch.item, shelters.branches }, { cfg.Stone.item, shelters.stones } } do
				local left = spec[2]
				for _ = 1, spec[2] * cfg.AttemptsPerItem do
					if left <= 0 then
						break
					end
					local angle = random:NextNumber() * 2 * math.pi -- constante (tour complet)
					local distance = math.sqrt(random:NextNumber()) * shelters.radius
					local x = center.X + math.cos(angle) * distance
					local z = center.Z + math.sin(angle) * distance
					local hit = groundHit(x, z, groundParams)
					if hit and not excluded[hit.Material] and not nearTrunk(hit.Position) then
						left -= 1
						count[spec[1]] += 1
						ItemSpawnService:SpawnWorldItem(spec[1], 1, hit.Position)
					end
				end
			end
		end
	end
	print(("ItemSpawnService : %d branches et %d pierres au sol"):format(count.ITM_Branch, count.ITM_Stone))
end

local function spawnAll(info)
	local random = Random.new(info.seed)
	print(("ItemSpawnService : graine %d"):format(info.seed))

	-- points d'indice
	local clues = drawCluePoints(random)
	drawn.clues = clues
	local drawnCodes = Util.sortedKeys(clues)
	print("ItemSpawnService : points d'indice tirés : " .. table.concat(drawnCodes, ", "))
	for code, contents in clues do
		local base = markerOr(code, MapConfig.CluePoints[code].pos)
		for i, id in contents do
			local offset = Vector3.new((i - 1) * ItemConfig.ClueItemSpacing, 0, 0)
			local count = if string.match(id, "^DOC_") then 1 else MapConfig.ClueItemQuantity[id] or 1
			ItemSpawnService:SpawnWorldItem(id, count, base + offset, nil, code)
		end
	end

	-- objets clés (un emplacement tiré par objet)
	local difficulty = ActConfig.difficulty(info.difficulty)
	for key, spec in MapConfig.KeyItems do
		if spec.item == "AmmoBox" and not difficulty.ammoBox then
			continue -- 5.4 : pas de boîte de munitions en Cauchemar
		end
		local index = random:NextInteger(1, #spec.spots)
		local code = ({
			Keys = "K",
			AmmoBox = "A",
			Jack = "J",
			CoaxCable = "R",
			CarBattery = "R",
			Jerrycan = "R",
			StarterRelay = "R",
		})[key] .. tostring(index)
		local position = markerOr(code, MapConfig.resolve(spec.spots[index]))
		drawn[key] = index
		if position then
			ItemSpawnService:SpawnWorldItem(spec.item, 1, position)
		end
	end

	-- objets à lieu fixe (8.1)
	for _, spec in MapConfig.FixedItems do
		for _, place in spec.places do
			local position = MapConfig.resolve(place)
			if position then
				ItemSpawnService:SpawnWorldItem(spec.item, spec.count or 1, position)
			end
		end
	end
	-- DÉFAUT : l'appareil photo de C03–C06 est posé sur un des points tirés parmi eux, s'il y en a un
	local photoPoints = {}
	for _, code in MapConfig.PhotoCameraCluePoints do
		if clues[code] then
			table.insert(photoPoints, code)
		end
	end
	if #photoPoints > 0 then
		local code = photoPoints[random:NextInteger(1, #photoPoints)]
		ItemSpawnService:SpawnWorldItem(
			"ITM_PhotoCamera",
			1,
			markerOr(code, MapConfig.CluePoints[code].pos) + Vector3.new(0, 0, ItemConfig.ClueItemSpacing)
		)
	end

	-- 19.6 (C17) : branches et pierres au sol, générées avec la graine de la partie (DÉFAUT du 2026-11-07)
	spawnGroundItems(random)

	-- documents à lieu fixe (2.7) ; DOC_09 est un message radio (rejoué par la tour, J9)
	for doc, place in MapConfig.FixedDocuments do
		if doc ~= "DOC_09" and LoreConfig.Documents and LoreConfig.Documents[doc] then
			local position = MapConfig.resolve(place)
			if position then
				ItemSpawnService:SpawnWorldItem(doc, 1, position + ItemConfig.DocumentOffset)
			end
		end
	end
end

function ItemSpawnService:GetDraw()
	return drawn
end

function ItemSpawnService:Init(allServices)
	services = allServices
	folder = Instance.new("Folder")
	folder.Name = "WorldItems"
	folder.Parent = workspace
end

function ItemSpawnService:Start()
	task.spawn(function()
		services.PartyLoaderService:WaitUntilLoaded()
		spawnAll(services.PartyLoaderService:GetMatchInfo())
	end)
end

return ItemSpawnService
