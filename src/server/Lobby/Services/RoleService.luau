-- ServerScriptService/Services/RoleService (Lobby)
-- Section 4.4 : chaque joueur choisit un rôle libre parmi les 10 (unique dans le groupe).
-- RE_SelectRole (C → S) : (roleId). Attribut du joueur : partyRole.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("PlayerConfig"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local RateLimiter = require(Shared:WaitForChild("RateLimiter"))
local Util = require(Shared:WaitForChild("Util"))

local RoleService = {}

local services = nil

local function validRole(roleId)
	for _, role in PlayerConfig.Roles do
		if role.id == roleId then
			return true
		end
	end
	return false
end

local function holderOf(party, roleId)
	for member, role in party.roles do
		if role == roleId and member.Parent then
			return member
		end
	end
	return nil
end

local function onSelect(player, roleId)
	if type(roleId) ~= "string" or not validRole(roleId) then
		return
	end
	local party = services.PartyService:GetParty(player)
	if party == nil or party.launching then
		return
	end
	local holder = holderOf(party, roleId)
	if holder and holder ~= player then
		Util.notify(player, "MSG_RoleTaken", { player = holder.DisplayName })
		return
	end
	party.roles[player] = roleId
	player:SetAttribute("partyRole", roleId)
	services.PartyService.MembersChanged:Fire(party)
end

function RoleService:Init(allServices)
	services = allServices
end

function RoleService:Start()
	local remote = Util.getRemote("RE_SelectRole")
	if remote then
		RateLimiter.connect(remote, onSelect)
	end
	services.PartyService.MemberLeft:Connect(function(party, player)
		party.roles[player] = nil
		if player.Parent then
			player:SetAttribute("partyRole", nil)
		end
	end)
end

return RoleService
