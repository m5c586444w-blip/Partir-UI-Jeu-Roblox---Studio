-- ServerScriptService/Services/CinematicService (Partie)
-- Sections 6.1 et 16.2 : déclenche les cinématiques. Une cinématique de lieu ne joue que pour les
-- joueurs dans son rayon ; les cinématiques de fin jouent pour tous. Pendant une cinématique, le
-- personnage est invulnérable et retiré des cibles de la créature, plus 3 s après (attribut
-- cinematicUntil, heure serveur). En partie : passer = vote à la majorité des joueurs concernés.
-- RE_PlayCinematic (S → C) : ("Play", id, extra) / ("Stop", id) / ("SkipVotes", n, total).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local CinematicConfig = require(Config:WaitForChild("CinematicConfig"))
local MapConfig = require(Config:WaitForChild("MapConfig"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local RateLimiter = require(Shared:WaitForChild("RateLimiter"))
local Signal = require(Shared:WaitForChild("Signal"))
local Util = require(Shared:WaitForChild("Util"))

local CinematicService = {}

CinematicService.Finished = Signal.new() -- (id, skipped)

local remote = nil
local current = nil -- { id, viewers = {Player}, votes = {[Player]=true}, done = Signal }

local function viewersFor(id, explicit)
	local def = CinematicConfig.Cinematics[id]
	if explicit then
		return explicit
	end
	if def.scope == "Place" then
		local place = MapConfig.Places[def.place]
		local list = {}
		for _, player in Players:GetPlayers() do
			local root = Util.characterRoot(player)
			if root and (root.Position - place.pos).Magnitude <= (place.radius or 0) then
				table.insert(list, player)
			end
		end
		return list
	end
	return Players:GetPlayers()
end

local function finish(skipped)
	if current == nil then
		return
	end
	local ended = current
	current = nil
	local safeUntil = workspace:GetServerTimeNow() + CinematicConfig.SafetyAfter
	for _, player in ended.viewers do
		if player.Parent then
			player:SetAttribute("cinematicUntil", safeUntil)
			if skipped and remote then
				remote:FireClient(player, "Stop", ended.id)
			end
		end
	end
	CinematicService.Finished:Fire(ended.id, skipped)
	ended.done:Fire()
end

-- joue une cinématique et attend sa fin ; `players` facultatif (sinon selon la portée de 6.2)
function CinematicService:PlayAndWait(id, players, extra)
	local def = CinematicConfig.Cinematics[id]
	if def == nil then
		warn("CinematicService : cinématique inconnue " .. tostring(id))
		return
	end
	while current ~= nil do
		current.done:Wait()
	end
	local viewers = viewersFor(id, players)
	if #viewers == 0 then
		return
	end
	local done = Signal.new()
	current = { id = id, viewers = viewers, votes = {}, done = done }
	local untilTime = workspace:GetServerTimeNow() + def.duration + CinematicConfig.SafetyAfter
	for _, player in viewers do
		player:SetAttribute("cinematicUntil", untilTime)
		if remote then
			remote:FireClient(player, "Play", id, extra)
		end
	end
	local mine = current
	task.delay(def.duration, function()
		if current == mine then
			finish(false)
		end
	end)
	done:Wait()
end

function CinematicService:Play(id, players, extra)
	task.spawn(self.PlayAndWait, self, id, players, extra)
end

function CinematicService:IsProtected(player)
	return (player:GetAttribute("cinematicUntil") or 0) > workspace:GetServerTimeNow()
end

local function onSkipVote(player)
	if current == nil or not table.find(current.viewers, player) then
		return
	end
	current.votes[player] = true
	local count = 0
	for voter in current.votes do
		if voter.Parent then
			count += 1
		end
	end
	for _, viewer in current.viewers do
		if remote and viewer.Parent then
			remote:FireClient(viewer, "SkipVotes", count, #current.viewers)
		end
	end
	if count * 2 > #current.viewers then
		finish(true)
	end
end

function CinematicService:Init() end

function CinematicService:Start()
	remote = Util.getRemote("RE_PlayCinematic")
	local skip = Util.getRemote("RE_CinematicSkipVote")
	if skip then
		RateLimiter.connect(skip, onSkipVote)
	end
end

return CinematicService
