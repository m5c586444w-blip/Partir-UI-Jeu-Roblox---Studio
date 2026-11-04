-- ServerScriptService/AI/Behaviors/BHV_Feed (Partie)
-- Section 9.5 : Manger : faim > 0,7 ; va à P19 ou à une carcasse.
-- Score de 0 à 1 (interprétation de la colonne « Score élevé quand », à régler en phase B3).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local CreatureConfig = require(Config:WaitForChild("CreatureConfig"))
local MapConfig = require(Config:WaitForChild("MapConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local B = CreatureConfig.Behaviors.BHV_Feed
local Behavior = {}

function Behavior.score(brain)
	if brain.id == "CRT_Female" or brain.hunger <= B.hungerAbove then
		return 0
	end
	return brain.hunger
end

function Behavior.start(brain)
	brain:MoveTo(MapConfig.Places[B.places[1]].pos, "Walk")
end

function Behavior.step(brain)
	if brain:Arrived(MapConfig.Places[B.places[1]].radius) then
		brain:Stop()
		brain.ai.CreatureAnimator:Play(brain.model, "FeedCrouch")
		brain.hunger = 0
	end
end

local _ = { MapConfig, Util, B }

return Behavior
