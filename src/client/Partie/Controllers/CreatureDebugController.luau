-- Controllers/CreatureDebugController (Partie)
-- Section 9.13 : en Studio seulement, la touche F8 affiche ou cache les étiquettes CreatureDebug.
-- Section 7.7 : le Pisteur voit les empreintes fraîches (moins de 120 s) en surbrillance.
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local PlayerConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("PlayerConfig"))

local CreatureDebugController = {}

local player = Players.LocalPlayer
local shown = false

function CreatureDebugController:Start()
	if RunService:IsStudio() then
		UserInputService.InputBegan:Connect(function(input, processed)
			if not processed and input.KeyCode == Enum.KeyCode.F8 then
				shown = not shown
				for _, creature in CollectionService:GetTagged("Creature") do
					local tag = creature:FindFirstChild("CreatureDebug")
					if tag then
						tag.Enabled = shown
					end
				end
			end
		end)
	end
	-- empreintes fraîches du Pisteur
	local highlights = {}
	RunService.Heartbeat:Connect(function()
		local isTracker = player:GetAttribute("role") == "Tracker"
		local maxAge = PlayerConfig.Abilities.Tracker.FootprintMaxAge
		for _, print_ in CollectionService:GetTagged("Footprint") do
			local age = workspace:GetServerTimeNow() - (print_:GetAttribute("createdTime") or 0)
			local show = isTracker and age <= maxAge
			local h = highlights[print_]
			if show and h == nil then
				h = Instance.new("Highlight")
				h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				h.Adornee = print_
				h.Parent = print_
				highlights[print_] = h
			elseif not show and h then
				h:Destroy()
				highlights[print_] = nil
			end
		end
		for print_, h in highlights do
			if print_.Parent == nil then
				h:Destroy()
				highlights[print_] = nil
			end
		end
	end)
end

return CreatureDebugController
