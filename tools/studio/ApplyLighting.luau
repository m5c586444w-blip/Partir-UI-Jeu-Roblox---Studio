-- tools/studio/ApplyLighting (hors projets Rojo) — pose l'éclairage de base de la Partie en Édition (12.1, 12.2)
-- Lit ReplicatedStorage/Config/AmbienceConfig : moment « Arrivée », effets d'image et brouillard de forêt.
-- À lancer dans la Partie (contexte Édition). En partie, c'est AmbienceController qui règle ensuite la lumière,
-- le brouillard par zone et la météo ; ce script ne sert qu'à avoir le bon rendu dans Studio.

local Lighting = game:GetService("Lighting")
local AmbienceConfig = require(game:GetService("ReplicatedStorage").Config.AmbienceConfig)

local function rgb(t)
	return Color3.fromRGB(t[1], t[2], t[3])
end

local function effect(className, name)
	local instance = Lighting:FindFirstChild(name)
	if instance and not instance:IsA(className) then
		instance:Destroy()
		instance = nil
	end
	instance = instance or Instance.new(className)
	instance.Name = name
	instance.Parent = Lighting
	return instance
end

-- 12.1 : technologie et moment de départ (Arrivée)
-- Lighting.Technology n'est pas modifiable par un script de plugin (capacité RobloxScript) : la régler à la main dans
-- les propriétés de Lighting, ou laisser Rojo la poser ($properties de Partie.serve.project.json)
pcall(function()
	Lighting.Technology = Enum.Technology[AmbienceConfig.Technology]
end)
local moment = AmbienceConfig.Moments[1]
Lighting.ClockTime = (moment.clockFrom + moment.clockTo) / 2
Lighting.Brightness = moment.brightness
Lighting.OutdoorAmbient = rgb(moment.outdoorAmbient)
Lighting.Ambient = rgb(moment.ambient)
Lighting.ExposureCompensation = moment.exposure

-- 12.1 : effets d'image
local correction = effect("ColorCorrectionEffect", "ColorCorrection")
correction.Saturation = AmbienceConfig.ColorCorrection.Saturation
correction.Contrast = AmbienceConfig.ColorCorrection.Contrast
correction.TintColor = rgb(AmbienceConfig.ColorCorrection.TintColor)
effect("BloomEffect", "Bloom").Intensity = AmbienceConfig.Bloom.Intensity

-- 12.2 : brouillard de forêt par défaut (les zones changent ses valeurs en partie)
local atmosphere = effect("Atmosphere", "Atmosphere")
local forest = AmbienceConfig.Fog.Forest
atmosphere.Density = forest.density
atmosphere.Haze = forest.haze
atmosphere.Color = rgb(forest.color)
print("ApplyLighting : éclairage de base appliqué")
