-- ServerScriptService/Services/FearService (Partie)
-- Section 7.5 : peur de 0 à 100 (attribut fear), jamais affichée en chiffre.
-- Lumière : la lampe du joueur allumée (attribut lightOn) ou une source taguée « LightSource »
-- dont la portée (attribut range) couvre le joueur. Feu et fusée : tag « FireSource » (attribut radius).
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local PlayerConfig = require(Config:WaitForChild("PlayerConfig"))
local NoiseTypes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("NoiseTypes"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local FearService = {}

local Fear = PlayerConfig.Fear
local services = nil
local state = {} -- [Player] = { lastScream, seenBodies = {}, lastOrder }

local function nearestTeammate(player, position)
	local best = math.huge
	for _, other in Players:GetPlayers() do
		if other ~= player and services.HealthService:IsAlive(other) then
			local root = Util.characterRoot(other)
			if root then
				best = math.min(best, (root.Position - position).Magnitude)
			end
		end
	end
	return best
end

local function inLight(player, position, radius)
	if player:GetAttribute("lightOn") then
		return true
	end
	for _, source in CollectionService:GetTagged("LightSource") do
		local part = if source:IsA("BasePart") then source else source:FindFirstAncestorWhichIsA("BasePart")
		local range = source:GetAttribute("range") or 0
		if part and (part.Position - position).Magnitude <= math.max(range, radius) then
			return true
		end
	end
	return false
end

local function nearFire(position)
	for _, source in CollectionService:GetTagged("FireSource") do
		local part = if source:IsA("BasePart") then source else source:FindFirstAncestorWhichIsA("BasePart")
		local radius = source:GetAttribute("radius") or 0
		if part and (part.Position - position).Magnitude <= radius then
			return true
		end
	end
	return false
end

-- change la peur ; les hausses sont multipliées par le facteur du rôle (Descendante ×1,25)
function FearService:Add(player, amount)
	if not services.HealthService:IsAlive(player) then
		return
	end
	if amount > 0 then
		amount *= Fear.RoleFactor[player:GetAttribute("role")] or 1
	end
	local fear = math.clamp((player:GetAttribute("fear") or 0) + amount, 0, Fear.Max)
	player:SetAttribute("fear", fear)
	local s = state[player]
	if
		fear >= Fear.InvoluntaryScreamAt
		and s
		and os.clock() - (s.lastScream or -math.huge) >= Fear.InvoluntaryScreamCooldown
	then
		s.lastScream = os.clock()
		local root = Util.characterRoot(player)
		if root then
			-- 7.5 : cri involontaire (bruit 200) ; les coéquipiers à moins de 100 studs : +10
			services.NoiseService:Emit(root.Position, Fear.InvoluntaryScreamNoise, NoiseTypes.Scream, player)
			self:OnScream(root.Position, player)
		end
	end
end

-- 7.5 : cri à moins de 100 studs : +10 (cri de joueur ou de créature)
function FearService:OnScream(position, except)
	for _, player in Players:GetPlayers() do
		local root = Util.characterRoot(player)
		if player ~= except and root and (root.Position - position).Magnitude <= Fear.ScreamRadius then
			self:Add(player, Fear.Scream)
		end
	end
end

-- 7.5 : coup sur tronc entendu (+4) ; appelé par l'IA
function FearService:OnWoodKnock(player)
	self:Add(player, Fear.WoodKnock)
end

-- 7.5 : voir la créature (+20 à +35, plus si proche) ; appelé par l'IA
function FearService:OnSeeCreature(player, distance)
	if Fear.SeeCreatureRange == nil or distance > Fear.SeeCreatureRange then
		return
	end
	local closeness = 1 - distance / Fear.SeeCreatureRange
	self:Add(player, Fear.SeeCreatureMin + (Fear.SeeCreatureMax - Fear.SeeCreatureMin) * closeness)
end

-- 7.7 : ordre du Meneur : −20 aux coéquipiers à 15 studs, recharge 90 s
function FearService:LeaderOrder(player)
	local ability = PlayerConfig.Abilities.Leader
	local s = state[player]
	local root = Util.characterRoot(player)
	if player:GetAttribute("role") ~= "Leader" or not s or not root then
		return false
	end
	if os.clock() - (s.lastOrder or -math.huge) < ability.OrderCooldown then
		return false
	end
	s.lastOrder = os.clock()
	for _, other in Players:GetPlayers() do
		local otherRoot = Util.characterRoot(other)
		if otherRoot and (otherRoot.Position - root.Position).Magnitude <= ability.OrderRange then
			self:Add(other, ability.OrderFear)
		end
	end
	return true
end

local function tick(dt)
	for _, player in Players:GetPlayers() do
		local root = Util.characterRoot(player)
		if state[player] and root and services.HealthService:IsAlive(player) then
			local position = root.Position
			local delta = 0
			if inLight(player, position, Fear.NoLightRadius) then
				delta += Fear.InLightPerSecond
			else
				delta += Fear.NoLightPerSecond
			end
			local mate = nearestTeammate(player, position)
			if mate > Fear.AloneRadius then
				delta += Fear.AlonePerSecond
			elseif mate <= Fear.TeammateRadius then
				delta += Fear.TeammatePerSecond
			end
			if nearFire(position) then
				delta += Fear.NearFirePerSecond
			end
			-- 7.5 : voir un corps (+15 une fois par corps), si la portée est donnée par la bible
			if Fear.SeeBodyRange then
				for _, corpse in CollectionService:GetTagged("Corpse") do
					local s = state[player]
					local pivot = corpse:IsA("Model") and corpse:GetPivot().Position or corpse.Position
					if not s.seenBodies[corpse] and (pivot - position).Magnitude <= Fear.SeeBodyRange then
						s.seenBodies[corpse] = true
						FearService:Add(player, Fear.SeeBody)
					end
				end
			end
			FearService:Add(player, delta * dt)
		end
	end
end

function FearService:Init(allServices)
	services = allServices
end

function FearService:Start()
	services.CharacterService.Spawned:Connect(function(player)
		state[player] = { seenBodies = {} }
		player:SetAttribute("fear", 0)
	end)
	Players.PlayerRemoving:Connect(function(player)
		state[player] = nil
	end)
	task.spawn(function()
		local step = PlayerConfig.Technical.Tick
		while true do
			task.wait(step)
			tick(step)
		end
	end)
end

return FearService
