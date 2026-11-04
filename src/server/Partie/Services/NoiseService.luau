-- ServerScriptService/Services/NoiseService (Partie)
-- Section 16.2 : reçoit tous les bruits (sections 7 et 8) et les diffuse à la perception (9.4).
-- Un bruit = { position, radius, kind, source, time }.
-- DÉFAUT : la pluie (×0,6, 12.3 et 9.4) est appliquée une seule fois, par la perception (AI/Perception).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Signal = require(Shared:WaitForChild("Signal"))
local NoiseTypes = require(Shared:WaitForChild("NoiseTypes"))

local NoiseService = {}

-- (noise) : chaque bruit émis
NoiseService.Emitted = Signal.new()

local history = {} -- [Player] = { {time, radius} } (9.7 : bruit des 10 dernières secondes)

function NoiseService:Emit(position, radius, kind, source)
	if radius == nil or radius <= 0 then
		return
	end
	local noise = {
		position = position,
		radius = radius,
		kind = kind or NoiseTypes.Other,
		source = source,
		time = os.clock(),
	}
	if typeof(source) == "Instance" and source:IsA("Player") then
		local list = history[source]
		if list == nil then
			list = {}
			history[source] = list
		end
		table.insert(list, { time = noise.time, radius = noise.radius })
	end
	self.Emitted:Fire(noise)
	return noise
end

-- 9.7 : plus fort bruit fait par le joueur pendant les `window` dernières secondes
-- (interprétation de « bruit des 10 dernières secondes », voir SUIVI.md)
function NoiseService:RecentNoise(player, window)
	local list = history[player]
	if list == nil then
		return 0
	end
	local now = os.clock()
	local loudest = 0
	for index = #list, 1, -1 do
		local entry = list[index]
		if now - entry.time > window then
			table.remove(list, index)
		elseif entry.radius > loudest then
			loudest = entry.radius
		end
	end
	return loudest
end

function NoiseService:Init() end

function NoiseService:Start()
	game:GetService("Players").PlayerRemoving:Connect(function(player)
		history[player] = nil
	end)
end

return NoiseService
