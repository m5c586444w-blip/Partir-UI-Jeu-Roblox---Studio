-- ServerScriptService/Services/EvidenceService (Partie)
-- Section 8.4 : preuves A/B/C. Une preuve est un objet d'inventaire ; elle ne compte que si un
-- survivant la sort de la forêt (CommitForSurvivor, appelé à l'extraction).
-- Vidéo A : créature visible à 60 % au moins, à 30 studs ou moins, 2 s sans interruption
-- (le caméscope a la vision nocturne). Carte mémoire ITM_SDCard créée après la vidéo.
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local ItemConfig = require(Config:WaitForChild("ItemConfig"))
local MapConfig = require(Config:WaitForChild("MapConfig"))
local ProgressionConfig = require(Config:WaitForChild("ProgressionConfig"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Signal = require(Shared:WaitForChild("Signal"))
local Util = require(Shared:WaitForChild("Util"))

local EvidenceService = {}

EvidenceService.Filmed = Signal.new() -- (player, creature, distance) : rancune +0,5 si filmée à moins de 30 studs (9.7)
EvidenceService.Created = Signal.new() -- (player, itemId)

local services = nil
local recordingSince = {} -- [Player] = os.clock() du début de la séquence visible
local Evidence = ItemConfig.Evidence

local VIDEO_CHECK = require(Config:WaitForChild("PlayerConfig")).Technical.VideoCheckInterval

local function creatures()
	return CollectionService:GetTagged("Creature")
end

-- fraction des parties de la créature visibles depuis `origin` (les feuillages tagués « Foliage » ne bloquent pas)
function EvidenceService:VisibleFraction(origin, creature, ignore)
	local parts = {}
	for _, part in creature:GetDescendants() do
		if part:IsA("BasePart") and part.Transparency < 1 then
			table.insert(parts, part)
		end
	end
	if #parts == 0 then
		return 0
	end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local filter = { creature }
	for _, inst in ignore or {} do
		table.insert(filter, inst)
	end
	for _, foliage in CollectionService:GetTagged("Foliage") do
		table.insert(filter, foliage)
	end
	params.FilterDescendantsInstances = filter
	local visible = 0
	for _, part in parts do
		local hit = workspace:Raycast(origin, part.Position - origin, params)
		if hit == nil then
			visible += 1
		end
	end
	return visible / #parts
end

local function give(player, itemId, extra)
	if services.InventoryService:Add(player, itemId, 1, extra) then
		EvidenceService.Created:Fire(player, itemId)
		return true
	end
	return false
end

local function nearestCreature(position, maxDistance)
	local best, bestDistance = nil, maxDistance
	for _, creature in creatures() do
		local d = (creature:GetPivot().Position - position).Magnitude
		if d <= bestDistance then
			best, bestDistance = creature, d
		end
	end
	return best, bestDistance
end

local function checkVideo(dt)
	for _, player in Players:GetPlayers() do
		local entry = services.InventoryService:Selected(player)
		local head = player.Character and player.Character:FindFirstChild("Head")
		if entry and entry.id == "ITM_Camcorder" and entry.recording and head then
			-- 8.1 : 6 min d'enregistrement
			local minutes = ItemConfig.Items.ITM_Camcorder.recordMinutes
			entry.battery = math.max(0, (entry.battery or 1) - dt / (minutes * Util.SECONDS_PER_MINUTE))
			if entry.battery <= 0 then
				entry.recording = false
			end
			local creature, distance = nearestCreature(head.Position, Evidence.VideoA.maxDistance)
			local ok = creature ~= nil
				and EvidenceService:VisibleFraction(head.Position, creature, { player.Character })
					>= Evidence.VideoA.minVisibleFraction
			if ok then
				EvidenceService.Filmed:Fire(player, creature, distance)
				recordingSince[player] = recordingSince[player] or os.clock()
				if os.clock() - recordingSince[player] >= Evidence.VideoA.minDuration then
					recordingSince[player] = nil
					entry.recording = false
					give(player, "ITM_SDCard")
				end
			else
				recordingSince[player] = nil
			end
		else
			recordingSince[player] = nil
		end
	end
end

local function nearTagged(tag, position, range)
	for _, inst in CollectionService:GetTagged(tag) do
		local pos = inst:IsA("Model") and inst:GetPivot().Position or inst.Position
		if (pos - position).Magnitude <= range then
			return inst
		end
	end
	return nil
end

local function onItemUsed(player, itemId, entry)
	local root = Util.characterRoot(player)
	local head = player.Character and player.Character:FindFirstChild("Head")
	if root == nil or head == nil then
		return
	end
	if itemId == "ITM_Camcorder" then
		-- 7.7 : seul le Caméraman produit des preuves de classe A
		if player:GetAttribute("role") == "Cameraman" then
			entry.recording = not entry.recording
			player:SetAttribute("isFilming", entry.recording)
		end
	elseif itemId == "ITM_PhotoCamera" then
		local def = ItemConfig.Items.ITM_PhotoCamera
		-- flash = lumière ×3 pendant 0,2 s (lu par la perception)
		player:SetAttribute("flashUntil", workspace:GetServerTimeNow() + def.flashDuration)
		entry.uses = (entry.uses or def.uses) - 1
		local creature = nearestCreature(head.Position, Evidence.PhotoB.maxDistance)
		if creature and EvidenceService:VisibleFraction(head.Position, creature, { player.Character }) > 0 then
			give(player, "EVD_PhotoCreature")
		elseif
			(root.Position - MapConfig.Places[Evidence.PhotoC.place].pos).Magnitude
			<= MapConfig.Places[Evidence.PhotoC.place].radius
		then
			give(player, "EVD_PhotoCharnier")
		end
		if entry.uses <= 0 then
			services.InventoryService:Remove(player, itemId, 1)
		end
	elseif itemId == "ITM_PlasterKit" then
		local print_ = nearTagged("Footprint", root.Position, ItemConfig.PickupDistance)
		local age = print_ and (os.clock() - (print_:GetAttribute("createdAt") or -math.huge))
		if print_ and age <= Evidence.PlasterB.footprintMaxAge then
			local now = workspace:GetServerTimeNow()
			player:SetAttribute("busyUntil", now + Evidence.PlasterB.workTime)
			task.delay(Evidence.PlasterB.workTime, function()
				player:SetAttribute("busyUntil", nil)
				if services.HealthService:IsUp(player) then
					entry.uses = (entry.uses or ItemConfig.Items.ITM_PlasterKit.uses) - 1
					give(player, "EVD_Cast")
					if entry.uses <= 0 then
						services.InventoryService:Remove(player, itemId, 1)
					end
				end
			end)
		end
	elseif itemId == "ITM_AudioRecorder" then
		entry.recording = not entry.recording
	elseif itemId == "ITM_SampleBag" then
		local p05 = MapConfig.Places.P05
		local nearStructure = nearTagged("StickStructure", root.Position, ItemConfig.PickupDistance)
		local nearRim = (Vector2.new(root.Position.X, root.Position.Z) - Vector2.new(p05.pos.X, p05.pos.Z)).Magnitude
				<= p05.radius
			-- DÉFAUT : « au bord » = plus près du bord (Y 400) que du fond (Y 250)
			and root.Position.Y >= (p05.rimY + p05.floorY) / 2
		if nearStructure or nearRim then
			if services.InventoryService:Remove(player, itemId, 1) then
				give(player, "EVD_Hair")
			end
		end
	end
end

-- 8.4 : enregistrement d'un cri à moins de 150 studs (appelé par l'IA à chaque cri)
function EvidenceService:OnCreatureCall(position)
	for _, player in Players:GetPlayers() do
		local root = Util.characterRoot(player)
		local entry = services.InventoryService:Selected(player)
		if root and entry and entry.id == "ITM_AudioRecorder" and entry.recording then
			if (root.Position - position).Magnitude <= Evidence.CallB.maxDistance then
				entry.recording = false
				give(player, "EVD_Call")
			end
		end
	end
end

-- 8.4 : document ramassé (DOC_03 à DOC_10) = preuve C
function EvidenceService:OnDocument(player, docId)
	if table.find(Evidence.DocumentC, docId) then
		give(player, "EVD_Document", { doc = docId })
	end
end

-- preuves portées par un joueur : { { itemId, class, kind, doc } }
function EvidenceService:Carried(player)
	local result = {}
	local inv = services.InventoryService:Get(player)
	if inv == nil then
		return result
	end
	for _, list in { inv.quick, inv.bag } do
		for _, entry in list do
			local def = entry and ItemConfig.Items[entry.id]
			if def and def.evidence then
				for _ = 1, entry.count or 1 do
					table.insert(
						result,
						{ itemId = entry.id, class = def.evidence.class, kind = def.evidence.kind, doc = entry.doc }
					)
				end
			end
		end
	end
	return result
end

function EvidenceService:CarriesClassA(player)
	for _, e in self:Carried(player) do
		if e.class == "A" then
			return true
		end
	end
	return false
end

-- 8.4 et 16.4 : un survivant sort de la forêt : preuves sauvegardées (200 au plus), XP de 8.4
function EvidenceService:CommitForSurvivor(player)
	local carried = self:Carried(player)
	local data = services.DataService:GetData(player)
	local xp = 0
	if data then
		for _, e in carried do
			table.insert(data.evidence, { class = e.class, kind = e.kind, date = os.time() })
			xp += ProgressionConfig.XPGains["Evidence" .. e.class] or 0
			if e.class == "B" then
				data.evidenceBOut = (data.evidenceBOut or 0) + 1 -- 19.5 (C38) : sac « Cold Trail »
			end
		end
		-- DÉFAUT : au-delà de 200, les plus anciennes sont retirées
		while #data.evidence > ProgressionConfig.MaxEvidence do
			table.remove(data.evidence, 1)
		end
		data.xp += xp
	end
	return carried, xp
end

-- appli Preuves de la tablette : preuves du groupe, classe, qui les porte
local function publishGroup()
	local list = {}
	for _, player in Players:GetPlayers() do
		for _, e in EvidenceService:Carried(player) do
			table.insert(list, { class = e.class, kind = e.kind, holder = player.DisplayName })
		end
	end
	Util.getMatchState():SetAttribute("evidence", Util.encode(list))
end

function EvidenceService:Init(allServices)
	services = allServices
end

function EvidenceService:Start()
	services.InventoryService.ItemUsed:Connect(onItemUsed)
	services.InventoryService.Changed:Connect(publishGroup)
	task.spawn(function()
		while true do
			task.wait(VIDEO_CHECK)
			checkVideo(VIDEO_CHECK)
		end
	end)
end

return EvidenceService
