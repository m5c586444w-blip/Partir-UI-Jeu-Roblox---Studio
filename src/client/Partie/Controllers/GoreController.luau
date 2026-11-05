-- Controllers/GoreController (Partie)
-- Sections 11.2, 11.4, 11.5 et 17.3 : affichage local du sang selon le profil (attribut goreProfile de
-- Workspace) et l'option « Gore réduit » (qui applique l'affichage Moderate). Jet court (0,3 s) à chaque
-- blessure ; flaque posée par rayon vers le sol ; plafond de flaques selon le préréglage (17.3) ;
-- noir à l'instant de la mort pour ATK_Execution (attribut blackoutAt).
-- Les décalques (Decal_Blood_Pool, 13.5) sont à créer : en attendant, plaque rouge sombre (DÉFAUT).
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local GoreConfig = require(Config:WaitForChild("GoreConfig"))
local PlayerConfig = require(Config:WaitForChild("PlayerConfig"))
local ProgressionConfig = require(Config:WaitForChild("ProgressionConfig"))

local GoreController = {}

GoreController.ReducedGore = GoreConfig.ReducedGoreDefault
GoreController.Preset = "High"

local player = Players.LocalPlayer
local pools = {}
local BLOOD_COLOR = Color3.fromRGB(80, 10, 8) -- constante (couleur de remplacement du décalque)
local POOL_THICKNESS = 0.05 -- constante (épaisseur d'une plaque au sol)

local function profileName()
	local profile = workspace:GetAttribute("goreProfile") or GoreConfig.Profile
	if GoreController.ReducedGore then
		return "Moderate" -- 11.4
	end
	return profile
end

local function maxPools()
	local preset = ProgressionConfig.Presets[GoreController.Preset] or ProgressionConfig.Presets.High
	local profile = GoreConfig.Profiles[profileName()]
	return math.min(preset.bloodPools, profile.bloodPools.maxOnMap or preset.bloodPools)
end

local function burst(part)
	local emitter = Instance.new("ParticleEmitter")
	emitter.Color = ColorSequence.new(BLOOD_COLOR)
	emitter.Rate = 0
	emitter.Parent = part
	emitter:Emit(if profileName() == "Restricted" then 20 else 4) -- constante (nombre de gouttes)
	Debris:AddItem(emitter, GoreConfig.Blood.BurstDuration * 4) -- constante (le temps que les gouttes retombent)
end

-- RaycastParams des flaques : tous les personnages exclus ; refaits seulement quand un personnage
-- apparaît ou disparaît (au lieu de reconstruire la liste à chaque flaque)
local poolParams = RaycastParams.new()
poolParams.FilterType = Enum.RaycastFilterType.Exclude
local poolParamsDirty = true

local function markCharactersChanged()
	poolParamsDirty = true
end

local function watchPlayer(p)
	p.CharacterAdded:Connect(markCharactersChanged)
	p.CharacterRemoving:Connect(markCharactersChanged)
end
for _, p in Players:GetPlayers() do
	watchPlayer(p)
end
Players.PlayerAdded:Connect(watchPlayer)
Players.PlayerRemoving:Connect(markCharactersChanged)

local function pool(position)
	if poolParamsDirty then
		poolParamsDirty = false
		local characters = {}
		for _, p in Players:GetPlayers() do
			if p.Character then
				table.insert(characters, p.Character)
			end
		end
		poolParams.FilterDescendantsInstances = characters
	end
	local params = poolParams
	local hit = workspace:Raycast(position, Vector3.new(0, -PlayerConfig.LimbHealth.Torso, 0), params)
	if hit == nil then
		return
	end
	local name = profileName()
	local size = GoreConfig.PoolSize[name]
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.Color = BLOOD_COLOR
	part.Material = Enum.Material.Glass
	part.Size = Vector3.new(size, POOL_THICKNESS, size)
	part.CFrame = CFrame.new(hit.Position)
	part.Parent = workspace
	table.insert(pools, part)
	while #pools > maxPools() do
		table.remove(pools, 1):Destroy()
	end
	Debris:AddItem(part, GoreConfig.Profiles[name].bloodPools.lifetime)
end

local function watch(other)
	local last = {}
	for _, limb in PlayerConfig.Limbs do
		local key = "hp" .. limb
		last[key] = other:GetAttribute(key)
		other:GetAttributeChangedSignal(key):Connect(function()
			local value = other:GetAttribute(key)
			local before = last[key]
			last[key] = value
			local root = other.Character and other.Character:FindFirstChild("HumanoidRootPart")
			if root and before and value and value < before then
				burst(root)
				pool(root.Position)
			end
		end)
	end
end

function GoreController:Start()
	for _, other in Players:GetPlayers() do
		watch(other)
	end
	Players.PlayerAdded:Connect(watch)
	-- 11.2 : noir à l'instant de la mort (mise à mort, profil Restricted)
	player:GetAttributeChangedSignal("blackoutAt"):Connect(function()
		local black = Instance.new("ColorCorrectionEffect")
		black.Brightness = -1
		black.Parent = Lighting
		Debris:AddItem(black, PlayerConfig.DeathCamera.Duration)
	end)
end

return GoreController
