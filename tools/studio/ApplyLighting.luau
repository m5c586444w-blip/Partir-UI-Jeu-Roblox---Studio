-- tools/studio/ApplyLighting (hors projets Rojo) — bascule l'éclairage de la Partie en Édition (12.1, 12.2)
-- Réglage de LA PLACE ENREGISTRÉE : jour neutre, sans effets (AmbienceConfig.EditorDay). La nuit n'est que temporaire,
-- pour les captures : MODE = "Night" pose le moment AmbienceConfig.CaptureNightMoment, les effets d'image et le brouillard
-- de forêt ; MODE = "Day" remet le jour et supprime les effets. En partie, AmbienceController pose toute l'ambiance.
-- Lighting.Technology n'est pas modifiable par un script de plugin : à régler à la main (Future, 12.1).
local MODE = "Night" -- "Night" ou "Day"

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

local function apply(clock, brightness, outdoorAmbient, ambient, exposure)
	Lighting.ClockTime = clock
	Lighting.Brightness = brightness
	Lighting.OutdoorAmbient = rgb(outdoorAmbient)
	Lighting.Ambient = rgb(ambient)
	Lighting.ExposureCompensation = exposure
end

if MODE == "Night" then
	local moment = AmbienceConfig.Moments[AmbienceConfig.CaptureNightMoment]
	apply(moment.clockFrom, moment.brightness, moment.outdoorAmbient, moment.ambient, moment.exposure)
	local correction = effect("ColorCorrectionEffect", "ColorCorrection")
	correction.Saturation = AmbienceConfig.ColorCorrection.Saturation
	correction.Contrast = AmbienceConfig.ColorCorrection.Contrast
	correction.TintColor = rgb(AmbienceConfig.ColorCorrection.TintColor)
	effect("BloomEffect", "Bloom").Intensity = AmbienceConfig.Bloom.Intensity
	local atmosphere = effect("Atmosphere", "Atmosphere")
	local forest = AmbienceConfig.Fog.Forest
	atmosphere.Density = forest.density
	atmosphere.Haze = forest.haze
	atmosphere.Color = rgb(forest.color)
else
	local day = AmbienceConfig.EditorDay
	apply(day.clock, day.brightness, day.outdoorAmbient, day.ambient, day.exposure)
	for _, name in { "ColorCorrection", "Bloom", "Atmosphere" } do
		local child = Lighting:FindFirstChild(name)
		if child then
			child:Destroy()
		end
	end
end
print("ApplyLighting : " .. MODE)
