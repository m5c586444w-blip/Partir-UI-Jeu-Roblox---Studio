-- Controllers/TeleportController (Lobby)
-- Sections 15.3 et 15.6 : LoadingGui > Background, Tip (astuce tirée au hasard), Spinner, affiché au
-- départ (MSG_Teleporting) et transmis à TeleportService:SetTeleportGui pour l'écran de transition.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

local LoreConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("LoreConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local TeleportController = {}

local gui = nil

local function show(visible)
	if gui == nil then
		return
	end
	for _, name in { "Background", "Tip", "Spinner" } do
		local element = gui:FindFirstChild(name)
		if element then
			element.Visible = visible
		end
	end
	if visible then
		local tips = LoreConfig.LoadingTips
		gui:FindFirstChild("Tip").Text = tips[math.random(1, #tips)]
		TeleportService:SetTeleportGui(gui)
	end
end

function TeleportController:Start()
	gui = Util.waitGui("LoadingGui")
	local remote = Util.getRemote("RE_Notify")
	if remote then
		remote.OnClientEvent:Connect(function(key)
			if key == "MSG_Teleporting" then
				show(true)
			elseif key == "MSG_TeleportAbort" then
				show(false)
			end
		end)
	end
end

return TeleportController
