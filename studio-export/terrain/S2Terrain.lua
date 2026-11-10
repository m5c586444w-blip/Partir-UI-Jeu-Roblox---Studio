--[[ S2Terrain : terrain du secteur S2 par blocs de 256x256, voxels de 4 studs. Copie locale : terrain/S2Terrain.lua
 Boites : 1 = A (X -1000..1400, Z -4000..-200), 2 = B (X 1400..1500, Z -4000..-2500).
 M.Construire(b, cx, cz) ; M.NbChunks(b) ; M.NettoyerBoite(b) (jamais Terrain:Clear) ; M.Raccord() reecrit 2 bandes de S3. ]]
local D = require(script.Parent.S2Donnees)
local S3 = require(script.Parent.S3Donnees)
local Mix = require(script.Parent.MelangeMateriaux)
local C = D.Cfg
local clamp = math.clamp
local Mat = Enum.Material
local M = {}
local N = 256
local YBAS, YHAUT = -40, 1000
M.Boites = { { XMin = C.XMin, XMax = C.XMax, ZMin = C.ZMin, ZMax = C.ZMax }, C.BoiteB }

function M.NbChunks(b)
	local B = M.Boites[b]
	return math.ceil((B.XMax - B.XMin) / N), math.ceil((B.ZMax - B.ZMin) / N)
end
function M.NettoyerBoite(b)
	local B = M.Boites[b]
	local nx, nz = M.NbChunks(b)
	for cx = 0, nx - 1 do
		for cz = 0, nz - 1 do
			local x0, z0 = B.XMin + cx * N, B.ZMin + cz * N
			local lx, lz = math.min(N, B.XMax - x0), math.min(N, B.ZMax - z0)
			workspace.Terrain:FillBlock(CFrame.new(x0 + lx / 2, (YBAS + YHAUT) / 2, z0 + lz / 2), Vector3.new(lx, YHAUT - YBAS, lz), Mat.Air)
		end
		task.wait()
	end
end

local function fbm(X, Z, s, o)
	return 2 * (Mix.Bord(X, Z, s, o) * 0.55 + Mix.Bord(X, Z, s * 0.5, o + 3.1) * 0.3 + Mix.Bord(X, Z, s * 0.25, o + 7.7) * 0.15)
end
local function cendre(X, Z, c)
	local a, b = fbm(X, Z, 45, 3.3), fbm(X, Z, 12, 7.1)
	if c.pente > 0.9 then return Mat.Rock end
	if c.pente > 0.6 then return (b > -0.1) and Mat.Rock or Mat.Basalt end
	if c.fleurs and fbm(X, Z, 16, 9.9) > 0.55 then return Mat.Grass end
	if b > 0.62 then return Mat.Rock end
	if a > 0.15 then return (b > 0.15) and Mat.Basalt or Mat.Slate end
	if a > -0.2 then return (b > -0.2) and Mat.Slate or Mat.Sand end
	return (b > 0.05) and Mat.Basalt or Mat.Sand
end
local function sol(X, Z, c)
	local w = c.wc
	if c.genre == nil and w > 0 then
		if w >= 0.999 or fbm(X, Z, 22, 5.5) < (w * 2 - 1) * 1.1 then return cendre(X, Z, c) end
	end
	return Mix.Sol(X, Z, c)
end

local function ecrire(x0, z0, nx, nz, col, couv, alt, cend)
	local T = workspace.Terrain
	local W = nz + 2
	local hs, gs, ws, hu, sa = {}, {}, {}, {}, {}
	local hmin, hmax = 1e9, -1e9
	for ix = 0, nx + 1 do
		for iz = 0, nz + 1 do
			local X, Z = x0 + 4 * (ix - 1) + 2, z0 + 4 * (iz - 1) + 2
			local h, genre, eau, _, hum, sable = col(X, Z)
			local k = ix * W + iz
			hs[k], gs[k], ws[k], hu[k], sa[k] = h, genre, eau, hum, sable
			if ix >= 1 and ix <= nx and iz >= 1 and iz <= nz then
				if h < hmin then hmin = h end
				if h > hmax then hmax = h end
			end
		end
	end
	local y0 = math.floor((hmin - 24) / 4) * 4
	local ny = math.ceil((hmax + 4 - y0) / 4)
	local Air, Water = Mat.Air, Mat.Water
	local Ms, Os = {}, {}
	for ix = 1, nx do
		local Mx, Ox = {}, {}
		for iy = 1, ny do Mx[iy] = table.create(nz, Air); Ox[iy] = table.create(nz, 0) end
		for iz = 1, nz do
			local k = ix * W + iz
			local h, genre, wt = hs[k], gs[k], ws[k]
			local X, Z = x0 + 4 * (ix - 1) + 2, z0 + 4 * (iz - 1) + 2
			local sx = (hs[k + W] - hs[k - W]) / 8
			local sz = (hs[k + 1] - hs[k - 1]) / 8
			local c = { genre = genre, pente = math.sqrt(sx * sx + sz * sz), h = h, hum = hu[k], sable = sa[k], couvert = couv(X, Z), altRoche = alt(Z) }
			c.wc = cend and D.WCendre(X, Z) or 0
			c.fleurs = c.wc > 0.5 and D.WPlateau(X, Z) > 0.5
			local m = sol(X, Z, c)
			local lit = wt and Mix.Lit(X, Z, c)
			for iy = 1, ny do
				local yb = y0 + 4 * (iy - 1)
				if yb >= h and (not wt or yb >= wt) then break end
				if yb < h then
					local oc = clamp((h - yb) / 4, 0, 1)
					if wt and wt >= yb + 4 then oc = 1 end
					local mm = Mix.Voxel(X, yb, Z, c, m)
					if wt and yb >= h - 8 then mm = lit end
					if wt and yb + 4 > h and wt > yb + 1.5 then -- derniere cellule solide sous l'eau : devient eau (sinon une eau mince disparait)
						Mx[iy][iz] = Water
						Ox[iy][iz] = clamp((wt - yb) / 4, 0, 1)
					else
						Mx[iy][iz] = mm
						Ox[iy][iz] = oc
					end
				else
					Mx[iy][iz] = Water
					Ox[iy][iz] = clamp((wt - yb) / 4, 0, 1)
				end
			end
		end
		Ms[ix], Os[ix] = Mx, Ox
	end
	T:WriteVoxels(Region3.new(Vector3.new(x0, y0, z0), Vector3.new(x0 + 4 * nx, y0 + 4 * ny, z0 + 4 * nz)), 4, Ms, Os)
end

function M.Construire(b, cx, cz)
	local B = M.Boites[b]
	local x0, z0 = B.XMin + cx * N, B.ZMin + cz * N
	local nx, nz = math.min(N, B.XMax - x0) // 4, math.min(N, B.ZMax - z0) // 4
	if nx <= 0 or nz <= 0 then return end
	ecrire(x0, z0, nx, nz, D.Colonne, D.Couvert, D.AltRoche, true)
end

function M.Raccord()
	for _, r in ipairs(D.BandesS3) do
		ecrire(r[1], r[2], (r[3] - r[1]) // 4, (r[4] - r[2]) // 4, D.Corr3, S3.Couvert, S3.AltRoche, false)
		task.wait()
	end
end

return M
