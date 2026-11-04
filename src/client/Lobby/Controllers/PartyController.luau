-- Controllers/PartyController (Lobby)
-- Sections 4.4 et 15.3 : PartyGui > PartyFrame > Header (Title, Code), MemberList > Template
-- (PlayerName, RoleName, ReadyIcon), Buttons (CreatePublic, CreatePrivate, JoinCode, QuickJoin,
-- Ready, Leave), CodeInput. Lit les attributs publiés par PartyService et RoleService.
-- DÉFAUT : en attendant la ville du lobby (J14), PartyFrame est visible dès l'arrivée.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("PlayerConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local PartyController = {}

local player = Players.LocalPlayer
local root = nil
local remotes = {}

local function find(path)
	return Util.findUI(root, "PartyGui/PartyFrame/" .. path)
end

-- membres du groupe du joueur local (même attribut partyId)
function PartyController:Members()
	local partyId = player:GetAttribute("partyId")
	local list = {}
	if partyId == nil then
		return list
	end
	for _, other in Players:GetPlayers() do
		if other:GetAttribute("partyId") == partyId then
			table.insert(list, other)
		end
	end
	table.sort(list, function(a, b)
		return a.UserId < b.UserId
	end)
	return list
end

local function roleTitle(roleId)
	for _, role in PlayerConfig.Roles do
		if role.id == roleId then
			return role.title
		end
	end
	return ""
end

local function refresh()
	if root == nil then
		return
	end
	local inParty = player:GetAttribute("partyId") ~= nil
	for _, name in { "CreatePublic", "CreatePrivate", "JoinCode", "QuickJoin" } do
		local button = find("Buttons/" .. name)
		if button then
			button.Visible = not inParty
		end
	end
	for _, name in { "Ready", "Leave" } do
		local button = find("Buttons/" .. name)
		if button then
			button.Visible = inParty
		end
	end
	local input = find("CodeInput")
	if input then
		input.Visible = not inParty
	end
	local code = find("Header/Code")
	if code then
		code.Text = player:GetAttribute("partyCode") or ""
	end
	local template = find("MemberList/Template")
	if template then
		Util.clearClones(template)
		for i, member in PartyController:Members() do
			local row = Util.cloneTemplate(template, i)
			row:FindFirstChild("PlayerName").Text = member.DisplayName
			row:FindFirstChild("RoleName").Text = roleTitle(member:GetAttribute("partyRole"))
			row:FindFirstChild("ReadyIcon").Visible = member:GetAttribute("isReady") == true
		end
	end
end

local function watch(other)
	for _, name in { "partyId", "partyCode", "partyRole", "isReady" } do
		other:GetAttributeChangedSignal(name):Connect(refresh)
	end
end

function PartyController:Start()
	local gui = Util.waitGui("PartyGui")
	if gui == nil then
		return
	end
	root = gui.Parent
	for _, name in { "RE_PartyCreate", "RE_PartyJoin", "RE_PartyQuickJoin", "RE_PartyLeave", "RE_Ready" } do
		remotes[name] = Util.getRemote(name)
	end
	local actions = {
		CreatePublic = function()
			remotes.RE_PartyCreate:FireServer(false)
		end,
		CreatePrivate = function()
			remotes.RE_PartyCreate:FireServer(true)
		end,
		JoinCode = function()
			local input = find("CodeInput")
			remotes.RE_PartyJoin:FireServer(input and input.Text or "")
		end,
		QuickJoin = function()
			remotes.RE_PartyQuickJoin:FireServer()
		end,
		Ready = function()
			remotes.RE_Ready:FireServer(player:GetAttribute("isReady") ~= true)
		end,
		Leave = function()
			remotes.RE_PartyLeave:FireServer()
		end,
	}
	for name, action in actions do
		local button = find("Buttons/" .. name)
		if button then
			button.Activated:Connect(action)
		end
	end
	local frame = Util.findUI(root, "PartyGui/PartyFrame")
	if frame then
		frame.Visible = true
	end
	for _, other in Players:GetPlayers() do
		watch(other)
	end
	Players.PlayerAdded:Connect(watch)
	Players.PlayerRemoving:Connect(function()
		task.defer(refresh)
	end)
	refresh()
end

return PartyController
