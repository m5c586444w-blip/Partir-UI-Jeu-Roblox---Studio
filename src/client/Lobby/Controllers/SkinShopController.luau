-- Controllers/SkinShopController (Lobby)
-- Sections 4.5, 7.1 et 15.3 : SkinShopGui > CharacterList > Template ; SkinGrid > Skin_A, Skin_B,
-- Skin_C (> Lock, Requirement) ; Preview (ViewportFrame) ; Equip. Ouvert au magasin (L04).
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
		if lock then
			lock.Visible = not (skins[role] and skins[role][id])
		end
	end
	preview()
end

local function show()
	find("CharacterList").Visible = true
	find("SkinGrid").Visible = true
	find("Preview").Visible = true
	find("Equip").Visible = true
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
				refresh()
			end)
		end
	end
	local remote = Util.getRemote("RE_EquipSkin")
	find("Equip").Activated:Connect(function()
		if remote then
			remote:FireServer(role, skin)
		end
	end)
	player:GetAttributeChangedSignal("skinsJson"):Connect(refresh)
	ProximityPromptService.PromptTriggered:Connect(function(prompt)
		if prompt:GetAttribute("lobbyAction") == "SkinShop" then
			show()
		end
	end)
	ProximityPromptService.PromptHidden:Connect(function(prompt)
		if prompt:GetAttribute("lobbyAction") == "SkinShop" then
			for _, name in { "CharacterList", "SkinGrid", "Preview", "Equip" } do
				find(name).Visible = false
			end
		end
	end)
end

return SkinShopController
