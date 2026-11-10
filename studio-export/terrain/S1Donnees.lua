--[[ S1Donnees : geometrie du secteur S1 Zone interdite (lieux 8, 19, 20, 25, 18 ; B3 ; affluent du lac ; sentiers).
 Copie locale : terrain/S1Donnees.lua. Coordonnees MONDE (X = x-4000, Z = y-4000). Boite construite : X -4000..-1000, Z -4000..-500.
 Au sud, la bande Z -600..-500 REECRIT la marge provisoire de S5 (H pur) : reconstruire S1 APRES S5. ]]
local H = require(script.Parent.HauteurGlobale)
local Mix = require(script.Parent.MelangeMateriaux)
local noise, Lisse, clamp = math.noise, H.Lisse, math.clamp
local sqrt, floor, max, min = math.sqrt, math.floor, math.max, math.min
local SEED = H.Config.Graine
local D = {}

D.Cfg = {
	XMin = -4000, XMax = -1000, ZMin = -4000, ZMax = -500,
	-- zone interdite (lieu 8) : relief adouci vers Basse (grandes vallees seules) ; Adoucit = part des collines/detail supprimee
	-- X1 = -1000 (limite de ma boite, pas de la zone qui va a -500) : H pur a X=-1000 pour se raccorder a S2
	Zone = { X0 = -3700, X1 = -1000, Z0 = -3700, Z1 = -800, Fondu = 250, Adoucit = 0.8 },
	-- lac Spirit (20) : ellipse A x B (demi-axes), Niveau = surface de l'eau (constante), Prof = profondeur au centre, terrasse de rive
	Lac = { X = -2500, Z = -1800, A = 175, B = 125, Niveau = 336, Prof = 12, RingPlein = 1.5, RingFin = 2.6, Terrasse = 5 },
	Charnier = { X = -2150, Z = -2280, Demi = 30, Fondu = 45, Creux = 4 }, -- lieu 19 : cuvette plate ~60x60
	TourRecherche = { X = -2200, Z = -3500, Rayon = 130 }, TourPad = { Demi = 15, Fondu = 40 }, -- lieu 25 : crete la plus haute dans ce rayon
	Cuvette = 7, PenteRuisseau = 0.004,
	-- affluent du lac : sort de l'ellipse, descend vers le sud ; fin a la frontiere sud (Z=-500)
	PtsRuisseau = { { -2380, -1760 }, { -2250, -1700 }, { -2100, -1590 }, { -1990, -1440 }, { -1910, -1250 }, { -1850, -1050 }, { -1800, -850 },
		{ -1760, -680 }, { -1735, -520 }, { -1730, -500 } },
	Sentier = { Demi = 3.0, Fondu = 12 }, SentierPetit = { Demi = 2.6, Fondu = 12 },
	-- sentier d'acces : bord est (-1000,-560) -> entree/barriere (~-1105,-740) -> jonction J (-1720,-2150)
	PtsPasse = { { -1000, -560 }, { -1060, -650 }, { -1105, -740 }, { -1160, -840 }, { -1240, -1000 }, { -1320, -1250 }, { -1420, -1520 },
		{ -1530, -1780 }, { -1640, -2000 }, { -1720, -2150 } },
	PtsCharnier = { { -1720, -2150 }, { -1950, -2190 }, { -2150, -2280 } },
	PtsEst = { { -1720, -2150 }, { -1500, -2250 }, { -1250, -2350 }, { -1000, -2420 } }, -- sortie vers S2 (raccord a continuer)
	PtsTourBase = { { -2150, -2280 }, { -2110, -2550 }, { -2120, -2850 }, { -2150, -3150 } }, -- + la tour
}
local C = D.Cfg

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
local function creerChemin(pts, pas)
	local out, n = {}, #pts
	for i = 1, n - 1 do
		local p0, p1, p2, p3 = pts[max(i - 1, 1)], pts[i], pts[i + 1], pts[min(i + 2, n)]
		local len = sqrt((p2[1] - p1[1]) ^ 2 + (p2[2] - p1[2]) ^ 2)
		local k = max(1, floor(len / pas))
		for j = 0, k - 1 do
			local t = j / k
			out[#out + 1] = { cr(p0[1], p1[1], p2[1], p3[1], t), cr(p0[2], p1[2], p2[2], p3[2], t) }
		end
	end
	out[#out + 1] = { pts[n][1], pts[n][2] }
	local ch = { P = out }
	cumul(ch)
	return ch
end
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

-- ===== Relief adouci de la zone interdite =====
function D.Soft(X, Z)
	local h = H.H(X, Z)
	local Zn = C.Zone
	local d = min(X - Zn.X0, Zn.X1 - X, Z - Zn.Z0, Zn.Z1 - Z)
	local w = Lisse(d / Zn.Fondu)
	if w > 0 then
		local b = H.Basse(X, Z)
		h = b + (h - b) * (1 - Zn.Adoucit * w)
	end
	return h
end
local Soft = D.Soft
local function cote(X, Z) return floor(Soft(X, Z) / 4 + 0.5) * 4 end

-- ===== Tour nord (25) : crete la plus haute (moyenne locale) =====
do
	local r = C.TourRecherche
	local bestH, bx, bz = -1e9, r.X, r.Z
	for dx = -r.Rayon, r.Rayon, 10 do
		for dz = -r.Rayon, r.Rayon, 10 do
			if dx * dx + dz * dz <= r.Rayon * r.Rayon then
				local X, Z = r.X + dx, r.Z + dz
				local h = (Soft(X, Z) * 2 + Soft(X + 20, Z) + Soft(X - 20, Z) + Soft(X, Z + 20) + Soft(X, Z - 20)) / 6
				if h > bestH then bestH, bx, bz = h, X, Z end
			end
		end
	end
	C.Tour = { X = bx, Z = bz, Demi = C.TourPad.Demi, Fondu = C.TourPad.Fondu }
	D.TourY = cote(bx, bz)
end
C.Ch = { X = C.Charnier.X, Z = C.Charnier.Z, Demi = C.Charnier.Demi, Fondu = C.Charnier.Fondu }
D.CharnierY = floor((Soft(C.Ch.X, C.Ch.Z) - C.Charnier.Creux) / 4 + 0.5) * 4

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

-- ===== Sentiers =====
local function profil(ch, bloqueurs)
	local n, y = #ch.P, {}
	for i = 1, n do y[i] = Soft(ch.P[i][1], ch.P[i][2]) end
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
	if d <= demi + 1.8 or dn <= demi - 0.8 then genre = "sentier" elseif dn <= demi + 3 and genre ~= "sentier" then genre = "sentier_bord" end
	return h, genre
end
local tourPts = {}
for _, p in ipairs(C.PtsTourBase) do tourPts[#tourPts + 1] = p end
tourPts[#tourPts + 1] = { C.Tour.X, C.Tour.Z }
local bTour = { C.Tour.X, C.Tour.Z, D.TourY, 60 }
local bCh = { C.Ch.X, C.Ch.Z, D.CharnierY, 60 }
local jx, jz = C.PtsEst[1][1], C.PtsEst[1][2]
local bJ = { jx, jz, (Soft(jx, jz) * 2 + Soft(jx + 20, jz) + Soft(jx - 20, jz) + Soft(jx, jz + 20) + Soft(jx, jz - 20)) / 6, 50 } -- jonction : meme hauteur pour les 3 sentiers
D.SentierPasse = sentier(C.PtsPasse, C.Sentier, { bJ })
D.SentierCharnier = sentier(C.PtsCharnier, C.Sentier, { bJ, bCh })
D.SentierEst = sentier(C.PtsEst, C.Sentier, { bJ })
D.SentierTour = sentier(tourPts, C.SentierPetit, { bCh, bTour })
D.Sentiers = { D.SentierPasse, D.SentierCharnier, D.SentierEst, D.SentierTour }

-- ===== Affluent du lac : niveau du lit strictement decroissant =====
local function construireRuisseau()
	local ch = creerChemin(C.PtsRuisseau, 20)
	local P = ch.P
	local copie = {}
	for i = 1, #P do copie[i] = { P[i][1], P[i][2] } end
	local total = ch.S[#P]
	for i = 2, #P - 1 do -- meandres (nuls au depart et a la sortie)
		local tx, tz = copie[i + 1][1] - copie[i - 1][1], copie[i + 1][2] - copie[i - 1][2]
		local l = sqrt(tx * tx + tz * tz)
		local fa = Lisse(ch.S[i] / 150) * (1 - Lisse((ch.S[i] - (total - 150)) / 150))
		local off = 22 * noise(ch.S[i] / 220 + 0.8, 3.3, SEED) * fa
		P[i] = { copie[i][1] - tz / l * off, copie[i][2] + tx / l * off }
	end
	cumul(ch)
	ch.F = {}
	local moy = {}
	for i = 1, #P do
		local a, c = 0, 0
		for j = max(1, i - 8), min(#P, i + 8) do a += H.Basse(P[j][1], P[j][2]); c += 1 end
		moy[i] = a / c
	end
	local bed
	for i = 1, #P do
		local s = ch.S[i]
		local sw = 16 + 8 * Lisse(s / 1800) -- largeur de l'eau 16 -> 24
		local raw = moy[i] - 6
		if not bed then bed = C.Lac.Niveau + 0.5 else bed = min(bed - C.PenteRuisseau * (s - ch.S[i - 1]), raw) end
		local rim = clamp(moy[i], bed + 4, bed + 14)
		local ww = clamp((rim - bed) * 1.6, 12, 40)
		ch.F[i] = { s = s, sw = sw, hw = sw / 2 + 3, ww = ww, bedC = bed, rim = rim }
	end
	indexer(ch, 250)
	return ch
end
D.Ruisseau = construireRuisseau()

-- q = distance elliptique normalisee au centre du lac (rive irreguliere)
function D.LacQ(X, Z)
	local L = C.Lac
	local q = sqrt(((X - L.X) / L.A) ^ 2 + ((Z - L.Z) / L.B) ^ 2)
	return q * (1 + 0.10 * noise(X / 90 + 0.4, Z / 90 + 0.2, SEED) + 0.05 * noise(X / 35 + 1.1, Z / 35 + 2.3, SEED))
end

function D.Surface(X, Z)
	local h = Soft(X, Z)
	local genre, eau, hum, sable = nil, nil, 0, false
	h, genre = pate(C.Ch, D.CharnierY, X, Z, h, genre)
	h, genre = pate(C.Tour, D.TourY, X, Z, h, genre)
	for _, ch in ipairs(D.Sentiers) do h, genre = appliquer(ch, X, Z, h, genre) end
	local h0 = h
	-- affluent
	local R = D.Ruisseau
	local d, i, f = proche(R, X, Z)
	if d < 250 then
		local a, b = R.F[i], R.F[i + 1]
		local function lp(k) return a[k] + (b[k] - a[k]) * f end
		local hw, ww, sw, rim, bedC = lp("hw"), lp("ww"), lp("sw"), lp("rim"), lp("bedC")
		local t = 1 - Lisse((d - (hw + ww)) / 110)
		if t > 0 then
			h += (rim - h) * t
			hum = 1 - Lisse((d - sw / 2 - 2) / 40)
			if d < hw + ww then
				local dd = d + 1.5 * noise(X / 14 + 0.1, Z / 14 + 0.9, SEED)
				local gr = H.CreuserGorge(dd, bedC, rim, hw, ww)
				if dd < sw / 2 then
					local q = 2 * dd / sw
					gr -= C.Cuvette * (1 - q * q)
				end
				h = gr
				local wt = bedC - 0.5
				if gr < wt - 0.3 then eau = wt end
				if dd < sw / 2 + 5 + 5 * noise(X / 10 + 0.3, Z / 10 + 0.6, SEED) then genre = "berge" end
			end
		end
	end
	-- lac
	local Lc = C.Lac
	local q = D.LacQ(X, Z)
	if q < Lc.RingFin then
		local wr = 1 - Lisse((q - Lc.RingPlein) / (Lc.RingFin - Lc.RingPlein))
		local lh
		if q < 1 then
			lh = Lc.Niveau - Lc.Prof * (1 - q * q)
			h, eau = lh, nil
		else
			local tgt = Lc.Niveau + Lc.Terrasse * Lisse((q - 1) / 0.5)
			lh = h0 + (tgt - h0) * wr
			h = h + (min(h, lh) - h) * wr
		end
		if h < Lc.Niveau - 0.3 then eau = max(eau or 0, Lc.Niveau) end
		hum = max(hum, 1 - Lisse((q - 1) / 0.5))
		if q > 0.85 and q < 1.3 then genre = "berge" end
		if q < 1.7 then sable = true end
	end
	return h, genre, eau, hum, sable
end

function D.Colonne(X, Z)
	local h, genre, eau, hum, sable = D.Surface(X, Z)
	return h, genre, eau, 0, hum, sable
end

-- sol de cendre : Slate/Basalt (gris), Sand/Ground (clairs), Rock en forte pente, Mud pres de l'eau
function D.Cendre(X, Z, c)
	local B = Mix.Bord
	local wx, wz = X + 14 * B(X, Z, 60, 2.2), Z + 14 * B(X, Z, 60, 5.7)
	if (c.pente or 0) + 0.15 * B(wx, wz, 25, 9.4) > 0.9 then return Enum.Material.Rock end
	local hum = (c.hum or 0) + 0.2 * B(wx, wz, 14, 31.4)
	if hum > 0.8 then return Enum.Material.Mud end
	if hum > 0.6 then return (B(wx, wz, 9, 13.3) > 0.1) and Enum.Material.Mud or Enum.Material.Ground end
	local a = B(wx, wz, 90, 1.3) + 0.6 * B(wx, wz, 36, 4.4) + 0.3 * B(wx, wz, 12, 7.1)
	local b = B(wx, wz, 28, 6.6) + 0.5 * B(wx, wz, 9, 2.9)
	if a < 0.02 then
		return (b < -0.05) and Enum.Material.Basalt or Enum.Material.Slate
	end
	if b > 0.05 then return Enum.Material.Sand end
	return Enum.Material.Ground
end

return D