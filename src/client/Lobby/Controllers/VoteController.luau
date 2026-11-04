-- Controllers/VoteController (Lobby)
-- Sections 4.4, 5.4 et 15.3 : VoteGui > Difficulty > Normal, Hard, Nightmare (> Lock) ;
-- Weather > Random, Clear, Fog, Rain, Snow ; Countdown (MSG_Countdown, 4.6).
-- Les scripts ne changent pas les couleurs (15.1) : le nombre de votes s'affiche dans le texte (DÉFAUT).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = ReplicatedStorage:WaitForChild("Config")
local LaunchConfig = require(Config:WaitForChild("LaunchConfig"))
local LoreConfig = require(Config:WaitForChild("LoreConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local VoteController = {}

local player = Players.LocalPlayer
local controllers = nil
local root = nil
local labels = {} -- [bouton] = texte de départ (15.6)

local function find(path)
	return Util.findUI(root, "VoteGui/" .. path)
end

function VoteController:Refresh()
	if root == nil then
		return
	end
	local members = controllers.PartyController:Members()
	local open = #members > 0 and controllers.RoleController:IsConfirmed()
	for _, name in { "Difficulty", "Weather" } do
		local panel = find(name)
		if panel then
			panel.Visible = open
		end
	end
	local counts = {}
	for _, member in members do
		for _, key in { "voteDifficulty", "voteWeather" } do
			local value = member:GetAttribute(key)
			if value then
				counts[value] = (counts[value] or 0) + 1
			end
		end
	end
	for button, text in labels do
		local n = counts[button.Name] or 0
		button.Text = if n > 0 then ("%s (%d)"):format(text, n) else text
	end
	local lock = find("Difficulty/Nightmare/Lock")
	if lock then
		lock.Visible = player:GetAttribute("nightmareUnlocked") ~= true
	end
end

function VoteController:Init(all)
	controllers = all
end

function VoteController:Start()
	local gui = Util.waitGui("VoteGui")
	if gui == nil then
		return
	end
	root = gui.Parent
	local remote = Util.getRemote("RE_Vote")
	for _, id in LaunchConfig.Votes.Difficulties do
		local button = find("Difficulty/" .. id)
		if button then
			labels[button] = button.Text
			button.Activated:Connect(function()
				remote:FireServer("Difficulty", id)
			end)
		end
	end
	for _, id in LaunchConfig.Votes.Weathers do
		local button = find("Weather/" .. id)
		if button then
			labels[button] = button.Text
			button.Activated:Connect(function()
				remote:FireServer("Weather", id)
			end)
		end
	end
	local function watch(other)
		for _, name in { "partyId", "voteDifficulty", "voteWeather", "nightmareUnlocked" } do
			other:GetAttributeChangedSignal(name):Connect(function()
				self:Refresh()
			end)
		end
	end
	for _, other in Players:GetPlayers() do
		watch(other)
	end
	Players.PlayerAdded:Connect(watch)
	local countdown = find("Countdown")
	RunService.Heartbeat:Connect(function()
		if countdown == nil then
			return
		end
		local endsAt = player:GetAttribute("partyCountdownEnd")
		countdown.Visible = endsAt ~= nil
		if endsAt then
			local n = math.max(0, math.ceil(endsAt - workspace:GetServerTimeNow()))
			countdown.Text = Util.formatMessage(LoreConfig.Messages.MSG_Countdown, { n = n })
		end
	end)
	self:Refresh()
end

return VoteController
