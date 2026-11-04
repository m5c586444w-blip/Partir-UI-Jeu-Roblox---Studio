-- ServerScriptService/Services/InteractionService (Partie)
-- Section 16.2 et 16.3 : les interactions passent par des ProximityPrompt (style Custom, affichés par
-- InteractGui). Durée de maintien propre à chaque joueur (rôle, caisse à outils) : le serveur écrit
-- l'attribut hold_<UserId> sur l'invite ; le client l'applique ; le serveur vérifie le temps réel.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("ItemConfig"))
local PlayerConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("PlayerConfig"))

local InteractionService = {}

local KEY = PlayerConfig.Technical.InteractKey
local GAMEPAD_KEY = PlayerConfig.Technical.InteractGamepadKey
local HOLD_TOLERANCE = PlayerConfig.Technical.HoldTolerance

local prompts = {} -- [ProximityPrompt] = opts
local holdStart = {} -- [prompt][player] = os.clock()

local function durationFor(opts, player)
	if opts.durationFor then
		return opts.durationFor(player)
	end
	local role = player:GetAttribute("role")
	return (opts.roleHoldDuration and opts.roleHoldDuration[role]) or opts.holdDuration or 0
end

local function refresh(prompt, opts)
	for _, player in Players:GetPlayers() do
		prompt:SetAttribute("hold_" .. player.UserId, durationFor(opts, player))
	end
end

-- crée une invite sur `parent` (BasePart ou Attachment). opts : action, object, holdDuration,
-- roleHoldDuration, durationFor(player), canUse(player), onTriggered(player), maxDistance
function InteractionService:CreatePrompt(parent, opts)
	local prompt = Instance.new("ProximityPrompt")
	prompt.Style = Enum.ProximityPromptStyle.Custom
	prompt.ActionText = opts.action or ""
	prompt.ObjectText = opts.object or ""
	prompt.KeyboardKeyCode = KEY
	prompt.GamepadKeyCode = GAMEPAD_KEY
	prompt.HoldDuration = opts.holdDuration or 0
	prompt.MaxActivationDistance = opts.maxDistance or ItemConfig.PickupDistance
	prompt.RequiresLineOfSight = false
	prompt.Parent = parent
	prompts[prompt] = opts
	holdStart[prompt] = {}
	refresh(prompt, opts)

	prompt.PromptButtonHoldBegan:Connect(function(player)
		holdStart[prompt][player] = os.clock()
	end)
	prompt.PromptButtonHoldEnded:Connect(function(player)
		holdStart[prompt][player] = nil
	end)
	prompt.Triggered:Connect(function(player)
		if opts.canUse and not opts.canUse(player) then
			return
		end
		local needed = durationFor(opts, player)
		if needed > 0 then
			local began = holdStart[prompt][player]
			if began == nil or os.clock() - began + HOLD_TOLERANCE < needed then
				return -- maintien trop court : refusé
			end
		end
		holdStart[prompt][player] = nil
		opts.onTriggered(player)
	end)
	prompt.Destroying:Connect(function()
		prompts[prompt] = nil
		holdStart[prompt] = nil
	end)
	return prompt
end

-- recalcule les durées propres à chaque joueur (inventaire ou rôle changé)
function InteractionService:Refresh()
	for prompt, opts in prompts do
		refresh(prompt, opts)
	end
end

function InteractionService:Init() end

-- 7.8 et 16.3 : RE_Ping (position) — repère visible 10 s par le groupe ;
-- clone de ReplicatedStorage/UITemplates/PingMarker (15.5)
local function onPing(player, position)
	if typeof(position) ~= "Vector3" or player:GetAttribute("isDead") then
		return
	end
	local templates = ReplicatedStorage:FindFirstChild("UITemplates")
	local marker = templates and templates:FindFirstChild("PingMarker")
	local anchor = Instance.new("Part")
	anchor.Name = "Ping_" .. player.Name
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanQuery = false
	anchor.Transparency = 1
	anchor.Size = Vector3.one
	anchor.Position = position
	anchor.Parent = workspace
	if marker then
		marker:Clone().Parent = anchor
	else
		warn("UI manquante : UITemplates/PingMarker")
	end
	game:GetService("Debris"):AddItem(anchor, PlayerConfig.Communication.PingDuration)
end

function InteractionService:Start()
	Players.PlayerAdded:Connect(function()
		self:Refresh()
	end)
	local remote = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util")).getRemote("RE_Ping")
	if remote then
		require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("RateLimiter")).connect(remote, onPing)
	end
end

return InteractionService
