-- Controllers/BoundaryController (Partie)
-- Section 3.8 : à ±3 900, message « Tu t'éloignes trop du groupe » (le mur invisible est à ±4 000).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = ReplicatedStorage:WaitForChild("Config")
local MapConfig = require(Config:WaitForChild("MapConfig"))
local PlayerConfig = require(Config:WaitForChild("PlayerConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local BoundaryController = {}

local player = Players.LocalPlayer
local controllers = nil
local lastShown = -math.huge

function BoundaryController:Init(all)
	controllers = all
end

function BoundaryController:Start()
	RunService.Heartbeat:Connect(function()
		local root = Util.characterRoot(player)
		if root == nil then
			return
		end
		local p = root.Position
		local outside = math.abs(p.X) >= MapConfig.WarnHalf or math.abs(p.Z) >= MapConfig.WarnHalf
		-- DÉFAUT : le message revient au plus une fois par durée d'affichage
		if outside and os.clock() - lastShown >= PlayerConfig.Interface.NotificationDuration then
			lastShown = os.clock()
			controllers.NotificationController:Show(MapConfig.WarnText)
		end
	end)
end

return BoundaryController
