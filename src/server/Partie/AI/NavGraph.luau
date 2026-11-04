-- ServerScriptService/AI/NavGraph (Partie)
-- Section 9.3 : graphe CreatureNav pour la simulation à distance : un nœud tous les 200 studs, plus
-- un par lieu. Des Part taguées « CreatureNav » dans Workspace/Navigation (posées à la main) s'ajoutent.
-- Les nœuds voisins (8 directions) sont reliés ; chemin par A*.
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local CreatureConfig = require(Config:WaitForChild("CreatureConfig"))
local MapConfig = require(Config:WaitForChild("MapConfig"))

local NavGraph = {}

local nodes = {} -- { position = Vector3, links = { index } }

local function groundY(x, z, fallback)
	local origin = Vector3.new(x, MapConfig.HighestPlayableY * 2, z)
	local hit = workspace:Raycast(origin, Vector3.new(0, -MapConfig.HighestPlayableY * 4, 0)) -- constante (rayon vertical assez long)
	return if hit then hit.Position.Y else fallback
end

local function build()
	local spacing = CreatureConfig.Simulation.NodeSpacing
	local half = MapConfig.PlayableHalf
	local grid = {}
	for x = -half, half, spacing do
		for z = -half, half, spacing do
			local y = groundY(x, z, MapConfig.Terrain.SouthY)
			table.insert(nodes, { position = Vector3.new(x, y, z), links = {} })
			grid[x .. ":" .. z] = #nodes
		end
	end
	for x = -half, half, spacing do
		for z = -half, half, spacing do
			local index = grid[x .. ":" .. z]
			for dx = -1, 1 do
				for dz = -1, 1 do
					local other = grid[(x + dx * spacing) .. ":" .. (z + dz * spacing)]
					if other and other ~= index then
						table.insert(nodes[index].links, other)
					end
				end
			end
		end
	end
	-- un nœud par lieu, relié aux 4 nœuds de grille les plus proches
	local extra = {}
	for _, place in MapConfig.Places do
		if place.pos and not place.outOfBounds then
			table.insert(extra, place.pos)
		end
	end
	for _, part in CollectionService:GetTagged("CreatureNav") do
		if part:IsA("BasePart") then
			table.insert(extra, part.Position)
		end
	end
	for _, position in extra do
		table.insert(nodes, { position = position, links = {} })
		local index = #nodes
		local sorted = {}
		for i = 1, index - 1 do
			table.insert(sorted, i)
		end
		table.sort(sorted, function(a, b)
			return (nodes[a].position - position).Magnitude < (nodes[b].position - position).Magnitude
		end)
		for i = 1, math.min(4, #sorted) do -- constante (4 voisins)
			table.insert(nodes[index].links, sorted[i])
			table.insert(nodes[sorted[i]].links, index)
		end
	end
end

function NavGraph:Nearest(position)
	local best, bestDistance = nil, math.huge
	for index, node in nodes do
		local d = (node.position - position).Magnitude
		if d < bestDistance then
			best, bestDistance = index, d
		end
	end
	return best
end

-- liste de positions du nœud le plus proche de `from` à celui de `to` (A*)
function NavGraph:Path(from, to)
	local start, goal = self:Nearest(from), self:Nearest(to)
	if start == nil or goal == nil then
		return { to }
	end
	local open, came, g = { [start] = true }, {}, { [start] = 0 }
	local function h(i)
		return (nodes[i].position - nodes[goal].position).Magnitude
	end
	while next(open) do
		local current, best = nil, math.huge
		for i in open do
			local f = g[i] + h(i)
			if f < best then
				current, best = i, f
			end
		end
		if current == goal then
			local path = { nodes[goal].position }
			while came[current] do
				current = came[current]
				table.insert(path, 1, nodes[current].position)
			end
			table.insert(path, to)
			return path
		end
		open[current] = nil
		for _, link in nodes[current].links do
			local cost = g[current] + (nodes[link].position - nodes[current].position).Magnitude
			if g[link] == nil or cost < g[link] then
				g[link] = cost
				came[link] = current
				open[link] = true
			end
		end
	end
	return { to }
end

function NavGraph:Init() end

function NavGraph:Start()
	task.spawn(build)
end

return NavGraph
