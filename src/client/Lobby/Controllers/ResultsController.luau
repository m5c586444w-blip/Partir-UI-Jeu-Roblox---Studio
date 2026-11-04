-- Controllers/ResultsController (Lobby)
-- Sections 4.4 (étape 8), 5.3 et 15.3 : écran de résultats au retour (fin obtenue, survivants,
-- preuves sorties, XP). ResultsGui > Card > EndingTitle, EndingText, Survivors > Template (Name, Status),
-- Evidence > Template, XPGained, Continue. Les résultats arrivent dans les données de téléportation
-- (affichage seulement).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

local Config = ReplicatedStorage:WaitForChild("Config")
local ItemConfig = require(Config:WaitForChild("ItemConfig"))
local LoreConfig = require(Config:WaitForChild("LoreConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local ResultsController = {}

local player = Players.LocalPlayer
local ENDING_ORDER = { "Ordonnance", "Survie", "Verite", "Preuve", "Silence" }

local function evidenceName(kind)
	for _, def in ItemConfig.Items do
		if def.evidence and def.evidence.kind == kind then
			return def.name
		end
	end
	return kind
end

function ResultsController:Show(results)
	local gui = Util.waitGui("ResultsGui")
	if gui == nil or type(results) ~= "table" then
		return
	end
	local root = gui.Parent
	local card = Util.findUI(root, "ResultsGui/Card")
	if card == nil then
		return
	end
	local titles, texts = {}, {}
	for _, id in ENDING_ORDER do
		if results.endings and results.endings[id] then
			table.insert(titles, LoreConfig.Endings[id].title)
			if LoreConfig.Endings[id].text ~= "" then
				table.insert(texts, LoreConfig.Endings[id].text)
			end
		end
	end
	card:FindFirstChild("EndingTitle").Text = table.concat(titles, " · ")
	card:FindFirstChild("EndingText").Text = table.concat(texts, "\n")
	local survivor = Util.findUI(root, "ResultsGui/Card/Survivors/Template")
	if survivor then
		Util.clearClones(survivor)
		for i, entry in results.players or {} do
			local row = Util.cloneTemplate(survivor, i)
			row:FindFirstChild("Name").Text = entry.name
			row:FindFirstChild("Status").Text = LoreConfig.Status[entry.status] or ""
		end
	end
	local evidence = Util.findUI(root, "ResultsGui/Card/Evidence/Template")
	if evidence then
		Util.clearClones(evidence)
		for i, e in results.evidence or {} do
			-- DÉFAUT : « A · Carte mémoire · Theo »
			Util.cloneTemplate(evidence, i).Text = ("%s · %s · %s"):format(e.class, evidenceName(e.kind), e.holder)
		end
	end
	local xp = results.xp and results.xp[tostring(player.UserId)] or 0
	-- DÉFAUT : format « +250 XP »
	card:FindFirstChild("XPGained").Text = ("+%d XP"):format(xp)
	card.Visible = true
end

function ResultsController:Start()
	local data = TeleportService:GetLocalPlayerTeleportData()
	if type(data) == "table" and data.results then
		self:Show(data.results)
	end
	local gui = Util.waitGui("ResultsGui")
	local continue = gui and Util.findUI(gui.Parent, "ResultsGui/Card/Continue")
	if continue then
		continue.Activated:Connect(function()
			Util.findUI(gui.Parent, "ResultsGui/Card").Visible = false
		end)
	end
end

return ResultsController
