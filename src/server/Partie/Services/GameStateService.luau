-- ServerScriptService/Services/GameStateService (Partie)
-- Sections 5 et 16.2 : actes, horloge, siège (acte 2), voie d'extraction, fins, fin à 06 h 00.
-- État publié dans MatchState : act, clock (heure décimale), objective, objectives (JSON),
-- siegeActive, finalAssault, creatureRetreat, mainRoute, routes, gameOver.
-- Interprétation (DÉFAUT, voir SUIVI.md) : un acte ne s'achève pas avant sa durée minimale, même
-- si sa condition est remplie ; il s'achève à sa durée maximale sinon.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local ActConfig = require(Config:WaitForChild("ActConfig"))
local CinematicConfig = require(Config:WaitForChild("CinematicConfig"))
local ItemConfig = require(Config:WaitForChild("ItemConfig"))
local MapConfig = require(Config:WaitForChild("MapConfig"))
local PlayerConfig = require(Config:WaitForChild("PlayerConfig"))
local ProgressionConfig = require(Config:WaitForChild("ProgressionConfig"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local NoiseTypes = require(Shared:WaitForChild("NoiseTypes"))
local Signal = require(Shared:WaitForChild("Signal"))
local Util = require(Shared:WaitForChild("Util"))

local GameStateService = {}

local HOURS = 24 -- constante (heures dans une journée)

GameStateService.ActChanged = Signal.new() -- (act)
GameStateService.SiegeStarted = Signal.new()
GameStateService.SiegeEnded = Signal.new()
GameStateService.BarricadeBroken = Signal.new() -- (openingPart) : tentative d'entrée (ATK_ReachThrough)
GameStateService.GameEnded = Signal.new() -- (results)

local services = nil
local state = nil
local info = nil
local act = 0
local actStartedAt = 0
local transition = nil -- { from, to, startedAt }
local cluesFound = {}
local campEntered = false
local cabinEnteredAt = nil
local alphaKilled = false
local extracted = {} -- [Player] = routeId
local extractionDone = false
local openings = {} -- [name] = part

-- 19.5 (C19) : objectifs séquentiels. Chaque étape : { text, done = fn, count = fn }.
-- MatchState.objective = étape en cours (+ ligne facultative) ; objectives = liste de la tablette.
local objectiveSteps = nil
local objectiveExtra = nil -- fonction qui rend un texte facultatif ou nil (E4)
local objectiveHistory = {} -- textes des étapes terminées
local currentStep = nil

local function stepText(step)
	if step.count then
		return Util.formatMessage(step.text, { n = step.count() })
	end
	return step.text
end

local function setObjective(text, extra)
	local shown = text or ""
	if extra then
		shown ..= "\n" .. extra -- DÉFAUT : la ligne facultative sous l'objectif en cours
	end
	if state:GetAttribute("objective") == shown then
		return
	end
	state:SetAttribute("objective", shown)
	local list = table.clone(objectiveHistory)
	if text and text ~= "" then
		table.insert(list, text)
	end
	if extra then
		table.insert(list, extra)
	end
	state:SetAttribute("objectives", Util.encode(list))
	local remote = Util.getRemote("RE_Objective")
	if remote then
		remote:FireAllClients(act, shown)
	end
end

local function updateObjectives()
	if objectiveSteps == nil then
		return
	end
	local current = objectiveSteps[#objectiveSteps]
	for _, step in objectiveSteps do
		if not (step.done and step.done()) then
			current = step
			break
		end
	end
	if currentStep and currentStep ~= current then
		table.insert(objectiveHistory, stepText(currentStep))
	end
	currentStep = current
	setObjective(stepText(current), objectiveExtra and objectiveExtra())
end

-- texts : liste de textes de la bible ; rules : { [i] = { done = fn, count = fn } }
local function setObjectives(texts, rules, extra)
	if currentStep then
		table.insert(objectiveHistory, stepText(currentStep))
		currentStep = nil
	end
	objectiveSteps = {}
	for i, text in texts do
		local rule = rules and rules[i] or {}
		table.insert(objectiveSteps, { text = text, done = rule.done, count = rule.count })
	end
	objectiveExtra = extra
	updateObjectives()
end

-- un joueur du groupe porte cet objet
local function groupHas(itemId)
	for _, player in Players:GetPlayers() do
		if services.HealthService:IsAlive(player) and services.InventoryService:Has(player, itemId) then
			return true
		end
	end
	return false
end

local function elapsedInAct()
	return os.clock() - actStartedAt
end

-- 5.1 : dans un acte, l'heure avance linéairement de l'heure de début à l'heure de fin sur la
-- durée maximale ; au changement d'acte, elle saute à l'heure de début suivante en 10 s
local function updateClock()
	local def = ActConfig.Acts[act]
	local clock
	if transition then
		local t = math.clamp((os.clock() - transition.startedAt) / ActConfig.ActTransition, 0, 1)
		local to = transition.to
		if to < transition.from then
			to += HOURS
		end
		clock = (transition.from + (to - transition.from) * t) % HOURS
		if t >= 1 then
			transition = nil
		end
	else
		local t = math.clamp(elapsedInAct() / def.maxDuration, 0, 1)
		clock = (def.start + (def.finish - def.start) * t) % HOURS
		if def.finish == HOURS and t >= 1 then
			clock = 0
		end
	end
	state:SetAttribute("clock", clock)
	return clock
end

local function setAct(newAct)
	local previous = state:GetAttribute("clock") or ActConfig.Acts[newAct].start
	act = newAct
	actStartedAt = os.clock()
	if newAct > 0 then
		transition = { from = previous, to = ActConfig.Acts[newAct].start, startedAt = os.clock() }
	end
	state:SetAttribute("act", newAct)
	GameStateService.ActChanged:Fire(newAct)
	print(("GameStateService : acte %d (%s)"):format(newAct, ActConfig.Acts[newAct].name))
end

local function maxReached()
	return elapsedInAct() >= ActConfig.Acts[act].maxDuration
end

local function minReached()
	return elapsedInAct() >= ActConfig.Acts[act].minDuration
end

local function step()
	task.wait(PlayerConfig.Technical.Tick)
	updateClock()
	updateObjectives()
end

local function alivePlayers()
	local list = {}
	for _, player in Players:GetPlayers() do
		if services.HealthService:IsAlive(player) and extracted[player] == nil then
			table.insert(list, player)
		end
	end
	return list
end

local function anyInside(place)
	for _, player in alivePlayers() do
		local root = Util.characterRoot(player)
		if root and (root.Position - place.pos).Magnitude <= place.radius then
			return true
		end
	end
	return false
end

-- 5.2 : barricades de la cabane (porte, fenêtre, trou du toit). Part nommées Door, Window, RoofHole
-- dans Workspace/Places/P05c si posées à la main ; sinon ancres invisibles autour de P05c (DÉFAUT).
local function setupBarricades()
	local cabin = MapConfig.Places.P05c
	local places = workspace:FindFirstChild("Places")
	local folder = places and places:FindFirstChild("P05c")
	for index, name in ActConfig.Siege.Openings do
		local part = folder and folder:FindFirstChild(name)
		if part == nil or not part:IsA("BasePart") then
			part = Instance.new("Part")
			part.Name = name
			part.Anchored = true
			part.CanCollide = false
			part.Transparency = 1
			part.Size = ItemConfig.PlaceholderSize
			local angle = (index - 1) * (2 * math.pi / #ActConfig.Siege.Openings)
			local r = cabin.radius / 2
			part.Position = cabin.pos + Vector3.new(math.cos(angle) * r, 0, math.sin(angle) * r)
			part.Parent = workspace
		end
		part:SetAttribute("planks", 0)
		part:SetAttribute("impacts", 0)
		part:AddTag("Barricade")
		openings[name] = part
		services.InteractionService:CreatePrompt(part, {
			action = require(Config:WaitForChild("LoreConfig")).Prompts.Barricade,
			holdDuration = ActConfig.Siege.PlankTime,
			roleHoldDuration = ActConfig.Siege.RolePlankTime,
			canUse = function(player)
				return part:GetAttribute("planks") == 0 and services.InventoryService:Has(player, "ITM_Plank")
			end,
			onTriggered = function(player)
				if services.InventoryService:Remove(player, "ITM_Plank", 1) then
					part:SetAttribute("planks", 1)
					part:SetAttribute("impacts", 0)
					services.NoiseService:Emit(
						part.Position,
						ItemConfig.Items.ITM_Plank.nailNoise,
						NoiseTypes.Repair,
						player
					)
				end
			end,
		})
	end
end

-- 5.2 : une planche reçoit 4 impacts avant de céder ; appelé par l'IA (pierres du siège)
function GameStateService:HitBarricade(part)
	if part:GetAttribute("planks") ~= 1 then
		return
	end
	local impacts = (part:GetAttribute("impacts") or 0) + 1
	part:SetAttribute("impacts", impacts)
	if impacts >= ActConfig.Siege.PlankImpacts then
		part:SetAttribute("planks", 0)
		self.BarricadeBroken:Fire(part)
	end
end

function GameStateService:GetOpenings()
	return openings
end

function GameStateService:GetAct()
	return act
end

-- 9.12 et 5.3 : appelé par l'IA quand l'Alpha meurt
function GameStateService:OnAlphaKilled()
	alphaKilled = true
	state:SetAttribute("alphaKilled", true)
end

local function cluesCount()
	local found = 0
	for _ in cluesFound do
		found += 1
	end
	return found
end

local function runAct1()
	setAct(1)
	local tabletRead = function()
		return services.DocumentService:HasRead("DOC_07")
	end
	-- DÉFAUT : « Fouiller le camp » est fait quand le camp est atteint et qu'un indice ou la tablette
	-- y a été trouvé
	setObjectives(ActConfig.Objectives[1], {
		{
			done = function()
				return campEntered and (cluesCount() > 0 or tabletRead())
			end,
		},
		{ done = tabletRead },
		{
			done = function()
				return cluesCount() >= ActConfig.Act1.CluesNeeded
			end,
			count = function()
				return math.min(cluesCount(), ActConfig.Act1.CluesNeeded)
			end,
		},
	})
	while true do
		if not campEntered and anyInside(MapConfig.Places[ActConfig.Act1.CampPlace]) then
			campEntered = true
			services.CinematicService:Play("CS_04") -- 1re entrée dans P09
		end
		local found = cluesCount()
		-- 5.2 : la tablette indique le point de repli ; l'objectif de la cabane vient une fois l'acte fini
		if
			extractionDone
			or (tabletRead() and found >= ActConfig.Act1.CluesNeeded and minReached())
			or maxReached()
		then
			break
		end
		step()
	end
end

local function barricaded()
	local n = 0
	for _, part in openings do
		if (part:GetAttribute("planks") or 0) > 0 then
			n += 1
		end
	end
	return n
end

local function runAct2()
	setAct(2)
	services.WeatherService:SiegeChange() -- 5.2 : la météo se dégrade
	local siege = ActConfig.Siege
	local cabin = MapConfig.Places[siege.CabinPlace]
	setObjectives(ActConfig.Objectives[2], {
		{
			done = function()
				return cabinEnteredAt ~= nil or state:GetAttribute("siegeActive") == true
			end,
		},
		{
			-- DÉFAUT : l'étape passe à « Tenir » quand les 3 ouvertures sont barricadées ou que le siège commence
			done = function()
				return barricaded() >= #siege.Openings or state:GetAttribute("siegeActive") == true
			end,
			count = barricaded,
		},
		{},
	})
	-- le siège commence 60 s après l'entrée du premier joueur, ou à 23 h 05 si personne n'y est
	while true do
		if cabinEnteredAt == nil and anyInside(cabin) then
			cabinEnteredAt = os.clock()
		end
		local clock = updateClock()
		if extractionDone or (cabinEnteredAt and os.clock() - cabinEnteredAt >= siege.StartDelayAfterEntry) then
			break
		end
		if transition == nil and clock >= siege.StartHourIfNobody and clock < ActConfig.Acts[2].finish then
			break
		end
		step()
	end
	state:SetAttribute("siegeActive", true)
	state:SetAttribute("siegeStartedAt", workspace:GetServerTimeNow())
	GameStateService.SiegeStarted:Fire()
	services.CinematicService:Play("CS_06")
	local started = os.clock()
	while os.clock() - started < siege.Duration and not extractionDone do
		step()
	end
	state:SetAttribute("siegeActive", false)
	state:SetAttribute("silence", true)
	local quiet = os.clock()
	while os.clock() - quiet < siege.SilenceAfter and not extractionDone do
		step()
	end
	state:SetAttribute("silence", false)
	GameStateService.SiegeEnded:Fire()
	-- 5.2 : page 2 du carnet ; voie d'extraction tirée et annoncée (CS_07)
	services.DocumentService:UnlockNotebookPage(siege.NotebookPageUnlocked)
	for _, player in Players:GetPlayers() do
		local data = services.DataService:GetData(player)
		if data then
			data.notebookPages[siege.NotebookPageUnlocked] = true
		end
	end
	local route = services.ExtractionService:DrawMainRoute(info.seed)
	services.CinematicService:PlayAndWait("CS_07", nil, { text = ActConfig.RouteAnnounce[route] })
end

-- 19.5 (C19) : ligne facultative de E4 si DOC_07 a été lu
local function secretLine(actNumber)
	return function()
		local secret = ActConfig.SecretRoute
		if services.DocumentService:HasRead(secret.requiresDocument) then
			return ActConfig.Objectives[actNumber][secret.id][1]
		end
		return nil
	end
end

-- règles d'avancement des objectifs de l'acte 3 (DÉFAUT : objet porté par un joueur du groupe)
local function act3Rules(route)
	local prepared = function()
		return services.ExtractionService:IsPrepared(route)
	end
	local has = function(itemId)
		return function()
			return prepared() or groupHas(itemId)
		end
	end
	if route == "E1" then
		return { { done = has("ITM_Keys") }, { done = has("ITM_Jack") }, { done = prepared } }
	elseif route == "E2" then
		local p11 = MapConfig.Places.P11
		return {
			{ done = has("ITM_CoaxCable") },
			{
				-- la batterie est à la tour : un joueur qui la porte est dans P11
				done = function()
					if prepared() then
						return true
					end
					for _, player in Players:GetPlayers() do
						local root = Util.characterRoot(player)
						if
							root
							and services.InventoryService:Has(player, "ITM_CarBattery")
							and (root.Position - p11.pos).Magnitude <= p11.radius
						then
							return true
						end
					end
					return false
				end,
			},
			{ done = prepared },
		}
	end
	return { { done = has("ITM_Jerrycan") }, { done = has("ITM_StarterRelay") }, { done = prepared } }
end

local function runAct3()
	setAct(3) -- constante (numéro d'acte, 5.1)
	services.CinematicService:Play("CS_08")
	services.ExtractionService:Activate()
	local mainRoute = services.ExtractionService:GetMainRoute()
	setObjectives(ActConfig.Objectives[3][mainRoute], act3Rules(mainRoute), secretLine(3)) -- constante (acte 3)
	while true do
		local route = services.ExtractionService:GetMainRoute()
		if extractionDone or (services.ExtractionService:IsPrepared(route) and minReached()) or maxReached() then
			break
		end
		step()
	end
end

local ACT_DAWN = 4 -- constante (numéro de l'acte 4, 5.1)

local function runAct4()
	setAct(4) -- constante (numéro d'acte, 5.1)
	services.CinematicService:Play("CS_09")
	local mainRoute = services.ExtractionService:GetMainRoute()
	local hold = ActConfig.Routes.E2.holdTime
	setObjectives(ActConfig.Objectives[ACT_DAWN][mainRoute], {
		{
			-- E2 : secondes restantes avant l'hélicoptère (durée entière avant l'appel)
			count = function()
				local at = state:GetAttribute("helicopterAt")
				return if at then math.max(0, math.ceil(at - workspace:GetServerTimeNow())) else hold
			end,
		},
	}, secretLine(ACT_DAWN))
	-- 5.2 : à 05 h 00, dernier assaut
	state:SetAttribute("finalAssault", true)
	services.ExtractionService:OpenTriggers()
	while not extractionDone do
		local clock = updateClock()
		if clock >= ActConfig.Dawn.CreatureRetreatHour then
			state:SetAttribute("creatureRetreat", true) -- aucune attaque après 05 h 50, sauf dans les tunnels
		end
		if maxReached() or clock >= ActConfig.EndHour then
			break
		end
		step()
	end
end

-- 5.3 : fins et récompenses
local function computeResults()
	local endings = {}
	local survivors, truthSurvivors = 0, 0
	local classA = false
	for player, route in extracted do
		if route == "E4" then
			truthSurvivors += 1
		else
			survivors += 1
		end
		if services.EvidenceService:CarriesClassA(player) then
			classA = true
		end
	end
	if survivors > 0 then
		endings.Survie = true
		if classA then
			endings.Preuve = true
		end
	end
	if truthSurvivors > 0 then
		endings.Verite = true
		if classA then
			endings.Preuve = true
		end
	end
	if alphaKilled then
		endings.Ordonnance = true
		endings.Survie = nil -- Ordonnance 69-01 remplace Survie
	end
	if survivors + truthSurvivors == 0 then
		endings.Silence = true
	end

	local players = {}
	local evidence = {}
	local xpByUser = {}
	for _, player in Players:GetPlayers() do
		local status = if extracted[player]
			then "Extracted"
			elseif player:GetAttribute("isDead") then "Dead"
			else "Missing"
		table.insert(players, { name = player.DisplayName, status = status })
		local data = services.DataService:GetData(player)
		local xp = ProgressionConfig.XPGains.GamePlayed
		if extracted[player] then
			local carried, evidenceXp = services.EvidenceService:CommitForSurvivor(player)
			xp += ProgressionConfig.XPGains.Survival + evidenceXp
			for _, e in carried do
				table.insert(evidence, { class = e.class, kind = e.kind, holder = player.DisplayName })
			end
		end
		if data then
			data.plays += 1
			-- l'XP des preuves a déjà été ajoutée par EvidenceService:CommitForSurvivor
			data.xp += ProgressionConfig.XPGains.GamePlayed + (if extracted[player]
				then ProgressionConfig.XPGains.Survival
				else 0)
			if extracted[player] then
				data.survivals += 1
				data.nightmareUnlocked = true -- 5.4 : Cauchemar après une première survie
			end
			for ending in endings do
				data.endings[ending] = true
			end
			if endings.Verite then
				data.notebookPages[ActConfig.Endings.Verite.notebookPage] = true -- 5.3 : page 3 du carnet
			end
			services.DataService:Save(player)
		end
		xpByUser[tostring(player.UserId)] = xp
	end
	return { endings = endings, players = players, evidence = evidence, xp = xpByUser }
end

local function endingCinematics(results)
	local order = {}
	if results.endings.Ordonnance then
		table.insert(order, ActConfig.Endings.Ordonnance.cinematic)
	end
	if results.endings.Survie then
		for _, route in extracted do
			if route ~= "E4" then
				table.insert(order, ActConfig.Endings.Survie.cinematics[route])
				break
			end
		end
	end
	if results.endings.Verite then
		table.insert(order, ActConfig.Endings.Verite.cinematic)
	end
	if results.endings.Preuve then
		table.insert(order, ActConfig.Endings.Preuve.cinematic)
	end
	if results.endings.Silence then
		table.insert(order, ActConfig.Endings.Silence.cinematic)
	end
	for _, id in order do
		services.CinematicService:PlayAndWait(id, Players:GetPlayers())
	end
end

local function endGame()
	state:SetAttribute("gameOver", true)
	local results = computeResults()
	GameStateService.GameEnded:Fire(results)
	endingCinematics(results)
	local remote = Util.getRemote("RE_EndGame")
	if remote then
		remote:FireAllClients(results)
	end
	services.ReturnService:ReturnAll(results)
end

local function run()
	local _, players = services.PartyLoaderService:WaitUntilLoaded()
	info = services.PartyLoaderService:GetMatchInfo()
	-- attendre que les personnages soient posés
	local waited = 0
	while waited < PlayerConfig.Technical.Tick * 10 do
		local ready = true
		for _, player in players do
			if player.Parent and player:GetAttribute("role") == nil then
				ready = false
			end
		end
		if ready then
			break
		end
		task.wait(PlayerConfig.Technical.Tick)
		waited += PlayerConfig.Technical.Tick
	end
	state:SetAttribute("difficulty", info.difficulty)
	services.WeatherService:Begin(info)
	setupBarricades()

	-- acte 0 : arrivée, 3 min fixes
	setAct(0)
	setObjectives(ActConfig.Objectives[0])
	services.CinematicService:Play(CinematicConfig.StartCinematic[info.start] or CinematicConfig.StartCinematic.S1)
	if info.start == "S3" then
		campEntered = true -- 5.2 : déjà au camp si départ S3
	end
	while not maxReached() and not extractionDone do
		step()
	end
	local acts = { runAct1, runAct2, runAct3, runAct4 }
	for _, runAct in acts do
		if extractionDone or #alivePlayers() == 0 then
			break
		end
		runAct()
	end
	endGame()
end

function GameStateService:Init(allServices)
	services = allServices
	state = Util.getMatchState()
	state:SetAttribute("act", 0)
	state:SetAttribute("clock", ActConfig.Acts[0].start)
end

function GameStateService:Start()
	services.ItemSpawnService.ClueFound:Connect(function(clueId)
		cluesFound[clueId] = true
		state:SetAttribute("cluesFound", Util.encode(Util.sortedKeys(cluesFound)))
	end)
	services.ExtractionService.Extracted:Connect(function(routeId, list)
		for _, player in list do
			extracted[player] = routeId
			player:SetAttribute("extracted", routeId)
		end
		if #list > 0 then
			extractionDone = true
		end
	end)
	-- DOC_08 lu : vidéo de la tablette (CS_05) pour le lecteur
	services.DocumentService.Read:Connect(function(docId, player)
		if docId == "DOC_08" and player then
			services.CinematicService:Play("CS_05", { player })
		end
	end)
	-- tous morts : la partie s'arrête (Silence)
	services.HealthService.Died:Connect(function()
		if #alivePlayers() == 0 and not state:GetAttribute("gameOver") then
			extractionDone = true
		end
	end)
	task.spawn(run)
end

return GameStateService
