--[[ Raccords_EST (A1 phase B, tache 2) : coutures du cote EST (S3, S7, S8) avec le terrain voisin deja construit (S4, S6, S2).
 MODULE DE POST-TRAITEMENT, a lancer en DERNIER (apres S7 -> S3 -> S8 "M" -> S8 "O" et apres tout autre module qui reecrit des chunks EST).
 Il NE MODIFIE PAS S3Donnees / S7Donnees / S8Donnees : il lit leur D.Colonne (donnees "de conception") et reecrit des bandes etroites de terrain.
 Il n'ecrit JAMAIS du terrain de S4, S2, S6, S5 (X < 1400, ou X < 1500 pour la marge nord).

 1. COUTURE OUEST (X = XB = 1400, Z de ZMin a ZMax) : S3 <-> S4 (Z -600..1700), S7 <-> S4 (1400..2500), S7 <-> S6 (2500..4000), S3 <-> S2 (Z < -600).
    Le terrain voisin est la reference : profil Delta(Z) = hauteur reelle du voisin (raycast en XB-Recul, moins Biais) - hauteur de conception EST prolongee en XB-Recul.
    Correction appliquee cote EST : Delta(Z) * (1 - Lisse((X - XB) / Fondu)) : nulle a X = XB + Fondu. Idempotent : le profil est recalcule depuis le voisin
    (jamais depuis le terrain EST deja corrige) et la conception est deterministe, donc relancer Appliquer() redonne le meme terrain.
 2. MARGE NORD de S3 (Z -2500..-2400, et son prolongement dans le raccord S8 Z -2560..-2440), X >= 1500 : S3Donnees descend le sol de ChuteMarge (45) sur 100 studs
    au bord Z = -2500 ; S2 (X < 1500) a deja annule cette chute. Cote EST on annule la chute sur X 1500..1500+Nord.Fondu (fondu en X) pour rejoindre S2 sans marche.
 3. JONCTIONS S7/S3 (Z 1580..1700) et S3/S8 (Z -2440) : raccord interne deja continu (S3 = S7 apres Z 1700 ; S8 = S3 puis montagne). Mesure seulement (Mesurer).
 Les couvertures d'eau : aucun cours d'eau ne traverse les bandes reecrites (verifie par Appliquer : nbEau) ; si un cas apparait, eau est decalee comme h.
 Ecriture : memes materiaux que S3Terrain / S7Terrain / S8Terrain (MelangeMateriaux), bandes de 256 studs, task.wait() entre les bandes.
 Valeurs DEFAUT PROPOSE (aucun appui chiffre dans la bible) : Fondu 240 (plage 150-300), Pas 8, Lissage 2, Biais 2.0 (mesure : raycast = conception + 1.84..2.07), Nord.Fondu 200, MaxCorr 30.
 API : M.CalibrerProfil() -> profil ; M.Delta(X,Z) ; M.AppliquerOuest() ; M.AppliquerNord() ; M.Appliquer() ; M.Mesurer() -> table, texte. ]]
local S3 = require(script.Parent.S3Donnees)
local S7 = require(script.Parent.S7Donnees)
local S8 = require(script.Parent.S8Donnees)
local Mix = require(script.Parent.MelangeMateriaux)
local clamp, floor, abs = math.clamp, math.floor, math.abs
local Mat = Enum.Material
local M = {}

M.Cfg = {
	XB = 1400,       -- frontiere ouest (S4 / S6 / S2 a gauche, EST a droite)
	Fondu = 240,     -- DEFAUT : largeur du fondu vers l'est (studs)
	Pas = 8,         -- DEFAUT : pas du profil le long de la frontiere
	Lissage = 2,     -- DEFAUT : moyenne glissante +-Lissage echantillons (+-16 studs)
	Recul = 10,      -- DEFAUT : distance a l'ouest de XB ou le voisin est lu (studs)
	Biais = 2.0,     -- mesure : raycast terrain = hauteur de conception + ~2 (rendu voxel)
	ZMin = -2400, ZMax = 4000,
	MaxCorr = 30,    -- DEFAUT : garde-fou : |Delta| borne
	Nord = { X0 = 1500, Fondu = 200, Z0 = -2560, Z1 = -2400 }, -- DEFAUT : bande nord (fondu en X)
	Bande = 256,
}
local C = M.Cfg

local function Lisse(t) t = clamp(t, 0, 1); return t * t * (3 - 2 * t) end

-- ===== raycast terrain (hauteur reelle du sol, eau ignoree) =====
local rp = RaycastParams.new()
rp.FilterType = Enum.RaycastFilterType.Include
rp.FilterDescendantsInstances = { workspace.Terrain }
rp.IgnoreWater = true
local function ray(X, Z)
	local r = workspace:Raycast(Vector3.new(X, 1300, Z), Vector3.new(0, -1500, 0), rp)
	return r and r.Position.Y
end
M.Ray = ray

-- colonne de conception de la bande ouest : S3 (Z <= 1700) puis S7, comme les builders
local function colOuest(X, Z)
	if Z <= 1700 then return S3.Colonne(X, Z) end
	return S7.Colonne(X, Z)
end
local function couvOuest(X, Z) if Z <= 1700 then return S3.Couvert(X, Z) end return S7.Couvert(X, Z) end
local function altOuest(Z) if Z <= 1700 then return S3.AltRoche(Z) end return nil end

-- ===== profil de la couture ouest =====
function M.CalibrerProfil()
	local n = floor((C.ZMax - C.ZMin) / C.Pas)
	local raw, manque = {}, 0
	for i = 0, n do
		local Z = C.ZMin + i * C.Pas
		local r = ray(C.XB - C.Recul, Z) -- reference prise a Recul studs a l'ouest : le rendu voxel de la couture n'influence plus la mesure (idempotence)
		if r then raw[i] = (r - C.Biais) - (colOuest(C.XB - C.Recul, Z)) else raw[i] = nil; manque += 1 end
	end
	for i = 0, n do -- trous : interpolation
		if raw[i] == nil then
			local a, b = i - 1, i + 1
			while a >= 0 and raw[a] == nil do a -= 1 end
			while b <= n and raw[b] == nil do b += 1 end
			if a >= 0 and b <= n then raw[i] = raw[a] + (raw[b] - raw[a]) * (i - a) / (b - a) elseif a >= 0 then raw[i] = raw[a] elseif b <= n then raw[i] = raw[b] else raw[i] = 0 end
		end
	end
	local D, mx = {}, 0
	for i = 0, n do
		local s, c = 0, 0
		for j = math.max(0, i - C.Lissage), math.min(n, i + C.Lissage) do s += raw[j]; c += 1 end
		D[i] = clamp(s / c, -C.MaxCorr, C.MaxCorr)
		mx = math.max(mx, abs(D[i]))
	end
	return { Z0 = C.ZMin, Pas = C.Pas, N = n, D = D, Max = mx, Manquants = manque }
end

local profil -- profil courant (calcule par AppliquerOuest)
local function deltaZ(Z)
	if not profil then return 0 end
	local u = clamp((Z - profil.Z0) / profil.Pas, 0, profil.N - 1e-6)
	local i = floor(u)
	return profil.D[i] + (profil.D[i + 1] - profil.D[i]) * (u - i)
end

-- ===== marge nord : annulation de la chute de S3 pour X >= Nord.X0 =====
local function deltaNord(X, Z)
	local N = C.Nord
	if Z >= N.Z1 or X < N.X0 or X >= N.X0 + N.Fondu then return 0 end
	local tn = 1 - Lisse((Z - S3.Cfg.ZMin) / S3.Cfg.Marge)
	local dip = S3.Cfg.ChuteMarge * tn * tn
	local R = S8.Cfg.Raccord
	local w = (Z < R.Z0) and Lisse((R.Z0 - Z) / (R.Z0 - R.Z1)) or 0 -- poids de la montagne dans S8.Colonne
	return dip * (1 - w) * (1 - Lisse((X - N.X0) / N.Fondu))
end

-- Delta total (ouest + nord)
function M.Delta(X, Z)
	local d = 0
	if X < C.XB + C.Fondu and Z >= C.ZMin then d += deltaZ(Z) * (1 - Lisse((X - C.XB) / C.Fondu)) end
	return d + deltaNord(X, Z)
end

-- ===== ecriture d'une bande (meme algorithme que S3Terrain / S7Terrain / S8Terrain, + Delta) =====
local function ecrire(x0, z0, nx, nz, colf, couv, altr, delta)
	local T = workspace.Terrain
	local W = nz + 2
	local hs, gs, ws, hu, sa = {}, {}, {}, {}, {}
	local hmin, hmax, nbEau, cmax = 1e9, -1e9, 0, 0
	for ix = 0, nx + 1 do
		for iz = 0, nz + 1 do
			local X, Z = x0 + 4 * (ix - 1) + 2, z0 + 4 * (iz - 1) + 2
			local h, genre, eau, _, hum, sable = colf(X, Z)
			local d = delta(X, Z)
			h += d
			if eau then eau += d end
			local k = ix * W + iz
			hs[k], gs[k], ws[k], hu[k], sa[k] = h, genre, eau, hum, sable
			if ix >= 1 and ix <= nx and iz >= 1 and iz <= nz then
				if h < hmin then hmin = h end
				if h > hmax then hmax = h end
				if eau then nbEau += 1 end
				if abs(d) > cmax then cmax = abs(d) end
			end
		end
	end
	local y0 = floor((hmin - 24) / 4) * 4
	local ny = math.ceil((hmax + 4 - y0) / 4)
	local ytop = hmax + 4 + C.MaxCorr + 12
	T:FillBlock(CFrame.new(x0 + 2 * nx, (y0 + ytop) / 2, z0 + 2 * nz), Vector3.new(4 * nx, ytop - y0, 4 * nz), Mat.Air)
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
			local c = { genre = genre, pente = math.sqrt(sx * sx + sz * sz), h = h, hum = hu[k], sable = sa[k], couvert = couv(X, Z), altRoche = altr and altr(Z) or nil }
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
	return nbEau, cmax
end

function M.AppliquerOuest()
	profil = M.CalibrerProfil()
	local nbEau, cmax, nb = 0, 0, 0
	local nxc = C.Fondu // 4
	local z = C.ZMin
	while z < C.ZMax do
		local nz = math.min(C.Bande, C.ZMax - z) // 4
		-- une bande ne doit pas enjamber Z = 1700 (S3 -> S7) : la colonne est choisie cellule par cellule
		local e, c = ecrire(C.XB, z, nxc, nz, colOuest, couvOuest, altOuest, M.Delta)
		nbEau += e; cmax = math.max(cmax, c); nb += 1
		z += C.Bande
		task.wait()
	end
	return { Bandes = nb, NbEau = nbEau, CorrMax = cmax, ProfilMax = profil.Max, Manquants = profil.Manquants }
end

function M.AppliquerNord()
	local N = C.Nord
	local nxc = C.Nord.Fondu // 4
	local nz = (N.Z1 - N.Z0) // 4
	local e, c = ecrire(N.X0, N.Z0, nxc, nz, S8.Colonne, S8.Couvert, S8.AltRoche, M.Delta)
	task.wait()
	return { NbEau = e, CorrMax = c }
end

function M.Appliquer()
	local a = M.AppliquerOuest()
	local b = M.AppliquerNord()
	return { Ouest = a, Nord = b }
end

-- ===== mesures (raycast sur le terrain reel) =====
local function trier(v) table.sort(v); return v end
local function resume(nom, v)
	trier(v)
	local sup = 0
	for _, q in ipairs(v) do if q > 4 then sup += 1 end end
	return { nom = nom, n = #v, max = v[#v] or 0, med = v[math.ceil(#v / 2)] or 0, sup4 = sup }
end
local function sautX(nom, xa, xb, z0, z1, pas) -- saut |h(xb)-h(xa)| le long de Z + ecart a la pente (2e difference au pas xb-xa : discontinuite reelle)
	local v, e, g = {}, {}, xb - xa
	for Z = z0, z1, pas do
		local a0, a, b, b1 = ray(xa - g, Z), ray(xa, Z), ray(xb, Z), ray(xb + g, Z)
		if a and b then v[#v + 1] = abs(a - b) end
		if a0 and a and b and b1 then e[#e + 1] = abs((b - a) - 0.5 * ((a - a0) + (b1 - b))) end
	end
	local r = resume(nom, v)
	trier(e)
	r.excMed, r.excMax = e[math.ceil(#e / 2)] or 0, e[#e] or 0
	return r
end
local function excesZ(nom, zb, x0, x1) -- ligne Z = zb : saut +-4 et ecart a l'extrapolation lineaire (2e difference)
	local v, e = {}, {}
	for X = x0, x1, 12 do
		local a, b, c, d = ray(X, zb - 12), ray(X, zb - 4), ray(X, zb + 4), ray(X, zb + 12)
		if a and b and c and d then
			v[#v + 1] = abs(b - c)
			e[#e + 1] = abs((c - b) - 0.5 * ((b - a) + (d - c)))
		end
	end
	local r = resume(nom, v)
	trier(e)
	r.excMed, r.excMax = e[math.ceil(#e / 2)] or 0, e[#e] or 0
	return r
end

function M.Mesurer()
	local R = { X = {}, Z = {} }
	local XB = C.XB
	for _, w in ipairs({ 4, 8 }) do
		local a, b = XB - w, XB + w
		table.insert(R.X, sautX("S7-S4  +-" .. w .. " (X " .. a .. "/" .. b .. ", Z 1400..2496)", a, b, 1400, 2496, 12))
		table.insert(R.X, sautX("S7-S6  +-" .. w .. " (Z 2500..3996)", a, b, 2500, 3996, 12))
		table.insert(R.X, sautX("S3-S4  +-" .. w .. " (Z -600..1396)", a, b, -600, 1396, 12))
		table.insert(R.X, sautX("S3-S2  +-" .. w .. " (X1400, Z -2400..-604)", a, b, -2400, -604, 12))
		table.insert(R.X, sautX("NOTE S3/S8-S2 +-" .. w .. " (X1500, Z -3996..-2404) cote S2 non touche", 1500 - w, 1500 + w, -3996, -2404, 12))
	end
	for _, zb in ipairs({ 1580, 1640, 1700 }) do table.insert(R.Z, excesZ("S7/S3 Z=" .. zb, zb, 1504, 3996)) end
	for _, zb in ipairs({ -2400, -2440, -2500, -2560 }) do table.insert(R.Z, excesZ("S3/S8 Z=" .. zb, zb, 1504, 3996)) end
	for _, zb in ipairs({ -1000, 500, 2500 }) do table.insert(R.Z, excesZ("BASE (hors couture) Z=" .. zb, zb, 1504, 3996)) end
	for _, s in ipairs({ { "S4", 1400, 2496 }, { "S6", 2500, 3996 }, { "S4", -600, 1396 }, { "S2", -2400, -604 } }) do -- lignes de reference (hors couture)
		table.insert(R.X, sautX("BASE interieur " .. s[1] .. " X=1300 +-4 (Z " .. s[2] .. ".." .. s[3] .. ")", 1296, 1304, s[2], s[3], 12))
		table.insert(R.X, sautX("BASE interieur EST X=1700 +-4 (Z " .. s[2] .. ".." .. s[3] .. ")", 1696, 1704, s[2], s[3], 12))
	end
	local t = {}
	for _, r in ipairs(R.X) do t[#t + 1] = string.format("%s : n=%d max=%.1f med=%.1f >4=%d | ecart 2e diff med=%.1f max=%.1f", r.nom, r.n, r.max, r.med, r.sup4, r.excMed or 0, r.excMax or 0) end
	for _, r in ipairs(R.Z) do t[#t + 1] = string.format("%s : n=%d saut max=%.1f med=%.1f >4=%d | ecart 2e diff med=%.1f max=%.1f", r.nom, r.n, r.max, r.med, r.sup4, r.excMed, r.excMax) end
	return R, table.concat(t, "\n")
end

return M
