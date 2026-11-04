-- ServerScriptService/Bootstrap (Partie)
-- Section 16.1 : charge les services dans l'ordre. Chaque service reçoit Init(services)
-- (références entre services, aucune attente), puis Start() une fois tous initialisés.
local ServerScriptService = game:GetService("ServerScriptService")

local servicesFolder = ServerScriptService:WaitForChild("Services")

-- ordre de chargement : DataService d'abord, les autres en dépendent
local ORDER = {
	"DataService",
	"ReturnService",
	"PartyLoaderService",
	"NoiseService",
	"InteractionService",
	"CharacterService",
	"SpawnService",
	"HealthService",
	"StaminaService",
	"FearService",
	"InventoryService",
	"ItemSpawnService",
	"WeaponService",
	"EvidenceService",
	"DocumentService",
	"TabletService",
	"CinematicService",
	"WeatherService",
	"ExtractionService",
	"GameStateService",
}

local services = {}
for _, name in ORDER do
	local module = servicesFolder:FindFirstChild(name)
	if module == nil then
		warn("Bootstrap : service manquant : Services/" .. name)
	else
		services[name] = require(module)
	end
end

for _, name in ORDER do
	local service = services[name]
	if service ~= nil and service.Init ~= nil then
		local ok, err = pcall(service.Init, service, services)
		if not ok then
			warn("Bootstrap : échec de " .. name .. ".Init : " .. tostring(err))
		end
	end
end

for _, name in ORDER do
	local service = services[name]
	if service ~= nil and service.Start ~= nil then
		local ok, err = pcall(service.Start, service)
		if not ok then
			warn("Bootstrap : échec de " .. name .. ".Start : " .. tostring(err))
		end
	end
end

-- 16.1 : modules de ServerScriptService/AI (IA de la créature), après les services
local AI_ORDER = {
	"NavGraph",
	"Perception",
	"CreatureAnimator",
	"MimicService",
	"TensionDirector",
	"EventDirector",
	"FamilyBrain",
	"CreatureDebug",
}
local aiFolder = ServerScriptService:WaitForChild("AI")
local aiModules = {}
for _, name in AI_ORDER do
	local module = aiFolder:FindFirstChild(name)
	if module == nil then
		warn("Bootstrap : module d'IA manquant : AI/" .. name)
	else
		aiModules[name] = require(module)
	end
end
for _, name in AI_ORDER do
	local module = aiModules[name]
	if module and module.Init then
		local ok, err = pcall(module.Init, module, services, aiModules)
		if not ok then
			warn("Bootstrap : échec de AI/" .. name .. ".Init : " .. tostring(err))
		end
	end
end
for _, name in AI_ORDER do
	local module = aiModules[name]
	if module and module.Start then
		local ok, err = pcall(module.Start, module)
		if not ok then
			warn("Bootstrap : échec de AI/" .. name .. ".Start : " .. tostring(err))
		end
	end
end

print("Bootstrap (Partie) : services démarrés")
