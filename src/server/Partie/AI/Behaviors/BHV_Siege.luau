-- ServerScriptService/AI/Behaviors/BHV_Siege (Partie)
-- Section 9.5 : Siège (acte 2) : tourne à 25–40 studs, lance depuis le bord du canyon, teste les barricades.
-- Score de 0 à 1 (interprétation de la colonne « Score élevé quand », à régler en phase B3).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local CreatureConfig = require(Config:WaitForChild("CreatureConfig"))
local MapConfig = require(Config:WaitForChild("MapConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local B = CreatureConfig.Behaviors.BHV_Siege
local Behavior = {}

Behavior.urgent = true

function Behavior.score(brain)
	if brain.id == "CRT_Female" then
		return 0
	end
	return if Util.getMatchState():GetAttribute("siegeActive") then 1 else 0
end

local function outsidePlayer(brain)
	local cabin = MapConfig.Places.P05c
	for _, player in brain:Candidates() do
		local root = Util.characterRoot(player)
		if root and (root.Position - cabin.pos).Magnitude > cabin.radius then
			-- 5.2 : un joueur resté dehors pendant le siège est la cible prioritaire
			if (root.Position - cabin.pos).Magnitude <= MapConfig.Places.P05.radius then
				return player
			end
		end
	end
	return nil
end

function Behavior.step(brain)
	local cabin = MapConfig.Places.P05c.pos
	local angle = (os.clock() / B.maxRadius) + (if brain.id == "CRT_Alpha" then 0 else math.pi)
	local radius = (B.minRadius + B.maxRadius) / 2
	brain:MoveTo(cabin + Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius), "Walk")
	local interval = require(Config:WaitForChild("ActConfig")).Siege.StoneInterval
	if os.clock() - (brain.lastThrowAt or -math.huge) < interval then
		return
	end
	brain.lastThrowAt = os.clock()
	local outside = outsidePlayer(brain)
	if outside then
		brain.target = outside
		brain:Attack("ATK_Throw", outside)
		return
	end
	-- tester les barricades : une ouverture clouée reçoit une pierre ; une ouverture cédée → bras
	local openings = brain.services.GameStateService:GetOpenings()
	for _, part in openings do
		if part:GetAttribute("planks") == 0 then
			for _, player in brain:Candidates() do
				local root = Util.characterRoot(player)
				if
					root
					and (root.Position - part.Position).Magnitude <= CreatureConfig.Attacks.ATK_ReachThrough.range
				then
					brain:Attack("ATK_ReachThrough", player)
					return
				end
			end
		end
	end
	local nailed = {}
	for _, part in openings do
		if part:GetAttribute("planks") == 1 then
			table.insert(nailed, part)
		end
	end
	if #nailed > 0 then
		brain:Attack("ATK_Throw", nailed[math.random(1, #nailed)])
	end
end

local _ = { MapConfig, Util, B }

return Behavior
