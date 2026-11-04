-- ServerScriptService/AI/TensionDirector (Partie)
-- Section 9.12 : tension T par joueur (0 à 100) et intensité de groupe (moyenne des T), 1 fois/s.
-- T = 0,5 × peur + 0,3 × (100 − santé moyenne) + 20 × e^(−t/30).
-- Il ne déplace pas la créature : il autorise ou interdit les attaques, impose des pauses, et demande
-- des événements (EventDirector).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local ActConfig = require(Config:WaitForChild("ActConfig"))
local CreatureConfig = require(Config:WaitForChild("CreatureConfig"))
local DirectorConfig = require(Config:WaitForChild("DirectorConfig"))
local PlayerConfig = require(Config:WaitForChild("PlayerConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local TensionDirector = {}

local services = nil
local ai = nil
local tension = {} -- [Player] = T
local lastStrong = {} -- [Player] = os.clock()
local intensity = 0
local lowSince, highSince = nil, nil
local pausedUntil = 0
local deathsInAct = {} -- [act] = nombre
local deathTimes = {}
local attackAttempts = {} -- [act] = nombre
local isolatedSince = {} -- [Player] = os.clock()
local shotCreature = {} -- [Player] = true (acte 1 : un joueur qui tire peut mourir)
local Tension = DirectorConfig.Tension

function TensionDirector:Intensity()
	return intensity
end

function TensionDirector:Tension(player)
	return tension[player] or 0
end

function TensionDirector:IsPaused()
	return os.clock() < pausedUntil and not self:IsFinalAssault()
end

function TensionDirector:IsFinalAssault()
	return Util.getMatchState():GetAttribute("finalAssault") == true
end

-- événement fort vécu (attaque, créature vue de près, mort d'un coéquipier)
function TensionDirector:StrongEvent(player)
	if player then
		lastStrong[player] = os.clock()
	end
end

function TensionDirector:RegisterAttackAttempt(_brain, target)
	local act = Util.getMatchState():GetAttribute("act") or 0
	attackAttempts[act] = (attackAttempts[act] or 0) + 1
	if typeof(target) == "Instance" and target:IsA("Player") then
		self:StrongEvent(target)
	end
end

function TensionDirector:AttackAttempts(act)
	return attackAttempts[act] or 0
end

-- règles d'acte (9.12) : la créature peut-elle attaquer ce joueur maintenant ?
function TensionDirector:AllowAttack(brain, player)
	local state = Util.getMatchState()
	local act = state:GetAttribute("act") or 0
	if state:GetAttribute("creatureRetreat") then
		-- 5.2 : aucune attaque après 05 h 50, sauf dans les tunnels
		local root = Util.characterRoot(player)
		if root == nil or not ai.Perception:InPlace(root.Position, "P07b") then
			return false
		end
	end
	if self:IsPaused() then
		return false
	end
	if act == 0 then
		return false -- 5.2 : la créature ne se montre pas
	end
	local difficulty = services.PartyLoaderService:GetMatchInfo().difficulty
	if act == 1 then
		if brain.personality == "Playful" and CreatureConfig.Personalities.Playful.noKillAct1 then
			return false -- harcèle sans tuer en acte 1
		end
		local isolated = isolatedSince[player] and os.clock() - isolatedSince[player] >= DirectorConfig.Act1.IsolatedFor
		return isolated or shotCreature[player] == true
	elseif act == 2 then
		local limit = DirectorConfig.Act2MaxDeaths[difficulty] or DirectorConfig.Act2MaxDeaths.Normal
		return (deathsInAct[2] or 0) < limit
	elseif act == 3 then -- constante (numéro d'acte)
		for _, time in deathTimes do
			if os.clock() - time < DirectorConfig.Act3.Window then
				return false -- au plus 1 mort par tranche de 3 min
			end
		end
		return true
	end
	return true -- acte 4 : dernier assaut
end

local function averageHealth(player)
	local total = 0
	for _, limb in PlayerConfig.Limbs do
		total += services.HealthService:GetFraction(player, limb)
	end
	return total / #PlayerConfig.Limbs * Tension.Max
end

local function groupCenter(except)
	local sum, count = Vector3.zero, 0
	for _, player in Players:GetPlayers() do
		local root = Util.characterRoot(player)
		if player ~= except and root and services.HealthService:IsAlive(player) then
			sum += root.Position
			count += 1
		end
	end
	return if count > 0 then sum / count else nil
end

local function tick()
	local total, count = 0, 0
	for _, player in Players:GetPlayers() do
		if services.HealthService:IsAlive(player) then
			local t = os.clock() - (lastStrong[player] or -math.huge)
			local value = Tension.FearWeight * (player:GetAttribute("fear") or 0)
				+ Tension.HealthWeight * (Tension.Max - averageHealth(player))
				+ Tension.EventWeight * math.exp(-t / Tension.EventDecay)
			tension[player] = math.clamp(value, 0, Tension.Max)
			total += tension[player]
			count += 1
			-- acte 1 : joueur isolé à plus de 200 studs du groupe
			local root = Util.characterRoot(player)
			local center = groupCenter(player)
			if root and center and (root.Position - center).Magnitude > DirectorConfig.Act1.IsolatedDistance then
				isolatedSince[player] = isolatedSince[player] or os.clock()
			else
				isolatedSince[player] = nil
			end
		end
	end
	intensity = if count > 0 then total / count else 0
	Util.getMatchState():SetAttribute("intensity", intensity)

	-- montée : intensité < 25 pendant 120 s → un événement du catalogue « bas »
	if intensity < DirectorConfig.Rise.Below then
		lowSince = lowSince or os.clock()
		if os.clock() - lowSince >= DirectorConfig.Rise.For then
			lowSince = nil
			ai.EventDirector:RequestLow()
		end
	else
		lowSince = nil
	end
	-- pic : intensité > 75 pendant 90 s → pause de 60 à 90 s (sauf acte 4)
	if intensity > DirectorConfig.Peak.Above and not TensionDirector:IsFinalAssault() then
		highSince = highSince or os.clock()
		if os.clock() - highSince >= DirectorConfig.Peak.For then
			highSince = nil
			pausedUntil = os.clock()
				+ DirectorConfig.Peak.PauseMin
				+ math.random() * (DirectorConfig.Peak.PauseMax - DirectorConfig.Peak.PauseMin)
		end
	else
		highSince = nil
	end
	-- acte 1 : 1 aperçu lointain (CS_03) et 2 signes garantis (EventDirector)
	local state = Util.getMatchState()
	if state:GetAttribute("act") == 1 then
		ai.EventDirector:EnsureAct1Guarantees()
	end
end

function TensionDirector:Init(allServices, aiModules)
	services = allServices
	ai = aiModules
end

function TensionDirector:Start()
	services.HealthService.Died:Connect(function(player)
		local act = Util.getMatchState():GetAttribute("act") or 0
		deathsInAct[act] = (deathsInAct[act] or 0) + 1
		table.insert(deathTimes, os.clock())
		for _, other in Players:GetPlayers() do
			if other ~= player then
				self:StrongEvent(other) -- mort d'un coéquipier
			end
		end
	end)
	services.WeaponService.CreatureHit:Connect(function(_model, _damage, shooter)
		shotCreature[shooter] = true
	end)
	task.spawn(function()
		local step = 1 / CreatureConfig.Rates.Director
		while true do
			task.wait(step)
			tick()
		end
	end)
	local _ = ActConfig
end

return TensionDirector
