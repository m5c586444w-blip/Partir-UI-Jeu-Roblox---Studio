-- Controllers/RadioController (Partie)
-- Sections 7.8 et 15.4 : RadioGui > Channel, Talking, Static. Visible avec le talkie-walkie en main ;
-- le talkie grésille dans les gorges (P03, P05) et les tunnels (P07a–P07c).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local MapConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("MapConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local RadioController = {}

local player = Players.LocalPlayer
local STATIC_PLACES = { "P03", "P05", "P07a", "P07b", "P07c" }

local function inStaticZone(position)
	for _, code in STATIC_PLACES do
		local place = MapConfig.Places[code]
		if
			place.pos
			and (Vector2.new(position.X, position.Z) - Vector2.new(place.pos.X, place.pos.Z)).Magnitude
				<= place.radius
		then
			return true
		end
	end
	return false
end

function RadioController:Start()
	local gui = Util.waitGui("RadioGui")
	if gui == nil then
		return
	end
	local channel = Util.findUI(gui.Parent, "RadioGui/Channel")
	local talking = Util.findUI(gui.Parent, "RadioGui/Talking")
	local static = Util.findUI(gui.Parent, "RadioGui/Static")
	RunService.Heartbeat:Connect(function()
		local holding = player:GetAttribute("heldItem") == "ITM_Walkie" and not player:GetAttribute("isDead")
		if channel then
			channel.Visible = holding
		end
		if talking then
			-- TODO(BIBLE): ce qui allume « Talking » (chat vocal de proximité, 19.4 : décision en attente)
			talking.Visible = false
		end
		local root = Util.characterRoot(player)
		if static then
			static.Visible = holding and root ~= nil and inStaticZone(root.Position)
		end
	end)
end

return RadioController
