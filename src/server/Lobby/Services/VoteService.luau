-- ServerScriptService/Services/VoteService (Lobby)
-- Sections 4.4 et 5.4 : votes de difficulté (Normal, Difficile, Cauchemar si débloquée) et de météo
-- (aléatoire ou fixe). Sans vote : Normal, aléatoire. Égalité : la difficulté la plus basse ; météo
-- aléatoire. RE_Vote (C → S) : ("Difficulty", id) / ("Weather", id) / ("Weapon", userId).
-- Attributs du joueur : voteDifficulty, voteWeather.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LaunchConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("LaunchConfig"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local RateLimiter = require(Shared:WaitForChild("RateLimiter"))
local Util = require(Shared:WaitForChild("Util"))

local VoteService = {}

local services = nil
local Votes = LaunchConfig.Votes

local function onVote(player, kind, value)
	if kind == "Weapon" then
		if type(value) == "number" then
			services.WeaponBoardService:Vote(player, value)
		end
		return
	end
	local party = services.PartyService:GetParty(player)
	if party == nil or party.launching or type(value) ~= "string" then
		return
	end
	party.votes[player] = party.votes[player] or {}
	if kind == "Difficulty" and table.find(Votes.Difficulties, value) then
		-- 5.4 : Cauchemar se débloque après une première survie
		if value == "Nightmare" then
			local data = services.DataService:GetData(player)
			if not (data and data.nightmareUnlocked) then
				Util.notify(player, "MSG_NightmareLocked")
				return
			end
		end
		party.votes[player].difficulty = value
		player:SetAttribute("voteDifficulty", value)
	elseif kind == "Weather" and table.find(Votes.Weathers, value) then
		party.votes[player].weather = value
		player:SetAttribute("voteWeather", value)
	end
end

local function tally(party, key, options, default, tie)
	local counts = {}
	for member, vote in party.votes do
		if member.Parent and vote[key] then
			counts[vote[key]] = (counts[vote[key]] or 0) + 1
		end
	end
	local best, bestCount, tied = nil, 0, false
	for _, option in options do -- dans l'ordre : de la plus basse à la plus haute
		local count = counts[option] or 0
		if count > bestCount then
			best, bestCount, tied = option, count, false
		elseif count == bestCount and count > 0 then
			tied = true
		end
	end
	if best == nil then
		return default
	end
	if tied then
		-- difficulté : la plus basse l'emporte (la première rencontrée) ; météo : aléatoire
		return if tie == "Lowest" then best else tie
	end
	return best
end

-- résultat des votes, écrit dans le groupe (lu par LaunchService)
function VoteService:Resolve(party)
	party.difficulty = tally(party, "difficulty", Votes.Difficulties, Votes.DefaultDifficulty, "Lowest")
	party.weather = tally(party, "weather", Votes.Weathers, Votes.DefaultWeather, Votes.TieWeather)
end

function VoteService:Init(allServices)
	services = allServices
end

function VoteService:Start()
	local remote = Util.getRemote("RE_Vote")
	if remote then
		RateLimiter.connect(remote, onVote)
	end
	services.PartyService.MemberLeft:Connect(function(party, player)
		party.votes[player] = nil
		if player.Parent then
			player:SetAttribute("voteDifficulty", nil)
			player:SetAttribute("voteWeather", nil)
		end
	end)
end

return VoteService
