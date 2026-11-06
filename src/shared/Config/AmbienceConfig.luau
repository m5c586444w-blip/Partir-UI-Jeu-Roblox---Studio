-- ReplicatedStorage/Config/AmbienceConfig
-- Valeurs de la bible, sections 12.1 à 12.4. Ne rien ajouter ici sans la bible.
-- Réglage à l'œil prévu en phase B2 (J4) : ces valeurs sont les réglages de départ.
local AmbienceConfig = {}

AmbienceConfig.Technology = "Future" -- 12.1 : Lighting.Technology

-- 12.1 : lumière par moment. clock = ClockTime (début → fin) ; couleurs en RGB 0–255
AmbienceConfig.Moments = {
	{
		name = "Arrivée",
		clockFrom = 18.5,
		clockTo = 19,
		brightness = 1.2,
		outdoorAmbient = { 60, 65, 80 },
		ambient = { 40, 45, 55 },
		exposure = 0,
	},
	{
		name = "Fin d'enquête",
		clockFrom = 21,
		clockTo = 21,
		brightness = 0.15,
		outdoorAmbient = { 20, 24, 32 },
		ambient = { 12, 14, 18 },
		exposure = 0,
	},
	{
		name = "Siège",
		clockFrom = 22,
		clockTo = 24,
		brightness = 0.05,
		outdoorAmbient = { 12, 14, 20 },
		ambient = { 8, 9, 12 },
		exposure = -0.1,
	},
	{
		name = "Nuit noire",
		clockFrom = 0,
		clockTo = 4,
		brightness = 0,
		outdoorAmbient = { 8, 9, 14 },
		ambient = { 5, 6, 9 },
		exposure = -0.3,
	},
	{
		name = "Aube",
		clockFrom = 5,
		clockTo = 6,
		brightness = 0.6,
		outdoorAmbient = { 45, 55, 75 },
		ambient = { 25, 30, 40 },
		exposure = 0,
	},
}

-- 12.1 : effets
AmbienceConfig.ColorCorrection = { Saturation = -0.25, Contrast = 0.1, TintColor = { 220, 230, 255 } }
AmbienceConfig.Bloom = { Intensity = 0.3 }
AmbienceConfig.DepthOfField = { FarIntensity = 0.15, presetOnly = "High" } -- réglage Élevé seulement
-- 12.1 : lune par nuit claire : les nuages s'ouvrent 20 s toutes les 3 à 5 min
AmbienceConfig.Moon = { OpenDuration = 20, IntervalMin = 180, IntervalMax = 300, SilhouetteRange = 80 }
-- 12.1 : lampes : SpotLight avec ombres, angle 45° ; clignotement aléatoire sous 15 % de pile
AmbienceConfig.Lamp = { Angle = 45, Shadows = true, FlickerBelow = 0.15, EngineMaxRange = 60 } -- 60 : limite Roblox de Light.Range

-- 12.2 : brouillard par zone (Atmosphere). Couleurs RGB 0–255.
AmbienceConfig.Fog = {
	Forest = { density = 0.35, haze = 1.5, color = { 190, 200, 215 } },
	Gorges = { places = { "P03", "P05" }, density = 0.45, haze = 2.0, color = { 180, 190, 205 } },
	ForbiddenZone = { places = { "P08" }, density = 0.20, haze = 0.5, color = { 170, 170, 175 }, ashParticles = true },
	Plateau = { places = { "P06" }, density = 0.25, haze = 1.0, color = { 200, 205, 215 } },
	Tunnels = { places = { "P07a", "P07b", "P07c" }, atmosphereDisabled = true }, -- noir total
}

-- 12.3 : météo (tirée à chaque partie, sauf vote « fixe »). probability en fraction.
AmbienceConfig.Weathers = {
	Clear = { name = "Nuit claire", probability = 0.30, moon = true, creatureSight = 1, noiseFactor = 1 },
	Fog = {
		name = "Brouillard",
		probability = 0.30,
		fogDensityFactor = 1.7,
		creatureSight = 0.5,
		playerSight = 0.5,
		noiseFactor = 1,
	},
	Rain = { name = "Pluie", probability = 0.25, creatureSight = 0.7, noiseFactor = 0.6, wetGround = true },
	Snow = {
		name = "Première neige",
		probability = 0.15,
		snowAboveY = 350,
		footprintDuration = 300,
		staminaFactor = 0.85,
		creatureSight = 1,
		noiseFactor = 1,
	},
}
AmbienceConfig.WeatherOrder = { "Clear", "Fog", "Rain", "Snow" }
-- 12.3 : pendant l'acte 2, une nuit claire ou un brouillard passe en pluie (ou en neige au-dessus de Y = 350)
AmbienceConfig.SiegeWeather = { from = { Clear = true, Fog = true }, to = "Rain", snowAboveY = 350, toAbove = "Snow" }

-- 12.4 : vent (workspace.GlobalWind) et rafales
AmbienceConfig.Wind = {
	Clear = { base = { 6, 0, -3 }, gust = 10, gustIntervalMin = 8, gustIntervalMax = 15 },
	Fog = { base = { 2, 0, -1 }, gust = 0 },
	Rain = { base = { 14, 0, -6 }, gust = 20, sine = true }, -- cycle en sinus comme l'exemple de la doc
	-- DÉFAUT (C21) : rafales de neige au même intervalle que par temps clair
	Snow = { base = { 10, 0, -8 }, gust = 12, gustIntervalMin = 8, gustIntervalMax = 15 },
}
-- DÉFAUT (C21, C27) : les rafales gardent la direction du vent (l'odorat de la créature, 9.4, ne lit que
-- la direction) ; ce sont donc des valeurs d'ambiance, ni texte ni gameplay ni asset (section 0).
AmbienceConfig.WindSinePeriod = 12 -- période du cycle en sinus de la pluie (s)
AmbienceConfig.WindSineStep = 0.5 -- pas de mise à jour du vent en sinus (s)
AmbienceConfig.GustDuration = 1 -- durée d'une rafale (s)
AmbienceConfig.TreeWindRange = 120 -- 12.4 : arbres animés par leurs os à moins de 120 studs (réglage Élevé)

-- 12.5 : réverbération par zone (SoundService.AmbientReverb)
AmbienceConfig.Reverb = {
	Forest = "Forest",
	Gorges = "Mountains",
	Tunnels = "Cave",
	Buildings = "Room",
	Plateau = "Plain",
	ForbiddenZone = "Plain",
}

-- DÉFAUT (Gabriel, 2026-11-07) : la place enregistrée reste en plein jour neutre pour l'édition ; l'ambiance de 12 est posée
-- au lancement par AmbienceController. editorDay = réglage d'édition ; captureNight = index du moment de 12.1 utilisé par
-- tools/studio/ApplyLighting.luau pour les captures de nuit (Fin d'enquête).
AmbienceConfig.EditorDay = {
	clock = 14,
	brightness = 3,
	outdoorAmbient = { 127, 127, 127 },
	ambient = { 70, 70, 70 },
	exposure = 0,
}
AmbienceConfig.CaptureNightMoment = 2

return AmbienceConfig
