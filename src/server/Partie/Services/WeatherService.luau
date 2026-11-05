-- ServerScriptService/Services/WeatherService (Partie)
-- Sections 12.3 et 12.4 : météo tirée à chaque partie (sauf vote « fixe »), passage en pluie
-- (ou neige au-dessus de Y = 350) pendant l'acte 2, vent global et rafales.
-- État : MatchState.weather (Clear, Fog, Rain, Snow).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local AmbienceConfig = require(Config:WaitForChild("AmbienceConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local WeatherService = {}

local services = nil
local current = nil
local random = nil

local function draw()
	local roll = random:NextNumber()
	local sum = 0
	for _, id in AmbienceConfig.WeatherOrder do
		sum += AmbienceConfig.Weathers[id].probability
		if roll <= sum then
			return id
		end
	end
	return AmbienceConfig.WeatherOrder[#AmbienceConfig.WeatherOrder]
end

local function apply(id)
	current = id
	Util.getMatchState():SetAttribute("weather", id)
	local wind = AmbienceConfig.Wind[id]
	workspace.GlobalWind = Vector3.new(table.unpack(wind.base))
end

function WeatherService:Get()
	return current
end

function WeatherService:Entry()
	return AmbienceConfig.Weathers[current]
end

-- 12.3 : pendant l'acte 2, nuit claire ou brouillard → pluie ; neige au-dessus de 350 (la cabane)
function WeatherService:SiegeChange()
	local rule = AmbienceConfig.SiegeWeather
	if rule.from[current] then
		local cabin = require(Config:WaitForChild("MapConfig")).Places.P05c
		apply(if cabin.pos.Y > rule.snowAboveY then rule.toAbove else rule.to)
	end
end

-- 12.4 : rafales (ajoutées au vent de base dans sa direction)
local function gustLoop()
	while true do
		local wind = AmbienceConfig.Wind[current]
		if wind and wind.sine and (wind.gust or 0) > 0 then
			-- pluie : force du vent en sinus autour du vent de base (DÉFAUT, C21)
			local base = Vector3.new(table.unpack(wind.base))
			local phase = os.clock() / AmbienceConfig.WindSinePeriod * math.pi * 2
			workspace.GlobalWind = base + base.Unit * wind.gust * (0.5 + 0.5 * math.sin(phase))
			task.wait(AmbienceConfig.WindSineStep)
		elseif wind == nil or (wind.gust or 0) <= 0 or wind.gustIntervalMin == nil then
			task.wait(AmbienceConfig.Wind.Clear.gustIntervalMin)
		else
			task.wait(random:NextNumber(wind.gustIntervalMin, wind.gustIntervalMax))
			local base = Vector3.new(table.unpack(wind.base))
			workspace.GlobalWind = base + base.Unit * wind.gust
			task.wait(AmbienceConfig.GustDuration)
			workspace.GlobalWind = base
		end
	end
end

function WeatherService:Begin(info)
	random = Random.new(info.seed)
	local chosen = info.weather
	if chosen == nil or chosen == "Random" or AmbienceConfig.Weathers[chosen] == nil then
		chosen = draw()
	end
	apply(chosen)
	print("WeatherService : météo " .. chosen)
	task.spawn(gustLoop)
end

function WeatherService:Init(allServices)
	services = allServices
end

function WeatherService:Start()
	local _ = services
end

return WeatherService
