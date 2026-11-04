-- Controllers/SpectatorController (Partie)
-- Sections 7.3 et 15.4 : après la caméra de mort, vue « caméra corporelle » d'un survivant
-- (Prev / Next, flèches ou balayage). SpectatorGui > Watching (« Tu regardes {player} »), Note.
-- RE_Spectate (C → S) : joueur suivi. Le spectateur n'a plus que le canal spectateurs (7.3).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Config = ReplicatedStorage:WaitForChild("Config")
local LoreConfig = require(Config:WaitForChild("LoreConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local SpectatorController = {}

local player = Players.LocalPlayer
local active = false
local index = 1
local root = nil
local remote = nil

local function survivors()
	local list = {}
	for _, other in Players:GetPlayers() do
		if other ~= player and not other:GetAttribute("isDead") and other.Character then
			table.insert(list, other)
		end
	end
	table.sort(list, function(a, b)
		return a.UserId < b.UserId
	end)
	return list
end

local function target()
	local list = survivors()
	if #list == 0 then
		return nil
	end
	index = ((index - 1) % #list) + 1
	return list[index]
end

local function refresh()
	local watched = target()
	local label = Util.findUI(root, "SpectatorGui/Watching")
	if label then
		label.Text = if watched
			then Util.formatMessage(LoreConfig.UI.Watching, { player = watched.DisplayName })
			else ""
	end
	if remote and watched then
		remote:FireServer(watched)
	end
end

local function step(delta)
	index += delta
	refresh()
end

function SpectatorController:IsActive()
	return active
end

function SpectatorController:Begin()
	if active then
		return
	end
	active = true
	for _, name in { "Watching", "Prev", "Next", "Note" } do
		local element = Util.findUI(root, "SpectatorGui/" .. name)
		if element then
			element.Visible = true
		end
	end
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	refresh()
end

function SpectatorController:Start()
	local gui = Util.waitGui("SpectatorGui")
	if gui == nil then
		return
	end
	root = gui.Parent
	remote = Util.getRemote("RE_Spectate")
	local prev = Util.findUI(root, "SpectatorGui/Prev")
	local nextButton = Util.findUI(root, "SpectatorGui/Next")
	if prev then
		prev.Activated:Connect(function()
			step(-1)
		end)
	end
	if nextButton then
		nextButton.Activated:Connect(function()
			step(1)
		end)
	end
	UserInputService.InputBegan:Connect(function(input, processed)
		if not active or processed then
			return
		end
		if input.KeyCode == Enum.KeyCode.Left then
			step(-1)
		elseif input.KeyCode == Enum.KeyCode.Right then
			step(1)
		end
	end)
	UserInputService.TouchSwipe:Connect(function(direction)
		if active then
			step(if direction == Enum.SwipeDirection.Left then 1 else -1)
		end
	end)
	-- caméra corporelle : à la place de la tête du survivant suivi
	RunService.RenderStepped:Connect(function()
		if not active then
			return
		end
		local watched = target()
		local head = watched and watched.Character and watched.Character:FindFirstChild("Head")
		if head then
			workspace.CurrentCamera.CFrame = head.CFrame
		end
	end)
end

return SpectatorController
