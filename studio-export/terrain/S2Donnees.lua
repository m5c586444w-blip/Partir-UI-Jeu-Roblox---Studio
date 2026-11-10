--[[ S2Donnees : geometrie du secteur S2 Plateau de cendres / centre-nord (X -1000..1500, Z -4000..-200).
 Copie locale : terrain/S2Donnees.lua. Coordonnees MONDE (X = x-4000, Z = y-4000).
 D.Colonne(X,Z) -> h, genre, niveauEau, gorge, hum, sable (meme contrat que S3/S4/S7).
 Boites : A = X -1000..1400 x Z -4000..-200 ; B = X 1400..1500 x Z -4000..-2500.
 Raccords : S4 (Z=-200) = memes fonctions ; S3 (est) = bandes de correction D.Corr3 ; S1/NE = marges douces 45/100. ]]
local H = require(script.Parent.HauteurGlobale)
local S4 = require(script.Parent.S4Donnees)
local S3 = require(script.Parent.S3Donnees)
local noise, Lisse, clamp, sqrt = math.noise, H.Lisse, math.clamp, math.sqrt
local SEED = H.Config.Graine
local D = {}

D.Cfg = {
	XMin = -1000, XMax = 1400, ZMin = -4000, ZMax = -200,
	BoiteB = { XMin = 1400, XMax = 1500, ZMin = -4000, ZMax = -2500 },
	Marge = 100, ChuteMarge = 45,
	OuestFond = { Z0 = -900, Z1 = -600 },
	Volcan = { Z0 = -3200, Z1 = -4000, Bonus = 200, FondX = 600 },
	Plateau = { X = 1100, Z = -2600, A = 220, B = 190, Fondu = 0.4, Montee = 25, Ond = 5 },
	Tour = { X = 0, Z = -1600, Demi = 15, Fondu = 35, Rayon = 150 },
	Station = { X = 500, Z = -2200, Demi = 10, Fondu = 30, Rayon = 150 },
	Sentier = { Demi = 2.2, Fondu = 12 },
	PtsRuisseau = { {1220,-2490},{1230,-2300},{1170,-2050},{1110,-1800},{1090,-1500},{1150,-1200},{1210,-900},{1245,-550},{1250,-250} },
	Cascades = { {260, 8}, {900, 7}, {1550, 6} },
	PenteMin = 0.0045, PenteMax = 0.15, LargeurJonction = 16, LargeurSource = 19,
	Cuvette = 3.5,
}
local C = D.Cfg
local P0 = C.Plateau

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
local function indexer(ch, k)
	local Q, mx = {}, 0
	for i = 1, #ch.P, k do Q[#Q + 1] = i end
	for i = 1, #ch.P - 1 do
		local a, b = ch.P[i], ch.P[i + 1]
		mx = math.max(mx, sqrt((b[1] - a[1]) ^ 2 + (b[2] - a[2]) ^ 2))
	end
	ch.Q, ch.K, ch.Slack = Q, k, k * mx
	cumul(ch)
	return ch
end
local function creerChemin(pts, pas, k)
	local out, n = {}, #pts
	for i = 1, n - 1 do
		local p0, p1, p2, p3 = pts[math.max(i - 1, 1)], pts[i], pts[i + 1], pts[math.min(i + 2, n)]
		local len = sqrt((p2[1] - p1[1]) ^ 2 + (p2[2] - p1[2]) ^ 2)
		local kk = math.max(1, math.floor(len / pas))
		for j = 0, kk - 1 do
			local t = j / kk
			out[#out + 1] = { cr(p0[1], p1[1], p2[1], p3[1], t), cr(p0[2], p1[2], p2[2], p3[2], t) }
		end
	end
	out[#out + 1] = { pts[n][1], pts[n][2] }
	return indexer({ P = out }, k or 6)
end
local function proche(ch, X, Z, rmax)
	local P, Q = ch.P, ch.Q
	local bd, bq = 1e18, 1
	for qi = 1, #Q do
		local p = P[Q[qi]]
		local dx, dz = X - p[1], Z - p[2]
		local d2 = dx * dx + dz * dz
		if d2 < bd then bd, bq = d2, qi end
	end
	if rmax and sqrt(bd) > rmax + ch.Slack then return nil end
	local i0, i1 = math.max(1, Q[bq] - 2 * ch.K), math.min(#P - 1, Q[bq] + 2 * ch.K)
	local best, bi, bf = 1e18, i0, 0
	for i = i0, i1 do
		local a, b = P[i], P[i + 1]
		local dx, dz = b[1] - a[1], b[2] - a[2]
		local l2 = dx * dx + dz * dz
		local ex, ez = X - a[1], Z - a[2]
		local f = 0
		if l2 > 1e-9 then f = clamp((ex * dx + ez * dz) / l2, 0, 1) end
		local px, pz = ex - f * dx, ez - f * dz
		local d2 = px * px + pz * pz
		if d2 < best then best, bi, bf = d2, i, f end
	end
	return sqrt(best), bi, bf
end
D.Proche = proche
local function round4(v) return math.floor(v / 4 + 0.5) * 4 end

local function masqueX(X) return Lisse((X - C.XMin) / C.Volcan.FondX) * Lisse((1500 - X) / C.Volcan.FondX) end
local function flanc(X, Z)
	local V = C.Volcan
	if Z >= V.Z0 then return 0 end
	local t = Lisse((V.Z0 - Z) / (V.Z0 - V.Z1))
	return V.Bonus * t ^ 1.3 * masqueX(X)
end
function D.WPlateau(X, Z)
	local dx, dz = (X - P0.X) / P0.A, (Z - P0.Z) / P0.B
	return 1 - Lisse((sqrt(dx * dx + dz * dz) - 1) / P0.Fondu)
end
do
	local s, n = 0, 0
	for X = P0.X - P0.A, P0.X + P0.A, 25 do
		for Z = P0.Z - P0.B, P0.Z + P0.B, 25 do s += H.H(X, Z); n += 1 end
	end
	P0.Y = round4(s / n + P0.Montee)
end
local function surface0(X, Z)
	local h = H.H(X, Z) + flanc(X, Z)
	local w = D.WPlateau(X, Z)
	if w > 0 then
		local tgt = P0.Y + P0.Ond * 2 * noise(X / 110 + 0.4, Z / 110 + 0.8, SEED) + 1.5 * noise(X / 35 + 2.2, Z / 35 + 6.1, SEED)
		h += (tgt - h) * w
	end
	return h
end
D.Surface0 = surface0
local function ref(X, Z)
	local b = H.Basse(X, Z)
	local w = D.WPlateau(X, Z)
	return b + (P0.Y - b) * w
end

local function crete(p)
	local best, bx, bz = -1e9, p.X, p.Z
	for dx = -p.Rayon, p.Rayon, 10 do
		for dz = -p.Rayon, p.Rayon, 10 do
			if dx * dx + dz * dz <= p.Rayon ^ 2 then
				local v = surface0(p.X + dx, p.Z + dz) - 0.02 * sqrt(dx * dx + dz * dz)
				if v > best then best, bx, bz = v, p.X + dx, p.Z + dz end
			end
		end
	end
	p.X, p.Z = bx, bz
	p.Y = math.floor(surface0(bx, bz) / 4) * 4
end
D.Nominal = { Tour = { C.Tour.X, C.Tour.Z }, Station = { C.Station.X, C.Station.Z } }
crete(C.Tour)
crete(C.Station)

local function distRect(p, X, Z)
	local dx, dz = math.max(math.abs(X - p.X) - p.Demi, 0), math.max(math.abs(Z - p.Z) - p.Demi, 0)
	return sqrt(dx * dx + dz * dz)
end
local function pate(p, X, Z, h, genre)
	if math.abs(X - p.X) > p.Demi + p.Fondu or math.abs(Z - p.Z) > p.Demi + p.Fondu then return h, genre end
	local d = distRect(p, X, Z)
	if d >= p.Fondu then return h, genre end
	h += (p.Y - h) * (1 - Lisse(d / p.Fondu))
	if d == 0 then genre = "aire" end
	return h, genre
end

local function profil(ch)
	local n, y = #ch.P, {}
	for i = 1, n do y[i] = surface0(ch.P[i][1], ch.P[i][2]) end
	for _ = 1, 5 do
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
local function relier(ch, cx, cz, y, R)
	for i = 1, #ch.P do
		local w = 1 - Lisse(sqrt((ch.P[i][1] - cx) ^ 2 + (ch.P[i][2] - cz) ^ 2) / R)
		ch.Y[i] += (y - ch.Y[i]) * w
	end
end
local T, St = C.Tour, C.Station
C.PtsNord = { {-340,-560},{-315,-650},{-280,-790},{-230,-950},{-170,-1130},{-110,-1300},{-60,-1450},{ T.X, T.Z } }
C.PtsPlateau = { { T.X, T.Z },{300,-1750},{480,-1900},{680,-2050},{850,-2200},{960,-2350},{1020,-2480},{1090,-2580} }
C.PtsStation = { {480,-1900},{440,-2000},{ (440 + St.X) / 2 + 20, (-2000 + St.Z) / 2 },{ St.X, St.Z } }
D.SNord = creerChemin(C.PtsNord, 12, 6)
D.SPlateau = creerChemin(C.PtsPlateau, 12, 6)
D.SStation = creerChemin(C.PtsStation, 12, 6)
for _, ch in ipairs({ D.SNord, D.SPlateau, D.SStation }) do profil(ch) end
relier(D.SNord, -340, -560, S4.SentierNord.Y[#S4.SentierNord.Y], 90)
relier(D.SNord, T.X, T.Z, T.Y, 110)
relier(D.SPlateau, T.X, T.Z, T.Y, 110)
relier(D.SStation, St.X, St.Z, St.Y, 110)
do
	local d, i, f = proche(D.SPlateau, 480, -1900, nil)
	relier(D.SStation, 480, -1900, D.SPlateau.Y[i] + (D.SPlateau.Y[i + 1] - D.SPlateau.Y[i]) * f, 90)
end

local function appliquer(ch, demi, fondu, X, Z, h, genre)
	local d, i, f = proche(ch, X, Z, demi + fondu)
	if not d or d > demi + fondu then return h, genre end
	local y = ch.Y[i] + (ch.Y[i + 1] - ch.Y[i]) * f
	h += (y - h) * (1 - Lisse((d - demi) / fondu))
	local dn = d + (0.25 * demi + 0.5) * noise(X / 7 + 0.9, Z / 7 + 0.4, SEED) * 2
	if d <= demi + 2.4 or dn <= demi - 0.8 then genre = "sentier" elseif dn <= demi + 3.5 and genre ~= "sentier" then genre = "sentier_bord" end
	return h, genre
end
local function appliquer4(X, Z, h, genre)
	local ch = S4.SentierNord
	local demi, fondu = S4.Cfg.Sentier.Demi, S4.Cfg.Sentier.Fondu
	local d, i, f = S4.Proche(ch, X, Z)
	if d > demi + fondu then return h, genre end
	local y = ch.Y[i] + (ch.Y[i + 1] - ch.Y[i]) * f
	h += (y - h) * (1 - Lisse((d - demi) / fondu))
	local dn = d + (0.25 * demi + 0.5) * noise(X / 7 + 0.9, Z / 7 + 0.4, SEED) * 2
	if d <= demi + 1.2 or dn <= demi - 0.8 then genre = "sentier" elseif dn <= demi + 3 and genre ~= "sentier" then genre = "sentier_bord" end
	return h, genre
end

local function construireRuisseau()
	local ch = creerChemin(C.PtsRuisseau, 20, 8)
	local P, n = ch.P, #ch.P
	local copie = {}
	for i = 1, n do copie[i] = { P[i][1], P[i][2] } end
	local SJ = ch.S[n]
	for i = 2, n - 1 do
		local tx, tz = copie[i + 1][1] - copie[i - 1][1], copie[i + 1][2] - copie[i - 1][2]
		local l = sqrt(tx * tx + tz * tz)
		local off = 20 * noise(ch.S[i] / 200 + 0.5, 7.7, SEED) * Lisse(ch.S[i] / 150) * Lisse((SJ - ch.S[i]) / 400)
		P[i] = { copie[i][1] - tz / l * off, copie[i][2] + tx / l * off }
	end
	cumul(ch)
	SJ = ch.S[n]
	D.LongueurS2 = SJ
	local F4 = S4.Ruisseau.F
	local moy, cum = {}, {}
	for i = 1, n do
		local a, c = 0, 0
		for j = math.max(1, i - 10), math.min(n, i + 10) do a += ref(P[j][1], P[j][2]); c += 1 end
		moy[i] = a / c
		local k = 0
		for _, cs in ipairs(C.Cascades) do k += cs[2] * Lisse((ch.S[i] - cs[1]) / 10 + 0.5) end
		cum[i] = k
	end
	local bedNo = {}
	bedNo[n] = F4[1].bedC + cum[n]
	for i = n - 1, 1, -1 do
		local ds = ch.S[i + 1] - ch.S[i]
		local want = moy[i] - 6 + cum[i]
		bedNo[i] = clamp(want, bedNo[i + 1] + C.PenteMin * ds, bedNo[i + 1] + C.PenteMax * ds)
	end
	ch.F = {}
	for i = 1, n do
		local s = ch.S[i]
		local sw = C.LargeurJonction + (C.LargeurSource - C.LargeurJonction) * Lisse((SJ - s) / SJ)
		local bedC = bedNo[i] - cum[i]
		local wj = 1 - Lisse((SJ - s) / 300)
		local rimC = clamp(moy[i], bedC + 5, bedC + 12)
		local rim = F4[1].rim * wj + rimC * (1 - wj)
		ch.F[i] = { s = s, sw = sw, hw = sw / 2 + 3, ww = clamp((rim - bedC) * 1.6, 12, 40), bedC = bedC, rim = rim }
	end
	ch.F[n] = F4[1]
	local P4 = S4.Ruisseau.P
	for j = 2, #P4 do
		if P4[j][2] > 250 then break end
		P[#P + 1] = P4[j]
		ch.F[#ch.F + 1] = F4[j]
	end
	return indexer(ch, 8)
end
D.Ruisseau = construireRuisseau()

local function ruisseau(h, genre, X, Z)
	local eau, hum = nil, 0
	local R = D.Ruisseau
	local d, i, f = proche(R, X, Z, 250)
	if not d then return h, genre, eau, hum end
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
	return h, genre, eau, hum
end

function D.Surface(X, Z)
	local h, genre = surface0(X, Z), nil
	if X < -200 and Z > -720 then h, genre = appliquer4(X, Z, h, genre) end
	local S = C.Sentier
	if X < 200 and Z > -1650 then h, genre = appliquer(D.SNord, S.Demi, S.Fondu, X, Z, h, genre) end
	if X > 100 then
		h, genre = appliquer(D.SPlateau, S.Demi, S.Fondu, X, Z, h, genre)
		if X < 600 and Z > -2250 and Z < -1850 then h, genre = appliquer(D.SStation, S.Demi, S.Fondu, X, Z, h, genre) end
	end
	h, genre = pate(C.Tour, X, Z, h, genre)
	h, genre = pate(C.Station, X, Z, h, genre)
	local eau, hum
	h, genre, eau, hum = ruisseau(h, genre, X, Z)
	return h, genre, eau, hum
end

function D.Colonne(X, Z)
	local h, genre, eau, hum = D.Surface(X, Z)
	local tw = 1 - Lisse((X - C.XMin) / C.Marge)
	if tw > 0 then
		local fw = 1 - Lisse((Z - C.OuestFond.Z0) / (C.OuestFond.Z1 - C.OuestFond.Z0))
		h -= C.ChuteMarge * tw * tw * fw
	end
	return h, genre, eau, 0, hum, false
end

D.BandesS3 = { { 1400, -1000, 1700, -500 }, { 1400, -2500, 1500, -2400 } }
function D.Corr3(X, Z)
	local h, genre, eau, gor, hum, sable = S3.Colonne(X, Z)
	local corr = 0
	local S4c = S4.Cfg
	if Z > -1000 and Z < -500 and X < 1700 then
		local w4 = 1 - Lisse((X - 1400) / 300)
		local tp = 1 - Lisse((Z - S4c.ZMin) / S4c.Marge)
		local fn = 1 - Lisse((S4c.ZMin - Z) / 300)
		corr += S4c.ChuteMarge * tp * tp * fn * w4
	end
	if Z < -2400 and X < 1500 then
		local tn = 1 - Lisse((Z - S3.Cfg.ZMin) / S3.Cfg.Marge)
		corr += S3.Cfg.ChuteMarge * tn * tn
	end
	return h + corr, genre, eau, gor, hum, sable
end

function D.WCendre(X, Z)
	return math.max(D.WPlateau(X, Z), Lisse((-2900 - Z) / 400))
end
function D.Couvert(X, Z)
	local c = 0.85 - 0.4 * Lisse(-Z / 2400)
	local function cl(p, r) return 0.5 * (1 - Lisse(sqrt((X - p.X) ^ 2 + (Z - p.Z) ^ 2) / r)) end
	c -= cl(C.Tour, 90) + cl(C.Station, 90)
	c -= 0.8 * D.WCendre(X, Z)
	return clamp(c, 0.05, 1)
end
function D.AltRoche(Z)
	return 330 + 90 * Lisse(-Z / 2500) + 200 * Lisse((-Z - 2500) / 1500)
end

return D
