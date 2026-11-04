-- Controllers/DownedController (Partie)
-- Sections 7.3 et 15.4 : DownedGui > Countdown, HelpHint, Bleed > Fill, visibles à terre.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local PlayerConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("PlayerConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local DownedController = {}

local player = Players.LocalPlayer

function DownedController:Start()
	local gui = Util.waitGui("DownedGui")
	if gui == nil then
		return
	end
	local countdown = Util.findUI(gui.Parent, "DownedGui/Countdown")
	local hint = Util.findUI(gui.Parent, "DownedGui/HelpHint")
	local bleed = Util.findUI(gui.Parent, "DownedGui/Bleed")
	local fill = bleed and bleed:FindFirstChild("Fill")
	RunService.RenderStepped:Connect(function()
		local downed = player:GetAttribute("isDowned") == true and not player:GetAttribute("isDead")
		for _, element in { countdown, hint, bleed } do
			if element then
				element.Visible = downed
			end
		end
		if downed then
			local left = math.max(0, (player:GetAttribute("downedEnd") or 0) - workspace:GetServerTimeNow())
			if countdown then
				countdown.Text = tostring(math.ceil(left))
			end
			if fill then
				fill.Size = UDim2.new((player:GetAttribute("blood") or 0) / PlayerConfig.Blood.Max, 0, 1, 0)
			end
		end
	end)
end

return DownedController
