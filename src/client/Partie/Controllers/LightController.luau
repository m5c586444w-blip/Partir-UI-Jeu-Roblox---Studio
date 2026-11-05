-- Controllers/LightController (Partie)
-- Sections 8.1 et 12.1 : lampes. Sous 15 % de pile, clignotement aléatoire (effet local, sur toutes
-- les lampes de joueurs taguées « PlayerLamp » ; la pile est lue sur l'attribut lightBattery du porteur).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TaggedSet = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("TaggedSet"))

local AmbienceConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("AmbienceConfig"))
local PlayerConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("PlayerConfig"))

local LightController = {}

function LightController:Start()
	local random = Random.new()
	RunService.Heartbeat:Connect(function()
		for _, lamp in TaggedSet.list("PlayerLamp") do
			local character = lamp:FindFirstAncestorOfClass("Model")
			local owner = character and Players:GetPlayerFromCharacter(character)
			local battery = owner and owner:GetAttribute("lightBattery") or 1
			if battery < AmbienceConfig.Lamp.FlickerBelow then
				lamp.Enabled = random:NextNumber() > PlayerConfig.Interface.LampFlickerChance
			else
				lamp.Enabled = true
			end
		end
	end)
end

return LightController
