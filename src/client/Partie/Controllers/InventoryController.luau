-- Controllers/InventoryController (Partie)
-- Section 15.4 : InventoryGui. QuickSlots > Slot_1 à Slot_4 (> Icon, Count, Key, Selected) ;
-- Bag > Weight, List > Template (Icon, Name, Count, Drop). Lit l'attribut inventory (JSON).
-- La Mécanicienne n'a que 3 emplacements rapides (Slot_4 caché).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local ItemConfig = require(Config:WaitForChild("ItemConfig"))
local WeaponConfig = require(Config:WaitForChild("WeaponConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local InventoryController = {}

local player = Players.LocalPlayer
local root = nil
local bag = nil
local equipRemote, dropRemote = nil, nil

local function def(id)
	return ItemConfig.Items[id] or WeaponConfig.Weapons[id]
end

local function icon(id)
	return ItemConfig.Icons[id] or WeaponConfig.Icons[id] or ""
end

local function countText(entry)
	if entry.uses then
		return tostring(entry.uses)
	end
	if (entry.count or 1) > 1 then
		return tostring(entry.count)
	end
	return ""
end

function InventoryController:ToggleBag()
	if bag then
		bag.Visible = not bag.Visible
	end
end

local function refresh()
	local inv = Util.decode(player:GetAttribute("inventory"), nil)
	if inv == nil or root == nil then
		return
	end
	local quickCount = #inv.quick
	for i = 1, ItemConfig.QuickSlots do
		local slot = Util.findUI(root, ("InventoryGui/QuickSlots/Slot_%d"):format(i))
		if slot then
			slot.Visible = i <= quickCount
			local entry = inv.quick[i]
			local iconLabel = slot:FindFirstChild("Icon")
			local count = slot:FindFirstChild("Count")
			local key = slot:FindFirstChild("Key")
			local selected = slot:FindFirstChild("Selected")
			if iconLabel then
				iconLabel.Image = if entry then icon(entry.id) else ""
			end
			if count then
				count.Text = if entry then countText(entry) else ""
			end
			if key then
				key.Text = tostring(i)
			end
			if selected then
				selected.Visible = inv.selected == i
			end
		end
	end
	if bag == nil then
		return
	end
	local weight = bag:FindFirstChild("Weight")
	if weight then
		-- DÉFAUT : format « 3,4 / 12 kg »
		weight.Text = (string.gsub(string.format("%.1f / %d kg", inv.weight or 0, ItemConfig.BagMaxWeight), "%.", ","))
	end
	local template = Util.findUI(root, "InventoryGui/Bag/List/Template")
	if template == nil then
		return
	end
	Util.clearClones(template)
	for index, entry in inv.bag do
		local row = Util.cloneTemplate(template, index)
		local d = def(entry.id)
		local name = row:FindFirstChild("Name")
		local count = row:FindFirstChild("Count")
		local iconLabel = row:FindFirstChild("Icon")
		local drop = row:FindFirstChild("Drop")
		if name then
			name.Text = d and d.name or entry.id
		end
		if count then
			count.Text = countText(entry)
		end
		if iconLabel then
			iconLabel.Image = icon(entry.id)
		end
		if drop and dropRemote then
			drop.Activated:Connect(function()
				dropRemote:FireServer(quickCount + index)
			end)
		end
	end
end

function InventoryController:Start()
	local gui = Util.waitGui("InventoryGui")
	if gui == nil then
		return
	end
	root = gui.Parent
	bag = Util.findUI(root, "InventoryGui/Bag")
	equipRemote = Util.getRemote("RE_EquipSlot")
	dropRemote = Util.getRemote("RE_DropItem")
	for i = 1, ItemConfig.QuickSlots do
		local slot = Util.findUI(root, ("InventoryGui/QuickSlots/Slot_%d"):format(i))
		if slot then
			slot.InputBegan:Connect(function(input)
				local click = input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch
				if not click then
					return
				end
				-- DÉFAUT (15.7, téléphone) : toucher l'emplacement déjà choisi ouvre ou ferme le sac
				local inv = Util.decode(player:GetAttribute("inventory"), nil)
				if input.UserInputType == Enum.UserInputType.Touch and inv and inv.selected == i then
					InventoryController:ToggleBag()
				elseif equipRemote then
					equipRemote:FireServer(i)
				end
			end)
		end
	end
	-- 15.7 : bouton Fermer du sac
	local close = Util.findUI(root, "InventoryGui/Bag/Close")
	if close then
		close.Activated:Connect(function()
			if bag then
				bag.Visible = false
			end
		end)
	end
	player:GetAttributeChangedSignal("inventory"):Connect(refresh)
	refresh()
end

return InventoryController
