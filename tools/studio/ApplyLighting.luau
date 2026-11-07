-- tools/studio/ApplyLighting (hors projets Rojo) — éclairage d'ÉDITION de la Partie (12.1, 12.2), recréable par script
-- MODE = "Day" : jour réaliste lisible pour travailler (AmbienceConfig.Editor) : ombres globales, environnement à 1,
-- ambiance très basse, Atmosphere « Forêt » (12.2), ColorCorrection (12.1), nuages couverts sous Terrain, ciel Poly Haven.
-- MODE = "Night" : nuit TEMPORAIRE pour les captures (moment AmbienceConfig.CaptureNightMoment) ; relancer en "Day" ensuite.
-- En partie, AmbienceController garde la main (moments, brouillard par zone, météo) et retire le ciel d'édition.
-- Lighting.Technology (Future, 12.1) n'est pas modifiable par un script de plugin (capacité RobloxScript) : à régler à la
-- main dans les propriétés de Lighting.
local MODE = "Day" -- "Day" ou "Night"

-- ciel : HDRI Poly Haven CC0 « overcast_soil_puresky » converti en 6 faces (tools/terrain/make_sky.py), envoi du 2026-11-07
local SKY = {
	SkyboxFt = 107356012648169,
	SkyboxBk = 82835751404125,
	SkyboxLf = 92814009618843,
	SkyboxRt = 85129441425842,
	SkyboxUp = 84688319824181,
	SkyboxDn = 113746013104240,
}

local Lighting = game:GetService("Lighting")
local AmbienceConfig = require(game:GetService("ReplicatedStorage").Config.AmbienceConfig)

local function rgb(t)
	return Color3.fromRGB(t[1], t[2], t[3])
end

local function effect(parent, className, name)
	local instance = parent:FindFirstChild(name)
	if instance and not instance:IsA(className) then
		instance:Destroy()
		instance = nil
	end
	instance = instance or Instance.new(className)
	instance.Name = name
	instance.Parent = parent
	return instance
end

pcall(function()
	Lighting.Technology = Enum.Technology.Future
end)

local editor = AmbienceConfig.Editor
local forest = AmbienceConfig.Fog.Forest
local atmosphere = effect(Lighting, "Atmosphere", "Atmosphere")
atmosphere.Density = forest.density
atmosphere.Haze = forest.haze
atmosphere.Color = rgb(forest.color)
local correction = effect(Lighting, "ColorCorrectionEffect", "ColorCorrection")
correction.Saturation = AmbienceConfig.ColorCorrection.Saturation
correction.Contrast = AmbienceConfig.ColorCorrection.Contrast
correction.TintColor = rgb(AmbienceConfig.ColorCorrection.TintColor)

if MODE == "Night" then
	local moment = AmbienceConfig.Moments[AmbienceConfig.CaptureNightMoment]
	Lighting.ClockTime = moment.clockFrom
	Lighting.Brightness = moment.brightness
	Lighting.OutdoorAmbient = rgb(moment.outdoorAmbient)
	Lighting.Ambient = rgb(moment.ambient)
	Lighting.ExposureCompensation = moment.exposure
	effect(Lighting, "BloomEffect", "Bloom").Intensity = AmbienceConfig.Bloom.Intensity
else
	Lighting.ClockTime = editor.clock
	Lighting.Brightness = editor.brightness
	Lighting.OutdoorAmbient = rgb(editor.outdoorAmbient)
	Lighting.Ambient = rgb(editor.ambient)
	Lighting.ExposureCompensation = editor.exposure
	local bloom = Lighting:FindFirstChild("Bloom")
	if bloom then
		bloom:Destroy()
	end
end
Lighting.GlobalShadows = editor.globalShadows
Lighting.EnvironmentDiffuseScale = editor.environmentDiffuseScale
Lighting.EnvironmentSpecularScale = editor.environmentSpecularScale

-- nuages couverts sous Terrain
local clouds = effect(workspace.Terrain, "Clouds", "Clouds")
clouds.Cover = editor.clouds.cover
clouds.Density = editor.clouds.density
clouds.Color = rgb(editor.clouds.color)

-- ciel réaliste à la place du ciel par défaut
local sky = effect(Lighting, "Sky", "Sky")
for face, id in SKY do
	sky[face] = "rbxassetid://" .. id
end
sky.CelestialBodiesShown = false
sky.StarCount = 0
print("ApplyLighting : " .. MODE)
