-- ReplicatedStorage/Shared/RateLimiter
-- Limite d'appels des remotes client → serveur (section 16.3).
-- Fenêtre fixe : au plus `calls` appels par joueur toutes les `per` secondes, par remote.
-- Les limites viennent de Config/LaunchConfig.RateLimits.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LaunchConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("LaunchConfig"))

local RateLimiter = {}
RateLimiter.__index = RateLimiter

local allLimiters = {}

function RateLimiter.new(calls, per)
	local limiter = setmetatable({ _calls = calls, _per = per, _windows = {} }, RateLimiter)
	table.insert(allLimiters, limiter)
	return limiter
end

-- limiteur réglé pour une remote donnée (valeur propre ou valeur par défaut de 16.3)
function RateLimiter.forRemote(remoteName)
	local limits = LaunchConfig.RateLimits[remoteName] or LaunchConfig.RateLimits.Default
	return RateLimiter.new(limits.calls, limits.per)
end

-- vrai si l'appel est autorisé pour cette clé (en général le joueur)
function RateLimiter:Allow(key)
	local now = os.clock()
	local window = self._windows[key]
	if window == nil or now - window.start >= self._per then
		window = { start = now, count = 0 }
		self._windows[key] = window
	end
	if window.count >= self._calls then
		return false
	end
	window.count += 1
	return true
end

function RateLimiter:Forget(key)
	self._windows[key] = nil
end

-- côté serveur : branche un handler sur une remote, derrière sa limite d'appels.
-- Les appels en trop sont ignorés sans réponse.
function RateLimiter.connect(remote, handler)
	local limiter = RateLimiter.forRemote(remote.Name)
	return remote.OnServerEvent:Connect(function(player, ...)
		if limiter:Allow(player) then
			handler(player, ...)
		end
	end)
end

-- un joueur qui part libère ses fenêtres dans tous les limiteurs
Players.PlayerRemoving:Connect(function(player)
	for _, limiter in allLimiters do
		limiter:Forget(player)
	end
end)

return RateLimiter
