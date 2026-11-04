-- Controllers/AmbienceController (les deux places)
-- Sections 12.1, 12.2 et 12.5 : interpole la lumière selon l'heure en jeu (MatchState.clock),
-- le brouillard selon la zone (Atmosphere), la réverbération par zone. Réglage à l'œil en phase B2.
-- Dans le lobby (pas d'horloge), rien n'est changé : la lumière du lobby est réglée dans Studio.
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local Config = ReplicatedStorage:WaitForChild("Config")
local AmbienceConfig = require(Config:WaitForChild("AmbienceConfig"))
local MapConfig = require(Config:WaitForChild("MapConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local AmbienceController = {}

local player = Players.LocalPlayer
local HOURS = 24 -- constante (heures dans une journée)
local START = AmbienceConfig.Moments[1].clockFrom -- l'horloge commence à 18 h 30

local function rgb(t)
	return Color3.fromRGB(table.unpack(t))
end

-- heure → position sur la nuit (0 à 18 h 30, croissante jusqu'à 6 h 00)
local function nightTime(clock)
	return (clock - START) % HOURS
end

-- images clés de 12.1 : début et fin de chaque moment
local keys = {}
for _, moment in AmbienceConfig.Moments do
	table.insert(keys, { t = nightTime(moment.clockFrom), m = moment })
	if moment.clockTo ~= moment.clockFrom then
		table.insert(keys, { t = nightTime(moment.clockTo % HOURS), m = moment })
	end
end
table.sort(keys, function(a, b)
	return a.t < b.t
end)

local function lerp(a, b, t)
	return a + (b - a) * t
end

local function sample(clock)
	local t = nightTime(clock)
	local before, after = keys[1], keys[#keys]
	for i = 1, #keys - 1 do
		if t >= keys[i].t and t <= keys[i + 1].t then
			before, after = keys[i], keys[i + 1]
			break
		end
	end
	local span = after.t - before.t
	local f = if span > 0 then math.clamp((t - before.t) / span, 0, 1) else 0
	local a, b = before.m, after.m
	return {
		brightness = lerp(a.brightness, b.brightness, f),
		outdoor = rgb(a.outdoorAmbient):Lerp(rgb(b.outdoorAmbient), f),
		ambient = rgb(a.ambient):Lerp(rgb(b.ambient), f),
		exposure = lerp(a.exposure, b.exposure, f),
	}
end

local function zoneOf(position)
	for zoneName, zone in AmbienceConfig.Fog do
		for _, code in zone.places or {} do
			local place = MapConfig.Places[code]
			if place and place.pos and place.radius then
				if
					(Vector2.new(position.X, position.Z) - Vector2.new(place.pos.X, place.pos.Z)).Magnitude
					<= place.radius
				then
					return zoneName
				end
			elseif place and place.zone then
				local z = place.zone
				if position.X >= z.minX and position.X <= z.maxX and position.Z >= z.minZ and position.Z <= z.maxZ then
					return zoneName
				end
			end
		end
	end
	return "Forest"
end

-- 17.2 : décalage de luminosité réglé par le joueur (SettingsController)
AmbienceController.Gamma = 0

function AmbienceController:Start()
	local state = ReplicatedStorage:FindFirstChild("MatchState")
		or ReplicatedStorage:WaitForChild("MatchState", Util.GUI_WAIT_TIMEOUT)
	if state == nil then
		return -- lobby
	end
	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
	atmosphere.Parent = Lighting
	local color = Lighting:FindFirstChild("AmbienceColor") or Instance.new("ColorCorrectionEffect")
	color.Name = "AmbienceColor"
	color.Saturation = AmbienceConfig.ColorCorrection.Saturation
	color.Contrast = AmbienceConfig.ColorCorrection.Contrast
	color.TintColor = rgb(AmbienceConfig.ColorCorrection.TintColor)
	color.Parent = Lighting
	local bloom = Lighting:FindFirstChildOfClass("BloomEffect") or Instance.new("BloomEffect")
	bloom.Intensity = AmbienceConfig.Bloom.Intensity
	bloom.Parent = Lighting

	RunService.RenderStepped:Connect(function()
		local clock = state:GetAttribute("clock")
		if clock == nil then
			return
		end
		Lighting.ClockTime = clock
		local s = sample(clock)
		Lighting.Brightness = s.brightness
		Lighting.OutdoorAmbient = s.outdoor
		Lighting.Ambient = s.ambient
		Lighting.ExposureCompensation = s.exposure + AmbienceController.Gamma

		local root = Util.characterRoot(player)
		if root == nil then
			return
		end
		local zoneName = zoneOf(root.Position)
		local zone = AmbienceConfig.Fog[zoneName]
		if zone.atmosphereDisabled then
			atmosphere.Density = 0
			atmosphere.Haze = 0
		else
			local weather = AmbienceConfig.Weathers[state:GetAttribute("weather") or "Clear"]
			atmosphere.Density = zone.density * ((weather and weather.fogDensityFactor) or 1)
			atmosphere.Haze = zone.haze
			atmosphere.Color = rgb(zone.color)
		end
		local reverb = AmbienceConfig.Reverb[zoneName] or AmbienceConfig.Reverb.Forest
		local ok, enum = pcall(function()
			return Enum.ReverbType[reverb]
		end)
		if ok and enum then
			SoundService.AmbientReverb = enum
		end
	end)
end

return AmbienceController
