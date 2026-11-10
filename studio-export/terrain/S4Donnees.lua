--[[ S4Donnees : geometrie du secteur S4 Centre (ruisseau, sentiers, camp 9, poste 17, foret 4).
 Copie locale : terrain/S4Donnees.lua. Coordonnees MONDE (X = x-4000, Z = y-4000).
 D.Colonne(X,Z) -> h, genre, niveauEau, gorge, hum, sable. Meme fonction H que S7 ; S7 reutilise D.AppliquerSentierEst
 (troncon X>1300 du sentier) : le raccord a X~1400 est donc identique des deux cotes. ]]
local H = require(script.Parent.HauteurGlobale)
local noise, Lisse, clamp = math.noise, H.Lisse, math.clamp
local SEED = H.Config.Graine
local D = {}

D.Cfg = {
	XMin = -1100, XMax = 1400, ZMin = -600, ZMax = 2500, -- terrain construit (S4 + 100 de marge nord/ouest)
	Marge = 100, ChuteMarge = 45, -- bords nord/ouest : le sol descend de 45 studs sur 100
	SudFondu = 100, SudChute = 30, -- bord sud (Z 2400..2500) : leger fondu, S5/S6 reprendront H pur
	Camp = { X = -800, Z = 600, Demi = 40, Fondu = 45 }, -- lieu 9 : aire ~80x80
	Poste = { X = 200, Z = 1500, Demi = 20, Fondu = 30 }, -- lieu 17 : plateforme ~40x40 (position deduite)
	Foret = { X = 950, Z = 1000 }, -- lieu 4 : centre de la partie de la foret ancienne dans S4 (X 500..1400)
	Cuvette = 3.5, PenteRuisseau = 0.004, Cascades = { { 900, 4 }, { 1900, 5 } },
	Sentier = { Demi = 2.2, Fondu = 12 },
	PtsRuisseau = { { 1250, -250 }, { 995, 4 }, { 740, 259 }, { 486, 513 }, { 231, 768 }, { -23, 1022 }, { -278, 1277 },
		{ -532, 1531 }, { -759, 1811 }, { -975, 2098 }, { -1110, 2260 } },
	-- camp (9) -> poste (17) -> vers l'est (prolonge dans S7 jusqu'au lahar, X 1660)
	PtsSentierEst = { { -800, 600 }, { -640, 730 }, { -450, 880 }, { -250, 1040 }, { -60, 1200 }, { 60, 1310 }, { 150, 1395 },
		{ 250, 1430 }, { 380, 1480 }, { 600, 1540 }, { 900, 1600 }, { 1200, 1610 }, { 1400, 1600 }, { 1530, 1600 }, { 1660, 1600 } },
	PtsSentierNord = { { -800, 600 }, { -770, 300 }, { -650, 0 }, { -510, -250 }, { -400, -450 }, { -340, -560 } },
	PtsSpur = { { 262, 1436 }, { 240, 1468 }, { 215, 1488 } }, -- piste du poste
}
local C = D.Cfg

local function cr(p0, p1, p2, p3, t)
	return 0.5 * ((2 * p1) + (-p0 + p2) * t + (2 * p0 - 5 * p1 + 4 * p2 - p3) * t * t + (-p0 + 3 * p1 - 3 * p2 + p3) * t * t * t)
end
local function cumul(ch)
	local S = { 0 }
	for i = 2, #ch.P do
		local a, b = ch.P[i - 1], ch.P[i]
		S[i] = S[i - 1] + math.sqrt((b[1] - a[1]) ^ 2 + (b[2] - a[2]) ^ 2)
	end
	ch.S = S
end
local function creerChemin(pts, pas)
	local out, n = {}, #pts
	for i = 1, n - 1 do
		local p0, p1, p2, p3 = pts[math.max(i - 1, 1)], pts[i], pts[i + 1], pts[math.min(i + 2, n)]
		local len = math.sqrt((p2[1] - p1[1]) ^ 2 + (p2[2] - p1[2]) ^ 2)
		local k = math.max(1, math.floor(len / pas))
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
local function proche(ch, X, Z)
	local P, best, bi, bf = ch.P, 1e18, 1, 0
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
	return math.sqrt(best), bi, bf
end
D.Proche = proche

-- ===== Pates plates (camp, poste) : hauteur unique multiple de 4 =====
local function cote(p) return math.floor(H.H(p.X, p.Z) / 4 + 0.5) * 4 end
D.CampY, D.PosteY = cote(C.Camp), cote(C.Poste)
local function distRect(p, X, Z)
	local dx, dz = math.max(math.abs(X - p.X) - p.Demi, 0), math.max(math.abs(Z - p.Z) - p.Demi, 0)
	return math.sqrt(dx * dx + dz * dz)
end
local function pate(p, y, X, Z, h, genre)
	local d = distRect(p, X, Z)
	if d >= p.Fondu then return h, genre end
	h += (y - h) * (1 - Lisse(d / p.Fondu))
	if d == 0 then genre = "aire" end
	return h, genre
end

-- ===== Sentiers : profil lisse = H lissee le long du chemin =====
local function profil(ch)
	local n, y = #ch.P, {}
	for i = 1, n do y[i] = H.H(ch.P[i][1], ch.P[i][2]) end
	for _ = 1, 6 do
		local z = {}
		for i = 1, n do
			local a, c = 0, 0
			for j = math.max(1, i - 5), math.min(n, i + 5) do a += y[j]; c += 1 end
			z[i] = a / c
		end
		y = z
	end
	ch.Y = y
end
D.SentierEst = creerChemin(C.PtsSentierEst, 12)
D.SentierNord = creerChemin(C.PtsSentierNord, 12)
D.Spur = creerChemin(C.PtsSpur, 6)
for _, ch in ipairs({ D.SentierEst, D.SentierNord, D.Spur }) do profil(ch) end
-- les extremites sur les pates plates rejoignent leur hauteur
for _, ch in ipairs({ D.SentierEst, D.SentierNord }) do
	for i = 1, #ch.P do
		local w = 1 - Lisse(math.sqrt((ch.P[i][1] - C.Camp.X) ^ 2 + (ch.P[i][2] - C.Camp.Z) ^ 2) / 100)
		ch.Y[i] += (D.CampY - ch.Y[i]) * w
	end
end
do
	local ch = D.Spur
	for i = 1, #ch.P do
		local w = 1 - Lisse(math.sqrt((ch.P[i][1] - C.Poste.X) ^ 2 + (ch.P[i][2] - C.Poste.Z) ^ 2) / 60)
		ch.Y[i] += (D.PosteY - ch.Y[i]) * w
	end
end

local function appliquer(ch, X, Z, h, genre)
	local demi, fondu = C.Sentier.Demi, C.Sentier.Fondu
	local d, i, f = proche(ch, X, Z)
	if d > demi + fondu then return h, genre end
	local y = ch.Y[i] + (ch.Y[i + 1] - ch.Y[i]) * f
	h += (y - h) * (1 - Lisse((d - demi) / fondu))
	local dn = d + (0.25 * demi + 0.5) * noise(X / 7 + 0.9, Z / 7 + 0.4, SEED) * 2 -- bord irregulier
	if d <= demi + 1.2 or dn <= demi - 0.8 then genre = "sentier" elseif dn <= demi + 3 and genre ~= "sentier" then genre = "sentier_bord" end
	return h, genre
end
-- troncon est du sentier, partage avec S7 (X>1300)
function D.AppliquerSentierEst(h, genre, X, Z)
	return appliquer(D.SentierEst, X, Z, h, genre)
end

-- ===== Ruisseau (affluent NE -> SO), niveau du lit strictement decroissant =====
local function construireRuisseau()
	local ch = creerChemin(C.PtsRuisseau, 20)
	local P = ch.P
	local copie = {}
	for i = 1, #P do copie[i] = { P[i][1], P[i][2] } end
	for i = 2, #P - 1 do -- meandres
		local tx, tz = copie[i + 1][1] - copie[i - 1][1], copie[i + 1][2] - copie[i - 1][2]
		local l = math.sqrt(tx * tx + tz * tz)
		local off = 22 * noise(ch.S[i] / 220 + 0.8, 3.3, SEED)
		P[i] = { copie[i][1] - tz / l * off, copie[i][2] + tx / l * off }
	end
	cumul(ch)
	ch.F = {}
	local moy = {}
	for i = 1, #P do
		local a, c = 0, 0
		for j = math.max(1, i - 8), math.min(#P, i + 8) do a += H.Basse(P[j][1], P[j][2]); c += 1 end
		moy[i] = a / c
	end
	local bed
	for i = 1, #P do
		local s = ch.S[i]
		local sw = 16 + 6 * Lisse(s / 3000) -- largeur de l'eau 16 -> 22
		local raw = moy[i] - 6
		if not bed then bed = raw else bed = math.min(bed - C.PenteRuisseau * (s - ch.S[i - 1]), raw) end
		local cum = 0
		for _, c in ipairs(C.Cascades) do cum += c[2] * Lisse((s - c[1]) / 10 + 0.5) end
		local bedC = bed - cum
		local rim = clamp(moy[i], bedC + 4, bedC + 14)
		local ww = clamp((rim - bedC) * 1.6, 12, 40)
		ch.F[i] = { s = s, sw = sw, hw = sw / 2 + 3, ww = ww, bedC = bedC, rim = rim }
	end
	return ch
end
D.Ruisseau = construireRuisseau()

-- ===== Surface avant marges : H + sentiers + pates + ruisseau =====
function D.Surface(X, Z)
	local h = H.H(X, Z)
	local genre, eau, hum, sable = nil, nil, 0, false
	h, genre = appliquer(D.SentierEst, X, Z, h, genre)
	if Z < 700 then h, genre = appliquer(D.SentierNord, X, Z, h, genre) end
	if X < 400 and Z > 1300 then h, genre = appliquer(D.Spur, X, Z, h, genre) end
	h, genre = pate(C.Camp, D.CampY, X, Z, h, genre)
	h, genre = pate(C.Poste, D.PosteY, X, Z, h, genre)
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
	return h, genre, eau, hum, sable
end

function D.Colonne(X, Z)
	local h, genre, eau, hum, sable = D.Surface(X, Z)
	-- bords nord/ouest en pente douce
	local tp = 1 - math.min(Lisse((X - C.XMin) / C.Marge), Lisse((Z - C.ZMin) / C.Marge))
	h -= C.ChuteMarge * tp * tp
	-- bord sud : fondu leger, absent pres de S7 (X>1350)
	local ts = Lisse((Z - (C.ZMax - C.SudFondu)) / C.SudFondu) * (1 - Lisse((X - 1200) / 150))
	h -= C.SudChute * ts * ts
	return h, genre, eau, 0, hum, sable
end

-- couvert forestier suppose (0..1) : dense, sauf clairieres du camp et du poste
function D.Couvert(X, Z)
	local c = 0.8
	if X > 500 then c = 0.92 end
	local dc = math.sqrt((X - C.Camp.X) ^ 2 + (Z - C.Camp.Z) ^ 2)
	local dp = math.sqrt((X - C.Poste.X) ^ 2 + (Z - C.Poste.Z) ^ 2)
	c = c - 0.6 * (1 - Lisse(dc / 150)) - 0.5 * (1 - Lisse(dp / 90))
	return clamp(c, 0.1, 1)
end

return D
