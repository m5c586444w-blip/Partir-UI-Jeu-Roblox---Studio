-- ServerScriptService/Services/SkinService (Lobby)
-- Sections 4.5 et 7.1 : équiper les skins débloqués par personnage. A dès le début, B après 5 parties
-- jouées, C après 1 survie. RE_EquipSkin (C → S) : (roleId, skinId). Données : skins, equipped (16.4).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local PlayerConfig = require(Config:WaitForChild("PlayerConfig"))
local ProgressionConfig = require(Config:WaitForChild("ProgressionConfig"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local RateLimiter = require(Shared:WaitForChild("RateLimiter"))
local Util = require(Shared:WaitForChild("Util"))

local SkinService = {}

local services = nil

local function unlocked(data, skinId)
	local rule = ProgressionConfig.SkinUnlocks[skinId]
	return rule ~= nil and (rule.stat == nil or (data[rule.stat] or 0) >= rule.need)
end

-- met à jour les déblocages enregistrés
local function refresh(player)
	local data = services.DataService:GetData(player)
	if data == nil then
		return
	end
	for _, role in PlayerConfig.Roles do
		data.skins[role.id] = data.skins[role.id] or {}
		for _, skinId in ProgressionConfig.SkinIds do
			if unlocked(data, skinId) then
				data.skins[role.id][skinId] = true
			end
		end
	end
	services.DataService:Save(player)
end

local function onEquip(player, roleId, skinId)
	local data = services.DataService:GetData(player)
	if data == nil or type(roleId) ~= "string" or type(skinId) ~= "string" then
		return
	end
	if data.skins[roleId] == nil or not data.skins[roleId][skinId] then
		return
	end
	data.equipped[roleId] = skinId
	services.DataService:Save(player)
end

function SkinService:Init(allServices)
	services = allServices
end

function SkinService:Start()
	local remote = Util.getRemote("RE_EquipSkin")
	if remote then
		RateLimiter.connect(remote, onEquip)
	end
	services.DataService.Loaded:Connect(refresh)
	local _ = Players
end

return SkinService
