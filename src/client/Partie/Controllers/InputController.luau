-- Controllers/InputController (Partie)
-- Section 16.2 : clavier, manette, MobileControlsGui (visible seulement sur écran tactile, 15.4).
-- Envoie des intentions au serveur : RE_SetStance, RE_EquipSlot, RE_UseItem, RE_FireWeapon,
-- RE_Reload, RE_ToggleLight, RE_Ping, RE_TabletAction. Touches : PlayerConfig.Keys (DÉFAUT).
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Config = ReplicatedStorage:WaitForChild("Config")
local ItemConfig = require(Config:WaitForChild("ItemConfig"))
local PlayerConfig = require(Config:WaitForChild("PlayerConfig"))
local WeaponConfig = require(Config:WaitForChild("WeaponConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local InputController = {}

local player = Players.LocalPlayer
local Keys = PlayerConfig.Keys
local remotes = {}
local controllers = nil
local stance = "Stand"
local lean = 0 -- −1 gauche, 0, 1 droite
local aiming = false
local activePrompt = nil

local function fire(name, ...)
	local remote = remotes[name]
	if remote then
		remote:FireServer(...)
	end
end

local function setStance(new)
	stance = new
	fire("RE_SetStance", new)
end

local function toggleStance(target)
	setStance(if stance == target then "Stand" else target)
end

function InputController:GetLean()
	return lean
end

function InputController:IsAiming()
	return aiming
end

local function selectedSlot()
	local inv = Util.decode(player:GetAttribute("inventory"), nil)
	return inv and inv.selected or 1
end

-- clic principal : tir si une arme est en main, sinon utiliser l'objet tenu
local function primary()
	local held = player:GetAttribute("heldItem")
	local camera = workspace.CurrentCamera
	if held and WeaponConfig.Weapons[held] then
		fire("RE_FireWeapon", camera.CFrame.Position, camera.CFrame.LookVector, workspace:GetServerTimeNow())
	elseif held and ItemConfig.Items[held] then
		-- direction de visée : sert au lancer balistique (19.5, C10)
		fire("RE_UseItem", selectedSlot(), camera.CFrame.LookVector)
	end
end

local function ping()
	local camera = workspace.CurrentCamera
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { player.Character }
	local hit = workspace:Raycast(
		camera.CFrame.Position,
		camera.CFrame.LookVector * PlayerConfig.Communication.PingRayLength,
		params
	)
	if hit then
		fire("RE_Ping", hit.Position)
	end
end

local ACTIONS = {
	Sprint = {
		down = function()
			setStance("Run")
		end,
		up = function()
			if stance == "Run" then
				setStance("Stand")
			end
		end,
	},
	Crouch = {
		down = function()
			toggleStance("Crouch")
		end,
	},
	Prone = {
		down = function()
			toggleStance("Prone")
		end,
	},
	LeanL = {
		down = function()
			lean = -1
		end,
		up = function()
			if lean == -1 then
				lean = 0
			end
		end,
	},
	LeanR = {
		down = function()
			lean = 1
		end,
		up = function()
			if lean == 1 then
				lean = 0
			end
		end,
	},
	Light = {
		down = function()
			fire("RE_ToggleLight")
		end,
	},
	Reload = {
		down = function()
			fire("RE_Reload")
		end,
	},
	Tablet = {
		down = function()
			fire("RE_TabletAction", "Device", "Toggle")
		end,
	},
	Ping = { down = ping },
	Bag = {
		down = function()
			if controllers.InventoryController then
				controllers.InventoryController:ToggleBag()
			end
		end,
	},
	Ability = {
		down = function()
			fire("RE_UseItem", 0)
		end,
	},
	Fire = { down = primary },
	Aim = {
		down = function()
			aiming = true
		end,
		up = function()
			aiming = false
		end,
	},
	Interact = {
		down = function()
			if activePrompt then
				activePrompt:InputHoldBegin()
			end
		end,
		up = function()
			if activePrompt then
				activePrompt:InputHoldEnd()
			end
		end,
	},
}

local KEYBOARD = {
	[Keys.Sprint] = "Sprint",
	[Keys.Crouch] = "Crouch",
	[Keys.Prone] = "Prone",
	[Keys.LeanL] = "LeanL",
	[Keys.LeanR] = "LeanR",
	[Keys.Light] = "Light",
	[Keys.Reload] = "Reload",
	[Keys.Tablet] = "Tablet",
	[Keys.Ping] = "Ping",
	[Keys.Bag] = "Bag",
	[Keys.Ability] = "Ability",
	[Keys.GamepadSprint] = "Sprint",
	[Keys.GamepadCrouch] = "Crouch",
	[Keys.GamepadFire] = "Fire",
	[Keys.GamepadAim] = "Aim",
	[Keys.GamepadReload] = "Reload",
}

local function onInput(input, processed, isDown)
	if processed and isDown then
		return
	end
	local name = KEYBOARD[input.KeyCode]
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		name = "Fire"
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
		name = "Aim"
	end
	if name then
		local action = ACTIONS[name]
		local handler = if isDown then action.down else action.up
		if handler then
			handler()
		end
		return
	end
	if isDown then
		local slot = table.find(Keys.Slots, input.KeyCode)
		if slot then
			fire("RE_EquipSlot", slot)
		end
	end
end

-- MobileControlsGui : un bouton par action (15.4), visible seulement sur écran tactile
local function bindMobile()
	if not UserInputService.TouchEnabled then
		return
	end
	local gui = Util.waitGui("MobileControlsGui")
	if gui == nil then
		return
	end
	local map = {
		Sprint = "Sprint",
		Crouch = "Crouch",
		Prone = "Prone",
		Interact = "Interact",
		Aim = "Aim",
		Fire = "Fire",
		Reload = "Reload",
		Light = "Light",
		Tablet = "Tablet",
		Ping = "Ping",
		LeanL = "LeanL",
		LeanR = "LeanR",
	}
	for buttonName, actionName in map do
		local button = Util.findUI(gui.Parent, "MobileControlsGui/" .. buttonName)
		if button then
			button.Visible = true
			local action = ACTIONS[actionName]
			-- courir et viser : maintien ; les autres : appui
			button.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.Touch and action.down then
					action.down()
				end
			end)
			button.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.Touch and action.up then
					action.up()
				end
			end)
		end
	end
end

function InputController:Init(all)
	controllers = all
end

function InputController:Start()
	for _, name in
		{
			"RE_SetStance",
			"RE_EquipSlot",
			"RE_UseItem",
			"RE_FireWeapon",
			"RE_Reload",
			"RE_ToggleLight",
			"RE_Ping",
			"RE_TabletAction",
		}
	do
		remotes[name] = Util.getRemote(name)
	end
	UserInputService.InputBegan:Connect(function(input, processed)
		onInput(input, processed, true)
	end)
	UserInputService.InputEnded:Connect(function(input, processed)
		onInput(input, processed, false)
	end)
	ProximityPromptService.PromptShown:Connect(function(prompt)
		activePrompt = prompt
	end)
	ProximityPromptService.PromptHidden:Connect(function(prompt)
		if activePrompt == prompt then
			activePrompt = nil
		end
	end)
	bindMobile()
end

return InputController
