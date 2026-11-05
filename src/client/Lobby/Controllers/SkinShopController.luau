-- Controllers/SkinShopController (Lobby)
-- Sections 4.5, 7.1 et 15.3 : SkinShopGui > CharacterList > Template ; SkinGrid > Skin_A, Skin_B,
-- Skin_C (> Lock, Requirement) ; Preview (ViewportFrame) ; Equip. Ouvert au magasin (L04).
-- 15.7 (7) : le verrou opaque affiche sa condition ; Requirement reste masqué tant qu'il est là.
-- 19.5 (C38) : Accessories > Beanie, AmberHeadlamp, ColdTrailBag (> Lock) ; Équiper porte ou retire.
local ProximityPromptService = game:GetService("ProximityPromptService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local PlayerConfig = require(Config:WaitForChild("PlayerConfig"))
local ProgressionConfig = require(Config:WaitForChild("ProgressionConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local SkinShopController = {}

local player = Players.LocalPlayer
local root = nil
local role = PlayerConfig.Roles[1].id
local skin = ProgressionConfig.DefaultSkin
local accessory = nil -- accessoire choisi (sinon : une tenue)
local PANELS = { "CharacterList", "SkinGrid", "Accessories", "Preview", "Equip" }

local function find(path)
	return Util.findUI(root, "SkinShopGui/" .. path)
end

local function preview()
	local viewport = find("Preview")
	if viewport == nil then
		return
	end
	viewport:ClearAllChildren()
	local folder = ReplicatedStorage:FindFirstChild(PlayerConfig.CharactersFolder)
	local model = folder
		and folder:FindFirstChild(role)
		and folder[role]:FindFirstChild(PlayerConfig.SkinPrefix .. skin)
	if model then
		local clone = model:Clone()
		clone.Parent = viewport
		local camera = Instance.new("Camera")
		local pivot = clone:GetPivot()
		camera.CFrame =
			CFrame.lookAt(pivot.Position + pivot.LookVector * PlayerConfig.Interface.PortraitDistance, pivot.Position)
		camera.Parent = viewport
		viewport.CurrentCamera = camera
	end
end

local function refresh()
	local skins = Util.decode(player:GetAttribute("skinsJson"), {})
	for _, id in ProgressionConfig.SkinIds do
		local button = find("SkinGrid/Skin_" .. id)
		local lock = button and button:FindFirstChild("Lock")
		local requirement = button and button:FindFirstChild("Requirement")
		local locked = not (skins[role] and skins[role][id])
		if lock then
			lock.Visible = locked and lock.Text ~= ""
		end
		if requirement then
			requirement.Visible = false
		end
	end
	local owned = Util.decode(player:GetAttribute("accessoriesJson"), {})
	for _, id in ProgressionConfig.AccessoryIds do
		local lock = find("Accessories/" .. id .. "/Lock")
		if lock then
			lock.Visible = not owned[id]
		end
	end
	preview()
end

local function show()
	for _, name in PANELS do
		local el = find(name)
		if el then
			el.Visible = true
		end
	end
	refresh()
end

function SkinShopController:Start()
	local gui = Util.waitGui("SkinShopGui")
	if gui == nil then
		return
	end
	root = gui.Parent
	local template = find("CharacterList/Template")
	for i, r in PlayerConfig.Roles do
		local row = Util.cloneTemplate(template, i)
		row.Text = r.character
		row.Activated:Connect(function()
			role = r.id
			refresh()
		end)
	end
	for _, id in ProgressionConfig.SkinIds do
		local button = find("SkinGrid/Skin_" .. id)
		if button then
			button.Activated:Connect(function()
				skin = id
				accessory = nil
				refresh()
			end)
		end
	end
	for _, id in ProgressionConfig.AccessoryIds do
		local button = find("Accessories/" .. id)
		if button then
			button.Activated:Connect(function()
				accessory = id
			end)
		end
	end
	local remote = Util.getRemote("RE_EquipSkin")
	find("Equip").Activated:Connect(function()
		if remote then
			-- DÉFAUT (C38) : un accessoire passe par RE_EquipSkin (roleId, accessoryId[, couleur]).
			-- 19.6 (C43) : Équiper sur le bonnet passe d'une couleur à la suivante, puis le retire
			local rule = accessory and ProgressionConfig.AccessoryUnlocks[accessory]
			if rule and rule.colors then
				local worn = Util.decode(player:GetAttribute("equippedAccessoriesJson"), {})
				local current = worn[role] and worn[role][accessory]
				local nextColor = (if type(current) == "number" then current else 0) + 1
				if nextColor <= rule.colors then
					remote:FireServer(role, accessory, nextColor)
				else
					remote:FireServer(role, accessory)
				end
			else
				remote:FireServer(role, accessory or skin)
			end
		end
	end)
	player:GetAttributeChangedSignal("skinsJson"):Connect(refresh)
	player:GetAttributeChangedSignal("accessoriesJson"):Connect(refresh)
	ProximityPromptService.PromptTriggered:Connect(function(prompt)
		if prompt:GetAttribute("lobbyAction") == "SkinShop" then
			show()
		end
	end)
	ProximityPromptService.PromptHidden:Connect(function(prompt)
		if prompt:GetAttribute("lobbyAction") == "SkinShop" then
			for _, name in PANELS do
				local el = find(name)
				if el then
					el.Visible = false
				end
			end
		end
	end)
end

return SkinShopController
