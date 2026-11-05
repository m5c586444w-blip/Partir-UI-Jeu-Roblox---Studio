-- ServerScriptService/Services/GoreService (Partie)
-- DÉFAUT : module ajouté (16.2 ne nomme pas le service du gore, jalon J13).
-- Section 11 : profil Restricted / Moderate. Démembrement (Restricted) : un coup de plus de 50 sur un
-- bras ou une jambe à moins de 10 % de PV détache le membre (pièce libre + capuchon Gore_Stump_<Membre>,
-- sans détail anatomique). Corps des géologues : variantes « Restricted » / « Moderate » posées dans
-- Studio (enfants des modèles Body_* de Workspace/Places). Sang, flaques et plaies : affichage client
-- (GoreController), selon le profil et l'option « Gore réduit » (11.4).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local GoreConfig = require(Config:WaitForChild("GoreConfig"))

local GoreService = {}

local services = nil

-- parties de rig par membre (R15 ; un skin découpé en 6 maillages peut nommer ses pièces pareil, 7.1)
local RIG_PARTS = {
	ArmL = { "LeftUpperArm", "LeftLowerArm", "LeftHand", "Left Arm" },
	ArmR = { "RightUpperArm", "RightLowerArm", "RightHand", "Right Arm" },
	LegL = { "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "Left Leg" },
	LegR = { "RightUpperLeg", "RightLowerLeg", "RightFoot", "Right Leg" },
}

function GoreService:Profile()
	return GoreConfig.Profiles[GoreConfig.Profile] or GoreConfig.Profiles.Moderate
end

local function detach(player, limb)
	local character = player.Character
	if character == nil or player:GetAttribute("lost" .. limb) then
		return
	end
	player:SetAttribute("lost" .. limb, true)
	for _, name in RIG_PARTS[limb] do
		local part = character:FindFirstChild(name)
		if part and part:IsA("BasePart") then
			for _, joint in part:GetChildren() do
				if joint:IsA("Motor6D") then
					joint:Destroy()
				end
			end
			part.CanCollide = true
			part.Parent = workspace -- pièce libre
		end
	end
	local stumps = ReplicatedStorage:FindFirstChild("Items")
	local stump = stumps and stumps:FindFirstChild(GoreConfig.Dismember.StumpPrefix .. limb)
	if stump then
		stump:Clone().Parent = character
	end
end

local function onDamaged(player, limb, amount)
	if not GoreService:Profile().dismember or not table.find(GoreConfig.Dismember.Limbs, limb) then
		return
	end
	if
		amount > GoreConfig.Dismember.MinHit
		and services.HealthService:GetFraction(player, limb) < GoreConfig.Dismember.MaxLimbFraction
	then
		detach(player, limb)
	end
end

-- variantes des corps des géologues selon le profil (DÉFAUT : enfants nommés comme le profil)
local function applyBodies()
	local places = workspace:FindFirstChild("Places")
	if places == nil then
		return
	end
	local wanted = GoreService:Profile().geologistBodies
	for _, body in places:GetDescendants() do
		if body:IsA("Model") and string.match(body.Name, "^Body_") then
			-- 19.6 (C1) : les corps des géologues comptent pour « voir un corps » (+15 de peur)
			body:AddTag("Corpse")
			for _, variant in body:GetChildren() do
				if variant.Name == "Restricted" or variant.Name == "Moderate" then
					variant.Parent = if variant.Name == wanted then body else nil
				end
			end
		end
	end
end

function GoreService:Init(allServices)
	services = allServices
	Players:SetAttribute("goreProfile", GoreConfig.Profile)
	workspace:SetAttribute("goreProfile", GoreConfig.Profile)
end

function GoreService:Start()
	services.HealthService.Damaged:Connect(onDamaged)
	applyBodies()
end

return GoreService
