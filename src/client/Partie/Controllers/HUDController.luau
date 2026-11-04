-- Controllers/HUDController (Partie)
-- Section 15.4 : HUDGui. Membres (Ok / Hurt / Critical, une seule visible), hémorragie, endurance,
-- pile, munitions, objet tenu, réticule (seulement en visant, 7.2), vignettage de peur (7.5 : jamais
-- de chiffre). 15.2 : le HUD s'efface après 4 s sans changement et réapparaît à la moindre variation.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = ReplicatedStorage:WaitForChild("Config")
local ItemConfig = require(Config:WaitForChild("ItemConfig"))
local PlayerConfig = require(Config:WaitForChild("PlayerConfig"))
local WeaponConfig = require(Config:WaitForChild("WeaponConfig"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"))

local HUDController = {}

local player = Players.LocalPlayer
local controllers = nil
local root = nil
local ui = {}
local lastChange = 0
local hidden = false

local FADING = { "BodyStatus", "Stamina", "Battery", "Ammo", "HeldItem" }

local function find(path)
	return Util.findUI(root, "HUDGui/" .. path)
end

local function maxFor(limb)
	local override = PlayerConfig.RoleLimbHealth[player:GetAttribute("role")]
	return (override and override[limb]) or PlayerConfig.LimbHealth[limb]
end

local function touch()
	lastChange = os.clock()
	if hidden then
		hidden = false
		for _, name in FADING do
			if ui[name] then
				ui[name].Visible = true
			end
		end
		HUDController:Refresh()
	end
end

local function setFill(frame, value)
	local fill = frame and frame:FindFirstChild("Fill")
	if fill then
		fill.Size = UDim2.new(math.clamp(value, 0, 1), 0, fill.Size.Y.Scale, fill.Size.Y.Offset)
	end
end

function HUDController:Refresh()
	for _, limb in PlayerConfig.Limbs do
		local frame = ui.limbs[limb]
		if frame then
			local value = (player:GetAttribute("hp" .. limb) or maxFor(limb)) / maxFor(limb)
			-- DÉFAUT : Ok = intact, Hurt = touché, Critical = sous 30 % (7.3)
			local state = if value < PlayerConfig.LowLimbThreshold then "Critical" elseif value < 1 then "Hurt" else "Ok"
			for _, name in { "Ok", "Hurt", "Critical" } do
				local child = frame:FindFirstChild(name)
				if child then
					child.Visible = name == state
				end
			end
		end
	end
	if ui.BleedIcon then
		ui.BleedIcon.Visible = (player:GetAttribute("bleed") or "None") ~= "None"
	end
	local stamina = player:GetAttribute("stamina") or 0
	local maxStamina = PlayerConfig.Stamina.RoleMax[player:GetAttribute("role")] or PlayerConfig.Stamina.Max
	setFill(ui.Stamina, stamina / maxStamina)
	setFill(ui.Battery, player:GetAttribute("lightBattery") or 1)

	local held = player:GetAttribute("heldItem")
	local weapon = held and WeaponConfig.Weapons[held]
	if ui.Ammo then
		ui.Ammo.Visible = weapon ~= nil and weapon.ammo ~= nil and not hidden
		local count = ui.Ammo:FindFirstChild("Count")
		local reserve = ui.Ammo:FindFirstChild("Reserve")
		if count then
			count.Text = tostring(player:GetAttribute("ammo") or 0)
		end
		if reserve then
			reserve.Text = tostring(player:GetAttribute("ammoReserve") or 0)
		end
	end
	if ui.HeldItem then
		local def = held and (ItemConfig.Items[held] or WeaponConfig.Weapons[held])
		ui.HeldItem.Text = def and def.name or ""
	end
end

-- 7.7 : le Meneur voit ses coéquipiers en contour à travers le décor, à 30 studs
local outlines = {}
local function updateOutlines()
	local isLeader = player:GetAttribute("role") == "Leader" and not player:GetAttribute("isDead")
	local myRoot = Util.characterRoot(player)
	local range = PlayerConfig.Abilities.Leader.OutlineRange
	for _, other in Players:GetPlayers() do
		if other ~= player then
			local character = other.Character
			local otherRoot = Util.characterRoot(other)
			local show = isLeader and myRoot and otherRoot and (otherRoot.Position - myRoot.Position).Magnitude <= range
			local highlight = outlines[other]
			if show and character and (highlight == nil or highlight.Parent ~= character) then
				highlight = Instance.new("Highlight")
				highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				highlight.FillTransparency = 1
				highlight.Parent = character
				outlines[other] = highlight
			elseif not show and highlight then
				highlight:Destroy()
				outlines[other] = nil
			end
		end
	end
end

local function update()
	updateOutlines()
	if ui.Crosshair then
		ui.Crosshair.Visible = controllers.InputController ~= nil and controllers.InputController:IsAiming()
	end
	if ui.FearVignette then
		-- 15.1 : transparence en fondu entre la valeur réglée et 1
		local fear = (player:GetAttribute("fear") or 0) / PlayerConfig.Fear.Max
		local minT = PlayerConfig.Interface.FearVignetteMinTransparency
		ui.FearVignette.ImageTransparency = 1 - fear * (1 - minT)
	end
	if not hidden and os.clock() - lastChange > PlayerConfig.Interface.HudFadeAfter then
		hidden = true
		for _, name in FADING do
			if ui[name] then
				ui[name].Visible = false
			end
		end
	end
end

function HUDController:Init(all)
	controllers = all
end

function HUDController:Start()
	local gui = Util.waitGui("HUDGui")
	if gui == nil then
		return
	end
	root = gui.Parent
	ui.limbs = {}
	for _, limb in PlayerConfig.Limbs do
		ui.limbs[limb] = find("BodyStatus/" .. limb)
	end
	for _, name in { "BodyStatus", "BleedIcon", "Stamina", "Battery", "Ammo", "HeldItem", "Crosshair", "FearVignette" } do
		ui[name] = find(name)
	end
	local watched = { "bleed", "stamina", "lightBattery", "heldItem", "ammo", "ammoReserve", "role" }
	for _, limb in PlayerConfig.Limbs do
		table.insert(watched, "hp" .. limb)
	end
	for _, name in watched do
		player:GetAttributeChangedSignal(name):Connect(function()
			touch()
			HUDController:Refresh()
		end)
	end
	touch()
	self:Refresh()
	RunService.RenderStepped:Connect(update)
end

return HUDController
