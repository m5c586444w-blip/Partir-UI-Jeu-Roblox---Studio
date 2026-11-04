-- Controllers/MuseumController (Lobby)
-- Sections 4.3 et 15.3 : MuseumPanelGui > Panel > Title, Body, Source, Illustration, Close.
-- Ouvert par l'invite d'un panneau (lobbyAction = "Museum", panelId) ; RE_MuseumRead (5 XP la 1re fois).
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LoreConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("LoreConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local MuseumController = {}

function MuseumController:Start()
	local gui = Util.waitGui("MuseumPanelGui")
	if gui == nil then
		return
	end
	local root = gui.Parent
	local panel = Util.findUI(root, "MuseumPanelGui/Panel")
	local remote = Util.getRemote("RE_MuseumRead")
	local close = Util.findUI(root, "MuseumPanelGui/Panel/Close")
	if close then
		close.Activated:Connect(function()
			panel.Visible = false
		end)
	end
	ProximityPromptService.PromptTriggered:Connect(function(prompt)
		local id = prompt:GetAttribute("panelId")
		local entry = id and LoreConfig.Museum[id]
		if prompt:GetAttribute("lobbyAction") ~= "Museum" or entry == nil or panel == nil then
			return
		end
		panel.Visible = true
		Util.findUI(root, "MuseumPanelGui/Panel/Title").Text = entry.title
		Util.findUI(root, "MuseumPanelGui/Panel/Body").Text = entry.body
		Util.findUI(root, "MuseumPanelGui/Panel/Source").Text = entry.source
		if remote then
			remote:FireServer(id)
		end
	end)
end

return MuseumController
