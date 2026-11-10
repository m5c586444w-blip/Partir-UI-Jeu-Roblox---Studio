--[[ S7Donnees : geometrie du secteur S7 (ruisseau R2 de Lava Canyon, lahar, route 83, sentier, parking, pont).
 Coordonnees MONDE (X = x-4000, Z = y-4000). D.Colonne(X,Z) -> h, genre, niveauEau, gorge, hum, sable
 A1 (10/11/2026) : alignement bible 3.2/3.5 : relief = HauteurEST (H + Alignement_EST.Delta) ; R2 = ruisseau de la bible
 (3067,-1600) -> ... -> (3733,4000) passant par P16 (3467,1600) eau 100 / tablier 150 et P03 (3200,2200) bord 110 / fond 40.
 D.R2 contient TOUTE la chaine R2 (y compris la partie nord, dans la boite de S3) : S3 l'applique aussi. ]]
local H = require(script.Parent.HauteurEST)
local S4 = require(script.Parent.S4Donnees)
local AE = require(script.Parent.Alignement_EST)
local noise, Lisse, clamp, sqrt = math.noise, H.Lisse, math.clamp, math.sqrt
local SEED = H.Config.Graine
local D = {}

D.Cfg = {
	XMin = 1400, XMax = 4000, ZMin = 1400, ZMax = 4000, -- terrain construit
	Marge = 100, ChuteMarge = 0,
	Lahar = { XMin = 1800, XMax = 2400, ZFin = 3500, ZFondu = 150, Fondu = 120, Creux = 6 },
	Cuvette = 7, -- creux du lit (studs) : le sol au centre = bedC - 7, l'eau = bedC - 0.5
	Route = { Demi = 9, Fondu = 45 }, -- bible RD1 : 18 de large
	Sentier = { Demi = 3, Fondu = 14 }, -- bible T1 : 6 de large (DEFAUT : meme largeur pour le raccord S4 prolonge)
	Parking = { X0 = 2765, X1 = 2835, Z0 = 3172, Z1 = 3229, Fondu = 55 }, -- centre (2800,3200) = P01
	-- R2 : points de passage (Catmull-Rom). Bible : bezier (3067,-1600)->(3467,0)->(3067,1200)->(3467,2400) puis ->(3667,3067)->(3600,3600)->(3733,4000).
	-- DEFAUT : la bezier passe a ~157 studs a l'ouest de P16 et a 230 de P03 : le trace est force par P16 (3467,1600) et P03 (3200,2200) (tableau 3.2 prime).
	PtsR2 = { {3067,-1600},{3150,-1150},{3223,-685},{3265,154},{3268,934},{3380,1330},{3467,1600},{3400,1870},{3200,2200},{3340,2330},{3467,2420},{3540,2700},{3583,3009},{3650,3560},{3733,4000},{3790,4150} },
	Largeur = { Source = 8, P16 = 16, Fin = 22 }, -- bible : 8 -> 16 -> 22
	Cles = { P16 = { Z = 1600, bed = 100.5 }, P03 = { Z = 2200, bed = 41.5 }, Fin = { Z = 4150, bed = 20 } }, -- bed = niveau du lit (eau = bed-0.5 = 100 a P16) ; sol au centre = bed-7 (P03 : fond 40)
	Gorge = { Z0 = 1380, F0 = 220, Z1 = 2450, F1 = 200 }, -- gorge de Lava Canyon : Z 1600..2600 (bible) : pleine de 1600 a 2450 puis fondu
	PenteMin = 0.0045, PenteMax = 0.14, -- DEFAUT : rapides a 14 % max en amont de P16
	Cascades = { {-1200,10},{-400,12},{300,8},{1700,6},{1820,8},{1950,7},{2060,9},{2150,6},{2480,6},{2620,5} }, -- {Z, chute}
	PtsRoute = { {4150,3480},{3800,3470},{3500,3420},{3200,3330},{2950,3260},{2800,3200},{2850,2950},{2940,2700},{3040,2480},{3110,2300},{3120,2250} },
	-- A1 phase B : T1 selon la bible 3.5 : P01 -> (2400,1867) -> jonction (2330,1590) = S3.Cfg.PtsApe[1] (DEFAUT PROPOSE : le long du bord est du lahar ; trace choisi par recherche A* + coupe max 7 studs)
	PtsSentier = { {2800,3172},{2750,3125},{2660,3090},{2560,3030},{2480,2930},{2420,2800},{2400,2500},{2395,2200},{2400,1867},{2330,1590} },
	PtsSpur = { {3120,2250},{3170,2080},{3260,1900},{3340,1760},{3414,1600} }, -- depart de la route 83 -> rive ouest du pont P16
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
-- plus proche point du chemin : d, i, f (nil si plus loin que rmax)
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
D.CreerChemin = creerChemin
D.Indexer = indexer

-- ===== R2 : chaine complete, lit decroissant vers l'aval =====
local function construireR2()
	local ch = creerChemin(C.PtsR2, 20, 8)
	local P, n = ch.P, #ch.P
	local copie = {}
	for i = 1, n do copie[i] = { P[i][1], P[i][2] } end
	for i = 2, n - 1 do -- meandres, annules pres de P16 / P03 (le pont et le fond de gorge restent a leur place)
		local tx, tz = copie[i + 1][1] - copie[i - 1][1], copie[i + 1][2] - copie[i - 1][2]
		local l = sqrt(tx * tx + tz * tz)
		local z = copie[i][2]
		local keep = 1 - math.max(math.exp(-((z - 1600) / 90) ^ 2), math.exp(-((z - 2200) / 90) ^ 2))
		local off = 12 * noise(ch.S[i] / 180 + 0.4, 6.6, SEED) * Lisse(ch.S[i] / 150) * keep
		P[i] = { copie[i][1] - tz / l * off, copie[i][2] + tx / l * off }
	end
	cumul(ch)
	local function sOfZ(Z) -- abscisse du premier point dont Z depasse la valeur
		for i = 1, n do if P[i][2] >= Z then return ch.S[i], i end end
		return ch.S[n], n
	end
	local sP16, iP16 = sOfZ(C.Cles.P16.Z)
	local _, iP03 = sOfZ(C.Cles.P03.Z)
	local _, iFin = sOfZ(C.Cles.Fin.Z)
	local cum, g, Dg, moy = {}, {}, {}, {}
	local Gz = C.Gorge
	for i = 1, n do
		local z = P[i][2]
		local c = 0
		for _, k in ipairs(C.Cascades) do c += k[2] * Lisse((z - k[1]) / 10 + 0.5) end
		cum[i] = c
		g[i] = Lisse((z - Gz.Z0) / Gz.F0) * (1 - Lisse((z - Gz.Z1) / Gz.F1))
		Dg[i] = 44 + 14 * Lisse((z - 1600) / 600) - 18 * Lisse((z - 2250) / 350) -- profondeur de gorge (P16 : 44 -> rim 150 ; P03 : 58 -> bord 110)
		local a, cnt = 0, 0
		for j = math.max(1, i - 12), math.min(n, i + 12) do a += H.Basse(P[j][1], P[j][2]); cnt += 1 end
		moy[i] = a / cnt
	end
	local bedNo = {}
	local K = C.Cles
	bedNo[iP16] = K.P16.bed + cum[iP16]
	for i = iP16 - 1, 1, -1 do -- amont de P16 : relief a grande echelle, pente bornee (monotone par construction)
		local ds = ch.S[i + 1] - ch.S[i]
		local want = moy[i] - 6 + cum[i]
		bedNo[i] = clamp(want, bedNo[i + 1] + C.PenteMin * ds, bedNo[i + 1] + C.PenteMax * ds)
	end
	local L16, L03, LFin = K.P16.bed + cum[iP16], K.P03.bed + cum[iP03], K.Fin.bed + cum[iFin]
	for i = iP16 + 1, n do -- aval : droites entre les cles (P16 -> P03 -> sortie), cascades en plus
		local s = ch.S[i]
		local s16, s03, sF = ch.S[iP16], ch.S[iP03], ch.S[iFin]
		if s <= s03 then bedNo[i] = L16 + (L03 - L16) * (s - s16) / (s03 - s16)
		elseif s <= sF then bedNo[i] = L03 + (LFin - L03) * (s - s03) / (sF - s03)
		else bedNo[i] = LFin - 0.0044 * (s - sF) end
	end
	ch.F = {}
	local W = C.Largeur
	for i = 1, n do
		local s = ch.S[i]
		local nz = noise(s / 150 + 0.3, 4.1, SEED)
		local sw = W.Source + (W.P16 - W.Source) * Lisse(s / sP16) + (W.Fin - W.P16) * Lisse((s - sP16) / (ch.S[n] - sP16))
		local hwG = 36 + 8 * nz * Lisse((P[i][2] - 1750) / 150) -- demi-largeur du fond de gorge (36 a P16 pour le pont de 106)
		local hw = (sw / 2 + 3) + g[i] * (hwG - (sw / 2 + 3))
		local bedC = bedNo[i] - cum[i]
		local lo = bedC + 5 + g[i] * Dg[i]
		local rim = clamp(moy[i], lo, lo + 7)
		local prof = rim - bedC
		local ww = (1 - g[i]) * clamp(prof * 1.3, 10, 60) + g[i] * 3
		ch.F[i] = { s = s, g = g[i], sw = sw, hw = hw, ww = ww, bedC = bedC, rim = rim }
	end
	ch.iP16, ch.iP03 = iP16, iP03
	return indexer(ch, 8)
end
D.R2 = construireR2()
D.Ruisseau = D.R2

-- ===== Pont (16) : plates-formes de rive a la meme hauteur (multiple de 4), de part et d'autre de la gorge =====
do
	local R = D.R2
	local i = R.iP16
	local a, b = R.P[i - 1], R.P[i + 1]
	local cx, cz = R.P[i][1], R.P[i][2]
	local tx, tz = b[1] - a[1], b[2] - a[2]
	local l = sqrt(tx * tx + tz * tz)
	tx, tz = tx / l, tz / l
	local nx, nz = -tz, tx
	if nx < 0 then nx, nz = -nx, -nz end -- N pointe vers l'est
	local F = R.F[i]
	local wl = F.hw + F.ww
	local dr = wl + 14
	D.Pont = { Centre = { cx, cz }, N = { nx, nz }, T = { tx, tz }, Dr = dr, Y = math.floor(F.rim / 4 + 0.5) * 4, RPlein = 8, RFondu = 26,
		Pads = { { cx + nx * dr, cz + nz * dr }, { cx - nx * dr, cz - nz * dr } } } -- Pads[1] = rive est, Pads[2] = rive ouest
end
local function pont(h, X, Z)
	local Pt = D.Pont
	for k = 1, 2 do
		local c = Pt.Pads[k]
		local d = sqrt((X - c[1]) ^ 2 + (Z - c[2]) ^ 2)
		if d < Pt.RFondu then h += (Pt.Y - h) * (1 - Lisse((d - Pt.RPlein) / (Pt.RFondu - Pt.RPlein))) end
	end
	return h
end

-- ===== Niveau du lit du lahar : fonction GLOBALE de Z (origine Z=-1500), monotone decroissante. Suit H.Basse + Delta (aligne P02) =====
local ZL0 = -1500
local niveauL = {}
do
	local prev
	for i = 0, 280 do
		local v = H.Basse(2100, ZL0 + i * 20) - C.Lahar.Creux
		if prev then v = math.min(v, prev - 0.2) end
		niveauL[i] = v
		prev = v
	end
end
function D.NiveauLahar(Z)
	local u = clamp((Z - ZL0) / 20, 0, 279.99)
	local i = math.floor(u)
	return niveauL[i] + (niveauL[i + 1] - niveauL[i]) * (u - i)
end

-- ===== Application du ruisseau R2 (utilisee aussi par S3 pour sa partie nord) =====
function D.AppliquerR2(h, genre, X, Z, avecPont)
	local eau, gor, hum, sable = nil, 0, 0, false
	local R = D.R2
	local d, i, f = proche(R, X, Z, 420)
	if not d then return h, genre, eau, gor, hum, sable end
	local a, b = R.F[i], R.F[i + 1]
	local function lp(k) return a[k] + (b[k] - a[k]) * f end
	local g, hw, ww, sw, rim, bedC = lp("g"), lp("hw"), lp("ww"), lp("sw"), lp("rim"), lp("bedC")
	local t = 1 - Lisse((d - (hw + ww)) / (10 + 240 + 110 * g))
	if t > 0 then
		h += (rim - h) * t
		gor = g
		hum = 1 - Lisse((d - sw / 2 - 2) / 45)
		sable = sw > 40
		genre = (g > 0.35 and d < hw + ww + 14) and "gorge" or genre
		if d < hw + ww + 14 then
			local dd = d + 4 * g * noise(X / 16 + 0.1, Z / 16 + 0.9, SEED) -- paroi irreguliere
			if d < hw + ww then
				local gr = H.CreuserGorge(dd, bedC, rim, hw, ww)
				if dd < sw / 2 then
					local q = 2 * dd / sw
					local cuv = D.Cfg.Cuvette
					for _, gu in ipairs(D.Gues or {}) do
						local dg = sqrt((X - gu[1]) ^ 2 + (Z - gu[2]) ^ 2)
						if dg < 45 then cuv *= 1 - 0.8 * (1 - Lisse((dg - 12) / 33)) end
					end
					gr -= cuv * (1 - q * q)
				elseif dd < hw then
					gr += 1.0 * noise(X / 9 + 0.5, Z / 9 + 0.5, SEED)
				end
				h = gr
				local wt = bedC - 0.5
				if gr < wt - 0.3 then eau = wt end
				if g <= 0.35 and dd < sw / 2 + 7 + 7 * noise(X / 10 + 0.3, Z / 10 + 0.6, SEED) then genre = "berge" end
			end
		end
		if avecPont and d > hw + ww + 5 and math.abs(X - D.Pont.Centre[1]) < 120 and math.abs(Z - D.Pont.Centre[2]) < 120 then h = pont(h, X, Z) end
	end
	return h, genre, eau, gor, hum, sable
end
D.Gues = { {3225,-520} } -- gue de R2 sur le sentier T4 (mine -> ruine) ; S3 en ajoute d'autres

-- ===== Surface avant routes : relief + lahar + R2 =====
function D.Surface0(X, Z)
	local h = H.H(X, Z)
	local genre
	local L = C.Lahar
	local xmin = L.XMin + 40 * noise(Z / 200 + 0.3, 2.2, SEED)
	local xmax = L.XMax + 40 * noise(Z / 230 + 5.1, 3.3, SEED)
	local out = math.max(xmin - X, X - xmax, 0)
	local tl = (1 - Lisse(out / L.Fondu)) * (1 - Lisse((Z - L.ZFin) / L.ZFondu))
	if tl > 0 then
		local lv = D.NiveauLahar(Z) + 1.5 * noise(X / 25 + 0.2, Z / 25 + 0.7, SEED)
		h += (lv - h) * tl
		if tl > 0.6 then genre = "lahar" elseif tl > 0.1 then genre = "laharbord" end
	end
	local eau, gor, hum, sable
	h, genre, eau, gor, hum, sable = D.AppliquerR2(h, genre, X, Z, true)
	return h, genre, eau, gor, hum, sable
end

-- ===== Route 83, sentier, parking, spur du pont : profils lisses (arasement progressif) =====
local function profil(ch)
	local n, y = #ch.P, {}
	for i = 1, n do y[i] = D.Surface0(ch.P[i][1], ch.P[i][2]) end
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
-- Graduer : limite la pente du profil ch.Y a mx (deblai/remblai). y0/y1 = valeurs imposees au debut/a la fin (nil = libre) ;
-- ipin = indice d'un point impose au milieu (balayages vers les deux extremites). Les cones d'accessibilite garantissent les deux bouts.
function D.Graduer(ch, mx, y0, y1, ipin)
	local Y, S, n = ch.Y, ch.S, #ch.Y
	if ipin then
		for i = ipin + 1, n do local ds = S[i] - S[i - 1]; Y[i] = clamp(Y[i], Y[i - 1] - mx * ds, Y[i - 1] + mx * ds) end
		for i = ipin - 1, 1, -1 do local ds = S[i + 1] - S[i]; Y[i] = clamp(Y[i], Y[i + 1] - mx * ds, Y[i + 1] + mx * ds) end
		return
	end
	if y1 then
		Y[n] = y1
		for i = n - 1, 1, -1 do local d = S[n] - S[i]; Y[i] = clamp(Y[i], y1 - mx * d, y1 + mx * d) end
	end
	if y0 then Y[1] = y0 end
	for i = 2, n do local ds = S[i] - S[i - 1]; Y[i] = clamp(Y[i], Y[i - 1] - mx * ds, Y[i - 1] + mx * ds) end
end
D.PenteRoute, D.PenteSentier = 0.08, 0.15 -- bible 3.7 : routes 8 %, sentiers 15 %
D.PenteT1 = 0.14 -- A1 phase B : T1 et sa branche P05 planifies a 14 % (marge pour le bruit de quantification des voxels ; mesure sur 24 studs <= 15 %)
D.Route = creerChemin(C.PtsRoute, 16, 6)
D.Sentier = creerChemin(C.PtsSentier, 12, 6)
D.Spur = creerChemin(C.PtsSpur, 12, 6)
profil(D.Route)
profil(D.Sentier)
profil(D.Spur)
do -- aire du parking : hauteur UNIQUE (multiple de 4)
	local P = C.Parking
	local _, ip = proche(D.Route, 2800, 3200)
	D.ParkingY = math.floor(D.Route.Y[ip] / 4 + 0.5) * 4
	for _, ch in ipairs({ D.Route, D.Sentier }) do
		for i = 1, #ch.P do
			local dx = math.max(P.X0 - ch.P[i][1], ch.P[i][1] - P.X1, 0)
			local dz = math.max(P.Z0 - ch.P[i][2], ch.P[i][2] - P.Z1, 0)
			local w = 1 - Lisse(sqrt(dx * dx + dz * dz) / (P.Fondu + 40))
			ch.Y[i] += (D.ParkingY - ch.Y[i]) * w
		end
	end
	do local _, ip = proche(D.Route, 2800, 3200); D.Graduer(D.Route, D.PenteRoute, nil, nil, ip) end
	D.Graduer(D.Sentier, D.PenteT1, D.ParkingY, nil)
	-- le spur rejoint la route (Y route) a son debut et la plate-forme ouest du pont a sa fin
	local sp = D.Spur
	local _, ir, fr = proche(D.Route, 3120, 2250)
	local yr = D.Route.Y[ir] + (D.Route.Y[ir + 1] - D.Route.Y[ir]) * fr
	for i = 1, #sp.P do
		local w1 = 1 - Lisse(sqrt((sp.P[i][1] - 3120) ^ 2 + (sp.P[i][2] - 2250) ^ 2) / 150)
		local w2 = 1 - Lisse(sqrt((sp.P[i][1] - D.Pont.Pads[2][1]) ^ 2 + (sp.P[i][2] - D.Pont.Pads[2][2]) ^ 2) / 150)
		sp.Y[i] += (yr - sp.Y[i]) * w1
		sp.Y[i] += (D.Pont.Y - sp.Y[i]) * w2
	end
	D.Graduer(sp, D.PenteSentier, yr, D.Pont.Y)
end

local function appliquer(ch, demi, fondu, X, Z, h, genre, nom)
	local d, i, f = proche(ch, X, Z, demi + fondu)
	if not d or d > demi + fondu then return h, genre end
	local y = ch.Y[i] + (ch.Y[i + 1] - ch.Y[i]) * f
	h += (y - h) * (1 - Lisse((d - demi) / fondu))
	local dn = d + (0.25 * demi + 0.5) * noise(X / 7 + 0.9, Z / 7 + 0.4, SEED) * 2 -- bord irregulier
	local coeur = (nom == "route") and (demi + 2) or (demi + 1.2) -- coeur sans bruit : axe 100 % continu
	if d <= coeur or dn <= demi - 0.8 then genre = nom elseif dn <= demi + 3 and genre ~= nom then genre = nom .. "_bord" end
	return h, genre
end

function D.Colonne(X, Z)
	local h, genre, eau, gor, hum, sable = D.Surface0(X, Z)
	if X > 2500 and Z > 2150 then
		h, genre = appliquer(D.Route, C.Route.Demi, C.Route.Fondu, X, Z, h, genre, "route")
		local P = C.Parking
		local dx, dz = math.max(P.X0 - X, X - P.X1, 0), math.max(P.Z0 - Z, Z - P.Z1, 0)
		local dp = sqrt(dx * dx + dz * dz)
		if dp < P.Fondu then
			h += (D.ParkingY - h) * (1 - Lisse(dp / P.Fondu))
			if dp <= 2 then genre = "route" end
		end
	end
	if X > 3000 and X < 3500 and Z > 1550 and Z < 2300 then
		local g0 = genre
		h, genre = appliquer(D.Spur, C.Sentier.Demi, C.Sentier.Fondu, X, Z, h, genre, "sentier")
		if g0 == "route" then genre = g0 end
	end
	if X < 2900 and Z < 3300 then
		local g0 = genre
		h, genre = appliquer(D.Sentier, C.Sentier.Demi, C.Sentier.Fondu, X, Z, h, genre, "sentier")
		if g0 == "route" then genre = g0 end
	end
	if X > 1300 and X < 1760 then -- sentier de S4 prolonge (relief S4 sans Delta : on retire puis remet Delta)
		local dl = AE.Delta(X, Z)
		local h2, g2 = S4.AppliquerSentierEst(h - dl, genre, X, Z)
		h, genre = h2 + dl, g2
	end
	local tp = 1 - math.min(Lisse((X - C.XMin) / C.Marge), Lisse((Z - C.ZMin) / C.Marge))
	h -= C.ChuteMarge * tp * tp
	return h, genre, eau, gor, hum, sable
end

D.Couvert = function(X, Z) -- couvert forestier suppose (0..1) : clairiere autour du parking
	local dp = sqrt((X - 2800) ^ 2 + (Z - 3200) ^ 2)
	return 0.72 - 0.4 * (1 - Lisse(dp / 160))
end

return D
