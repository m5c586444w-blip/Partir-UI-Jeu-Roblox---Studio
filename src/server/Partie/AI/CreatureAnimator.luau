-- ServerScriptService/AI/CreatureAnimator (Partie)
-- Sections 13.7 et 14.2 : animations ANIM_Creature_* (objets Animation de
-- ReplicatedStorage/Animations/Creature, identifiants collés par Gabriel) et sons placés dans le monde
-- (10.3 : chaque son de créature a une position). Un identifiant manquant produit un avertissement,
-- jamais une erreur.
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AudioConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("AudioConfig"))

local CreatureAnimator = {}

local warned = {}
-- DÉFAUT : durée de vie d'un son posé (s)
local SOUND_LIFETIME = 10

local function warnOnce(key, text)
	if not warned[key] then
		warned[key] = true
		warn(text)
	end
end

-- joue ANIM_Creature_<name> sur le modèle (si l'Animation existe et a un identifiant)
function CreatureAnimator:Play(model, name)
	local folder = ReplicatedStorage:FindFirstChild("Animations")
	local creatureFolder = folder and folder:FindFirstChild("Creature")
	local animation = creatureFolder and creatureFolder:FindFirstChild("ANIM_Creature_" .. name)
	if animation == nil or animation.AnimationId == "" then
		warnOnce("anim:" .. name, "CreatureAnimator : animation sans identifiant ANIM_Creature_" .. name)
		return nil
	end
	local humanoid = model and model:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	if animator == nil then
		return nil
	end
	local track = animator:LoadAnimation(animation)
	track:Play()
	return track
end

-- son posé à une position (prefix accepté : « SFX_WoodKnock » choisit une variante _01…)
function CreatureAnimator:PlaySoundAt(soundId, position)
	local id = AudioConfig.Sounds[soundId]
	if id == nil then
		-- variantes numérotées
		local variants = {}
		for key, value in AudioConfig.Sounds do
			if string.sub(key, 1, #soundId) == soundId then
				table.insert(variants, value)
			end
		end
		id = variants[1] and variants[math.random(1, #variants)]
	end
	if id == nil or id == "" then
		warnOnce("sound:" .. soundId, "CreatureAnimator : son manquant " .. soundId .. " (13.7)")
		return nil
	end
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.Transparency = 1
	part.Size = Vector3.one
	part.Position = position
	part.Parent = workspace
	local sound = Instance.new("Sound")
	sound.SoundId = id
	sound.Parent = part
	sound:Play()
	Debris:AddItem(part, SOUND_LIFETIME)
	return sound
end

function CreatureAnimator:Init() end

function CreatureAnimator:Start() end

return CreatureAnimator
