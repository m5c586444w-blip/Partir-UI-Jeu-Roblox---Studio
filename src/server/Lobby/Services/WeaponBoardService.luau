-- ServerScriptService/Services/WeaponBoardService (Lobby)
-- Sections 4.4 et 8.2 : le tableau du van affiche les armes disponibles selon la taille du groupe
-- (1–3 : fusil ; 4–6 : + revolver ; 7–10 : + fusil à pompe). Un joueur clique pour en prendre une ;
-- en cas de conflit, vote à la majorité en 15 s, sinon tirage. Le fusil revient d'office au Pisteur
-- s'il est présent ; l'Opératrice ne peut pas porter d'arme à feu.
-- RE_TakeWeapon (C → S) : (weaponId). Votes : RE_Vote ("Weapon", userId du candidat), via VoteService.
-- Attributs : partyWeapon (joueur) ; weaponVote (JSON { weapon, a, b, endsAt }) sur chaque membre.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WeaponConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("WeaponConfig"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local RateLimiter = require(Shared:WaitForChild("RateLimiter"))
local Util = require(Shared:WaitForChild("Util"))

local WeaponBoardService = {}

local services = nil
local random = Random.new()

function WeaponBoardService:Available(party)
	local count = #party.members
	for _, entry in WeaponConfig.FirearmsByGroupSize do
		if count <= entry.maxPlayers then
			return entry.weapons
		end
	end
	return {}
end

local function holderOf(party, weaponId)
	for member, weapon in party.weapons do
		if weapon == weaponId and member.Parent then
			return member
		end
	end
	return nil
end

local function trackerOf(party)
	for member, role in party.roles do
		if role == WeaponConfig.RifleToRole and member.Parent then
			return member
		end
	end
	return nil
end

local function publish(party)
	for _, member in party.members do
		member:SetAttribute("partyWeapon", party.weapons[member])
		member:SetAttribute("weaponVote", if party.weaponVote then Util.encode(party.weaponVote.public) else nil)
	end
end

local function assign(party, player, weaponId)
	for member, weapon in party.weapons do
		if weapon == weaponId then
			party.weapons[member] = nil
		end
	end
	party.weapons[player] = weaponId
end

-- règles qui dépendent du groupe : armes disponibles, fusil au Pisteur, Opératrice sans arme
function WeaponBoardService:Refresh(party)
	local available = self:Available(party)
	for member, weapon in party.weapons do
		if
			not table.find(available, weapon)
			or party.roles[member] == WeaponConfig.NoFirearmRole
			or member.Parent == nil
		then
			party.weapons[member] = nil
		end
	end
	local tracker = trackerOf(party)
	if tracker and table.find(available, "WPN_Rifle") then
		assign(party, tracker, "WPN_Rifle")
	end
	publish(party)
end

local function finishVote(party)
	local vote = party.weaponVote
	if vote == nil then
		return
	end
	party.weaponVote = nil
	local a, b = 0, 0
	for _, choice in vote.votes do
		if choice == vote.public.a then
			a += 1
		elseif choice == vote.public.b then
			b += 1
		end
	end
	local winnerId
	if a > b then
		winnerId = vote.public.a
	elseif b > a then
		winnerId = vote.public.b
	else
		winnerId = if random:NextInteger(1, 2) == 1 then vote.public.a else vote.public.b -- sinon tirage
	end
	for _, member in party.members do
		if member.UserId == winnerId then
			assign(party, member, vote.public.weapon)
		end
	end
	publish(party)
end

local function onTake(player, weaponId)
	local party = services.PartyService:GetParty(player)
	if party == nil or party.launching or type(weaponId) ~= "string" then
		return
	end
	if not table.find(WeaponBoardService:Available(party), weaponId) then
		return
	end
	if party.roles[player] == WeaponConfig.NoFirearmRole then
		Util.notify(player, "MSG_WeaponNotAllowed")
		return
	end
	local holder = holderOf(party, weaponId)
	if holder == player then
		return
	end
	local tracker = trackerOf(party)
	if weaponId == "WPN_Rifle" and tracker and tracker ~= player then
		Util.notify(player, "MSG_WeaponTaken", { player = tracker.DisplayName })
		return
	end
	if holder == nil then
		assign(party, player, weaponId)
		publish(party)
		return
	end
	-- conflit : vote à la majorité en 15 s, sinon tirage
	if party.weaponVote then
		Util.notify(player, "MSG_WeaponTaken", { player = holder.DisplayName })
		return
	end
	party.weaponVote = {
		votes = {},
		public = {
			weapon = weaponId,
			a = holder.UserId,
			b = player.UserId,
			endsAt = workspace:GetServerTimeNow() + WeaponConfig.ConflictVoteDuration,
		},
	}
	for _, member in party.members do
		Util.notify(member, "MSG_WeaponVote")
	end
	publish(party)
	task.delay(WeaponConfig.ConflictVoteDuration, finishVote, party)
end

-- RE_Vote ("Weapon", userId) transmis par VoteService
function WeaponBoardService:Vote(player, candidateId)
	local party = services.PartyService:GetParty(player)
	local vote = party and party.weaponVote
	if vote and (candidateId == vote.public.a or candidateId == vote.public.b) then
		vote.votes[player] = candidateId
	end
end

function WeaponBoardService:Init(allServices)
	services = allServices
end

function WeaponBoardService:Start()
	local remote = Util.getRemote("RE_TakeWeapon")
	if remote then
		RateLimiter.connect(remote, onTake)
	end
	services.PartyService.MembersChanged:Connect(function(party)
		self:Refresh(party)
	end)
	services.PartyService.MemberLeft:Connect(function(party, player)
		party.weapons[player] = nil
		if player.Parent then
			player:SetAttribute("partyWeapon", nil)
			player:SetAttribute("weaponVote", nil)
		end
	end)
end

return WeaponBoardService
