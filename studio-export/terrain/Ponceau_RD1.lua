--[[ Ponceau_RD1 : passage voxel de R2 SOUS la route RD1 (vers (3640,3450)). Ticket A1 phase B, tache 3.
 Probleme : la plateforme de RD1 (profil lisse, pente <= 8 %) est a ~84 studs alors que le lit de R2 est a ~17 (eau a ~23) : la route est un remblai
 plein de ~100 studs de long qui coupe le ruisseau ; l'eau disparait sous l'asphalte.
 Methode : on ne reconstruit pas le terrain. Appliquer() lit les voxels d'une zone (grille 4 studs), puis, POUR CHAQUE COLONNE decidee a partir des DONNEES
 (S7Donnees : distance a l'axe de R2, Surface0 = sol SANS route, Colonne = sol AVEC route), rouvre le passage :
  - colonnes a <= DemiLargeur de l'axe et portant un remblai (Colonne - Surface0 > EpaisseurMin) : sol d'origine (lit + eau de R2 recalcules par Surface0, meme niveau
    d'eau que le ruisseau naturel), air jusqu'au plafond = ceil((niveau d'eau + LibreMin)/4)*4 + voute (marches de 4) ; si le remblai est trop bas pour une voute
    (Colonne < plafond + Paroi) : tranchee ouverte (portail) jusqu'au dessus du remblai ;
  - voute : Paroi studs de Concrete au-dessus du plafond (si remblai assez epais) ;
  - parois : colonnes entre DemiLargeur et DemiLargeur + Paroi : materiau Rock sur les cellules pleines (hauteur jusqu'a la voute + Paroi).
 La chaussee (surface Asphalt du remblai a ~84) n'est jamais touchee. Aucun asset. Aucun Terrain:Clear.
 Idempotent : tout est deduit des donnees, pas du contenu voxel precedent ; un 2e Appliquer() ne change aucune cellule (retourne 0).
 Boite autorisee : X 3390..3890, Z 3200..3700 ; la zone ecrite (Cfg.Zone) est bien a l'interieur.
 API : M.Appliquer() -> nombre de cellules modifiees ; M.Mesurer() -> table de mesures (eau sur l'axe de R2, chaussee, bords de boite).
 A relancer apres toute S7Terrain.Construire des chunks (8,7) et (8,8) (X 3448..3704, Z 3200..3704) : elle efface le ponceau.
 Ne modifie ni S7Donnees ni S7Terrain. Tous les parametres marques DEFAUT sont des propositions. ]]
local TS = script.Parent
local D = require(TS.S7Donnees)
local Mix = require(TS.MelangeMateriaux)
local Mat = Enum.Material
local clamp, floor, ceil = math.clamp, math.floor, math.ceil
local M = {}

M.Cfg = {
	Boite = { X0 = 3390, X1 = 3890, Z0 = 3200, Z1 = 3700 }, -- boite autorisee (rien n'est ecrit en dehors)
	Zone = { X0 = 3580, X1 = 3700, Z0 = 3360, Z1 = 3544 }, -- zone lue/ecrite (multiples de 4)
	YMin = 0, YMax = 112, -- plage de hauteurs de la zone (multiples de 4) : jusqu'au-dessus de la chaussee (~84-90)
	DemiLargeur = 16, -- DEFAUT : demi-largeur du passage (largeur 32 >= eau de R2 21 + berges)
	LibreMin = 6, -- DEFAUT : hauteur libre mini au-dessus de l'eau (studs) ; le plafond est arrondi au voxel superieur
	Voute = { { 8, 8 }, { 12, 4 }, { 16, 0 } }, -- DEFAUT : {distance a l'axe max, hausse du plafond} (arche en marches de 4)
	Paroi = 8, -- DEFAUT : epaisseur de la voute / des parois en materiau dur (studs)
	EpaisseurMin = 2, -- remblai minimal (Colonne - Surface0) pour qu'une colonne soit traitee
	MatVoute = Mat.Concrete, MatParoi = Mat.Rock,
	PasZ = 48, -- tranche d'ecriture (studs) : task.wait() entre les tranches
}
local C = M.Cfg

local function hausseVoute(d)
	for _, v in ipairs(C.Voute) do if d <= v[1] then return v[2] end end
	return 0
end

-- renvoie nil si la colonne n'est pas concernee, sinon d, hc, h0, eau0, base (plafond avant voute), genre et eau de Colonne (avec route)
local function colonne(X, Z)
	local R = D.R2
	local d, i, f = D.Proche(R, X, Z, C.DemiLargeur + C.Paroi + 8)
	if not d or d > C.DemiLargeur + C.Paroi then return nil end
	local hc, gc, ec = D.Colonne(X, Z)
	local h0, _, eau0 = D.Surface0(X, Z)
	if hc - h0 <= C.EpaisseurMin then return nil end
	local a, b = R.F[i], R.F[i + 1]
	local wt = a.bedC + (b.bedC - a.bedC) * f - 0.5
	return d, hc, h0, eau0, ceil((wt + C.LibreMin) / 4) * 4, gc, ec
end

function M.Appliquer()
	local T = workspace.Terrain
	local Z = C.Zone
	local Air, Water = Mat.Air, Mat.Water
	local nx, ny = (Z.X1 - Z.X0) // 4, (C.YMax - C.YMin) // 4
	local changes = 0
	for z0 = Z.Z0, Z.Z1 - 1, C.PasZ do
		local z1 = math.min(z0 + C.PasZ, Z.Z1)
		local nz = (z1 - z0) // 4
		local reg = Region3.new(Vector3.new(Z.X0, C.YMin, z0), Vector3.new(Z.X1, C.YMax, z1))
		local Ms, Os = T:ReadVoxels(reg, 4)
		local liste = {} -- cellules a modifier : {ix, iy, iz, materiau, occupation}
		local function set(ix, iy, iz, m, o)
			local m0, o0 = Ms[ix][iy][iz], Os[ix][iy][iz]
			if (o0 > 0.01 or o > 0.01) and (m0 ~= m or math.abs(o0 - o) > 0.01) then -- une cellule vide reste vide quel que soit son materiau
				liste[#liste + 1] = { ix, iy, iz, m, o }
				changes += 1
			end
		end
		for ix = 1, nx do
			for iz = 1, nz do
				local X, ZZ = Z.X0 + 4 * (ix - 1) + 2, z0 + 4 * (iz - 1) + 2
				local d, hc, h0, eau0, base, gc, ec = colonne(X, ZZ)
				if d then
					-- surface de la chaussee : S7Terrain peint le lit (galets/boue) dans les 8 studs du haut des colonnes qui portent l'eau de R2, meme sous la route ;
					-- on rend l'Asphalt a ces cellules (axe de RD1 100 % Asphalt)
					if gc == "route" and ec then
						for iy = 1, ny do
							local yb = C.YMin + 4 * (iy - 1)
							if yb >= floor((hc - 8) / 4) * 4 and yb < hc then
								local m0, o0 = Ms[ix][iy][iz], Os[ix][iy][iz]
								if m0 ~= Air and m0 ~= Water and o0 > 0.01 then set(ix, iy, iz, Mat.Asphalt, o0) end
							end
						end
					end
					local yLow = floor((h0 - 8) / 4) * 4
					if d <= C.DemiLargeur then
						local ceilTop = base + hausseVoute(d)
						local ouvert = hc < ceilTop + C.Paroi
						local cutTop = ouvert and math.max(floor(hc / 4) * 4 + 4, eau0 and ceil(eau0 / 4) * 4 or 0) or ceilTop
						local lit = eau0 and Mix.Lit(X, ZZ, { sable = false })
						for iy = 1, ny do
							local yb = C.YMin + 4 * (iy - 1)
							if yb >= yLow and yb < cutTop then
								if yb < h0 then
									local o = clamp((h0 - yb) / 4, 0, 1)
									if eau0 and eau0 >= yb + 4 then o = 1 end
									set(ix, iy, iz, (eau0 and yb >= h0 - 8) and lit or C.MatParoi, o)
								elseif eau0 and yb < eau0 then
									set(ix, iy, iz, Water, clamp((eau0 - yb) / 4, 0, 1))
								else
									set(ix, iy, iz, Air, 0)
								end
							elseif (not ouvert) and yb >= cutTop and yb < cutTop + C.Paroi then
								set(ix, iy, iz, C.MatVoute, 1)
							end
						end
					else
						local top = math.min(floor(hc / 4) * 4 + 4, base + 8 + C.Paroi)
						for iy = 1, ny do
							local yb = C.YMin + 4 * (iy - 1)
							if yb >= yLow and yb < top then
								local m0, o0 = Ms[ix][iy][iz], Os[ix][iy][iz]
								if m0 ~= Air and m0 ~= Water and o0 > 0 then set(ix, iy, iz, C.MatParoi, o0) end
							end
						end
					end
				end
			end
		end
		if #liste > 0 then
			-- WriteVoxels ignore l'eau ecrite dans une cellule qui garde une occupation residuelle : on vide d'abord, puis on ecrit
			for _, c in ipairs(liste) do Ms[c[1]][c[2]][c[3]], Os[c[1]][c[2]][c[3]] = Air, 0 end
			T:WriteVoxels(reg, 4, Ms, Os)
			for _, c in ipairs(liste) do Ms[c[1]][c[2]][c[3]], Os[c[1]][c[2]][c[3]] = c[4], c[5] end
			T:WriteVoxels(reg, 4, Ms, Os)
		end
		task.wait()
	end
	return changes
end

-- ===== mesures =====
local function lireColonne(X, Zc, ymax) -- cellules d'une colonne (X, Zc) : materiaux, occupations, y0
	local cx, cz = floor(X / 4) * 4, floor(Zc / 4) * 4
	local Ms, Os = workspace.Terrain:ReadVoxels(Region3.new(Vector3.new(cx, 0, cz), Vector3.new(cx + 4, ymax, cz + 4)), 4)
	return Ms[1], Os[1], function(iy) return 4 * (iy - 1) end
end
local function surface(Mc, Oc, n) -- hauteur et materiau de la derniere cellule solide
	for iy = n, 1, -1 do
		local m, o = Mc[iy][1], Oc[iy][1]
		if m ~= Mat.Air and m ~= Mat.Water and o > 0 then return 4 * (iy - 1) + 4 * o, m end
	end
	return 0, Mat.Air
end

local function axeX(Zv)
	local R = D.R2
	for i = 1, #R.P - 1 do
		local a, b = R.P[i], R.P[i + 1]
		if (a[2] - Zv) * (b[2] - Zv) <= 0 and a[2] ~= b[2] then return a[1] + (b[1] - a[1]) * (Zv - a[2]) / (b[2] - a[2]) end
	end
end

function M.Mesurer()
	local B = C.Boite
	local YM, n = 128, 32
	local R = { }
	-- eau sur l'axe de R2 : un echantillon tous les 4 studs
	local trous, hausses, maxHausse, prev, nEch = {}, 0, 0, nil, 0
	local clairMin, clairZ = math.huge, nil
	local niveaux = {}
	for Zv = B.Z0 + 2, B.Z1, 4 do
		local X = axeX(Zv)
		if X then
			nEch += 1
			local Mc, Oc = lireColonne(X, Zv, YM)
			local top
			for iy = n, 1, -1 do
				if Mc[iy][1] == Mat.Water and Oc[iy][1] > 0 then top = 4 * (iy - 1) + 4 * Oc[iy][1]; break end
			end
			if not top then
				trous[#trous + 1] = Zv
			else
				niveaux[#niveaux + 1] = { Zv, top }
				if prev and top > prev + 0.05 then hausses += 1; maxHausse = math.max(maxHausse, top - prev) end
				prev = top
				for iy = n, 1, -1 do -- premiere cellule pleine au-dessus de l'eau
					if Mc[iy][1] == Mat.Water and Oc[iy][1] > 0 then
						local libre = math.huge
						for j = iy + 1, n do
							if Mc[j][1] ~= Mat.Air and Mc[j][1] ~= Mat.Water and Oc[j][1] > 0 then libre = 4 * (j - 1) - top; break end
						end
						if libre < clairMin then clairMin, clairZ = libre, Zv end
						break
					end
				end
			end
		end
	end
	R.Echantillons, R.Trous, R.Hausses, R.MaxHausse, R.Niveaux = nEch, trous, hausses, maxHausse, niveaux
	R.LibreMin, R.LibreZ = clairMin, clairZ
	-- chaussee RD1 : un echantillon tous les 4 studs le long de l'axe (D.Route.P), dans la boite
	local pts, asph, nAs, penteMax, hs, cs = {}, 0, 0, 0, {}, {}
	local P = D.Route.P
	local carry = 0
	for i = 1, #P - 1 do
		local a, b = P[i], P[i + 1]
		local len = math.sqrt((b[1] - a[1]) ^ 2 + (b[2] - a[2]) ^ 2)
		local t = carry
		while t < len do
			local f = t / len
			local X, Zv = a[1] + (b[1] - a[1]) * f, a[2] + (b[2] - a[2]) * f
			if X >= B.X0 and X <= B.X1 and Zv >= B.Z0 and Zv <= B.Z1 then pts[#pts + 1] = { X, Zv } end
			t += 4
		end
		carry = t - len
	end
	for k, p in ipairs(pts) do
		local Mc, Oc = lireColonne(p[1], p[2], YM)
		local h, m = surface(Mc, Oc, n)
		hs[k] = h
		cs[k] = { floor(p[1] / 4) * 4 + 2, floor(p[2] / 4) * 4 + 2 } -- centre de la cellule lue (la pente se mesure entre centres de cellules)
		nAs += 1
		if m == Mat.Asphalt then asph += 1 end
	end
	for k = 4, #hs do
		local dx, dz = cs[k][1] - cs[k - 3][1], cs[k][2] - cs[k - 3][2]
		local dist = math.sqrt(dx * dx + dz * dz)
		if dist > 8 then penteMax = math.max(penteMax, math.abs(hs[k] - hs[k - 3]) / dist) end
	end
	R.RouteEchantillons, R.RouteAsphaltPct, R.PenteVoxelMax12 = nAs, nAs > 0 and 100 * asph / nAs or 0, penteMax
	-- pente des donnees (profil D.Route.Y, comparaison)
	local pd = 0
	for i = 2, #P do
		if P[i][1] >= B.X0 and P[i][1] <= B.X1 then
			local ds = D.Route.S[i] - D.Route.S[i - 1]
			pd = math.max(pd, math.abs(D.Route.Y[i] - D.Route.Y[i - 1]) / ds)
		end
	end
	R.PenteDonneesMax = pd
	-- saut entre la derniere cellule de la boite et la cellule voisine (4 studs) sur les 4 bords
	local function saut(fixe, horizontal, v0, v1)
		local mx = 0
		for v = v0, v1 - 1, 4 do
			local X1, Z1, X2, Z2
			if horizontal then X1, Z1, X2, Z2 = v + 2, fixe - 2, v + 2, fixe + 2 else X1, Z1, X2, Z2 = fixe - 2, v + 2, fixe + 2, v + 2 end
			local ma, oa = lireColonne(X1, Z1, YM)
			local mb, ob = lireColonne(X2, Z2, YM)
			mx = math.max(mx, math.abs(surface(ma, oa, n) - surface(mb, ob, n)))
		end
		return mx
	end
	local x0, x1, z0, z1 = floor(B.X0 / 4) * 4, floor(B.X1 / 4) * 4, floor(B.Z0 / 4) * 4, floor(B.Z1 / 4) * 4
	R.SautBords = { Ouest = saut(x0, false, z0, z1), Est = saut(x1, false, z0, z1), Nord = saut(z0, true, x0, x1), Sud = saut(z1, true, x0, x1) }
	return R
end

return M
