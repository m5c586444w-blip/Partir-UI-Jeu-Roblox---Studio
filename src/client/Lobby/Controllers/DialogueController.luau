-- Controllers/DialogueController (Lobby)
-- Sections 4.2 et 15.3 : DialogueGui > Dialogue > SpeakerName, Line, Choices > Choice_1, Choice_2,
-- Choice_3. Ouvert par l'invite du ranger (lobbyAction = "Dialogue") ; un choix affiche la réponse.
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LoreConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("LoreConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local DialogueController = {}

function DialogueController:Start()
	local gui = Util.waitGui("DialogueGui")
	if gui == nil then
		return
	end
	local root = gui.Parent
	local dialogue = Util.findUI(root, "DialogueGui/Dialogue")
	local line = Util.findUI(root, "DialogueGui/Dialogue/Line")
	local remote = Util.getRemote("RE_DialogueChoice")
	local d = LoreConfig.Dialogue
	local function open()
		dialogue.Visible = true
		Util.findUI(root, "DialogueGui/Dialogue/SpeakerName").Text = d.Speaker
		line.Text = d.Opening
	end
	for i, choice in d.Choices do
		local button = Util.findUI(root, "DialogueGui/Dialogue/Choices/Choice_" .. i)
		if button then
			button.Text = choice.text
			button.Activated:Connect(function()
				line.Text = choice.answer
				if remote then
					remote:FireServer(i)
				end
			end)
		end
	end
	ProximityPromptService.PromptTriggered:Connect(function(prompt)
		if prompt:GetAttribute("lobbyAction") == "Dialogue" and dialogue then
			open()
		end
	end)
	-- fermer : s'éloigner du ranger (l'invite disparaît)
	ProximityPromptService.PromptHidden:Connect(function(prompt)
		if prompt:GetAttribute("lobbyAction") == "Dialogue" and dialogue then
			dialogue.Visible = false
		end
	end)
end

return DialogueController
