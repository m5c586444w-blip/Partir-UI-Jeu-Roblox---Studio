-- ServerScriptService/AI/Behaviors/BHV_Ambush (Partie)
-- Section 9.5 : Embuscade : objectif des joueurs connu ; attend à 20–30 studs du chemin probable (90 s max).
-- Score de 0 à 1 (interprétation de la colonne « Score élevé quand », à régler en phase B3).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local CreatureConfig = require(Config:WaitForChild("CreatureConfig"))
local MapConfig = require(Config:WaitForChild("MapConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local B = CreatureConfig.Behaviors.BHV_Ambush
local Behavior = {}

local function objectivePoint()
	local state = Util.getMatchState()
	local route = state:GetAttribute("mainRoute")
	local routes = require(Config:WaitForChild("ActConfig")).Routes
	if route and routes[route] then
		return MapConfig.Places[routes[route].place].pos
	end
	if (state:GetAttribute("act") or 0) <= 1 then
		return MapConfig.Places.P05c.pos -- 5.2 : point de repli vers la cabane
	end
	return nil
end

function Behavior.score(brain)
	if brain.id == "CRT_Female" or brain.target == nil or objectivePoint() == nil then
		return 0
	end
	if os.clock() - (brain.lastAmbushAt or -math.huge) < B.maxDuration * 2 then
		return 0
	end
	return B.baseScore
end

function Behavior.start(brain)
	brain.lastAmbushAt = os.clock()
	local goal = objectivePoint()
	local root = Util.characterRoot(brain.target)
	if goal and root then
		-- sur le chemin probable : entre la cible et son objectif, à 20–30 studs de côté
		local mid = root.Position:Lerp(goal, 0.5)
		local side = (goal - root.Position):Cross(Vector3.yAxis)
		local offset = if side.Magnitude > 0 then side.Unit * (B.minDistance + B.maxDistance) / 2 else Vector3.zero
		brain:MoveTo(mid + offset, "Sneak")
	end
end

function Behavior.step(brain)
	if os.clock() - brain.behaviorStartedAt > B.maxDuration then
		brain.behaviorStartedAt = -math.huge -- fin de l'embuscade
		return
	end
	local t = brain.target
	if t and brain:DistanceTo(t) <= B.maxDistance and brain.ai.TensionDirector:AllowAttack(brain, t) then
		brain:Attack(
			if brain:DistanceTo(t) >= CreatureConfig.Attacks.ATK_Charge.minRange then "ATK_Charge" else "ATK_Strike",
			t
		)
	end
end

local _ = { MapConfig, Util, B }

return Behavior
