-- Controllers/TreeWindController (Partie)
-- Sections 12.4, 16.2, 17.1, 17.2 et 17.3 : vent dans les arbres, côté client seulement.
-- workspace.GlobalWind ne bouge pas les maillages (12.4) : les arbres sont animés par leurs os (Bone),
-- seulement près de la caméra (17.3 : Élevé 120 studs = AmbienceConfig.TreeWindRange, Ultra 200, Bas et
-- Moyen aucun), seulement si le réglage « Vent dans les arbres » est actif (17.2), et jamais sur mobile (17.1).
-- Direction et force lues dans workspace.GlobalWind (posé par WeatherService). Un arbre sans os est ignoré.
-- SettingsController pousse Enabled (réglage TreeWind) et Preset (préréglage graphique) à chaque Apply.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Config = ReplicatedStorage:WaitForChild("Config")
local AmbienceConfig = require(Config:WaitForChild("AmbienceConfig"))
local MapConfig = require(Config:WaitForChild("MapConfig"))
local ProgressionConfig = require(Config:WaitForChild("ProgressionConfig"))

local TreeWindController = {}

-- valeurs par défaut de 17.2 tant que SettingsController n'a rien poussé
local function isMobile()
	return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end
TreeWindController.Enabled = if isMobile()
	then ProgressionConfig.Settings.TreeWind.mobile
	else ProgressionConfig.Settings.TreeWind.pc
TreeWindController.Preset = if isMobile()
	then ProgressionConfig.Settings.Preset.mobile
	else ProgressionConfig.Settings.Preset.pc

local cfg = AmbienceConfig.TreeWind
local chunkSize = MapConfig.Terrain.ChunkSize
local random = Random.new()

local cache = {} -- [Model] = { bones = {Bone}, phase = number } (bones vide : arbre sans os, ignoré)
local active = {} -- [Model] = true : arbres animés en ce moment

-- vent le plus fort de 12.4 (vent de base + rafale) : sert d'échelle à l'inclinaison
local strongest = 0
for _, wind in AmbienceConfig.Wind do
	strongest = math.max(strongest, Vector3.new(table.unpack(wind.base)).Magnitude + (wind.gust or 0))
end

-- portée selon le préréglage (0 = pas d'arbres animés)
local function range()
	if isMobile() or not TreeWindController.Enabled then
		return 0
	end
	local preset = ProgressionConfig.Presets[TreeWindController.Preset]
	return preset and preset.animatedTrees or 0
end

local function entry(tree)
	local data = cache[tree]
	if data then
		return data
	end
	local bones = {}
	for _, descendant in tree:GetDescendants() do
		if descendant:IsA("Bone") then
			table.insert(bones, descendant)
		end
	end
	data = { bones = bones, phase = random:NextNumber() * 2 * math.pi }
	cache[tree] = data
	tree.Destroying:Once(function()
		cache[tree] = nil
		active[tree] = nil
	end)
	return data
end

-- remet les os d'un arbre au repos
local function rest(tree)
	local data = cache[tree]
	for _, bone in data and data.bones or {} do
		bone.Transform = CFrame.identity
	end
end

-- arbres « Tree_* » des blocs Workspace/Vegetation/Chunk_X_Z proches de la caméra, les plus proches d'abord
local function nearbyTrees(origin, reach)
	local found = {}
	local vegetation = workspace:FindFirstChild("Vegetation")
	if vegetation == nil then
		return found
	end
	local cx0 = math.floor((origin.X - reach) / chunkSize)
	local cx1 = math.floor((origin.X + reach) / chunkSize)
	local cz0 = math.floor((origin.Z - reach) / chunkSize)
	local cz1 = math.floor((origin.Z + reach) / chunkSize)
	for cx = cx0, cx1 do
		for cz = cz0, cz1 do
			local chunk = vegetation:FindFirstChild(("Chunk_%d_%d"):format(cx, cz))
			for _, tree in chunk and chunk:GetChildren() or {} do
				if tree:IsA("Model") and string.sub(tree.Name, 1, #cfg.ModelPrefix) == cfg.ModelPrefix then
					local distance = (tree:GetPivot().Position - origin).Magnitude
					if distance <= reach and #entry(tree).bones > 0 then
						table.insert(found, { tree = tree, distance = distance })
					end
				end
			end
		end
	end
	table.sort(found, function(a, b)
		return a.distance < b.distance
	end)
	return found
end

local function rescan()
	local camera = workspace.CurrentCamera
	local reach = range()
	local keep = {}
	if camera and reach > 0 then
		for index, item in nearbyTrees(camera.CFrame.Position, reach) do
			if index > cfg.MaxActiveTrees then
				break
			end
			keep[item.tree] = true
		end
	end
	for tree in active do
		if not keep[tree] then
			rest(tree)
		end
	end
	active = keep
end

local function sway(now)
	local wind = workspace.GlobalWind
	local flat = Vector3.new(wind.X, 0, wind.Z)
	if flat.Magnitude == 0 or strongest == 0 then
		return
	end
	-- axe horizontal perpendiculaire au vent : l'arbre penche dans le sens du vent
	local axis = Vector3.yAxis:Cross(flat.Unit)
	local maxAngle = math.rad(cfg.MaxSwayDegrees) * math.min(wind.Magnitude / strongest, 1)
	for tree in active do
		local data = cache[tree]
		if data then
			-- penché sous le vent, avec un balancement autour de cette position (0 à maxAngle)
			local angle = maxAngle * (0.5 + 0.5 * math.sin(now * cfg.Frequency * 2 * math.pi + data.phase))
			for _, bone in data.bones do
				local parent = bone.Parent
				-- l'axe est exprimé dans le repère de l'os au repos (sans l'animation de l'image précédente)
				local frame = if parent and parent:IsA("Bone")
					then parent.TransformedWorldCFrame * bone.CFrame
					elseif parent and parent:IsA("BasePart") then parent.CFrame * bone.CFrame
					else nil
				if frame then
					bone.Transform = CFrame.fromAxisAngle(frame:VectorToObjectSpace(axis), angle)
				end
			end
		end
	end
end

function TreeWindController:Start()
	local elapsed = 0
	RunService.RenderStepped:Connect(function(dt)
		elapsed += dt
		if elapsed >= cfg.RescanInterval then
			elapsed = 0
			rescan()
		end
		if next(active) ~= nil then
			sway(os.clock())
		end
	end)
end

return TreeWindController
