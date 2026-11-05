-- ServerScriptService/AI/Behaviors/BHV_Sabotage (Partie)
-- Section 9.5 : Saboter : groupe soudé depuis 120 s ; casse les lanternes, renverse le feu, vole un sac posé.
-- Score de 0 à 1 (interprétation de la colonne « Score élevé quand », à régler en phase B3).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local CreatureConfig = require(Config:WaitForChild("CreatureConfig"))
local MapConfig = require(Config:WaitForChild("MapConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local B = CreatureConfig.Behaviors.BHV_Sabotage
local Behavior = {}

local TaggedSet = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("TaggedSet"))

local function sabotageTarget(brain)
	local best, bestDistance = nil, math.huge
	for _, tag in { "FireSource", "LightSource" } do
		for _, item in TaggedSet.list(tag) do
			if item:IsA("BasePart") and not brain:IsPointSeen(item.Position) then
				local d = (item.Position - brain:Position()).Magnitude
				if d < bestDistance then
					best, bestDistance = item, d
				end
			end
		end
	end
	return best
end

function Behavior.score(brain)
	if brain.id == "CRT_Female" or not brain.ai.FamilyBrain:GroupTight() then
		return 0
	end
	return if sabotageTarget(brain) then B.baseScore else 0
end

function Behavior.step(brain)
	local item = sabotageTarget(brain)
	if item == nil then
		return
	end
	brain:MoveTo(item.Position, "Sneak")
	if (item.Position - brain:Position()).Magnitude <= CreatureConfig.Attacks.ATK_Strike.range then
		item:Destroy()
	end
end

local _ = { MapConfig, Util, B }

return Behavior
