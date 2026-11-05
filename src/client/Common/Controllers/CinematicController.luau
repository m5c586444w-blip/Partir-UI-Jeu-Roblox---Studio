-- Controllers/CinematicController (les deux places)
-- Sections 6.1, 6.2 et 15.5 : caméra Scriptable sur les Part Workspace/Cinematics/CS_xx_Shot_n,
-- transitions TweenService, bandes noires et sous-titres (CinematicGui). Passer : en lobby, bouton
-- après 10 s ; en partie, vote (RE_CinematicSkipVote). CS_00 joue à la première connexion au lobby
-- (attribut plays = 0, DÉFAUT : la bible ne prévoit pas de drapeau « déjà vue »).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Config = ReplicatedStorage:WaitForChild("Config")
local CinematicConfig = require(Config:WaitForChild("CinematicConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local CinematicController = {}

local player = Players.LocalPlayer
local root = nil
local playing = nil -- { id, token }
local isLobby = false
local skipRemote = nil

local function find(path)
	return Util.findUI(root, "CinematicGui/" .. path)
end

local function setVisible(visible)
	for _, name in { "BarTop", "BarBottom", "Subtitle", "Skip" } do
		local element = find(name)
		if element then
			element.Visible = visible
		end
	end
end

function CinematicController:IsPlaying()
	return playing ~= nil
end

local function stop()
	playing = nil
	setVisible(false)
	local camera = workspace.CurrentCamera
	camera.CameraType = Enum.CameraType.Custom
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		camera.CameraSubject = humanoid
	end
end

function CinematicController:Play(id, extra)
	local def = CinematicConfig.Cinematics[id]
	-- 19.5 (C23) : une vidéo de tablette est jouée par TabletController, sans prise de caméra
	if def == nil or root == nil or def.inTablet then
		return
	end
	local token = {}
	playing = { id = id, token = token }
	setVisible(true)
	local subtitle = find("Subtitle")
	if subtitle then
		-- DÉFAUT (15.7) : un long sous-titre est montré phrase par phrase, réparties sur la durée
		local text = (extra and extra.text) or def.subtitle or def.screenText or ""
		local sentences = {}
		for sentence in string.gmatch(text .. " ", "(.-[%.%!%?…]+)%s+") do
			table.insert(sentences, sentence)
		end
		if #sentences <= 1 then
			subtitle.Text = text
		else
			task.spawn(function()
				for _, sentence in sentences do
					if playing == nil or playing.token ~= token then
						return
					end
					subtitle.Text = sentence
					task.wait(def.duration / #sentences)
				end
			end)
		end
	end
	local skip = find("Skip")
	local votes = find("Skip/Votes")
	if votes then
		votes.Text = ""
	end
	if skip then
		skip.Visible = not isLobby -- en lobby, le bouton apparaît après 10 s
		if isLobby then
			task.delay(CinematicConfig.LobbySkipAfter, function()
				if playing and playing.token == token then
					skip.Visible = true
				end
			end)
		end
	end
	-- plans : Part invisibles CS_xx_Shot_n (6.1) ; sans plans posés, seules les bandes et le texte s'affichent
	local folder = workspace:FindFirstChild("Cinematics")
	local shots = {}
	for n = 1, def.shots or 0 do
		local shot = folder and folder:FindFirstChild(("%s_Shot_%d"):format(id, n))
		if shot and shot:IsA("BasePart") then
			table.insert(shots, shot)
		end
	end
	local camera = workspace.CurrentCamera
	if #shots > 0 and not def.noCut then
		camera.CameraType = Enum.CameraType.Scriptable
		if def.fov then
			camera.FieldOfView = def.fov
		end
		camera.CFrame = shots[1].CFrame
		local perShot = def.duration / #shots
		task.spawn(function()
			for i = 2, #shots do
				if not (playing and playing.token == token) then
					return
				end
				TweenService:Create(camera, TweenInfo.new(perShot, Enum.EasingStyle.Sine), { CFrame = shots[i].CFrame })
					:Play()
				task.wait(perShot)
			end
		end)
	elseif #shots == 0 and not def.noCut then
		warn(("CinematicController : aucun plan %s_Shot_n dans Workspace/Cinematics"):format(id))
	end
	task.delay(def.duration, function()
		if playing and playing.token == token then
			stop()
		end
	end)
end

function CinematicController:Start()
	-- la place Partie a Workspace/Places (16.1) ; le lobby non
	isLobby = workspace:FindFirstChild("Places") == nil
	local gui = Util.waitGui("CinematicGui")
	if gui == nil then
		return
	end
	root = gui.Parent
	skipRemote = Util.getRemote("RE_CinematicSkipVote")
	local skip = find("Skip")
	if skip then
		skip.Activated:Connect(function()
			if isLobby then
				stop()
			elseif skipRemote then
				skipRemote:FireServer()
			end
		end)
	end
	local remote = Util.getRemote("RE_PlayCinematic")
	if remote then
		remote.OnClientEvent:Connect(function(action, a, b)
			if action == "Play" then
				self:Play(a, b)
			elseif action == "Stop" then
				stop()
			elseif action == "SkipVotes" then
				local votes = find("Skip/Votes")
				if votes then
					votes.Text = ("%d/%d"):format(a, b)
				end
			end
		end)
	end
	-- 6.2 : CS_00 à la première connexion au lobby
	if isLobby then
		while player:GetAttribute("dataLoaded") == nil do
			task.wait(CinematicConfig.SafetyAfter)
		end
		if (player:GetAttribute("plays") or 0) == 0 then
			self:Play("CS_00")
		end
	end
end

return CinematicController
