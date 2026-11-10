--[[ S5Terrain : ecrit le terrain du secteur S5 Ouest (X -4000..-860, Z -600..2500) par chunks de 256x256, voxels de 4 studs.
 M.Construire(cx, cz) : cx 0..NbX-1, cz 0..NbZ-1. M.Nettoyer() vide SEULEMENT la boite de S5 (jamais Terrain:Clear).
 Les tubes de lave (Ape Cave 7, tunnel effondre 21) sont creuses dans la meme passe : occupation = min(terrain, cavite).
 Copie locale : terrain/S5Terrain.lua. Reconstruire APRES S4. ]]
local D = require(script.Parent.S5Donnees)
local Mix = require(script.Parent.MelangeMateriaux)
local C = D.Cfg
local clamp = math.clamp
local Mat = Enum.Material
local M = {}
local N = 256
M.NbX = math.ceil((C.XMax - C.XMin) / N)
M.NbZ = math.ceil((C.ZMax - C.ZMin) / N)
local YBAS, YHAUT = -40, 640

function M.NettoyerChunk(cx, cz)
	local x0, z0 = C.XMin + cx * N, C.ZMin + cz * N
	local lx, lz = math.min(N, C.XMax - x0), math.min(N, C.ZMax - z0)
	if lx <= 0 or lz <= 0 then return end
	workspace.Terrain:FillBlock(CFrame.new(x0 + lx / 2, (YBAS + YHAUT) / 2, z0 + lz / 2), Vector3.new(lx, YHAUT - YBAS, lz), Mat.Air)
end
function M.Nettoyer()
	for cx = 0, M.NbX - 1 do
		for cz = 0, M.NbZ - 1 do M.NettoyerChunk(cx, cz) end
		task.wait()
	end
end

function M.Construire(cx, cz)
	local T = workspace.Terrain
	local x0, z0 = C.XMin + cx * N, C.ZMin + cz * N
	local nx, nz = math.min(N, C.XMax - x0) // 4, math.min(N, C.ZMax - z0) // 4
	if nx <= 0 or nz <= 0 then return end
	local W = nz + 2
	local hs, gs, ws, hu, sa = {}, {}, {}, {}, {}
	local hmin, hmax = 1e9, -1e9
	for ix = 0, nx + 1 do
		for iz = 0, nz + 1 do
			local X, Z = x0 + 4 * (ix - 1) + 2, z0 + 4 * (iz - 1) + 2
			local h, genre, eau, _, hum, sable = D.Colonne(X, Z)
			local k = ix * W + iz
			hs[k], gs[k], ws[k], hu[k], sa[k] = h, genre, eau, hum, sable
			if ix >= 1 and ix <= nx and iz >= 1 and iz <= nz then
				if h < hmin then hmin = h end
				if h > hmax then hmax = h end
			end
		end
	end
	-- tubes actifs dans ce chunk
	local tubes = {}
	local ymin = hmin - 24
	for _, Tu in pairs(D.Tubes) do
		if Tu.bx1 > x0 and Tu.bx0 < x0 + 4 * nx and Tu.bz1 > z0 and Tu.bz0 < z0 + 4 * nz then
			tubes[#tubes + 1] = Tu
			ymin = math.min(ymin, Tu.Y0 - 14)
		end
	end
	local y0 = math.floor(ymin / 4) * 4
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
			local c = { genre = genre, pente = math.sqrt(sx * sx + sz * sz), h = h, hum = hu[k], sable = sa[k], couvert = D.Couvert(X, Z), altRoche = 330 }
			local m = Mix.Sol(X, Z, c)
			local lit = wt and Mix.Lit(X, Z, c)
			local qs
			for _, Tu in ipairs(tubes) do
				local q = D.TubeConsulter(Tu, X, Z)
				if q and q.d < q.w + q.hh + 14 then qs = qs or {}; qs[#qs + 1] = q end
			end
			for iy = 1, ny do
				local yb = y0 + 4 * (iy - 1)
				if yb >= h and (not wt or yb >= wt) and not qs then break end
				if yb < h then
					local oc = clamp((h - yb) / 4, 0, 1)
					if wt and wt >= yb + 4 then oc = 1 end
					local mm = Mix.Voxel(X, yb, Z, c, m)
					if wt and yb >= h - 8 then mm = lit end
					if qs then
						for _, q in ipairs(qs) do
							local sd, ebl = D.TubeSd(q, yb + 2)
							if sd < 6 then
								mm = ebl and Mat.Rock or Mat.Basalt
								oc = math.min(oc, clamp(0.5 + sd / 4, 0, 1))
							end
						end
					end
					if oc <= 0.02 then mm, oc = Air, 0 end
					Mx[iy][iz] = mm
					Ox[iy][iz] = oc
				elseif wt and yb < wt then
					Mx[iy][iz] = Water
					Ox[iy][iz] = clamp((wt - yb) / 4, 0, 1)
				end
			end
		end
		Ms[ix], Os[ix] = Mx, Ox
	end
	T:WriteVoxels(Region3.new(Vector3.new(x0, y0, z0), Vector3.new(x0 + 4 * nx, y0 + 4 * ny, z0 + 4 * nz)), 4, Ms, Os)
end

return M
