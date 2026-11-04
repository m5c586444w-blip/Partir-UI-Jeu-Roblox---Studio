-- Controllers/FearFXController (Partie)
-- Sections 7.3 et 7.5 : effets locaux. Sang < 40 : vision qui se désature ; tête < 30 % : vision
-- floue ; peur ≥ 40 : battements de cœur (son à fournir, AudioConfig) ; le vignettage est dans HUDController.
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = ReplicatedStorage:WaitForChild("Config")
local PlayerConfig = require(Config:WaitForChild("PlayerConfig"))

local FearFXController = {}

local player = Players.LocalPlayer

function FearFXController:Start()
	local color = Instance.new("ColorCorrectionEffect")
	color.Name = "PlayerBloodFX"
	color.Parent = Lighting
	local blur = Instance.new("BlurEffect")
	blur.Name = "PlayerHeadFX"
	blur.Size = 0
	blur.Parent = Lighting
	RunService.RenderStepped:Connect(function()
		local blood = player:GetAttribute("blood") or PlayerConfig.Blood.Max
		local below = PlayerConfig.Blood.DesaturateBelow
		color.Saturation = if blood < below then PlayerConfig.Interface.LowBloodSaturation * (1 - blood / below) else 0
		local head = (player:GetAttribute("hpHead") or PlayerConfig.LimbHealth.Head) / PlayerConfig.LimbHealth.Head
		blur.Size = if head < PlayerConfig.LowLimbThreshold then PlayerConfig.Interface.LowHeadBlur else 0
	end)
end

return FearFXController
