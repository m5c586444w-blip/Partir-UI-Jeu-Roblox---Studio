--[[
 MelangeMateriaux - choisit le materiau de terrain de CHAQUE voxel par bruit fractal (plusieurs echelles + deformation
 de domaine) : taches irregulieres de ~8 a 60 studs, bords bruites, transitions en melange, jamais de ligne droite.
 Module PARTAGE (S1..S7). Copie locale : terrain/MelangeMateriaux.lua. Ne touche pas a MaterialService.
 API : M.Sol(X,Z,c), M.Voxel(X,Y,Z,c,mSurface), M.Lit(X,Z,c), M.Bord(X,Z,echelle,o)
 c = { genre, pente (tan), h, hum (0..1 proximite d'eau), couvert (0..1), altRoche (defaut 270), sable (bool) }
 genre : nil | route | route_bord | sentier | sentier_bord | lahar | laharbord | berge | gorge | aire
]]
local M = {}
M.Graine = 7.31

local noise = math.noise
local Mat = Enum.Material

local function n2(x, z, s, o) return noise(x / s + o, z / s + o * 0.37 + 11.3, M.Graine) end
local function n3(x, y, z, sx, sy, o) return noise(x / sx + o, y / sy + o * 0.61 + 3.3, z / sx + M.Graine + o * 0.29) end

-- deformation de domaine : casse les alignements
local function warp(X, Z)
	return X + 16 * n2(X, Z, 70, 1.7), Z + 16 * n2(X, Z, 70, 4.2)
end

-- bruit fractal ~[-1, 1], echelle principale s (taches de s/4 a s)
local function fbm(X, Z, s, o)
	return 2 * (n2(X, Z, s, o) * 0.55 + n2(X, Z, s * 0.5, o + 3.1) * 0.3 + n2(X, Z, s * 0.25, o + 7.7) * 0.15)
end

-- sol naturel : sous-bois (LeafyGrass), terre de foret (Ground), clairiere (Grass), roche (pente/altitude), bords d'eau
local function naturel(X, Z, c)
	local wx, wz = warp(X, Z)
	local couvert = c.couvert or 0.7
	local pente = (c.pente or 0) + 0.12 * fbm(wx, wz, 25, 9.4)
	local r = fbm(wx, wz, 9, 13.3)
	if pente > 0.95 then return Mat.Rock end
	if pente > 0.6 then
		if fbm(wx, wz, 16, 21.1) > (0.95 - pente) * 3 - 0.35 then return Mat.Rock end
		return r > 0 and Mat.Ground or Mat.LeafyGrass
	end
	local alt = (c.h or 0) + 30 * fbm(wx, wz, 200, 2.2)
	local ar = c.altRoche or 270
	if alt > ar then return (fbm(wx, wz, 30, 17.7) > -0.2) and Mat.Rock or Mat.Ground end
	local hum = (c.hum or 0) + 0.18 * fbm(wx, wz, 14, 31.4)
	if hum > 0.8 then return Mat.Mud end
	if hum > 0.6 then
		if c.sable and fbm(wx, wz, 20, 41.9) > 0.15 then return Mat.Sand end
		return r > 0.1 and Mat.Mud or Mat.Ground
	end
	local p = fbm(wx, wz, 48, 0.3)
	local q = fbm(wx, wz, 20, 5.1)
	local v = (couvert - 0.55) * 1.7 + p * 0.5 + q * 0.28
	if alt > ar - 50 and r > 0.2 then return Mat.Ground end
	if v > 0.45 then return (r > 0.75) and Mat.Ground or Mat.LeafyGrass end
	if v > 0.12 then return (r > 0.05) and Mat.LeafyGrass or Mat.Ground end
	if v > -0.2 then return (r > 0.2) and Mat.Grass or Mat.Ground end
	return (r > -0.35) and Mat.Grass or Mat.Ground
end

function M.Sol(X, Z, c)
	local g = c.genre
	if g == nil then return naturel(X, Z, c) end
	local wx, wz = warp(X, Z)
	if g == "aire" then -- aire arasee (camp, poste) : terre battue, boue et touffes d'herbe en taches
		local r = fbm(wx, wz, 14, 6.1)
		if r < -0.45 then return Mat.Mud elseif r > 0.5 then return Mat.Grass end
		return Mat.Ground
	end
	if g == "route" then return Mat.Asphalt end
	if g == "route_bord" then
		local r = fbm(wx, wz, 7, 3.3)
		if r > 0.25 then return Mat.Ground elseif r < -0.35 then return Mat.Mud end
		return naturel(X, Z, c)
	end
	if g == "sentier" then
		local r = fbm(wx, wz, 6, 8.8)
		if r < -0.75 then return Mat.Mud end
		return Mat.Ground
	end
	if g == "sentier_bord" then
		if fbm(wx, wz, 5, 12.5) > 0.05 then return Mat.Ground end
		return naturel(X, Z, c)
	end
	if g == "lahar" then
		local a, b = fbm(wx, wz, 40, 6.6), fbm(wx, wz, 11, 2.9)
		if b > 0.55 or a < -0.45 then return Mat.Rock end
		if b < -0.45 then return Mat.Basalt end
		if a > -0.05 then return Mat.Slate end
		return (b > 0) and Mat.Slate or Mat.Basalt
	end
	if g == "laharbord" then
		local a = fbm(wx, wz, 20, 1.4)
		if a > 0.2 then return Mat.Slate elseif a > -0.2 then return Mat.Ground end
		return naturel(X, Z, c)
	end
	if g == "berge" then
		local a = fbm(wx, wz, 9, 7.7)
		if a > 0.45 and c.sable then return Mat.Sand end
		if a > -0.1 then return Mat.Mud end
		return (a > -0.5) and Mat.Ground or Mat.Cobblestone
	end
	if g == "gorge" then return (n2(wx, wz, 14, 5.5) > 0.0) and Mat.Basalt or Mat.Rock end
	return naturel(X, Z, c)
end

function M.Voxel(X, Y, Z, c, mSurface)
	if c.genre == "gorge" then
		local n = n3(X, Y, Z, 15, 7, 2.2) + 0.5 * n3(X, Y, Z, 6, 3, 8.1)
		if n > 0.12 then return Mat.Basalt end
		if n < -0.45 then return Mat.Slate end
		return Mat.Rock
	end
	return mSurface
end

-- fond de ruisseau : galets, sable, boue en taches
function M.Lit(X, Z, c)
	local wx, wz = warp(X, Z)
	local a, b = fbm(wx, wz, 16, 4.4), fbm(wx, wz, 7, 9.1)
	if a > 0.25 and c.sable then return Mat.Sand end
	if b > 0.3 then return Mat.Cobblestone end
	if a < -0.35 then return Mat.Mud end
	return (b > -0.3) and Mat.Cobblestone or Mat.Ground
end

-- bruit scalaire reutilisable (bords irreguliers de chemins / berges)
function M.Bord(X, Z, echelle, o)
	return n2(X, Z, echelle or 6, o or 0)
end

return M
