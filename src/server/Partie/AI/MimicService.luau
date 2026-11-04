-- ServerScriptService/AI/MimicService (Partie)
-- Section 9.8 : imitation des éclaireurs — sons préenregistrés du jeu, jamais la vraie voix d'un joueur :
-- sifflement humain (SFX_Whistle_01–03), appel « Hey ! » (VO_<ROLE>_Hey), appel à l'aide d'un
-- personnage mort (VO_<ROLE>_Help). 7.7 : l'Opératrice radio entend les éclaireurs imiter à 150 studs
-- et voit leur direction (attributs mimicAt et mimicDirection, en degrés depuis le nord).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local PlayerConfig = require(Config:WaitForChild("PlayerConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local MimicService = {}

local ai = nil

local function deadRole()
	for _, player in Players:GetPlayers() do
		if player:GetAttribute("isDead") then
			return player:GetAttribute("role")
		end
	end
	return nil
end

local function teammateRole(target)
	for _, player in Players:GetPlayers() do
		if player ~= target and player:GetAttribute("role") then
			return player:GetAttribute("role")
		end
	end
	return nil
end

function MimicService:Play(brain, target)
	local position = brain:Position()
	local sound
	local dead = deadRole()
	if dead then
		sound = ("VO_%s_Help"):format(dead) -- 9.9 : séparation, appel à l'aide d'un mort
	elseif target and teammateRole(target) and math.random() < 0.5 then -- constante (une chance sur deux)
		sound = ("VO_%s_Hey"):format(teammateRole(target))
	else
		sound = ("SFX_Whistle_0%d"):format(math.random(1, 3)) -- constante (3 sifflements, 9.8)
	end
	ai.CreatureAnimator:Play(brain.model, "MimicCall")
	ai.CreatureAnimator:PlaySoundAt(sound, position)
	-- 7.7 : l'Opératrice radio repère les voix imitées
	local range = PlayerConfig.Abilities.RadioOperator.MimicHearRange
	for _, player in Players:GetPlayers() do
		local root = Util.characterRoot(player)
		if
			player:GetAttribute("role") == "RadioOperator"
			and root
			and (root.Position - position).Magnitude <= range
		then
			local offset = position - root.Position
			player:SetAttribute("mimicDirection", math.deg(math.atan2(offset.X, -offset.Z)))
			player:SetAttribute("mimicAt", workspace:GetServerTimeNow())
		end
	end
end

function MimicService:Init(_services, aiModules)
	ai = aiModules
end

function MimicService:Start() end

return MimicService
