-- ServerScriptService/AI/Behaviors/BHV_Guard (Partie)
-- Section 9.5 : Garder : femelle, joueur à moins de 40 studs du repaire ; attaque sans avertissement.
-- Score de 0 à 1 (interprétation de la colonne « Score élevé quand », à régler en phase B3).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local CreatureConfig = require(Config:WaitForChild("CreatureConfig"))
local MapConfig = require(Config:WaitForChild("MapConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local B = CreatureConfig.Behaviors.BHV_Guard
local Behavior = {}

Behavior.urgent = true

local function intruder(brain)
	local lair = MapConfig.Places[CreatureConfig.LairPlace].pos
	for _, player in brain:Candidates() do
		local root = Util.characterRoot(player)
		if root and (root.Position - lair).Magnitude <= B.range then
			return player
		end
	end
	return nil
end

function Behavior.score(brain)
	if brain.id ~= "CRT_Female" then
		return 0
	end
	return if intruder(brain) then 1 else 0
end

function Behavior.step(brain)
	local player = intruder(brain)
	local root = player and Util.characterRoot(player)
	if root == nil then
		return
	end
	brain.target = player
	brain.vigilance[player] = CreatureConfig.Vision.TargetAt
	local distance = brain:DistanceTo(player)
	if distance <= CreatureConfig.Attacks.ATK_Grab.range then
		brain:Attack("ATK_Grab", player)
	elseif distance <= CreatureConfig.Attacks.ATK_Strike.range then
		brain:Attack("ATK_Strike", player)
	end
	brain:MoveTo(root.Position, "Run")
end

local _ = { MapConfig, Util, B }

return Behavior
