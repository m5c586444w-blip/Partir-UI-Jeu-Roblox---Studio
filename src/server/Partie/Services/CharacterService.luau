-- ServerScriptService/Services/CharacterService (Partie)
-- Sections 7.1 et 16.2 : l'avatar Roblox n'est jamais utilisé. Au spawn, le serveur clone le skin
-- choisi (ReplicatedStorage/Characters/<ROLE>/Skin_<n>) et l'assigne à Player.Character.
-- Modèle absent (MANQUANT, 13.3) : un mannequin Roblox neutre nommé MANQUANT_CHR_<ROLE>_Skin_<n>.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local PlayerConfig = require(Config:WaitForChild("PlayerConfig"))
local ProgressionConfig = require(Config:WaitForChild("ProgressionConfig"))
local Signal = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Signal"))

local CharacterService = {}

-- (player, character) : personnage créé et posé au départ
CharacterService.Spawned = Signal.new()

local services = nil
local roleOf = {} -- [Player] = role id
local order = {} -- ordre d'arrivée (index du point de départ)
local matchReady = false

local function takenRoles()
	local taken = {}
	for _, role in roleOf do
		taken[role] = true
	end
	return taken
end

-- rôle de la configuration de partie, sinon le premier rôle libre (DÉFAUT : test dans Studio, ou rôle non choisi)
local function assignRole(player, info)
	local entry = info.roles[player.UserId]
	local taken = takenRoles()
	if entry and entry.role and not taken[entry.role] then
		return entry.role
	end
	for _, role in PlayerConfig.Roles do
		if not taken[role.id] then
			return role.id
		end
	end
	return nil
end

local function equippedSkin(player, role)
	local data = services.DataService:WaitForData(player)
	local skin = data and data.equipped and data.equipped[role]
	return skin or ProgressionConfig.DefaultSkin
end

local function buildCharacter(player, role)
	local skin = equippedSkin(player, role)
	local folder = ReplicatedStorage:FindFirstChild(PlayerConfig.CharactersFolder)
	local roleFolder = folder and folder:FindFirstChild(role)
	local template = roleFolder and roleFolder:FindFirstChild(PlayerConfig.SkinPrefix .. skin)
	local character
	if template ~= nil then
		character = template:Clone()
	else
		-- 13.3 : CHR_<ROLE>_Skin_A–C MANQUANT → mannequin neutre, noté dans SUIVI.md
		warn(("CharacterService : modèle manquant Characters/%s/%s%s"):format(role, PlayerConfig.SkinPrefix, skin))
		character =
			Players:CreateHumanoidModelFromDescription(Instance.new("HumanoidDescription"), Enum.HumanoidRigType.R15)
		character:SetAttribute("placeholder", ("MANQUANT_CHR_%s_%s%s"):format(role, PlayerConfig.SkinPrefix, skin))
	end
	character.Name = player.Name
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		-- la mort est gérée par HealthService (ragdoll, sac au sol), pas par Roblox
		humanoid.BreakJointsOnDeath = false
		humanoid.RequiresNeck = false
	end
	return character
end

-- personnage assigné à la main (CharacterAutoLoads = false) : Roblox ne copie pas StarterGui ;
-- le serveur clone donc chaque ScreenGui déjà présent (15.1 : clones de modèles existants)
local function ensureGui(player)
	local playerGui = player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui", 10)
	if playerGui == nil then
		return
	end
	for _, gui in game:GetService("StarterGui"):GetChildren() do
		if gui:IsA("LayerCollector") and playerGui:FindFirstChild(gui.Name) == nil then
			gui:Clone().Parent = playerGui
		end
	end
end

local function setup(player)
	if roleOf[player] ~= nil or player.Parent == nil then
		return
	end
	local info = services.PartyLoaderService:GetMatchInfo()
	local role = assignRole(player, info)
	if role == nil then
		warn("CharacterService : aucun rôle libre pour " .. player.Name)
		return
	end
	roleOf[player] = role
	table.insert(order, player)
	player:SetAttribute("role", role)

	ensureGui(player)
	local character = buildCharacter(player, role)
	player.Character = character
	character.Parent = workspace
	services.SpawnService:Place(player, character, info.start, table.find(order, player))
	CharacterService.Spawned:Fire(player, character)
end

function CharacterService:GetRole(player)
	return roleOf[player]
end

-- rôles présents dans la partie (4.4 : sous 10 joueurs, les rôles non pris n'existent pas)
function CharacterService:GetPlayersByRole()
	local result = {}
	for player, role in roleOf do
		if player.Parent ~= nil then
			result[role] = player
		end
	end
	return result
end

function CharacterService:IsMatchReady()
	return matchReady
end

function CharacterService:Init(allServices)
	services = allServices
	Players.CharacterAutoLoads = false
end

function CharacterService:Start()
	task.spawn(function()
		local _, players = services.PartyLoaderService:WaitUntilLoaded()
		matchReady = true
		for _, player in players do
			task.spawn(setup, player)
		end
		for _, player in Players:GetPlayers() do
			task.spawn(setup, player)
		end
	end)
	Players.PlayerAdded:Connect(function(player)
		if matchReady then
			setup(player)
		end
	end)
	Players.PlayerRemoving:Connect(function(player)
		roleOf[player] = nil
	end)
end

return CharacterService
