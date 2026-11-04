-- ServerScriptService/Services/InventoryService (Partie)
-- Sections 8 et 8.1, 16.3 : 4 emplacements rapides (3 pour la Mécanicienne), sac limité à 12 kg,
-- objets lourds (> 5 kg) à deux mains, utilisation des objets, lampes et piles.
-- Remotes : RE_EquipSlot, RE_UseItem, RE_DropItem, RE_PickupItem, RE_ToggleLight.
-- Numéros d'emplacement (DÉFAUT) : 1..N = emplacements rapides, N+1.. = lignes du sac ; 0 = capacité du rôle.
-- État répliqué : attribut inventory (JSON { quick, bag, selected, weight }), heldItem, heavyHands,
-- lightOn, lightBattery, busyUntil.
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local ItemConfig = require(Config:WaitForChild("ItemConfig"))
local PlayerConfig = require(Config:WaitForChild("PlayerConfig"))
local WeaponConfig = require(Config:WaitForChild("WeaponConfig"))
local AmbienceConfig = require(Config:WaitForChild("AmbienceConfig"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local NoiseTypes = require(Shared:WaitForChild("NoiseTypes"))
local RateLimiter = require(Shared:WaitForChild("RateLimiter"))
local Signal = require(Shared:WaitForChild("Signal"))
local Util = require(Shared:WaitForChild("Util"))

local InventoryService = {}

InventoryService.Changed = Signal.new() -- (player)
InventoryService.ItemUsed = Signal.new() -- (player, itemId, entry)
InventoryService.AbilityUsed = Signal.new() -- (player, role)
InventoryService.BearSpray = Signal.new() -- (player, origin, direction, cone)
InventoryService.ProjectileLanded = Signal.new() -- (player, itemId, position)

local services = nil
local inventories = {} -- [Player] = { quick = {}, bag = {}, selected = 1 }

local THROW_SPEED = ItemConfig.Throw.Speed
local THROW_FLIGHT = ItemConfig.Throw.Flight
local NOISE_TRAP_RADIUS = ItemConfig.NoiseTrapRadius

local function itemDef(id)
	return ItemConfig.Items[id] or WeaponConfig.Weapons[id]
end

local function weightOf(entry)
	local def = itemDef(entry.id)
	return ((def and def.weight) or 0) * (entry.count or 1)
end

local function isHeavy(id)
	local def = ItemConfig.Items[id]
	return def ~= nil and (def.twoHands or (def.weight or 0) > ItemConfig.HeavyAbove)
end

local function quickCount(player)
	if player:GetAttribute("role") == "Mechanic" then
		return PlayerConfig.Abilities.Mechanic.QuickSlots
	end
	return ItemConfig.QuickSlots
end

local function bagWeight(inv)
	local total = 0
	for _, entry in inv.bag do
		total += weightOf(entry)
	end
	return total
end

local function publish(player)
	local inv = inventories[player]
	if inv == nil then
		return
	end
	local quick = {}
	for i = 1, quickCount(player) do
		quick[i] = inv.quick[i] or false
	end
	player:SetAttribute(
		"inventory",
		Util.encode({ quick = quick, bag = inv.bag, selected = inv.selected, weight = bagWeight(inv) })
	)
	local held = inv.quick[inv.selected]
	player:SetAttribute("heldItem", held and held.id or nil)
	local heavy = false
	for _, entry in inv.quick do
		if entry and isHeavy(entry.id) then
			heavy = true
		end
	end
	player:SetAttribute("heavyHands", heavy)
	InventoryService.Changed:Fire(player)
end

-- entrée par numéro d'emplacement ; renvoie entry, liste, index
local function entryAt(player, slot)
	local inv = inventories[player]
	if inv == nil or type(slot) ~= "number" then
		return nil
	end
	local n = quickCount(player)
	if slot >= 1 and slot <= n then
		return inv.quick[slot], inv.quick, slot
	end
	local bagIndex = slot - n
	return inv.bag[bagIndex], inv.bag, bagIndex
end

local function newEntry(id, count, extra)
	local entry = { id = id, count = count or 1 }
	local def = itemDef(id)
	if def and def.uses then
		entry.uses = def.uses
	end
	if def and (def.light or def.recordMinutes) then
		entry.battery = 1
	end
	if WeaponConfig.Weapons[id] and WeaponConfig.Weapons[id].ammo then
		-- TODO(BIBLE): munitions au départ (chargeur plein, réserve ?). PROVISOIRE : chargeur plein, réserve 0.
		entry.ammo = WeaponConfig.Weapons[id].ammo
	end
	if extra then
		for k, v in extra do
			entry[k] = v
		end
	end
	return entry
end

function InventoryService:Get(player)
	return inventories[player]
end

function InventoryService:Selected(player)
	local inv = inventories[player]
	return inv and inv.quick[inv.selected] or nil, inv and inv.selected or nil
end

-- nombre d'unités d'un objet dans tout l'inventaire
function InventoryService:Count(player, id)
	local inv = inventories[player]
	local total = 0
	if inv then
		for _, list in { inv.quick, inv.bag } do
			for _, entry in list do
				if entry and entry.id == id then
					total += entry.count or 1
				end
			end
		end
	end
	return total
end

function InventoryService:Has(player, id)
	return self:Count(player, id) > 0
end

-- retire `count` unités d'un objet ; renvoie true si tout a été retiré
function InventoryService:Remove(player, id, count)
	local inv = inventories[player]
	count = count or 1
	if inv == nil or self:Count(player, id) < count then
		return false
	end
	for _, list in { inv.quick, inv.bag } do
		for key, entry in list do
			if count > 0 and entry and entry.id == id then
				local take = math.min(count, entry.count or 1)
				entry.count -= take
				count -= take
				if entry.count <= 0 then
					if list == inv.quick then
						list[key] = nil
					else
						table.remove(list, key)
					end
				end
			end
		end
	end
	publish(player)
	return true
end

-- ajoute un objet : d'abord une pile existante, puis un emplacement rapide libre, puis le sac (12 kg).
-- Un objet lourd (> 5 kg) va seulement dans un emplacement rapide (porté à deux mains).
function InventoryService:Add(player, id, count, extra)
	local inv = inventories[player]
	local def = itemDef(id)
	if inv == nil then
		return false
	end
	count = count or 1
	local stack = (def and def.stack) or 1
	if extra == nil then
		for _, list in { inv.quick, inv.bag } do
			for _, entry in list do
				if count > 0 and entry and entry.id == id and entry.count < stack then
					local add = math.min(count, stack - entry.count)
					entry.count += add
					count -= add
				end
			end
		end
	end
	while count > 0 do
		local put = math.min(count, stack)
		local entry = newEntry(id, put, extra)
		local placed = false
		for i = 1, quickCount(player) do
			if inv.quick[i] == nil then
				inv.quick[i] = entry
				placed = true
				break
			end
		end
		if not placed and not isHeavy(id) and bagWeight(inv) + weightOf(entry) <= ItemConfig.BagMaxWeight then
			table.insert(inv.bag, entry)
			placed = true
		end
		if not placed then
			publish(player)
			return false
		end
		count -= put
	end
	publish(player)
	return true
end

-- objet posé dans le monde (ItemSpawnService) ; renvoie la Part
function InventoryService:SpawnWorld(id, count, position, extra)
	return services.ItemSpawnService:SpawnWorldItem(id, count, position, extra)
end

local function dropEntry(player, entry)
	local root = Util.characterRoot(player)
	if root then
		local extra = table.clone(entry)
		extra.id = nil
		extra.count = nil
		InventoryService:SpawnWorld(entry.id, entry.count, root.Position - Vector3.new(0, 2, 0), extra)
		local def = itemDef(entry.id)
		if def and def.dropNoise then
			services.NoiseService:Emit(root.Position, def.dropNoise, NoiseTypes.Item, player)
		end
	end
end

function InventoryService:Drop(player, slot)
	local entry, list, index = entryAt(player, slot)
	if entry == nil then
		return
	end
	if list == inventories[player].quick then
		list[index] = nil
	else
		table.remove(list, index)
	end
	if entry.lit then
		self:SetLight(player, false)
	end
	dropEntry(player, entry)
	publish(player)
end

-- 7.3 : à la mort, l'inventaire tombe dans un sac ramassable
function InventoryService:DropAllAsBag(player, position)
	local inv = inventories[player]
	if inv == nil then
		return
	end
	self:SetLight(player, false)
	local contents = {}
	for i = 1, quickCount(player) do
		if inv.quick[i] then
			table.insert(contents, inv.quick[i])
		end
	end
	for _, entry in inv.bag do
		table.insert(contents, entry)
	end
	inv.quick, inv.bag = {}, {}
	publish(player)
	if #contents > 0 then
		services.ItemSpawnService:SpawnBag(contents, position)
	end
end

-- prend le contenu d'un sac au sol ; le reste y reste
function InventoryService:TakeBag(player, bagPart)
	local contents = Util.decode(bagPart:GetAttribute("contents"), {})
	local left = {}
	for _, entry in contents do
		local extra = table.clone(entry)
		extra.id, extra.count = nil, nil
		if not self:Add(player, entry.id, entry.count, next(extra) and extra or nil) then
			table.insert(left, entry)
		end
	end
	if #left == 0 then
		bagPart:Destroy()
	else
		bagPart:SetAttribute("contents", Util.encode(left))
	end
end

function InventoryService:Pickup(player, part)
	if part == nil or not part:IsDescendantOf(workspace) then
		return false
	end
	local root = Util.characterRoot(player)
	if root == nil or not services.HealthService:IsUp(player) then
		return false
	end
	local position = part:IsA("Model") and part:GetPivot().Position or part.Position
	if (position - root.Position).Magnitude > ItemConfig.PickupDistance then
		return false
	end
	local id = part:GetAttribute("itemId")
	if id == nil then
		return false
	end
	-- documents (2.7) : lus et rangés dans le journal du groupe
	if string.match(id, "^DOC_") then
		services.DocumentService:Collect(player, id, part)
		part:Destroy()
		return true
	end
	if id == "AmmoBox" then
		-- 3.4 : 5 balles de fusil + 6 de revolver + 4 cartouches (rangées en réserve, AMMO_<arme>)
		for weaponId, amount in WeaponConfig.AmmoBox do
			self:Add(player, "AMMO_" .. weaponId, amount)
		end
		part:Destroy()
		return true
	end
	local extra = Util.decode(part:GetAttribute("payload"), nil)
	if self:Add(player, id, part:GetAttribute("count") or 1, extra) then
		services.ItemSpawnService:OnPickedUp(player, part)
		part:Destroy()
		return true
	end
	return false
end

function InventoryService:Equip(player, slot)
	local inv = inventories[player]
	if inv == nil or type(slot) ~= "number" or slot < 1 or slot > quickCount(player) then
		return
	end
	-- 8 : objet lourd porté : il reste en main
	local held = inv.quick[inv.selected]
	if held and isHeavy(held.id) and slot ~= inv.selected then
		return
	end
	if held and held.lit and not (itemDef(held.id).light or {}).handsFree then
		self:SetLight(player, false)
	end
	inv.selected = slot
	publish(player)
end

-- lampes (8.1, 12.1) : SpotLight à 45° sur la tête du personnage, portée de l'objet
local function lightEntry(player)
	local inv = inventories[player]
	if inv == nil then
		return nil
	end
	local held = inv.quick[inv.selected]
	if held and itemDef(held.id) and itemDef(held.id).light then
		return held
	end
	for _, list in { inv.quick, inv.bag } do
		for _, entry in list do
			local def = entry and itemDef(entry.id)
			if def and def.light and def.light.handsFree then
				return entry -- la frontale éclaire sans être en main
			end
		end
	end
	return nil
end

function InventoryService:SetLight(player, on)
	local character = player.Character
	local head = character and character:FindFirstChild("Head")
	local existing = head and head:FindFirstChild("PlayerLamp")
	local inv = inventories[player]
	if inv then
		for _, list in { inv.quick, inv.bag } do
			for _, entry in list do
				if entry then
					entry.lit = nil
				end
			end
		end
	end
	if not on then
		if existing then
			existing:Destroy()
		end
		player:SetAttribute("lightOn", false)
		publish(player)
		return
	end
	local entry = lightEntry(player)
	if entry == nil or (entry.battery or 0) <= 0 or head == nil then
		return
	end
	local def = itemDef(entry.id).light
	entry.lit = true
	if existing then
		existing:Destroy()
	end
	local lamp = Instance.new("SpotLight")
	lamp.Name = "PlayerLamp"
	lamp.Angle = def.angle
	lamp.Range = math.min(def.range, AmbienceConfig.Lamp.EngineMaxRange)
	lamp.Shadows = true
	lamp.Face = Enum.NormalId.Front
	lamp:SetAttribute("range", def.range) -- portée de jeu (8.1), lue par la perception
	lamp:AddTag("PlayerLamp")
	lamp.Parent = head
	player:SetAttribute("lightOn", true)
	player:SetAttribute("lightRange", def.range)
	publish(player)
end

-- utilisation à durée : bloque les autres actions (« pas en action », 16.3)
local function busy(player, duration, done)
	local now = workspace:GetServerTimeNow()
	if (player:GetAttribute("busyUntil") or 0) > now then
		return false
	end
	player:SetAttribute("busyUntil", now + duration)
	task.delay(duration, function()
		player:SetAttribute("busyUntil", nil)
		if services.HealthService:IsUp(player) then
			done()
		end
	end)
	return true
end

local function consumeUse(player, entry, slot)
	if entry.uses then
		entry.uses -= 1
		if entry.uses <= 0 then
			entry.count -= 1
			if entry.count <= 0 then
				local _, list, index = entryAt(player, slot)
				if list == inventories[player].quick then
					list[index] = nil
				else
					table.remove(list, index)
				end
			else
				entry.uses = itemDef(entry.id).uses
			end
		end
	else
		InventoryService:Remove(player, entry.id, 1)
	end
	publish(player)
end

local function placeSource(position, duration, opts)
	local part = Instance.new("Part")
	part.Name = opts.name
	part.Size = ItemConfig.FireVisuals.Size
	part.Anchored = true
	part.CanCollide = false
	part.Color = opts.color
	part.Material = Enum.Material.Neon
	part.Position = position
	local light = Instance.new("PointLight")
	light.Color = opts.color
	light.Range = math.min(opts.radius, AmbienceConfig.Lamp.EngineMaxRange)
	light.Parent = part
	part:SetAttribute("radius", opts.radius)
	part:SetAttribute("range", opts.radius)
	part:SetAttribute("keepAway", opts.keepAway)
	part:SetAttribute("visibleRange", opts.visibleRange)
	CollectionService:AddTag(part, "FireSource")
	CollectionService:AddTag(part, "LightSource")
	part.Parent = workspace
	Debris:AddItem(part, duration)
	return part
end

local function throw(player, entry, slot)
	local root = Util.characterRoot(player)
	if root == nil then
		return
	end
	local def = itemDef(entry.id)
	local landing = root.Position + root.CFrame.LookVector * THROW_SPEED * THROW_FLIGHT
	consumeUse(player, entry, slot)
	task.delay(THROW_FLIGHT, function()
		local noise = def.impactNoise or def.breakNoise
		services.NoiseService:Emit(landing, noise, NoiseTypes.Impact, player)
		InventoryService.ProjectileLanded:Fire(player, entry.id, landing)
	end)
end

local EFFECTS = {}

EFFECTS.RechargeLight = function(player, entry, slot, def)
	local light = lightEntry(player)
	if light == nil then
		return
	end
	busy(player, def.duration, function()
		light.battery = 1
		consumeUse(player, entry, slot)
	end)
end

local function healDuration(player, def)
	-- 7.7 : la Médecin soigne ×2 (DÉFAUT : deux fois plus vite)
	if player:GetAttribute("role") == "Medic" then
		return def.duration / PlayerConfig.Abilities.Medic.HealFactor
	end
	return def.duration
end

EFFECTS.Bandage = function(player, entry, slot, def)
	busy(player, healDuration(player, def), function()
		services.HealthService:TreatBleed(player, false)
		services.HealthService:Heal(player, nil, def.heal)
		consumeUse(player, entry, slot)
	end)
end

EFFECTS.Splint = function(player, entry, slot, def)
	busy(player, healDuration(player, def), function()
		services.HealthService:Splint(player)
		consumeUse(player, entry, slot)
	end)
end

EFFECTS.Medkit = function(player, entry, slot, def)
	busy(player, healDuration(player, def), function()
		services.HealthService:Heal(player, nil, def.heal)
		-- 8.1 : arrête une hémorragie grave (Médecin seulement)
		if player:GetAttribute("role") == "Medic" then
			services.HealthService:TreatBleed(player, true)
		end
		consumeUse(player, entry, slot)
	end)
end

EFFECTS.Flare = function(player, entry, slot, def)
	local root = Util.characterRoot(player)
	if root == nil then
		return
	end
	consumeUse(player, entry, slot)
	services.NoiseService:Emit(root.Position, def.noise, NoiseTypes.Item, player)
	-- DÉFAUT : la fusée allumée est posée aux pieds du joueur
	placeSource(root.Position - Vector3.new(0, ItemConfig.FireVisuals.GroundOffset, 0), def.burn, {
		name = "Flare",
		color = ItemConfig.FireVisuals.FlareColor,
		radius = def.lightRadius,
		keepAway = def.creatureKeepAway,
	})
end

EFFECTS.Campfire = function(player, entry, slot, def)
	local root = Util.characterRoot(player)
	if root == nil or InventoryService:Count(player, "ITM_Branch") < def.branchesNeeded then
		return
	end
	InventoryService:Remove(player, "ITM_Branch", def.branchesNeeded)
	consumeUse(player, entry, slot)
	services.NoiseService:Emit(root.Position, def.noise, NoiseTypes.Item, player)
	local flare = ItemConfig.Items.ITM_Flare
	placeSource(
		root.Position
			+ root.CFrame.LookVector * ItemConfig.FireVisuals.CampfireAhead
			- Vector3.new(0, ItemConfig.FireVisuals.GroundOffset, 0),
		def.burn,
		{
			name = "Campfire",
			color = ItemConfig.FireVisuals.CampfireColor,
			radius = flare.lightRadius, -- 8.1 : même effet qu'une fusée
			keepAway = flare.creatureKeepAway,
			visibleRange = def.visibleRange,
		}
	)
end

EFFECTS.BearSpray = function(player, entry, slot, def)
	local root = Util.characterRoot(player)
	if root == nil then
		return
	end
	consumeUse(player, entry, slot)
	services.NoiseService:Emit(root.Position, def.noise, NoiseTypes.Item, player)
	InventoryService.BearSpray:Fire(player, root.Position, root.CFrame.LookVector, def.cone)
end

local function useAbility(player)
	local role = player:GetAttribute("role")
	if role == "Leader" then
		services.FearService:LeaderOrder(player)
	elseif role == "Pyrotechnician" then
		-- 7.7 : 1 fusée par 2 piles + 1 ruban ; piège : boîte de conserve + corde
		local recipes = PlayerConfig.Abilities.Pyrotechnician
		local function canCraft(recipe)
			for id, n in recipe do
				if InventoryService:Count(player, id) < n then
					return false
				end
			end
			return true
		end
		if canCraft(recipes.FlareRecipe) then
			for id, n in recipes.FlareRecipe do
				InventoryService:Remove(player, id, n)
			end
			InventoryService:Add(player, "ITM_Flare", 1)
		elseif canCraft(recipes.NoiseTrapRecipe) and NOISE_TRAP_RADIUS then
			for id, n in recipes.NoiseTrapRecipe do
				InventoryService:Remove(player, id, n)
			end
		end
	end
	InventoryService.AbilityUsed:Fire(player, role)
end

function InventoryService:Use(player, slot)
	if not services.HealthService:IsUp(player) then
		return
	end
	if slot == 0 then
		useAbility(player)
		return
	end
	local entry = entryAt(player, slot)
	if entry == nil then
		return
	end
	local def = itemDef(entry.id)
	if def == nil then
		return
	end
	if def.throwable then
		throw(player, entry, slot)
	elseif def.effect and EFFECTS[def.effect] then
		local root = Util.characterRoot(player)
		if def.noise and root and def.effect ~= "Flare" and def.effect ~= "BearSpray" then
			services.NoiseService:Emit(root.Position, def.noise, NoiseTypes.Item, player)
		end
		EFFECTS[def.effect](player, entry, slot, def)
	end
	-- effets traités ailleurs : preuves, tablette, documents (EvidenceService, TabletService, DocumentService)
	self.ItemUsed:Fire(player, entry.id, entry, slot)
end

-- 8.1 et 8.3 : décharge des lampes allumées
local function drainLights(dt)
	for player, inv in inventories do
		for _, list in { inv.quick, inv.bag } do
			for _, entry in list do
				if entry and entry.lit then
					local def = itemDef(entry.id).light
					entry.battery =
						math.max(0, (entry.battery or 0) - dt / (def.batteryMinutes * Util.SECONDS_PER_MINUTE))
					player:SetAttribute("lightBattery", entry.battery)
					if entry.battery <= 0 then
						InventoryService:SetLight(player, false)
					end
				end
			end
		end
	end
end

-- objets de départ (8.1, colonne « Où »)
function InventoryService:GiveStarting(player, weaponId)
	local role = player:GetAttribute("role")
	local start = ItemConfig.StartingItems
	if not start.Flashlight.exceptRoles[role] then
		self:Add(player, start.Flashlight.item, 1)
	end
	for id, n in start.Roles[role] or {} do
		self:Add(player, id, n)
	end
	for id, n in start.All do
		self:Add(player, id, n)
	end
	-- 8.2 : armes de rôle (pistolet lance-fusées, hache) et arme choisie au lobby
	for id, weapon in WeaponConfig.Weapons do
		if weapon.owner == role then
			self:Add(player, id, 1)
		end
	end
	if weaponId and WeaponConfig.Weapons[weaponId] then
		self:Add(player, weaponId, 1)
	end
end

function InventoryService:Init(allServices)
	services = allServices
end

function InventoryService:Start()
	services.CharacterService.Spawned:Connect(function(player)
		inventories[player] = { quick = {}, bag = {}, selected = 1 }
		local info = services.PartyLoaderService:GetMatchInfo()
		local entry = info.roles[player.UserId]
		self:GiveStarting(player, entry and entry.weapon)
		services.InteractionService:Refresh()
	end)
	Players.PlayerRemoving:Connect(function(player)
		inventories[player] = nil
	end)

	local handlers = {
		RE_EquipSlot = function(player, slot)
			self:Equip(player, slot)
		end,
		RE_UseItem = function(player, slot)
			self:Use(player, slot)
		end,
		RE_DropItem = function(player, slot)
			self:Drop(player, slot)
		end,
		RE_PickupItem = function(player, part)
			if typeof(part) == "Instance" then
				self:Pickup(player, part)
			end
		end,
		RE_ToggleLight = function(player)
			-- 16.3 : lampe équipée, pile > 0
			local root = Util.characterRoot(player)
			local on = not player:GetAttribute("lightOn")
			self:SetLight(player, on)
			if root then
				services.NoiseService:Emit(
					root.Position,
					ItemConfig.Items.ITM_Flashlight.noise,
					NoiseTypes.Item,
					player
				)
			end
		end,
	}
	for name, handler in handlers do
		local remote = Util.getRemote(name)
		if remote then
			RateLimiter.connect(remote, handler)
		end
	end

	task.spawn(function()
		local step = PlayerConfig.Technical.Tick
		while true do
			task.wait(step)
			drainLights(step)
		end
	end)
end

return InventoryService
