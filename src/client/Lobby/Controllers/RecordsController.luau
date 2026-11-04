-- Controllers/RecordsController (Lobby)
-- Sections 4.5 et 15.3 : RecordsGui > Board > Template (Rank, Group, Value) ; Tabs > Survivors,
-- EvidenceA, Endings. Données : ReplicatedStorage/LobbyState.records (RecordsService). Ouvert au diner.
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local RecordsController = {}

function RecordsController:Start()
	local gui = Util.waitGui("RecordsGui")
	if gui == nil then
		return
	end
	local root = gui.Parent
	local state = ReplicatedStorage:WaitForChild("LobbyState", Util.GUI_WAIT_TIMEOUT)
	local tab = "Survivors"
	local function refresh()
		local template = Util.findUI(root, "RecordsGui/Board/Template")
		if template == nil or state == nil then
			return
		end
		Util.clearClones(template)
		local rows = Util.decode(state:GetAttribute("records"), {})[tab] or {}
		for rank, row in rows do
			local line = Util.cloneTemplate(template, rank)
			line:FindFirstChild("Rank").Text = tostring(rank)
			line:FindFirstChild("Group").Text = row.group
			line:FindFirstChild("Value").Text = tostring(row.value)
		end
	end
	for _, name in { "Survivors", "EvidenceA", "Endings" } do
		local button = Util.findUI(root, "RecordsGui/Tabs/" .. name)
		if button then
			button.Activated:Connect(function()
				tab = name
				refresh()
			end)
		end
	end
	if state then
		state:GetAttributeChangedSignal("records"):Connect(refresh)
	end
	local function setVisible(visible)
		Util.findUI(root, "RecordsGui/Tabs").Visible = visible
		Util.findUI(root, "RecordsGui/Board").Visible = visible
	end
	ProximityPromptService.PromptTriggered:Connect(function(prompt)
		if prompt:GetAttribute("lobbyAction") == "Records" then
			setVisible(true)
			refresh()
		end
	end)
	ProximityPromptService.PromptHidden:Connect(function(prompt)
		if prompt:GetAttribute("lobbyAction") == "Records" then
			setVisible(false)
		end
	end)
end

return RecordsController
