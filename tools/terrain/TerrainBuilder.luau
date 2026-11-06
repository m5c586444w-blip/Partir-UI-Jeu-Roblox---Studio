-- ServerStorage/TerrainBuilder (Partie) — script d'édition, lancé une seule fois en mode Edit (3.7)
-- Barre de commande de Studio :
--   require(game.ServerStorage.TerrainBuilder).Build()        -- relief, eau, matériaux, lieux, limites
--   require(game.ServerStorage.TerrainBuilder).Vegetation()   -- végétation (après import des modèles)
-- Graine fixe 1924 : la carte est identique à chaque régénération. Toutes les valeurs : MapConfig.
-- Étapes de 3.7 : 1 relief de base (collines gaussiennes + pente sud → nord), 2 bruit fractal et crêtes,
-- 3 rivières (lit 0,35 × largeur + 4, raccord 3 × largeur, fond toujours descendant), 4 gorges,
-- 5 aplanir chaque lieu (raccord 1,5 × rayon), 6 routes et sentiers (pente max 8 % / 15 %),
-- 7 matériaux (pente > 40° = Rock ou Basalt, puis biomes), 8 eau (R1, R2, R3, lac P20),
-- 9 végétation (Workspace/Vegetation/Chunk_X_Z, blocs de 512 studs).
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local MapConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("MapConfig"))

local TerrainBuilder = {}

local T = MapConfig.Terrain
local CELL = T.Cell
local HALF = MapConfig.DecorHalf
local N = math.floor(2 * HALF / CELL) + 1
local VOXEL = 4 -- constante (résolution des voxels du terrain Roblox)

local height = {} -- [i][j] hauteur du sol (studs)
local material = {} -- [i][j] nom de matériau imposé (rivière, route…)
local water = {} -- [i][j] niveau d'eau, ou nil

local function toCell(v)
	return math.clamp(math.floor((v + HALF) / CELL + 0.5) + 1, 1, N)
end

local function toWorld(i)
	return (i - 1) * CELL - HALF
end

local function getH(x, z)
	return height[toCell(x)][toCell(z)]
end

-- 1. relief de base : pente douce du sud (Y ≈ 40) au nord (Y ≈ 420), plus les ancres gaussiennes
local function baseHeight(_x, z)
	local t = math.clamp((MapConfig.PlayableHalf - z) / (2 * MapConfig.PlayableHalf), 0, 1)
	return T.SouthY + (T.NorthY - T.SouthY) * t
end

local function anchors(x, z, h)
	for _, a in T.Anchors do
		local dx = (x - a.pos.X) / a.radius.X
		local dz = (z - a.pos.Y) / a.radius.Y
		local w = math.exp(-(dx * dx + dz * dz))
		h += (a.height - baseHeight(a.pos.X, a.pos.Y)) * w
	end
	return h
end

-- 2. bruit fractal : 5 octaves, période 1 600, amplitude 60, fréquence ×2 et amplitude ÷2 par octave ;
-- bruit en crêtes d'amplitude 40 sur les crêtes (ancres « Crête »)
local function noise(x, z)
	local total, period, amplitude = 0, T.Noise.period, T.Noise.amplitude
	for _ = 1, T.Noise.octaves do
		total += math.noise(x / period, z / period, T.Seed) * amplitude
		period /= 2
		amplitude /= 2
	end
	local ridge = 0
	for _, a in T.Anchors do
		if string.find(a.name, "Crête") then
			local dx = (x - a.pos.X) / a.radius.X
			local dz = (z - a.pos.Y) / a.radius.Y
			local w = math.exp(-(dx * dx + dz * dz))
			ridge += (1 - math.abs(math.noise(x / T.Noise.period, z / T.Noise.period, T.Seed + 1))) * T.Noise.ridgeAmplitude * w
		end
	end
	return total + ridge
end

-- tracé d'un chemin (3.5) : liste de points (X, Z) ; « c » = contrôles de Bézier cubique
local function resolve(point)
	if type(point) == "string" then
		local p = MapConfig.Places[point].pos
		return Vector2.new(p.X, p.Z)
	end
	return Vector2.new(point[1], point[2])
end

local function bezier(p0, p1, p2, p3, t)
	local u = 1 - t
	return p0 * u * u * u + p1 * 3 * u * u * t + p2 * 3 * u * t * t + p3 * t * t * t -- constante (Bézier cubique)
end

local function samplePath(path, step)
	local anchorsList, samples = {}, {}
	local i = 1
	local points = path.points
	while i <= #points do
		local p = points[i]
		if type(p) == "table" and p.c then
			i += 1
		else
			table.insert(anchorsList, { index = i, pos = resolve(p) })
			i += 1
		end
	end
	for k = 1, #anchorsList - 1 do
		local a, b = anchorsList[k], anchorsList[k + 1]
		local controls = {}
		for j = a.index + 1, b.index - 1 do
			table.insert(controls, Vector2.new(points[j].c[1], points[j].c[2]))
		end
		local length = (b.pos - a.pos).Magnitude
		local count = math.max(1, math.ceil(length / step))
		for s = 0, count - 1 do
			local t = s / count
			local p
			if #controls == 2 then
				p = bezier(a.pos, controls[1], controls[2], b.pos, t)
			else
				p = a.pos:Lerp(b.pos, t)
			end
			table.insert(samples, p)
		end
	end
	table.insert(samples, anchorsList[#anchorsList].pos)
	return samples
end

local function widthAt(path, f)
	if path.widths then
		local w = path.widths
		local x = f * (#w - 1) + 1
		local lo = math.floor(x)
		local hi = math.min(#w, lo + 1)
		return w[lo] + (w[hi] - w[lo]) * (x - lo)
	end
	return path.width
end

-- applique une hauteur cible sur une bande (largeur), raccordée sur `blend`
local function stamp(center, halfWidth, blend, target, mat)
	local reach = halfWidth + blend
	for i = toCell(center.X - reach), toCell(center.X + reach) do
		for j = toCell(center.Y - reach), toCell(center.Y + reach) do
			local d = (Vector2.new(toWorld(i), toWorld(j)) - center).Magnitude
			if d <= halfWidth then
				height[i][j] = target
				if mat then
					material[i][j] = mat
				end
			elseif d <= reach then
				local w = 1 - (d - halfWidth) / blend
				height[i][j] = height[i][j] + (target - height[i][j]) * w * w
			end
		end
	end
end

local function buildHeights()
	for i = 1, N do
		height[i], material[i], water[i] = {}, {}, {}
		local x = toWorld(i)
		for j = 1, N do
			local z = toWorld(j)
			height[i][j] = anchors(x, z, baseHeight(x, z)) + noise(x, z)
		end
		if i % 64 == 0 then -- constante (pause pour ne pas figer Studio)
			task.wait()
		end
	end
end

-- 4. gorges : Ape Canyon (150, de (2 300, −600) à (3 000, −2 200)) ; Lava Canyon (70, le long de R2 entre Z = 1 600 et 2 600)
-- 19.5 (C40) : profil en trapèze — largeur `top` au bord, `bottom` au fond ; parois à plus de 60°
local function carveGorge(center, top, bottom, rimY, depth, mat)
	local floor = rimY - depth
	local halfTop, halfBottom = top / 2, math.min(bottom, top) / 2
	for i = toCell(center.X - halfTop), toCell(center.X + halfTop) do
		for j = toCell(center.Y - halfTop), toCell(center.Y + halfTop) do
			local d = (Vector2.new(toWorld(i), toWorld(j)) - center).Magnitude
			if d <= halfTop then
				local h = floor
				if d > halfBottom and halfTop > halfBottom then
					h = floor + (d - halfBottom) / (halfTop - halfBottom) * depth
				end
				if h < height[i][j] then
					height[i][j] = h
					material[i][j] = mat
				end
			end
		end
	end
end

-- contrôle : une paroi à moins de 60° est signalée (à retoucher à la main en B1)
local function checkWalls(name, top, bottom, depth)
	local run = (top - math.min(bottom, top)) / 2
	local degrees = if run <= 0 then 90 else math.deg(math.atan(depth / run)) -- constante (angle droit)
	if degrees < T.GorgeMinWallDegrees then
		warn(("TerrainBuilder : parois de %s à %.0f° (< %d°)"):format(name, degrees, T.GorgeMinWallDegrees))
	end
end

-- 3.2 : Y d'un lieu « fond de gorge » = le fond ; on relève le bord de la profondeur de la gorge avant de creuser
local function pinGorgeRims()
	for code, gorge in T.GorgeFloorPlaces do
		local place = MapConfig.Places[code]
		local center = Vector2.new(place.pos.X, place.pos.Z)
		stamp(center, T.GorgeRimPinRadius, T.GorgeRimPinBlend, place.pos.Y + T.Gorges[gorge].depth)
	end
end

local function buildGorges()
	local ape = T.Gorges.ApeCanyon
	checkWalls("Ape Canyon", ape.topWidth, ape.bottomWidth, ape.depth)
	-- resserrement à P05s : la largeur passe de topWidth à narrowWidth sur GorgeNarrowTaperFactor × topWidth
	local narrow = MapConfig.Places[ape.narrowAt]
	local narrowPoint = Vector2.new(narrow.pos.X, narrow.pos.Z)
	local axis = (ape.to - ape.from).Unit
	local narrowT = (narrowPoint - ape.from):Dot(axis)
	local taper = ape.topWidth * T.GorgeNarrowTaperFactor
	-- les hauteurs du bord sont lues avant de creuser (sinon chaque point creuserait sous le précédent)
	local cuts = {}
	local count = math.ceil((ape.to - ape.from).Magnitude / CELL)
	for k = 0, count do
		local p = ape.from:Lerp(ape.to, k / count)
		local along = math.abs((p - ape.from):Dot(axis) - narrowT)
		local w = math.clamp(along / taper, 0, 1)
		local top = ape.narrowWidth + (ape.topWidth - ape.narrowWidth) * w
		table.insert(
			cuts,
			{ at = p, top = top, bottom = math.min(ape.bottomWidth, top), rim = getH(p.X, p.Y), depth = ape.depth }
		)
	end
	local lava = T.Gorges.LavaCanyon
	checkWalls("Lava Canyon", lava.topWidth, lava.bottomWidth, lava.depth)
	for _, p in samplePath(MapConfig.Paths[lava.path], CELL) do
		if p.Y >= lava.fromZ and p.Y <= lava.toZ then
			table.insert(
				cuts,
				{ at = p, top = lava.topWidth, bottom = lava.bottomWidth, rim = getH(p.X, p.Y), depth = lava.depth }
			)
		end
	end
	for _, c in cuts do
		carveGorge(c.at, c.top, c.bottom, c.rim, c.depth, T.Materials.GorgeCliff)
	end
end

-- 5. aplanir chaque lieu sur son rayon, raccordé sur 1,5 fois le rayon
local function flattenPlaces()
	for code, place in MapConfig.Places do
		if
			place.pos
			and place.radius
			and not place.outOfBounds
			and not place.underground
			and T.GorgeFloorPlaces[code] == nil
		then
			local center = Vector2.new(place.pos.X, place.pos.Z)
			stamp(center, place.radius, place.radius * (T.FlattenBlendFactor - 1), place.pos.Y)
		end
	end
end

-- 3. rivières : lit de profondeur 0,35 × largeur + 4, raccord 3 × largeur, fond toujours descendant
local function buildRivers()
	for _, path in MapConfig.Paths do
		if path.kind == "River" then
			local samples = samplePath(path, CELL)
			local bed = math.huge
			for k, p in samples do
				local w = widthAt(path, (k - 1) / math.max(1, #samples - 1))
				local depth = T.RiverDepthFactor * w + T.RiverDepthBase
				bed = math.min(bed, getH(p.X, p.Y) - depth)
				stamp(p, w / 2, w * T.RiverBlendFactor, bed, "Ground")
				for i = toCell(p.X - w / 2), toCell(p.X + w / 2) do
					for j = toCell(p.Y - w / 2), toCell(p.Y + w / 2) do
						water[i][j] = bed + depth -- 8. eau du terrain
					end
				end
			end
		end
	end
end

-- 6. routes et sentiers : pente maximale 8 % (routes) et 15 % (sentiers) ; les lacets à part (C42)
-- hauteur imposée à un point de route : celle du lieu (3.2) qu'il traverse, sinon nil
local function pinnedHeight(point)
	for _, place in MapConfig.Places do
		if place.pos and place.radius and not place.outOfBounds and not place.underground then
			local reach = math.min(place.radius, T.RoadPinRadius)
			if (Vector2.new(place.pos.X, place.pos.Z) - point).Magnitude <= reach then
				return place.pos.Y
			end
		end
	end
	return nil
end

-- profil de hauteur d'une route ou d'un sentier : sol voisin, hauteurs des lieux traversés imposées, puis pente limitée
-- (avant, arrière, avant) sans toucher aux hauteurs imposées
local function roadProfile(samples, maxSlope)
	local h, fixed = {}, {}
	for k, p in samples do
		local pin = pinnedHeight(p)
		fixed[k] = pin ~= nil
		h[k] = pin or getH(p.X, p.Y)
	end
	local function limit(from, to, step)
		for k = from, to, step do
			if not fixed[k] then
				local d = (samples[k] - samples[k - step]).Magnitude * maxSlope
				h[k] = math.clamp(h[k], h[k - step] - d, h[k - step] + d)
			end
		end
	end
	limit(2, #samples, 1)
	limit(#samples - 1, 1, -1)
	limit(2, #samples, 1)
	return h
end

local function buildRoads()
	for _, path in MapConfig.Paths do
		if path.kind ~= "River" and path.kind ~= "Switchbacks" and (path.width or 0) > 0 then
			local maxSlope = if path.kind == "Road" then T.MaxRoadSlope else T.MaxTrailSlope
			local mat = if path.surface == "Asphalt"
				then T.Materials.Road
				elseif path.surface == "Gravel" then T.Materials.Gravel
				else T.Materials.Trail
			local samples = samplePath(path, CELL)
			local profile = roadProfile(samples, maxSlope)
			for k, p in samples do
				stamp(p, path.width / 2, path.width, profile[k], mat)
			end
		end
	end
end

-- F01 : falaise de la Crête, marche de 40 le long de Z = −800 (X de −507 à 1 800), sauf le passage X −100 à +100
local function buildCliff()
	local f = MapConfig.Places.F01
	for i = toCell(f.line.fromX), toCell(f.line.toX) do
		local x = toWorld(i)
		if x < f.passMinX or x > f.passMaxX then
			local north = toCell(f.line.z - CELL)
			local top = height[i][north]
			for j = toCell(f.line.z), toCell(f.line.z + f.height) do
				height[i][j] = math.min(height[i][j], top - f.height)
				material[i][j] = T.Materials.Cliff
			end
		end
	end
end

-- 19.5 (C42) : lacets de T3 sous F01 — segments droits, hauteur linéaire de fromY à toY sur la longueur
local function buildSwitchbacks()
	for _, path in MapConfig.Paths do
		if path.kind == "Switchbacks" then
			local points = {}
			local total = 0
			for k, p in path.points do
				points[k] = Vector2.new(p[1], p[2])
				if k > 1 then
					total += (points[k] - points[k - 1]).Magnitude
				end
			end
			local done = 0
			for k = 2, #points do
				local a, b = points[k - 1], points[k]
				local length = (b - a).Magnitude
				local count = math.max(1, math.ceil(length / CELL))
				for s = 0, count do
					local t = s / count
					local y = path.fromY + (path.toY - path.fromY) * (done + length * t) / total
					stamp(a:Lerp(b, t), path.width / 2, path.width, y, T.Materials.Trail)
				end
				done += length
			end
		end
	end
end

-- 8. lac P20 et réservoir Swift (décor, 3.8)
local function buildLakes()
	local lake = MapConfig.Places.P20
	for i = toCell(lake.pos.X - lake.ellipse.X), toCell(lake.pos.X + lake.ellipse.X) do
		for j = toCell(lake.pos.Z - lake.ellipse.Y), toCell(lake.pos.Z + lake.ellipse.Y) do
			local dx = (toWorld(i) - lake.pos.X) / lake.ellipse.X
			local dz = (toWorld(j) - lake.pos.Z) / lake.ellipse.Y
			if dx * dx + dz * dz <= 1 then
				water[i][j] = lake.pos.Y
			end
		end
	end
	for i = 1, N do
		for j = toCell(T.SwiftReservoirZ), N do
			water[i][j] = T.ReservoirLevel
			height[i][j] = math.min(height[i][j], T.ReservoirLevel - CELL)
		end
	end
end

-- 7. matériau d'une colonne : pente > 40° = Rock (Basalt dans les gorges), puis biome (3.6)
local function biomeMaterial(x, z)
	for _, biome in MapConfig.Biomes do
		for _, code in biome.places or {} do
			local place = MapConfig.Places[code]
			if place.zone then
				local zz = place.zone
				if x >= zz.minX and x <= zz.maxX and z >= zz.minZ and z <= zz.maxZ then
					return biome.materials[1]
				end
			elseif place.corridor then
				local c = place.corridor
				local a, b = c.from, c.to
				local p = Vector2.new(x, z)
				local t = math.clamp((p - a):Dot(b - a) / (b - a):Dot(b - a), 0, 1)
				if (p - (a + (b - a) * t)).Magnitude <= c.width / 2 then
					return biome.materials[1]
				end
			elseif
				place.pos
				and place.radius
				and (Vector2.new(x, z) - Vector2.new(place.pos.X, place.pos.Z)).Magnitude <= place.radius
			then
				return biome.materials[1]
			end
		end
	end
	return T.Materials.Default
end

local function columnMaterial(i, j)
	if material[i][j] then
		return material[i][j]
	end
	local h = height[i][j]
	local hx = height[math.min(N, i + 1)][j]
	local hz = height[i][math.min(N, j + 1)]
	local slope = math.deg(math.atan(math.max(math.abs(hx - h), math.abs(hz - h)) / CELL))
	if slope > T.CliffSlopeDegrees then
		return T.Materials.Cliff
	end
	return biomeMaterial(toWorld(i), toWorld(j))
end

-- écriture des voxels, bloc par bloc
local function writeTerrain()
	local terrain = workspace.Terrain
	terrain:SetMaterialColor(Enum.Material.Sand, T.Materials.AshColor) -- Sand recoloré gris cendre (3.6)
	local chunk = T.WriteChunk
	for x0 = -HALF, HALF - 1, chunk do
		for z0 = -HALF, HALF - 1, chunk do
			local minY, maxY = math.huge, -math.huge
			for x = x0, x0 + chunk - 1, CELL do
				for z = z0, z0 + chunk - 1, CELL do
					local i, j = toCell(x), toCell(z)
					minY = math.min(minY, height[i][j])
					maxY = math.max(maxY, height[i][j], water[i][j] or -math.huge)
				end
			end
			local columnBottom = math.floor((minY - CELL * 2) / VOXEL) * VOXEL
			local columnTop = math.ceil((maxY + VOXEL) / VOXEL) * VOXEL
			-- tranches verticales : WriteVoxels refuse les régions trop hautes (reliefs de plusieurs centaines de studs)
			for bottom = columnBottom, columnTop - 1, T.WriteSlab do
				local top = math.min(bottom + T.WriteSlab, columnTop)
				local region = Region3.new(Vector3.new(x0, bottom, z0), Vector3.new(x0 + chunk, top, z0 + chunk))
					:ExpandToGrid(VOXEL)
				local size = region.Size / VOXEL
				local mats, occ = {}, {}
				for xi = 1, size.X do
					mats[xi], occ[xi] = {}, {}
					local x = region.CFrame.Position.X - region.Size.X / 2 + (xi - 0.5) * VOXEL
					for yi = 1, size.Y do
						mats[xi][yi], occ[xi][yi] = {}, {}
					end
					for zi = 1, size.Z do
						local z = region.CFrame.Position.Z - region.Size.Z / 2 + (zi - 0.5) * VOXEL
						local i, j = toCell(x), toCell(z)
						local ground = height[i][j]
						local level = water[i][j]
						local mat = Enum.Material[columnMaterial(i, j)] or Enum.Material.Grass
						for yi = 1, size.Y do
							local y = bottom + (yi - 0.5) * VOXEL
							if y <= ground then
								mats[xi][yi][zi] = mat
								occ[xi][yi][zi] = 1
							elseif level and y <= level then
								mats[xi][yi][zi] = Enum.Material.Water
								occ[xi][yi][zi] = 1
							else
								mats[xi][yi][zi] = Enum.Material.Air
								occ[xi][yi][zi] = 0
							end
						end
					end
				end
				terrain:WriteVoxels(region, VOXEL, mats, occ)
				task.wait()
			end
		end
		print(("TerrainBuilder : colonne X = %d écrite"):format(x0))
	end
end

-- J2 : un bloc gris étiqueté par lieu (Workspace/Places/Pxx_<Nom>)
local function placeBlocks()
	local places = workspace:FindFirstChild("Places") or Instance.new("Folder")
	places.Name = "Places"
	places.Parent = workspace
	for code, place in MapConfig.Places do
		if place.pos and not place.outOfBounds then
			local clean = string.gsub(place.name, "[^%w]", "")
			local folder = places:FindFirstChild(code .. "_" .. clean) or Instance.new("Folder")
			folder.Name = code .. "_" .. clean
			folder.Parent = places
			local block = Instance.new("Part")
			block.Name = code
			block.Anchored = true
			block.Size = Vector3.one * T.PlaceBlockSize
			block.Color = Color3.fromRGB(128, 128, 128) -- constante (bloc gris)
			block.Position = place.pos + Vector3.new(0, T.PlaceBlockSize / 2, 0)
			block.Parent = folder
		end
	end
end

-- 3.8 : mur invisible à ±4 000 (le message à ±3 900 est affiché par BoundaryController)
local function walls()
	local folder = Instance.new("Folder")
	folder.Name = "Limits"
	folder.Parent = workspace
	local half = MapConfig.PlayableHalf
	local size = 2 * half
	for _, spec in
		{
			{ Vector3.new(half, 0, 0), Vector3.new(1, T.WallHeight, size) },
			{ Vector3.new(-half, 0, 0), Vector3.new(1, T.WallHeight, size) },
			{ Vector3.new(0, 0, half), Vector3.new(size, T.WallHeight, 1) },
			{ Vector3.new(0, 0, -half), Vector3.new(size, T.WallHeight, 1) },
		}
	do
		local wall = Instance.new("Part")
		wall.Anchored = true
		wall.Transparency = 1
		wall.Position = spec[1] + Vector3.new(0, T.WallHeight / 2, 0)
		wall.Size = spec[2]
		wall.Parent = folder
	end
end

-- relief complet en mémoire (tableaux height / material / water), sans écrire les voxels
local function compute()
	buildHeights()
	pinGorgeRims()
	buildGorges()
	buildRivers()
	flattenPlaces()
	buildRoads()
	buildCliff()
	buildSwitchbacks()
	buildLakes()
end

function TerrainBuilder.Build()
	local started = os.clock()
	workspace.Terrain:Clear()
	print("TerrainBuilder : relief")
	compute()
	print("TerrainBuilder : écriture du terrain")
	writeTerrain()
	placeBlocks()
	walls()
	print(("TerrainBuilder : terminé en %d s"):format(os.clock() - started))
end

-- contrôle sans écriture : hauteur calculée au point exact de chaque lieu (3.2) comparée à la colonne Y du tableau
function TerrainBuilder.Measure()
	compute()
	local lines = {}
	for code, place in MapConfig.Places do
		if place.pos and not place.outOfBounds then
			local got = getH(place.pos.X, place.pos.Z)
			table.insert(
				lines,
				("%s attendu %d calculé %.0f%s"):format(
					code,
					place.pos.Y,
					got,
					if math.abs(got - place.pos.Y) <= T.PlaceTolerance then "" else "  <-- ÉCART"
				)
			)
		end
	end
	table.sort(lines)
	return table.concat(lines, "\n")
end

-- 9. végétation : répartition aléatoire (graine 1924), distance minimale, rotation libre, échelle ±15 %,
-- rangée dans Workspace/Vegetation/Chunk_X_Z (blocs de 512) ; plafond global 20 000 ; LOD au-delà de 700 studs.
-- Modèles attendus dans ServerStorage/Vegetation (noms de 13.3, ex. Tree_DouglasFir_A) ; sans eux : rien.
local function groundAt(x, z)
	local top = MapConfig.HighestPlayableY * 2 -- constante (au-dessus du point le plus haut)
	local hit = workspace:Raycast(Vector3.new(x, top, z), Vector3.new(0, -top * 2, 0))
	return if hit then hit.Position.Y else T.SouthY
end

-- 3.2 : réseau d'Ape Cave (P21 → P07b → P07a → P07c), creusé dans le terrain déjà écrit (MapConfig.ApeCave)
local function terrainSurface(x, z)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = { workspace.Terrain }
	local top = MapConfig.HighestPlayableY * 2 -- constante (au-dessus du point le plus haut)
	local hit = workspace:Raycast(Vector3.new(x, top, z), Vector3.new(0, -top * 2, 0), params)
	return if hit then hit.Position.Y else T.SouthY
end

local function floorOf(code)
	local place = MapConfig.Places[code]
	return place.tubeY or place.pos.Y
end

-- un tronçon d'arche à sol plat entre deux points du plancher : boîte, puis demi-cylindre posé dessus
local function fillSection(a, b, width, boxHeight, fill)
	local cave = MapConfig.ApeCave
	local terrain = workspace.Terrain
	local length = (b - a).Magnitude + cave.overlap
	local base = CFrame.lookAt((a + b) / 2, b)
	terrain:FillBlock(base * CFrame.new(0, boxHeight / 2, 0), Vector3.new(width, boxHeight, length), fill)
	terrain:FillCylinder(base * CFrame.new(0, boxHeight, 0) * CFrame.Angles(math.pi / 2, 0, 0), length, width / 2, fill)
end

function TerrainBuilder.Caves()
	local cave = MapConfig.ApeCave
	local terrain = workspace.Terrain
	local Air, count = Enum.Material.Air, 0
	local function point(code)
		local place = MapConfig.Places[code]
		return Vector3.new(place.pos.X, floorOf(code), place.pos.Z)
	end
	-- tubes entre les lieux ; points du plancher décalés pour la partie haute (parois accidentées)
	local plugAt, plugDir
	for k = 1, #cave.route - 1 do
		local from, to = point(cave.route[k]), point(cave.route[k + 1])
		local section = cave[cave.sections[k]]
		local direction = (to - from) * Vector3.new(1, 0, 1)
		local side = Vector3.new(-direction.Z, 0, direction.X).Unit
		local pieces = math.max(1, math.ceil((to - from).Magnitude / cave.step))
		local previous = from
		local rockfall = {}
		for _, fraction in cave.rockfalls.fractions do
			if k == 1 then
				table.insert(rockfall, math.floor(fraction * pieces))
			end
		end
		for i = 1, pieces do
			local t = i / pieces
			local p = from:Lerp(to, t)
			if section.meander and i < pieces then
				local n = math.noise(i * 0.37, cave.seed, 0) -- constante (échelle du bruit)
				p += side * n * section.meander + Vector3.new(
					0,
					math.noise(0, cave.seed, i * section.floorNoiseScale) * section.floorRoughness,
					0
				)
			end
			fillSection(previous, p, section.width, section.boxHeight, Air)
			if table.find(rockfall, i) then
				local r = cave.rockfalls
				for _, offset in r.ballOffsets do
					terrain:FillBall(
						p + side * offset + Vector3.new(0, r.height - r.radius, 0),
						r.radius,
						Enum.Material[r.material]
					)
				end
			end
			previous = p
			count += 1
			if count % 20 == 0 then -- constante (pause pour ne pas figer Studio)
				task.wait()
			end
		end
		plugAt, plugDir = previous, (to - from).Unit
	end
	-- salle P07b
	local room = cave.room
	local roomPlace = MapConfig.Places[room.place]
	local roomFloor = point(room.place)
	terrain:FillCylinder(CFrame.new(roomFloor + Vector3.new(0, room.height / 2, 0)), room.height, roomPlace.radius, Air)
	-- puits P21 : vertical, du plancher du tube à la surface
	local shaft = cave.shaft
	local shaftFloor = point(shaft.place)
	local surface = terrainSurface(shaftFloor.X, shaftFloor.Z) + shaft.openLift
	terrain:FillCylinder(
		CFrame.new(shaftFloor.X, (shaftFloor.Y + surface) / 2, shaftFloor.Z),
		surface - shaftFloor.Y,
		shaft.radius,
		Air
	)
	-- entrée principale P07a : tranchée ouverte, le sol monte de sloppe vers la piste jusqu'à la surface
	local entrance = cave.entrance
	local entry = point(entrance.place)
	local target = MapConfig.Places[entrance.toward].pos
	local toward = ((target - entry) * Vector3.new(1, 0, 1)).Unit
	local lowSection = cave.Low
	for distance = 0, (MapConfig.Places[entrance.place].pos.Y - entry.Y) / entrance.slope + entrance.margin, cave.step do
		local x, z = entry.X + toward.X * distance, entry.Z + toward.Z * distance
		local ground = terrainSurface(x, z)
		local floorY = math.min(entry.Y + distance * entrance.slope, ground - 1)
		local top = math.max(floorY + lowSection.boxHeight + lowSection.width / 2, ground + entrance.openLift)
		terrain:FillBlock(
			CFrame.lookAt(
				Vector3.new(x, (floorY + top) / 2, z),
				Vector3.new(x + toward.X, (floorY + top) / 2, z + toward.Z)
			),
			Vector3.new(entrance.width, top - floorY, cave.step + cave.overlap),
			Air
		)
		if floorY >= ground - 1 then
			break
		end
	end
	-- bouchon de sédiments à l'extrémité (P07c)
	local plug = cave.plug
	local last = cave[cave.sections[#cave.sections]]
	fillSection(plugAt - plugDir * plug.length, plugAt, last.width, last.boxHeight, Enum.Material[plug.material])
	print("TerrainBuilder : Ape Cave creusée")
end

function TerrainBuilder.Vegetation()
	local source = ServerStorage:FindFirstChild("Vegetation")
	if source == nil then
		warn("TerrainBuilder : ServerStorage/Vegetation absent (modèles de 13.3 à importer en phase B)")
		return
	end
	local random = Random.new(T.Seed)
	local root = workspace:FindFirstChild("Vegetation") or Instance.new("Folder")
	root.Name = "Vegetation"
	root.Parent = workspace
	local count = 0
	local placed = {}
	local half = MapConfig.PlayableHalf
	local areaUnit = 10000 -- constante (3.6 : arbres pour 10 000 studs²)
	local cellArea = MapConfig.Terrain.ChunkSize * MapConfig.Terrain.ChunkSize
	for cx = -half, half - 1, T.ChunkSize do
		for cz = -half, half - 1, T.ChunkSize do
			local folder = Instance.new("Folder")
			folder.Name = ("Chunk_%d_%d"):format(cx // T.ChunkSize, cz // T.ChunkSize)
			folder.Parent = root
			local centerBiome = "MixedForest"
			for name, biome in MapConfig.Biomes do
				if
					biome.materials[1] == biomeMaterial(cx + T.ChunkSize / 2, cz + T.ChunkSize / 2)
					and not biome.default
				then
					centerBiome = name
				end
			end
			local biome = MapConfig.Biomes[centerBiome]
			local trees = biome.trees or {}
			local amount = math.floor(biome.treesPer10k * cellArea / areaUnit)
			for _ = 1, amount do
				if count >= MapConfig.VegetationCap or #trees == 0 then
					break
				end
				local x = cx + random:NextNumber() * T.ChunkSize
				local z = cz + random:NextNumber() * T.ChunkSize
				local ok = true
				for _, p in placed do
					if (p - Vector2.new(x, z)).Magnitude < (biome.minTreeSpacing or 0) then
						ok = false
						break
					end
				end
				local variants = {}
				for _, model in source:GetChildren() do
					if string.find(model.Name, trees[random:NextInteger(1, #trees)], 1, true) then
						table.insert(variants, model)
					end
				end
				if ok and #variants > 0 then
					local tree = variants[random:NextInteger(1, #variants)]:Clone()
					local scale = 1 + (random:NextNumber() * 2 - 1) * T.ScaleJitter
					tree:ScaleTo(scale)
					tree:PivotTo(
						CFrame.new(x, groundAt(x, z), z) * CFrame.Angles(0, random:NextNumber() * 2 * math.pi, 0)
					)
					pcall(function()
						tree.LevelOfDetail = Enum.ModelLevelOfDetail.StreamingMesh -- 3.6 (à vérifier, 19.3)
					end)
					tree.Parent = folder
					table.insert(placed, Vector2.new(x, z))
					count += 1
				end
			end
			task.wait()
		end
	end
	print(("TerrainBuilder : %d modèles de végétation posés"):format(count))
end

return TerrainBuilder
