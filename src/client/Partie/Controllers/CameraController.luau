-- Controllers/CameraController (Partie)
-- Sections 7.2 et 6.3 : vue à la première personne verrouillée, FOV 70 (76 en course),
-- balancement de marche (par code, 14.3), se pencher ; caméra de mort : 4 s au-dessus du corps,
-- inclinée de 10°, puis spectateur (SpectatorController).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local PlayerConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("PlayerConfig"))

local CameraController = {}

local player = Players.LocalPlayer
local controllers = nil
local Interface = PlayerConfig.Interface
local bobTime = 0
local deathCamUntil = nil

-- 17.2 : « Réduire les mouvements » (balancement de caméra) ; lu par SettingsController
CameraController.ReduceMotion = false

function CameraController:IsDeathCam()
	return deathCamUntil ~= nil and os.clock() < deathCamUntil
end

local function startDeathCam()
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if root == nil then
		return
	end
	local camera = workspace.CurrentCamera
	camera.CameraType = Enum.CameraType.Scriptable
	-- 6.3 : légèrement au-dessus du corps, inclinée de 10°, sans gros plan
	local above = root.Position + Vector3.new(0, PlayerConfig.DeathCamera.Height, 0)
	camera.CFrame = CFrame.new(above)
		* CFrame.Angles(math.rad(PlayerConfig.DeathCamera.TiltDegrees) - math.pi / 2, 0, 0)
	deathCamUntil = os.clock() + PlayerConfig.DeathCamera.Duration
	task.delay(PlayerConfig.DeathCamera.Duration, function()
		if controllers.SpectatorController then
			controllers.SpectatorController:Begin()
		end
	end)
end

local function update(dt)
	if
		player:GetAttribute("isDead")
		or controllers.SpectatorController and controllers.SpectatorController:IsActive()
	then
		return
	end
	if controllers.CinematicController and controllers.CinematicController:IsPlaying() then
		return
	end
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid == nil then
		return
	end
	local camera = workspace.CurrentCamera
	player.CameraMode = Enum.CameraMode.LockFirstPerson
	local running = player:GetAttribute("stance") == "Run" and humanoid.MoveDirection.Magnitude > 0.1
	camera.FieldOfView = if running
		then PlayerConfig.Camera.RunFieldOfView
		else (CameraController.FieldOfView or PlayerConfig.Camera.FieldOfView)

	local lean = controllers.InputController and controllers.InputController:GetLean() or 0
	local offset = Vector3.new(lean * Interface.LeanOffset, 0, 0)
	if not CameraController.ReduceMotion and humanoid.MoveDirection.Magnitude > 0.1 then
		bobTime += dt * humanoid.WalkSpeed / PlayerConfig.Movement.Walk.speed * Interface.BobFrequency
		offset += Vector3.new(0, math.sin(bobTime) * Interface.BobAmplitude, 0)
	end
	humanoid.CameraOffset = offset
end

function CameraController:Init(all)
	controllers = all
end

function CameraController:Start()
	player:GetAttributeChangedSignal("isDead"):Connect(function()
		if player:GetAttribute("isDead") then
			startDeathCam()
		end
	end)
	RunService.RenderStepped:Connect(update)
end

return CameraController
