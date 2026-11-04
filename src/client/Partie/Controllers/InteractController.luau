-- Controllers/InteractController (Partie)
-- Section 15.4 : InteractGui > Prompt > KeyHint, ActionText, Progress > Fill, pour les
-- ProximityPrompt en style Custom. La durée de maintien propre au joueur (rôle, outils) est lue
-- dans l'attribut hold_<UserId> de l'invite (InteractionService).
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local InteractController = {}

local player = Players.LocalPlayer
local frame, keyHint, actionText, fill = nil, nil, nil, nil
local current = nil
local holdBegan = nil

local function keyName(prompt)
	if UserInputService.TouchEnabled then
		return ""
	end
	return UserInputService:GetStringForKeyCode(prompt.KeyboardKeyCode)
end

local function show(prompt)
	current = prompt
	local hold = prompt:GetAttribute("hold_" .. player.UserId)
	if hold ~= nil then
		prompt.HoldDuration = hold
	end
	if frame then
		frame.Visible = true
		actionText.Text = prompt.ActionText
		keyHint.Text = keyName(prompt)
		fill.Size = UDim2.new(0, 0, fill.Size.Y.Scale, 0)
	end
end

local function hide(prompt)
	if current == prompt then
		current = nil
		holdBegan = nil
		if frame then
			frame.Visible = false
		end
	end
end

function InteractController:Start()
	local gui = Util.waitGui("InteractGui")
	if gui then
		frame = Util.findUI(gui.Parent, "InteractGui/Prompt")
		keyHint = Util.findUI(gui.Parent, "InteractGui/Prompt/KeyHint")
		actionText = Util.findUI(gui.Parent, "InteractGui/Prompt/ActionText")
		fill = Util.findUI(gui.Parent, "InteractGui/Prompt/Progress/Fill")
	end
	ProximityPromptService.PromptShown:Connect(function(prompt)
		if prompt.Style == Enum.ProximityPromptStyle.Custom then
			show(prompt)
		end
	end)
	ProximityPromptService.PromptHidden:Connect(hide)
	ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
		if prompt == current then
			holdBegan = os.clock()
		end
	end)
	ProximityPromptService.PromptButtonHoldEnded:Connect(function(prompt)
		if prompt == current then
			holdBegan = nil
			if fill then
				fill.Size = UDim2.new(0, 0, fill.Size.Y.Scale, 0)
			end
		end
	end)
	RunService.RenderStepped:Connect(function()
		if current and holdBegan and fill and current.HoldDuration > 0 then
			local progress = math.clamp((os.clock() - holdBegan) / current.HoldDuration, 0, 1)
			fill.Size = UDim2.new(progress, 0, fill.Size.Y.Scale, 0)
		end
	end)
	-- écran tactile : toucher la fenêtre de l'invite déclenche l'interaction
	if frame then
		frame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch and current then
				current:InputHoldBegin()
			end
		end)
		frame.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch and current then
				current:InputHoldEnd()
			end
		end)
	end
end

return InteractController
