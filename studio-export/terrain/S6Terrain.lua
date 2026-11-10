--[[ S6Terrain : ecrit le terrain du secteur S6 (X -4000..1400, Z 2500..4000) par blocs de 256x256 studs, voxels de 4 studs.
 M.Construire(cx, cz) : cx 0..NbX-1, cz 0..NbZ-1. M.Nettoyer() vide UNIQUEMENT la boite de S6 (jamais Terrain:Clear()). ]]
local D = require(script.Parent.S6Donnees)
local Mix = require(script.Parent.MelangeMateriaux)
local C = D.Cfg
local clamp = math.clamp
local Mat = Enum.Material
local M = {}
local N = 256
M.NbX = math.ceil((C.XMax - C.XMin) / N)
M.NbZ = math.ceil((C.ZMax - C.ZMin) / N)

function M.Nettoyer()
	local T = workspace.Terrain
	local x0, x1, z0, z1 = C.XMin, C.XMax, C.ZMin, C.ZMax
	T:FillBlock(CFrame.new((x0 + x1) / 2, 200, (z0 + z1) / 2), Vector3.new(x1 - x0, 800, z1 - z0), Mat.Air)
end

local function ecrire(colonne, couvert, x0, z0, nx, nz)
	local T = workspace.Terrain
	local W = nz + 2
	local hs, gs, ws, hu, sa = {}, {}, {}, {}, {}
	local hmin, hmax = 1e9, -1e9
	for ix = 0, nx + 1 do
		for iz = 0, nz + 1 do
			local X, Z = x0 + 4 * (ix - 1) + 2, z0 + 4 * (iz - 1) + 2
			local h, genre, eau, _, hum, sable = colonne(X, Z)
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
			local c = { genre = genre, pente = math.sqrt(sx * sx + sz * sz), h = h, hum = hu[k], sable = sa[k], couvert = couvert(X, Z), altRoche = 330 }
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
	T:WriteVoxels(Region3.new(Vector3.new(x0, y0, z0), Vector3.new(x0 + 4 * nx, y0 + 4 * ny, z0 + 4 * nz)), 4, Ms, Os)
end

function M.Construire(cx, cz)
	local x0, z0 = C.XMin + cx * N, C.ZMin + cz * N
	local nx, nz = math.min(N, C.XMax - x0) // 4, math.min(N, C.ZMax - z0) // 4
	if nx <= 0 or nz <= 0 then return end
	ecrire(D.Colonne, D.Couvert, x0, z0, nx, nz)
end

-- Reecriture de la bande sud de S4 (Z 2400..2500, X>=-792) : S4 y avait pose un rabais PROVISOIRE de 30 studs ("S5/S6 reprendront H pur").
-- On retire w(X) de ce rabais (w : 0 a X=-790 -> 1 a X=-590) pour que S6 n'ait pas a creuser une tranchee. Meme code materiaux que S4Terrain.
local D4 = require(script.Parent.S4Donnees)
local D5 = require(script.Parent.S5Donnees)
M.BandeX0, M.BandeNb = -1300, math.ceil((C.XMax + 1300) / N) -- autorise par Gabriel pour X -1300..-790 (coin S5)
function M.ReecrireBandeS4(i)
	local x0 = M.BandeX0 + i * N
	local nx = math.min(N, C.XMax - x0) // 4
	if nx <= 0 then return end
	local function col(X, Z)
		local h, genre, eau, d, hum, sable = D5.Colonne(X, Z) -- S5 (SudChute=0 : H pur) pour X<-1000, S4 au-dela
		if X >= -1000 then -- rabais de S4 (SudChute 30) a retirer
			local t = math.clamp((Z - 2400) / 100, 0, 1)
			t = t * t * (3 - 2 * t)
			local s = math.clamp((X - 1200) / 150, 0, 1)
			s = 1 - s * s * (3 - 2 * s)
			h += 30 * (t * s) ^ 2
		end
		if X > 150 and X < 310 then h, genre = D.AppliquerSentierPoste(h, genre, X, Z) end
		return h, genre, eau, d, hum, sable
	end
	ecrire(col, D5.Couvert, x0, 2400, nx, 25)
end

-- Sentiers prolonges dans S4 / S5 (bandes etroites, memes colonnes que le builder du secteur + sentier) -----------------
local function bande(colBase, couv, x0, z0, nx, nz, appl)
	local function col(X, Z)
		local h, genre, eau, d, hum, sable = colBase(X, Z)
		h, genre = appl(h, genre, X, Z)
		return h, genre, eau, d, hum, sable
	end
	ecrire(col, couv, x0, z0, nx, nz)
end
-- sentier d'Ape Cave : X -2480..-2400, Z 2380..2500 (boite de S5)
function M.EcrireSentierCave() bande(D5.Colonne, D5.Couvert, -2480, 2380, 20, 30, D.AppliquerSentierCave) end
-- sentier du poste : X 176..256, Z 1480..2400 (boite de S4 ; Z 2400..2500 est ecrit par la bande), i = 0..3
function M.EcrireSentierPoste(i)
	local z0 = 1480 + i * 256
	bande(D4.Colonne, D4.Couvert, 176, z0, 20, math.min(64, (2400 - z0) // 4), D.AppliquerSentierPoste)
end

return M
