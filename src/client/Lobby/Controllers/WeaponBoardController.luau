-- Controllers/WeaponBoardController (Lobby)
-- Sections 4.4, 8.2 et 15.3 : WeaponBoardGui > Board > Slot_Rifle, Slot_Revolver, Slot_Shotgun
-- (Icon, Holder, Take) ; VotePopup > Question, Option_1, Option_2, Timer (conflit : vote en 15 s).
-- Visible une fois le rôle confirmé.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = ReplicatedStorage:WaitForChild("Config")
local LoreConfig = require(Config:WaitForChild("LoreConfig"))
local WeaponConfig = require(Config:WaitForChild("WeaponConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local WeaponBoardController = {}

local player = Players.LocalPlayer
local controllers = nil
local root = nil
local SLOTS = { Slot_Rifle = "WPN_Rifle", Slot_Revolver = "WPN_Revolver", Slot_Shotgun = "WPN_Shotgun" }

local function find(path)
	return Util.findUI(root, "WeaponBoardGui/" .. path)
end

local function available(count)
	for _, entry in WeaponConfig.FirearmsByGroupSize do
		if count <= entry.maxPlayers then
			return entry.weapons
		end
	end
	return {}
end

function WeaponBoardController:Refresh()
	if root == nil then
		return
	end
	local members = controllers.PartyController:Members()
	local open = #members > 0 and controllers.RoleController:IsConfirmed()
	local board = find("Board")
	if board then
		board.Visible = open
	end
	local weapons = available(#members)
	for slotName, weaponId in SLOTS do
		local slot = find("Board/" .. slotName)
		if slot then
			slot.Visible = table.find(weapons, weaponId) ~= nil
			local holder = ""
			for _, member in members do
				if member:GetAttribute("partyWeapon") == weaponId then
					holder = member.DisplayName
				end
			end
			slot:FindFirstChild("Holder").Text = holder
			local icon = slot:FindFirstChild("Icon")
			if icon then
				icon.Image = WeaponConfig.Icons[weaponId] or ""
			end
		end
	end
	local vote = Util.decode(player:GetAttribute("weaponVote"), nil)
	local popup = find("VotePopup")
	if popup then
		popup.Visible = open and vote ~= nil
		if vote then
			popup:FindFirstChild("Question").Text = LoreConfig.Messages.MSG_WeaponVote
			for i, userId in { vote.a, vote.b } do
				local other = Players:GetPlayerByUserId(userId)
				popup:FindFirstChild("Option_" .. i).Text = other and other.DisplayName or ""
			end
		end
	end
end

function WeaponBoardController:Init(all)
	controllers = all
end

function WeaponBoardController:Start()
	local gui = Util.waitGui("WeaponBoardGui")
	if gui == nil then
		return
	end
	root = gui.Parent
	local take = Util.getRemote("RE_TakeWeapon")
	local voteRemote = Util.getRemote("RE_Vote")
	for slotName, weaponId in SLOTS do
		local button = find("Board/" .. slotName .. "/Take")
		if button and take then
			button.Activated:Connect(function()
				take:FireServer(weaponId)
			end)
		end
	end
	for i = 1, 2 do
		local option = find("VotePopup/Option_" .. i)
		if option and voteRemote then
			option.Activated:Connect(function()
				local vote = Util.decode(player:GetAttribute("weaponVote"), nil)
				if vote then
					voteRemote:FireServer("Weapon", if i == 1 then vote.a else vote.b)
				end
			end)
		end
	end
	local function watch(other)
		for _, name in { "partyId", "partyWeapon", "weaponVote", "partyRole" } do
			other:GetAttributeChangedSignal(name):Connect(function()
				self:Refresh()
			end)
		end
	end
	for _, other in Players:GetPlayers() do
		watch(other)
	end
	Players.PlayerAdded:Connect(watch)
	RunService.Heartbeat:Connect(function()
		local vote = Util.decode(player:GetAttribute("weaponVote"), nil)
		local timer = find("VotePopup/Timer")
		if vote and timer then
			timer.Text = tostring(math.max(0, math.ceil(vote.endsAt - workspace:GetServerTimeNow())))
		end
	end)
	self:Refresh()
end

return WeaponBoardController
