--[[ S8Terrain : ecrit le terrain du coin nord-est (S8). Deux zones : "M" (montagne X 1500..4000, Z -4000..-2440) et "O" (couloir dans S3,
 X 2440..2900, Z -2440..-1380 : sentier + ruisseau de fonte). M.Construire(zone, cx, cz) ; M.Nettoyer() ne vide QUE ces deux boites (jamais Terrain:Clear).
 NB : "O" reecrit des colonnes de S3 (identiques sauf sentier/ruisseau) ; pour restaurer S3 refaire S3Terrain sur ces chunks puis Construire("O"). ]]
local D = require(script.Parent.S8Donnees)
local Mix = require(script.Parent.MelangeMateriaux)
local C = D.Cfg
local clamp = math.clamp
local Mat = Enum.Material
local M = {}
local N = 256
local Z_ = {
	M = { X0 = C.XMin, X1 = C.XMax, Z0 = C.ZMin, Z1 = C.ZMax },
	O = { X0 = C.Ov.X0, X1 = C.Ov.X1, Z0 = C.Ov.Z0, Z1 = C.Ov.Z1 },
}
M.Zones = Z_
M.Nb = {}
for k, z in pairs(Z_) do M.Nb[k] = { math.ceil((z.X1 - z.X0) / N), math.ceil((z.Z1 - z.Z0) / N) } end
local YBAS, YHAUT = 100, 1100

function M.Nettoyer(zone)
	for k, z in pairs(Z_) do
		if zone == nil or zone == k then
			for cx = 0, M.Nb[k][1] - 1 do
				local x0 = z.X0 + cx * N
				local lx = math.min(N, z.X1 - x0)
				workspace.Terrain:FillBlock(CFrame.new(x0 + lx / 2, (YBAS + YHAUT) / 2, (z.Z0 + z.Z1) / 2), Vector3.new(lx, YHAUT - YBAS, z.Z1 - z.Z0), Mat.Air)
				task.wait()
			end
		end
	end
end

function M.Construire(zone, cx, cz)
	local T = workspace.Terrain
	local z = Z_[zone]
	local x0, z0 = z.X0 + cx * N, z.Z0 + cz * N
	local nx, nz = math.min(N, z.X1 - x0) // 4, math.min(N, z.Z1 - z0) // 4
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
			local c = { genre = genre, pente = math.sqrt(sx * sx + sz * sz), h = h, hum = hu[k], sable = sa[k], couvert = D.Couvert(X, Z), altRoche = D.AltRoche(Z) }
			local m = Mix.Sol(X, Z, c)
			local lit = wt and Mix.Lit(X, Z, c)
			for iy = 1, ny do
				local yb = y0 + 4 * (iy - 1)
				if yb >= h and (not wt or yb >= wt) then break end
				if yb < h then
					local oc = clamp((h - yb) / 4, 0, 1)
					if wt and wt >= yb + 4 then oc = 1 end
					local mm = Mix.Voxel(X, yb, Z, c, m)
					if wt and yb >= h - 8 then mm = lit end
					Mx[iy][iz] = mm
					Ox[iy][iz] = oc
				else
					Mx[iy][iz] = Water
					Ox[iy][iz] = clamp((wt - yb) / 4, 0, 1)
				end
			end
		end
		Ms[ix], Os[ix] = Mx, Ox
	end
	if y0 > 100 then T:FillBlock(CFrame.new(x0 + 2 * nx, (100 + y0) / 2, z0 + 2 * nz), Vector3.new(4 * nx, y0 - 100, 4 * nz), Mat.Slate) end -- A1 : socle plein sous la bande ecrite
	T:WriteVoxels(Region3.new(Vector3.new(x0, y0, z0), Vector3.new(x0 + 4 * nx, y0 + 4 * ny, z0 + 4 * nz)), 4, Ms, Os)
end

return M
