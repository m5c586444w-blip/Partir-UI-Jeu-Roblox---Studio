-- Controllers/RoleController (Lobby)
-- Sections 4.4 et 15.3 : RoleSelectGui > Grid > RoleCard_<ROLE> (Portrait, CharacterName, RoleTitle,
-- Ability, Weakness, TakenOverlay > TakenBy) ; Confirm. Le portrait est un ViewportFrame qui affiche
-- le modèle Skin_A du rôle (13.5). La grille s'ouvre à l'entrée dans un groupe ; Confirm la ferme.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local LoreConfig = require(Config:WaitForChild("LoreConfig"))
local PlayerConfig = require(Config:WaitForChild("PlayerConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local RoleController = {}

local player = Players.LocalPlayer
local controllers = nil
local root = nil
local confirmed = false

local PORTRAIT_DISTANCE = PlayerConfig.Interface.PortraitDistance

local function find(path)
	return Util.findUI(root, "RoleSelectGui/" .. path)
end

function RoleController:IsConfirmed()
	return confirmed and player:GetAttribute("partyRole") ~= nil
end

local function setOpen(open)
	local grid, confirm = find("Grid"), find("Confirm")
	if grid then
		grid.Visible = open
	end
	if confirm then
		confirm.Visible = open
	end
end

local function fillPortrait(card, roleId)
	local viewport = card:FindFirstChild("Portrait")
	local folder = ReplicatedStorage:FindFirstChild(PlayerConfig.CharactersFolder)
	local model = folder
		and folder:FindFirstChild(roleId)
		and folder[roleId]:FindFirstChild(PlayerConfig.SkinPrefix .. "A")
	if viewport == nil or model == nil or viewport:FindFirstChildOfClass("Camera") then
		return
	end
	local clone = model:Clone()
	clone.Parent = viewport
	local camera = Instance.new("Camera")
	local pivot = clone:GetPivot()
	camera.CFrame = CFrame.lookAt(pivot.Position + pivot.LookVector * PORTRAIT_DISTANCE, pivot.Position)
	camera.Parent = viewport
	viewport.CurrentCamera = camera
end

local function refresh()
	if root == nil then
		return
	end
	local members = controllers.PartyController and controllers.PartyController:Members() or {}
	for _, role in PlayerConfig.Roles do
		local card = find("Grid/RoleCard_" .. role.id)
		if card then
			local holder = nil
			for _, member in members do
				if member:GetAttribute("partyRole") == role.id and member ~= player then
					holder = member
				end
			end
			local overlay = card:FindFirstChild("TakenOverlay")
			if overlay then
				overlay.Visible = holder ~= nil
				local takenBy = overlay:FindFirstChild("TakenBy")
				if takenBy and holder then
					takenBy.Text = Util.formatMessage(LoreConfig.UI.TakenBy, { player = holder.DisplayName })
				end
			end
		end
	end
	if player:GetAttribute("partyId") == nil then
		confirmed = false
		setOpen(false)
	elseif not confirmed then
		setOpen(true)
	end
end

function RoleController:Init(all)
	controllers = all
end

function RoleController:Start()
	local gui = Util.waitGui("RoleSelectGui")
	if gui == nil then
		return
	end
	root = gui.Parent
	local remote = Util.getRemote("RE_SelectRole")
	for _, role in PlayerConfig.Roles do
		local card = find("Grid/RoleCard_" .. role.id)
		if card then
			fillPortrait(card, role.id)
			card.Activated:Connect(function()
				if remote then
					remote:FireServer(role.id)
				end
			end)
		end
	end
	local confirm = find("Confirm")
	if confirm then
		confirm.Activated:Connect(function()
			if player:GetAttribute("partyRole") then
				confirmed = true
				setOpen(false)
				if controllers.VoteController then
					controllers.VoteController:Refresh()
				end
				if controllers.WeaponBoardController then
					controllers.WeaponBoardController:Refresh()
				end
			end
		end)
	end
	local function watch(other)
		for _, name in { "partyId", "partyRole" } do
			other:GetAttributeChangedSignal(name):Connect(refresh)
		end
	end
	for _, other in Players:GetPlayers() do
		watch(other)
	end
	Players.PlayerAdded:Connect(watch)
	refresh()
end

return RoleController
