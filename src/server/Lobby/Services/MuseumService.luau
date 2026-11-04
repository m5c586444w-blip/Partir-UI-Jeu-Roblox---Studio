-- ServerScriptService/Services/MuseumService (Lobby)
-- Sections 4.2 et 4.3 : chaque panneau lu donne 5 XP la première fois (données museumRead, 16.4).
-- RE_MuseumRead (C → S) : (panelId).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local LoreConfig = require(Config:WaitForChild("LoreConfig"))
local ProgressionConfig = require(Config:WaitForChild("ProgressionConfig"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local RateLimiter = require(Shared:WaitForChild("RateLimiter"))
local Util = require(Shared:WaitForChild("Util"))

local MuseumService = {}

local services = nil

local function onRead(player, panelId)
	if type(panelId) ~= "string" or LoreConfig.Museum[panelId] == nil then
		return
	end
	local data = services.DataService:GetData(player)
	if data == nil or data.museumRead[panelId] then
		return
	end
	data.museumRead[panelId] = true
	data.xp += ProgressionConfig.XPGains.MuseumPanel
	services.DataService:Save(player)
end

function MuseumService:Init(allServices)
	services = allServices
end

function MuseumService:Start()
	local remote = Util.getRemote("RE_MuseumRead")
	if remote then
		RateLimiter.connect(remote, onRead)
	end
end

return MuseumService
