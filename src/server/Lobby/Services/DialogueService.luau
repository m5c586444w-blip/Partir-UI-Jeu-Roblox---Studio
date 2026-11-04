-- ServerScriptService/Services/DialogueService (Lobby)
-- Section 4.2 : dialogue du ranger Dale Hollis (bulles, 3 choix). Les textes sont dans
-- LoreConfig.Dialogue ; le client les affiche. RE_DialogueChoice (C → S) : (index du choix), vérifié ;
-- aucune donnée n'en dépend (16.4).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LoreConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("LoreConfig"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local RateLimiter = require(Shared:WaitForChild("RateLimiter"))
local Util = require(Shared:WaitForChild("Util"))

local DialogueService = {}

function DialogueService:Init() end

function DialogueService:Start()
	local remote = Util.getRemote("RE_DialogueChoice")
	if remote then
		RateLimiter.connect(remote, function(player, index)
			if type(index) == "number" and LoreConfig.Dialogue.Choices[index] then
				player:SetAttribute("lastDialogueChoice", index)
			end
		end)
	end
end

return DialogueService
