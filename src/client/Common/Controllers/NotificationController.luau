-- Controllers/NotificationController (les deux places)
-- Sections 4.6 et 15.5 : affiche les messages système (RE_Notify : clé, paramètres) dans
-- NotificationGui > Stack > Template (Text). {player} et {n} sont remplacés.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local LoreConfig = require(Config:WaitForChild("LoreConfig"))
local PlayerConfig = require(Config:WaitForChild("PlayerConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local NotificationController = {}

local template = nil
local shown = {}
local order = 0

-- affiche un texte déjà rédigé (tiré de la bible)
function NotificationController:Show(text)
	if template == nil or text == nil or text == "" then
		return
	end
	order += 1
	local item = Util.cloneTemplate(template, order)
	local label = item:FindFirstChild("Text")
	if label then
		label.Text = text
	end
	table.insert(shown, item)
	while #shown > PlayerConfig.Interface.NotificationMax do
		table.remove(shown, 1):Destroy()
	end
	task.delay(PlayerConfig.Interface.NotificationDuration, function()
		local index = table.find(shown, item)
		if index then
			table.remove(shown, index)
		end
		item:Destroy()
	end)
end

function NotificationController:ShowMessage(key, params)
	local text = LoreConfig.Messages[key]
	if text == nil then
		warn("NotificationController : message inconnu " .. tostring(key))
		return
	end
	self:Show(Util.formatMessage(text, params))
end

function NotificationController:Start()
	local gui = Util.waitGui("NotificationGui")
	template = gui and Util.findUI(gui.Parent, "NotificationGui/Stack/Template")
	local remote = Util.getRemote("RE_Notify")
	if remote then
		remote.OnClientEvent:Connect(function(key, params)
			self:ShowMessage(key, params)
		end)
	end
end

return NotificationController
