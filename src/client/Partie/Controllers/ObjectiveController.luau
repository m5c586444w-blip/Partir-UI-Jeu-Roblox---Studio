-- Controllers/ObjectiveController (Partie)
-- Sections 5.1, 5.4 et 15.4 : ObjectiveGui > ActName, ObjectiveText, Clock. En Cauchemar, pas
-- d'indications d'objectif à l'écran (tablette seulement) ; l'heure reste affichée (DÉFAUT).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local ActConfig = require(Config:WaitForChild("ActConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local ObjectiveController = {}

local MINUTES = 60 -- constante (minutes dans une heure)

-- DÉFAUT : heure au format de la bible (« 19 h 00 »)
local function formatClock(clock)
	local hours = math.floor(clock)
	local minutes = math.floor((clock - hours) * MINUTES)
	return ("%02d h %02d"):format(hours, minutes)
end

function ObjectiveController:Start()
	local gui = Util.waitGui("ObjectiveGui")
	if gui == nil then
		return
	end
	local actName = Util.findUI(gui.Parent, "ObjectiveGui/ActName")
	local objective = Util.findUI(gui.Parent, "ObjectiveGui/ObjectiveText")
	local clock = Util.findUI(gui.Parent, "ObjectiveGui/Clock")
	local state = Util.getMatchState()
	local function refresh()
		local difficulty = state:GetAttribute("difficulty")
		local hints = ActConfig.difficulty(difficulty).objectiveHints
		local act = ActConfig.Acts[state:GetAttribute("act") or 0]
		if actName then
			actName.Visible = hints
			actName.Text = act and act.name or ""
		end
		if objective then
			objective.Visible = hints
			objective.Text = state:GetAttribute("objective") or ""
		end
		if clock then
			clock.Text = formatClock(state:GetAttribute("clock") or ActConfig.Acts[0].start)
		end
	end
	for _, name in { "act", "objective", "clock", "difficulty" } do
		state:GetAttributeChangedSignal(name):Connect(refresh)
	end
	refresh()
end

return ObjectiveController
