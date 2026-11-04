-- Controllers/EvidenceBoardController (Lobby)
-- Sections 4.5 et 15.3 : EvidenceBoardGui > Cork > Template (Photo, Label, Class) : preuves
-- personnelles sorties de la forêt ; NotebookPages > Page_1..3 (> Lock) : pages du carnet débloquées.
local ProximityPromptService = game:GetService("ProximityPromptService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("ItemConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local EvidenceBoardController = {}

local player = Players.LocalPlayer

local function nameOf(kind)
	for _, def in ItemConfig.Items do
		if def.evidence and def.evidence.kind == kind then
			return def.name
		end
	end
	return kind
end

function EvidenceBoardController:Start()
	local gui = Util.waitGui("EvidenceBoardGui")
	if gui == nil then
		return
	end
	local root = gui.Parent
	local function refresh()
		local template = Util.findUI(root, "EvidenceBoardGui/Cork/Template")
		if template then
			Util.clearClones(template)
			for i, e in Util.decode(player:GetAttribute("evidenceJson"), {}) do
				local card = Util.cloneTemplate(template, i)
				card:FindFirstChild("Label").Text = nameOf(e.kind)
				card:FindFirstChild("Class").Text = e.class
			end
		end
		local pages = Util.decode(player:GetAttribute("notebookPagesJson"), {})
		for i = 1, 3 do -- constante (3 pages, DOC_12)
			local lock = Util.findUI(root, ("EvidenceBoardGui/NotebookPages/Page_%d/Lock"):format(i))
			if lock then
				lock.Visible = pages[i] ~= true
			end
		end
	end
	local function setVisible(visible)
		Util.findUI(root, "EvidenceBoardGui/Cork").Visible = visible
		Util.findUI(root, "EvidenceBoardGui/NotebookPages").Visible = visible
	end
	player:GetAttributeChangedSignal("evidenceJson"):Connect(refresh)
	player:GetAttributeChangedSignal("notebookPagesJson"):Connect(refresh)
	ProximityPromptService.PromptTriggered:Connect(function(prompt)
		if prompt:GetAttribute("lobbyAction") == "EvidenceBoard" then
			setVisible(true)
			refresh()
		end
	end)
	ProximityPromptService.PromptHidden:Connect(function(prompt)
		if prompt:GetAttribute("lobbyAction") == "EvidenceBoard" then
			setVisible(false)
		end
	end)
end

return EvidenceBoardController
