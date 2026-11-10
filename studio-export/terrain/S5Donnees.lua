--[[ S5Donnees : geometrie du secteur S5 Ouest (prairie 12, tour 26, cascade 13, Ape Cave 7, tunnel effondre 21, sentiers, ruisseau).
 Copie locale : terrain/S5Donnees.lua. Coordonnees MONDE (X = x-4000, Z = y-4000).
 Boite construite : X -4000..-790, Z -600..2500. Bande X -1000..-790 = D4.Colonne (S4) + sentier du camp ; X < -1000 = Surface propre.
 Raccord est : meme H, meme chaine de ruisseau (la queue de S4 est COPIEE telle quelle : D4.Ruisseau.P/S/F), memes marges nord/sud.
 !! Reconstruire S5 APRES S4 (S4 remet sa marge ouest dans la bande X -1100..-1000). ]]
local H = require(script.Parent.HauteurGlobale)
local D4 = require(script.Parent.S4Donnees)
local noise, Lisse, clamp = math.noise, H.Lisse, math.clamp
local sqrt, floor, max, min = math.sqrt, math.floor, math.max, math.min
local SEED = H.Config.Graine
local D = {}

D.Cfg = {
	XMin = -4000, XMax = -790, ZMin = -600, ZMax = 2500,
	XJonction = -1000,
	Marge = 100, ChuteMarge = 45, SudFondu = 100, SudChute = 0, -- memes valeurs que S4 (nord) ; sud : fondu provisoire
	Prairie = { X = -2200, Z = 200, Plein = 170, Fondu = 260, Adoucit = 0.8 }, -- lieu 12 : relief adouci (collines/detail x0.2)
	TourRecherche = { X = -2500, Z = 0, Rayon = 150 }, -- lieu 26 : crete la plus haute dans ce rayon
	TourPad = { Demi = 15, Fondu = 40 },
	Cuvette = 3.5,
	Gues = {}, -- passages a gue (aucun sentier ne croise le ruisseau dans S5)
	-- ruisseau : prolongement de la sortie de S4 (-1110,2260) ; coupe la crete (X -1400..-1250) puis tombe dans la cuvette (cascade 13), sort vers le sud
	ExtRuisseau = { { -1230, 2238 }, { -1330, 2226 }, { -1425, 2215 }, { -1500, 2208 }, { -1560, 2218 }, { -1595, 2255 }, { -1605, 2310 },
		{ -1605, 2380 }, { -1600, 2450 }, { -1603, 2520 }, { -1606, 2560 } },
	Cascade = { X = -1425, Z = 2215, Chute = 22, Long = 14, BedLevre = 76, BedFin = 70, Bassin = 36, Chute2 = 8, Dist2 = 120 },
	Sentier = { Demi = 2.4, Fondu = 12 }, SentierPetit = { Demi = 2.3, Fondu = 12 },
	PtsSentierCamp = { { -800, 600 }, { -960, 585 }, { -1150, 550 }, { -1350, 500 }, { -1550, 440 }, { -1750, 380 }, { -1950, 300 }, { -2100, 240 }, { -2200, 200 } },
	PtsSentierCascade = { { -2200, 200 }, { -2190, 500 }, { -2180, 800 }, { -2160, 1100 }, { -2180, 1350 }, { -2230, 1550 }, { -2250, 1750 },
		{ -2230, 1950 }, { -2180, 2080 }, { -2000, 2090 }, { -1800, 2075 }, { -1650, 2080 }, { -1560, 2105 }, { -1500, 2135 } },
	PtsSentierCave = { { -2180, 2080 }, { -2300, 2118 }, { -2400, 2170 }, { -2460, 2250 }, { -2465, 2320 }, { -2440, 2345 } },
	PtsSpur21 = { { -2250, 1780 }, { -2400, 1810 }, { -2550, 1815 }, { -2700, 1815 }, { -2800, 1805 }, { -2900, 1800 } },
}
local C = D.Cfg

-- ===== utilitaires de chemins (Catmull-Rom) =====
local function cr(p0, p1, p2, p3, t)
	return 0.5 * ((2 * p1) + (-p0 + p2) * t + (2 * p0 - 5 * p1 + 4 * p2 - p3) * t * t + (-p0 + 3 * p1 - 3 * p2 + p3) * t * t * t)
end
local function cumul(ch)
	local S = { 0 }
	for i = 2, #ch.P do
		local a, b = ch.P[i - 1], ch.P[i]
		S[i] = S[i - 1] + sqrt((b[1] - a[1]) ^ 2 + (b[2] - a[2]) ^ 2)
	end
	ch.S = S
end
-- debut = indice du premier segment a produire (2 pour ne produire que les segments apres le 1er point de controle)
local function creerChemin(pts, pas, debut)
	local out, n = {}, #pts
	for i = (debut or 1), n - 1 do
		local p0, p1, p2, p3 = pts[max(i - 1, 1)], pts[i], pts[i + 1], pts[min(i + 2, n)]
		local len = sqrt((p2[1] - p1[1]) ^ 2 + (p2[2] - p1[2]) ^ 2)
		local k = max(1, floor(len / pas))
		for j = (debut and i == debut) and 1 or 0, k - 1 do
			local t = j / k
			out[#out + 1] = { cr(p0[1], p1[1], p2[1], p3[1], t), cr(p0[2], p1[2], p2[2], p3[2], t) }
		end
	end
	out[#out + 1] = { pts[n][1], pts[n][2] }
	local ch = { P = out }
	cumul(ch)
	return ch
end
-- index spatial grossier : cellules de 64, chaque segment est liste dans les cellules de sa boite elargie de `rayon`
local CELL = 64
local function indexer(ch, rayon)
	local P, idx = ch.P, {}
	for i = 1, #P - 1 do
		local a, b = P[i], P[i + 1]
		local x0, x1 = min(a[1], b[1]) - rayon, max(a[1], b[1]) + rayon
		local z0, z1 = min(a[2], b[2]) - rayon, max(a[2], b[2]) + rayon
		for cx = floor(x0 / CELL), floor(x1 / CELL) do
			for cz = floor(z0 / CELL), floor(z1 / CELL) do
				local k = cx * 100003 + cz
				local l = idx[k]
				if not l then l = {}; idx[k] = l end
				l[#l + 1] = i
			end
		end
	end
	ch.Idx = idx
end
local function proche(ch, X, Z)
	local l = ch.Idx[floor(X / CELL) * 100003 + floor(Z / CELL)]
	if not l then return 1e9, 1, 0 end
	local P, best, bi, bf = ch.P, 1e18, l[1], 0
	for q = 1, #l do
		local i = l[q]
		local a, b = P[i], P[i + 1]
		local dx, dz = b[1] - a[1], b[2] - a[2]
		local ex, ez = X - a[1], Z - a[2]
		local f = (ex * dx + ez * dz) / (dx * dx + dz * dz)
		if f < 0 then f = 0 elseif f > 1 then f = 1 end
		local px, pz = ex - f * dx, ez - f * dz
		local d2 = px * px + pz * pz
		if d2 < best then best, bi, bf = d2, i, f end
	end
	return sqrt(best), bi, bf
end
D.Proche = proche

-- ===== Relief de base : H, avec prairie adoucie =====
function D.Base(X, Z)
	local h = H.H(X, Z)
	local P = C.Prairie
	local w = 1 - Lisse((sqrt((X - P.X) ^ 2 + (Z - P.Z) ^ 2) - P.Plein) / P.Fondu)
	if w > 0 then
		local b = H.Basse(X, Z)
		h = b + (h - b) * (1 - P.Adoucit * w)
	end
	return h
end
local Base = D.Base
local function cote(X, Z) return floor(Base(X, Z) / 4 + 0.5) * 4 end

-- ===== Tour d'observation ouest (26) : crete locale =====
do
	local bestH, bx, bz = -1e9, C.TourRecherche.X, C.TourRecherche.Z
	local r = C.TourRecherche
	for dx = -r.Rayon, r.Rayon, 10 do
		for dz = -r.Rayon, r.Rayon, 10 do
			if dx * dx + dz * dz <= r.Rayon * r.Rayon then
				local X, Z = r.X + dx, r.Z + dz
				-- moyenne locale (evite un pic isole) : 5 points
				local h = (Base(X, Z) * 2 + Base(X + 20, Z) + Base(X - 20, Z) + Base(X, Z + 20) + Base(X, Z - 20)) / 6
				if h > bestH then bestH, bx, bz = h, X, Z end
			end
		end
	end
	C.Tour = { X = bx, Z = bz, Demi = C.TourPad.Demi, Fondu = C.TourPad.Fondu }
	D.TourY = cote(bx, bz)
end

-- ===== Pates plates =====
local function distRect(p, X, Z)
	local dx, dz = max(math.abs(X - p.X) - p.Demi, 0), max(math.abs(Z - p.Z) - p.Demi, 0)
	return sqrt(dx * dx + dz * dz)
end
local function pate(p, y, X, Z, h, genre)
	local d = distRect(p, X, Z)
	if d >= p.Fondu then return h, genre end
	h += (y - h) * (1 - Lisse(d / p.Fondu))
	if d == 0 then genre = "aire" end
	return h, genre
end

-- ===== Tubes de lave (7 et 21) : definitions =====
-- Pts : axe (X,Z) en partant de l'aire devant l'entree ; Y0 = hauteur du sol a l'entree ; Pente = montee du plancher par stud
D.Tubes = {}
D.Aire7 = { X = -2440, Z = 2345, Demi = 12, Fondu = 30 }
D.Aire7Y = cote(D.Aire7.X, D.Aire7.Z)
D.Aire21 = { X = -2900, Z = 1800, Demi = 10, Fondu = 28 }
D.Aire21Y = cote(D.Aire21.X, D.Aire21.Z)
-- Ape Cave : entree en rampe (effondrement) : le plancher descend de ~17 studs sur 50 puis remonte tres doucement ; le plafond voute ressort a la surface sur ~30 studs (tranchee d'entree)
D.Tubes.ApeCave = {
	Nom = "ApeCave", Y0 = D.Aire7Y,
	Plancher = function(Y0, s) return Y0 - 0.22 * math.min(s, 78) + 0.02 * math.max(s - 78, 0) end,
	Pts = { { -2440, 2345 }, { -2480, 2342 }, { -2540, 2330 }, { -2600, 2335 }, { -2655, 2320 }, { -2710, 2290 }, { -2745, 2245 } },
	W = function(s) return 11 - 1.2 * Lisse((s - 20) / 60) + 0.8 * noise(s / 45 + 1.3, 5.5, SEED) end, -- demi-largeur (largeur 17-20)
	HH = function(s) return 18 + 2 * Lisse((s - 30) / 50) + 0.8 * noise(s / 38 + 4.1, 2.2, SEED) end, -- hauteur de la voute au centre (12-15)
}
D.Tubes.Effondre = {
	Nom = "Effondre", Y0 = D.Aire21Y,
	Plancher = function(Y0, s) return Y0 + 0.03 * s end,
	Pts = { { -2900, 1800 }, { -2928, 1800 }, { -2958, 1796 }, { -2988, 1792 } },
	W = function(s) return 8.5 + 0.6 * noise(s / 25 + 2.3, 1.1, SEED) end,
	HH = function(s) return 8 + 1.5 * Lisse((s - 20) / 30) end, -- entree basse
	Eboulis = { s0 = 40, s1 = 72, lMin = 1, hMax = 7 }, -- zone remplie d'eboulis (s depuis le debut de l'axe), couloir lateral laisse libre
}
for _, T in pairs(D.Tubes) do
	local ch = creerChemin(T.Pts, 4)
	T.P, T.S = ch.P, ch.S
	T.F = {}
	for i = 1, #T.P do T.F[i] = T.Plancher(T.Y0, T.S[i]) end
	local x0, x1, z0, z1 = 1e9, -1e9, 1e9, -1e9
	for _, p in ipairs(T.P) do x0, x1, z0, z1 = min(x0, p[1]), max(x1, p[1]), min(z0, p[2]), max(z1, p[2]) end
	T.bx0, T.bx1, T.bz0, T.bz1 = x0 - 30, x1 + 30, z0 - 30, z1 + 30
	T.Longueur = T.S[#T.S]
end
-- interroge un tube pour la colonne (X,Z) : nil si hors boite
function D.TubeConsulter(T, X, Z)
	if X < T.bx0 or X > T.bx1 or Z < T.bz0 or Z > T.bz1 then return nil end
	local P, best, bi, bf = T.P, 1e18, 1, 0
	for i = 1, #P - 1 do
		local a, b = P[i], P[i + 1]
		local dx, dz = b[1] - a[1], b[2] - a[2]
		local ex, ez = X - a[1], Z - a[2]
		local f = (ex * dx + ez * dz) / (dx * dx + dz * dz)
		if f < 0 then f = 0 elseif f > 1 then f = 1 end
		local px, pz = ex - f * dx, ez - f * dz
		local d2 = px * px + pz * pz
		if d2 < best then best, bi, bf = d2, i, f end
	end
	local a, b = P[bi], P[bi + 1]
	local dx, dz = b[1] - a[1], b[2] - a[2]
	local len = sqrt(dx * dx + dz * dz)
	local l = (dx * (Z - a[2]) - dz * (X - a[1])) / len -- distance laterale signee
	local s = T.S[bi] + bf * len
	return { d = sqrt(best), l = l, s = s, fl = T.F[bi] + bf * (T.F[bi + 1] - T.F[bi]), w = T.W(s), hh = T.HH(s), T = T }
end
-- distance signee approchee a la cavite au point d'altitude Y (negatif = dans le vide) ; 2e retour : true si voxel d'eboulis
function D.TubeSd(q, Y)
	local v, d, w, hh = Y - q.fl, q.d, q.w, q.hh
	local sd
	if v >= 0 then
		sd = (sqrt((d / w) ^ 2 + (v / hh) ^ 2) - 1) * min(w, hh)
	else
		sd = sqrt(max(d - w, 0) ^ 2 + v * v)
	end
	local E = q.T.Eboulis
	if E then
		local fill = max(max(E.s0 - q.s, q.s - E.s1), min(q.l - E.lMin, E.hMax - v))
		if fill < 0 and sd < 0 then return -fill, true end -- eboulis : plein
		if fill < 0 then return sd, false end
		return max(sd, -fill), false
	end
	return sd, false
end
-- couverture de roche au-dessus du plafond le long de l'axe (pour regler les pentes)
function D.TubeCouverture(T, pas)
	local out = {}
	for i = 1, #T.P, pas or 5 do
		local h = D.Colonne(T.P[i][1], T.P[i][2])
		out[#out + 1] = { s = T.S[i], X = T.P[i][1], Z = T.P[i][2], sol = h, plafond = T.F[i] + T.HH(T.S[i]), couv = h - (T.F[i] + T.HH(T.S[i])) }
	end
	return out
end

-- ===== Sentiers =====
local function profil(ch, bloqueurs)
	local n, y = #ch.P, {}
	for i = 1, n do y[i] = Base(ch.P[i][1], ch.P[i][2]) end
	for _ = 1, 6 do
		local z = {}
		for i = 1, n do
			local a, c = 0, 0
			for j = max(1, i - 5), min(n, i + 5) do a += y[j]; c += 1 end
			z[i] = a / c
		end
		y = z
	end
	for _, b in ipairs(bloqueurs or {}) do
		for i = 1, n do
			local w = 1 - Lisse(sqrt((ch.P[i][1] - b[1]) ^ 2 + (ch.P[i][2] - b[2]) ^ 2) / b[4])
			y[i] += (b[3] - y[i]) * w
		end
	end
	ch.Y = y
end
local function sentier(pts, cfg, bloqueurs)
	local ch = creerChemin(pts, 12)
	ch.Demi, ch.Fondu = cfg.Demi, cfg.Fondu
	profil(ch, bloqueurs)
	indexer(ch, cfg.Demi + cfg.Fondu + 8)
	return ch
end
local function appliquer(ch, X, Z, h, genre)
	local demi, fondu = ch.Demi, ch.Fondu
	local d, i, f = proche(ch, X, Z)
	if d > demi + fondu then return h, genre end
	local y = ch.Y[i] + (ch.Y[i + 1] - ch.Y[i]) * f
	h += (y - h) * (1 - Lisse((d - demi) / fondu))
	local dn = d + (0.25 * demi + 0.5) * noise(X / 7 + 0.9, Z / 7 + 0.4, SEED) * 2 -- bord irregulier
	if d <= demi + 1.2 or dn <= demi - 0.8 then genre = "sentier" elseif dn <= demi + 3 and genre ~= "sentier" then genre = "sentier_bord" end
	return h, genre
end
D.SentierCamp = sentier(C.PtsSentierCamp, C.Sentier, { { -800, 600, D4.CampY, 100 } })
D.SentierTour = sentier({ { -2200, 200 }, { C.Tour.X + (-2200 - C.Tour.X) * 0.55, C.Tour.Z + (200 - C.Tour.Z) * 0.55 + 15 }, { C.Tour.X, C.Tour.Z } },
	C.SentierPetit, { { C.Tour.X, C.Tour.Z, D.TourY, 60 } })
D.SentierCascade = sentier(C.PtsSentierCascade, C.Sentier)
D.SentierCave = sentier(C.PtsSentierCave, C.Sentier, { { D.Aire7.X, D.Aire7.Z, D.Aire7Y, 60 } })
D.SentierSpur = sentier(C.PtsSpur21, C.SentierPetit, { { D.Aire21.X, D.Aire21.Z, D.Aire21Y, 60 } })
D.Sentiers = { D.SentierCamp, D.SentierTour, D.SentierCascade, D.SentierCave, D.SentierSpur }

-- ===== Ruisseau : queue de S4 (copiee) + prolongement =====
local function construireRuisseau()
	local R4 = D4.Ruisseau
	local n4, TAIL = #R4.P, 25
	local P, S, F = {}, {}, {}
	for i = n4 - TAIL + 1, n4 do
		local k = i - (n4 - TAIL)
		P[k] = { R4.P[i][1], R4.P[i][2] }
		S[k] = R4.S[i]
		F[k] = R4.F[i]
	end
	local nT = #P
	local sEnd = S[nT]
	local bedJ = F[nT].bedC + 0 -- niveau du lit a la jonction (cascades de S4 deja comptees)
	local ctrl = { { R4.P[n4 - 1][1], R4.P[n4 - 1][2] }, { R4.P[n4][1], R4.P[n4][2] } }
	for _, p in ipairs(C.ExtRuisseau) do ctrl[#ctrl + 1] = p end
	local ext = creerChemin(ctrl, 20, 2).P
	local cop = {}
	for i = 1, #ext do cop[i] = { ext[i][1], ext[i][2] } end
	-- cumul provisoire pour meandres et rim
	local sAcc, Lext = {}, 0
	local prev = P[nT]
	for i = 1, #ext do
		Lext += sqrt((ext[i][1] - prev[1]) ^ 2 + (ext[i][2] - prev[2]) ^ 2)
		sAcc[i] = Lext
		prev = ext[i]
	end
	for i = 1, #ext - 1 do -- meandres (nuls a la jonction et a la sortie)
		local a = (i == 1) and P[nT] or cop[i - 1]
		local b = cop[i + 1]
		local tx, tz = b[1] - a[1], b[2] - a[2]
		local l = sqrt(tx * tx + tz * tz)
		local amp = 14 * noise((sEnd + sAcc[i]) / 200 + 0.8, 3.3, SEED) * Lisse(sAcc[i] / 140) * (1 - Lisse((sAcc[i] - (Lext - 120)) / 100))
		ext[i] = { cop[i][1] - tz / l * amp, cop[i][2] + tx / l * amp }
	end
	for i = 1, #ext do P[#P + 1] = ext[i] end
	local ch = { P = P }
	cumul(ch)
	local Sabs = {}
	for i = 1, #P do Sabs[i] = sEnd + (ch.S[i] - ch.S[nT]) end
	for i = 1, nT do Sabs[i] = S[i] end
	ch.S = Sabs
	-- station de la cascade : point de l'axe le plus proche de C.Cascade
	local cc = C.Cascade
	local best, bi = 1e18, nT
	for i = nT, #P do
		local d2 = (P[i][1] - cc.X) ^ 2 + (P[i][2] - cc.Z) ^ 2
		if d2 < best then best, bi = d2, i end
	end
	local sc = Sabs[bi] - sEnd -- abscisse relative a la jonction
	local sp = sc + 44 -- centre du bassin
	local Lrel = Sabs[#P] - sEnd
	ch.SC, ch.SP, ch.SEnd = sc, sp, sEnd
	-- rim : moyenne de Basse (comme S4)
	local moy = {}
	for i = 1, #P do
		local a, c = 0, 0
		for j = max(1, i - 8), min(#P, i + 8) do a += H.Basse(P[j][1], P[j][2]); c += 1 end
		moy[i] = a / c
	end
	local function bedUp(sr)
		if sr <= sc then return bedJ + (cc.BedLevre - bedJ) * (sr / sc) end
		return cc.BedLevre + (cc.BedFin - cc.BedLevre) * ((sr - sc) / (Lrel - sc))
	end
	ch.F = {}
	for i = 1, #P do
		if i <= nT then
			ch.F[i] = F[i]
		else
			local sr = Sabs[i] - sEnd
			local g = 1 - Lisse(math.abs(sr - sp) / 52) -- bulle du bassin
			local casc = 1 - Lisse((math.abs(sr - sc) - 12) / 14) -- 1 pres de la chute
			local bedC = bedUp(sr) - cc.Chute * Lisse((sr - sc) / cc.Long + 0.5) - cc.Chute2 * Lisse((sr - sc - cc.Dist2) / 10 + 0.5)
			local sw = 24 + 10 * Lisse((sr - 300) / 600) + cc.Bassin * g
			local rim = clamp(moy[i], bedC + 4, bedC + 14)
			local ww = clamp((rim - bedC) * 1.6, 12, 40)
			ch.F[i] = { s = Sabs[i], sw = sw, hw = sw / 2 + 3, ww = ww, bedC = bedC, rim = rim, cuv = C.Cuvette + 2.5 * Lisse(sr / 200) + 3 * g, g = g, casc = casc }
		end
	end
	indexer(ch, 250)
	return ch
end
D.Ruisseau = construireRuisseau()

local function facteurGue(X, Z)
	local f = 0
	for _, g in ipairs(C.Gues) do
		local dg = sqrt((X - g[1]) ^ 2 + (Z - g[2]) ^ 2)
		f = max(f, 1 - Lisse((dg - 12) / 38))
	end
	return f
end

-- ===== Surface (X < XJonction) : relief + sentiers + pates + ruisseau =====
function D.Surface(X, Z)
	local h = Base(X, Z)
	local genre, eau, hum, sable = nil, nil, 0, false
	for _, ch in ipairs(D.Sentiers) do h, genre = appliquer(ch, X, Z, h, genre) end
	h, genre = pate(C.Tour, D.TourY, X, Z, h, genre)
	h, genre = pate(D.Aire7, D.Aire7Y, X, Z, h, genre)
	h, genre = pate(D.Aire21, D.Aire21Y, X, Z, h, genre)
	local R = D.Ruisseau
	local d, i, f = proche(R, X, Z)
	if d < 250 then
		local a, b = R.F[i], R.F[i + 1]
		local function lp(k) return (a[k] or 0) + ((b[k] or 0) - (a[k] or 0)) * f end
		local sw, rim, bedC = lp("sw"), lp("rim"), lp("bedC")
		local cuv = (a.cuv and b.cuv) and lp("cuv") or C.Cuvette
		local gu = facteurGue(X, Z)
		if gu > 0 then
			rim = min(rim, bedC + 4.5 + (rim - bedC - 4.5) * (1 - gu))
			cuv *= 1 - 0.8 * gu
		end
		local hw = sw / 2 + 3
		local ww = clamp((rim - bedC) * 1.6, 12, 40)
		local t = 1 - Lisse((d - (hw + ww)) / 110)
		if t > 0 then
			h += (rim - h) * t
			hum = 1 - Lisse((d - sw / 2 - 2) / 40)
			if d < hw + ww then
				local dd = d + 1.5 * noise(X / 14 + 0.1, Z / 14 + 0.9, SEED)
				local gr = H.CreuserGorge(dd, bedC, rim, hw, ww)
				if dd < sw / 2 then
					local q = 2 * dd / sw
					gr -= cuv * (1 - q * q)
				end
				h = gr
				local wt = bedC - 0.5
				if gr < wt - 0.3 then eau = wt end
				if dd < sw / 2 + 5 + 5 * noise(X / 10 + 0.3, Z / 10 + 0.6, SEED) then genre = "berge" end
				if (lp("casc") > 0.4 or lp("g") > 0.3) and dd > sw / 2 + 6 then genre = "gorge" end
			end
		end
	end
	return h, genre, eau, hum, sable
end

function D.Colonne(X, Z)
	local h, genre, eau, hum, sable
	if X >= C.XJonction then
		local _
		h, genre, eau, _, hum, sable = D4.Colonne(X, Z)
		h, genre = appliquer(D.SentierCamp, X, Z, h, genre)
	else
		h, genre, eau, hum, sable = D.Surface(X, Z)
		local tp = 1 - Lisse((Z - C.ZMin) / C.Marge) -- bord nord provisoire (meme formule que S4 a X=-1000)
		h -= C.ChuteMarge * tp * tp
		-- bord sud : H pur jusqu'a Z=2500 (S6 construit en parallele depuis H pur) ; seul le coin sud-est (X -1300..-1000) se fond vers S4
		local ts = Lisse((Z - (C.ZMax - C.SudFondu)) / C.SudFondu) * Lisse((X - (C.XJonction - 300)) / 300)
		h -= C.SudChute * ts * ts
	end
	return h, genre, eau, 0, hum, sable
end

-- couvert forestier suppose (0..1) : foret dense, clairieres (prairie, tour)
function D.Couvert(X, Z)
	if X >= C.XJonction then return D4.Couvert(X, Z) end
	local c = 0.8 - 0.07 * Lisse((C.XJonction - X) / 400)
	local P, T = C.Prairie, C.Tour
	local dp = sqrt((X - P.X) ^ 2 + (Z - P.Z) ^ 2)
	local dt = sqrt((X - T.X) ^ 2 + (Z - T.Z) ^ 2)
	c = c - 0.38 * (1 - Lisse((dp - 200) / 200)) - 0.4 * (1 - Lisse((dt - 40) / 90))
	return clamp(c, 0.1, 1)
end

return D
