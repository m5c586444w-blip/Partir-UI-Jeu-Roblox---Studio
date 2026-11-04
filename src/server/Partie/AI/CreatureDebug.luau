-- ServerScriptService/AI/CreatureDebug (Partie)
-- Section 9.13 : en Studio seulement, affiche au-dessus de chaque créature : comportement, cible,
-- scores, vigilance par joueur, chemin prévu, et la tension du directeur. Le texte est mis à jour par
-- le serveur dans un clone de ReplicatedStorage/UITemplates/CreatureDebug (15.1 : clone d'un modèle) ;
-- la touche F8 l'affiche ou le cache (CreatureDebugController, client).
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = ReplicatedStorage:WaitForChild("Config")
local CreatureConfig = require(Config:WaitForChild("CreatureConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local CreatureDebug = {}

local ai = nil

local function describe(brain)
	local lines = {
		("%s  PV %d/%d  %s"):format(brain.id, brain.health, brain.maxHealth, brain.personality or ""),
		("comportement : %s"):format(brain.behaviorId or "—"),
		("cible : %s"):format(brain.target and brain.target.Name or "—"),
	}
	local scores = {}
	for id, score in brain.scores do
		if score > 0 then
			table.insert(scores, ("%s %.2f"):format(string.gsub(id, "^BHV_", ""), score))
		end
	end
	table.sort(scores)
	table.insert(lines, "scores : " .. table.concat(scores, ", "))
	local vigilance = {}
	for player, value in brain.vigilance do
		table.insert(vigilance, ("%s %.2f"):format(player.Name, value))
	end
	table.insert(lines, "vigilance : " .. table.concat(vigilance, ", "))
	table.insert(lines, ("chemin : %d points"):format(brain.path and #brain.path or 0))
	table.insert(lines, ("tension : %.0f"):format(ai.TensionDirector:Intensity()))
	return table.concat(lines, "\n")
end

function CreatureDebug:Init(_services, aiModules)
	ai = aiModules
end

function CreatureDebug:Start()
	if not RunService:IsStudio() then
		return
	end
	task.spawn(function()
		local templates = ReplicatedStorage:WaitForChild("UITemplates", Util.GUI_WAIT_TIMEOUT)
		local template = templates and templates:FindFirstChild("CreatureDebug")
		if template == nil then
			warn("UI manquante : UITemplates/CreatureDebug")
			return
		end
		while true do
			task.wait(1 / CreatureConfig.Rates.Family)
			for _, brain in ai.FamilyBrain:GetBrains() do
				local tag = brain.model:FindFirstChild("CreatureDebug")
				if tag == nil and brain.head then
					tag = template:Clone()
					tag.Adornee = brain.head
					tag.Parent = brain.model
				end
				local label = tag and tag:FindFirstChild("Info")
				if label then
					label.Text = describe(brain)
				end
			end
		end
	end)
end

return CreatureDebug
