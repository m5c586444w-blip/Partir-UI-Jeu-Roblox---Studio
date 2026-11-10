-- Controllers/SettingsController (les deux places)
-- Sections 15.5, 17.2 et 17.3 : SettingsGui > Window > Tabs, Pages (une page par onglet, une ligne par
-- réglage), Apply, Reset, Close. Défauts PC / mobile de 17.2 ; enregistrement dans settings (16.4) par
-- RE_SaveSettings (DÉFAUT). Touche P (DÉFAUT) pour ouvrir.
-- Les scripts ne changent pas les couleurs (15.1) : la valeur choisie s'affiche dans le texte de
-- l'étiquette Value (curseurs) ou par un « • » devant l'option choisie (DÉFAUT).
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")

local Config = ReplicatedStorage:WaitForChild("Config")
local PlayerConfig = require(Config:WaitForChild("PlayerConfig"))
local ProgressionConfig = require(Config:WaitForChild("ProgressionConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local SettingsController = {}

local player = Players.LocalPlayer
local controllers = nil
local root = nil
local values = {}
local labels = {} -- [bouton] = texte de départ
local Settings = ProgressionConfig.Settings
local MARK = "• " -- DÉFAUT : marque de l'option choisie

-- identifiant de l'option (« Opt_High » → "High", « Opt_25 » → 25, « Opt_Yes » → true)
local OPTION_NAMES = {
	Yes = true,
	No = false,
	Low = "Low",
	Medium = "Medium",
	High = "High",
	Ultra = "Ultra",
	Normal = "Normal",
	Small = "Small",
	Large = "Large",
	French = "French",
	English = "English",
}

local function optionValue(name)
	local raw = string.gsub(name, "^Opt_", "")
	if OPTION_NAMES[raw] ~= nil then
		return OPTION_NAMES[raw]
	end
	return tonumber(raw)
end

local function isMobile()
	return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

local function defaults()
	local result = {}
	for key, spec in Settings do
		result[key] = if isMobile() then spec.mobile else spec.pc
	end
	return result
end

local function find(path)
	return Util.findUI(root, "SettingsGui/Window/" .. path)
end

local function pageOf(key)
	for _, page in { "Graphics", "Controls", "Audio", "Accessibility" } do
		if find("Pages/" .. page .. "/" .. key) then
			return page
		end
	end
	return nil
end

-- application locale des réglages
function SettingsController:Apply()
	local camera = controllers.CameraController
	if camera then
		camera.FieldOfView = values.FieldOfView
		camera.ReduceMotion = values.ReduceMotion
	end
	local ambience = controllers.AmbienceController
	if ambience then
		ambience.Gamma = values.Brightness
	end
	local gore = controllers.GoreController
	if gore then
		gore.ReducedGore = values.ReducedGore
		gore.Preset = values.Preset
	end
	-- 12.4, 17.2, 17.3 : vent dans les arbres (Partie seulement)
	local treeWind = controllers.TreeWindController
	if treeWind then
		treeWind.Enabled = values.TreeWind
		treeWind.Preset = values.Preset
	end
	-- 17.3 : préréglage (profondeur de champ, flou lumineux)
	local preset = ProgressionConfig.Presets[values.Preset]
	local dof = Lighting:FindFirstChildOfClass("DepthOfFieldEffect")
	if dof then
		dof.Enabled = preset.dof and values.DepthOfField
	end
	local bloom = Lighting:FindFirstChildOfClass("BloomEffect")
	if bloom then
		bloom.Enabled = preset.bloom
	end
	-- 17.2 : volumes (SoundGroup nommés comme les réglages, à créer dans Studio : Ambience, Voice, Music, Effects)
	for _, key in { "Ambience", "Voice", "Music", "Effects" } do
		local group = SoundService:FindFirstChild(key)
		if group and group:IsA("SoundGroup") then
			group.Volume = values[key] / Settings[key].max * values.Master / Settings.Master.max
		end
	end
end

local function refresh()
	for button, text in labels do
		local row = button.Parent and button.Parent.Parent
		local key = row and row.Name
		button.Text = if key and values[key] == optionValue(button.Name) then MARK .. text else text
	end
	for key, spec in Settings do
		if spec.min then
			local page = pageOf(key)
			local row = page and find("Pages/" .. page .. "/" .. key)
			if row then
				local value = row:FindFirstChild("Value")
				local fill = row:FindFirstChild("Slider")
					and row.Slider:FindFirstChild("Track")
					and row.Slider.Track:FindFirstChild("Fill")
				if value then
					value.Text = tostring(values[key])
				end
				if fill then
					fill.Size = UDim2.new((values[key] - spec.min) / (spec.max - spec.min), 0, 1, 0)
				end
			end
		end
	end
end

local function setOpen(open)
	local window = Util.findUI(root, "SettingsGui/Window")
	if window then
		window.Visible = open
	end
end

local function showPage(name)
	for _, page in { "Graphics", "Controls", "Audio", "Accessibility" } do
		local frame = find("Pages/" .. page)
		if frame then
			frame.Visible = page == name
		end
	end
end

function SettingsController:Init(all)
	controllers = all
end

function SettingsController:Start()
	local gui = Util.waitGui("SettingsGui")
	if gui == nil then
		return
	end
	root = gui.Parent
	values = defaults()
	local saved = Util.decode(player:GetAttribute("settingsJson"), {})
	for key, value in saved do
		values[key] = value
	end
	local remote = Util.getRemote("RE_SaveSettings")
	for _, page in { "Graphics", "Controls", "Audio", "Accessibility" } do
		local tab = find("Tabs/" .. page)
		if tab then
			tab.Activated:Connect(function()
				showPage(page)
			end)
		end
	end
	for key, spec in Settings do
		local page = pageOf(key)
		local row = page and find("Pages/" .. page .. "/" .. key)
		if row and spec.options then
			local options = row:FindFirstChild("Options")
			for _, button in options and options:GetChildren() or {} do
				if button:IsA("TextButton") then
					labels[button] = button.Text
					button.Activated:Connect(function()
						values[key] = optionValue(button.Name)
						refresh()
					end)
				end
			end
		elseif row and spec.min then
			-- curseur : clic ou glissement sur la piste
			local track = row:FindFirstChild("Slider") and row.Slider:FindFirstChild("Track")
			if track then
				track.InputBegan:Connect(function(input)
					if
						input.UserInputType == Enum.UserInputType.MouseButton1
						or input.UserInputType == Enum.UserInputType.Touch
					then
						local rel =
							math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
						local value = spec.min + (spec.max - spec.min) * rel
						values[key] = math.floor(value * 10 + 0.5) / 10 -- constante (arrondi au dixième)
						refresh()
					end
				end)
			end
		end
	end
	local apply = find("Apply")
	if apply then
		apply.Activated:Connect(function()
			self:Apply()
			if remote then
				remote:FireServer(values)
			end
		end)
	end
	local reset = find("Reset")
	if reset then
		reset.Activated:Connect(function()
			values = defaults()
			refresh()
		end)
	end
	local close = find("Close")
	if close then
		close.Activated:Connect(function()
			setOpen(false)
		end)
	end
	UserInputService.InputBegan:Connect(function(input, processed)
		if not processed and input.KeyCode == PlayerConfig.Keys.Settings then
			local window = Util.findUI(root, "SettingsGui/Window")
			setOpen(window ~= nil and not window.Visible)
		end
	end)
	showPage("Graphics")
	refresh()
	self:Apply()
end

return SettingsController
