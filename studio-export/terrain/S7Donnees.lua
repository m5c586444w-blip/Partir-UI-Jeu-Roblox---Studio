--[[ S7Donnees : geometrie du secteur S7 (ruisseau de Lava Canyon, lahar, route 83, sentier, parking).
 Coordonnees MONDE (X = x-4000, Z = y-4000). D.Colonne(X,Z) -> h, genre, niveauEau, gorge ]]
local H = require(script.Parent.HauteurGlobale)
local S4 = require(script.Parent.S4Donnees)
local noise, Lisse, clamp = math.noise, H.Lisse, math.clamp
local SEED = H.Config.Graine
local D = {}

D.Cfg = {
	XMin = 1400, XMax = 4000, ZMin = 1400, ZMax = 4000, -- terrain construit
	Marge = 100, ChuteMarge = 0, -- ChuteMarge=0 : plus de marge (S4 a l'ouest, S3 au nord prolongent la meme fonction H)
	Lit = { {0,112}, {600,86}, {1146,64}, {2969,56} }, -- {abscisse, niveau du lit HORS cascades} (lineaire par morceaux, decroissant)
	ProfGorge = 36, -- profondeur supplementaire de gorge au-dessus du lit (le terrain autour est releve si besoin)
	Lahar = { XMin = 1800, XMax = 2400, ZFin = 3500, ZFondu = 150, Fondu = 120, Creux = 6 },
	Cuvette = 7, PenteRuisseau = 0.004, -- cuvette du lit (studs) ; pente mini du lit (descente garantie)
	Cascades = { {650, 6}, {760, 8}, {900, 5}, {1020, 9}, {1120, 6} }, -- {abscisse curviligne, chute en studs}
	Route = { Demi = 7, Fondu = 45 }, Sentier = { Demi = 2.4, Fondu = 14 },
	Parking = { X0 = 2765, X1 = 2835, Z0 = 3205, Z1 = 3262, Fondu = 55 },
	PtsRuisseau = { {2550,1500},{2900,1780},{3150,2000},{3250,2250},{3400,2650},{3500,3100},{3650,3500},{3800,3900},{3880,4150} },
	PtsRoute = { {2950,4150},{2950,3800},{2880,3500},{2800,3260},{2860,3000},{2960,2720},{3050,2500},{3090,2400} },
	PtsSentier = { {2800,3260},{2680,3050},{2560,2750},{2520,2400},{2470,2100},{2400,1800},{2300,1600} },
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

-- ===== Ruisseau de Lava Canyon (niveau du lit strictement decroissant) =====
local function construireRuisseau()
	local ch = creerChemin(C.PtsRuisseau, 20)
	local P = ch.P
	local copie = {}
	for i = 1, #P do copie[i] = { P[i][1], P[i][2] } end
	for i = 2, #P - 1 do -- meandres
		local tx, tz = copie[i + 1][1] - copie[i - 1][1], copie[i + 1][2] - copie[i - 1][2]
		local l = math.sqrt(tx * tx + tz * tz)
		local off = 14 * noise(ch.S[i] / 180 + 0.4, 6.6, SEED)
		P[i] = { copie[i][1] - tz / l * off, copie[i][2] + tx / l * off }
	end
	cumul(ch)
	ch.F = {}
	local moy = {} -- relief a grande echelle moyenne (+-250 studs) le long du ruisseau
	for i = 1, #P do
		local a, c = 0, 0
		for j = math.max(1, i - 12), math.min(#P, i + 12) do a += H.Basse(P[j][1], P[j][2]); c += 1 end
		moy[i] = a / c
	end
		for i = 1, #P do
		local s = ch.S[i]
		local g = Lisse((s - 250) / 350) * (1 - Lisse((s - 1150) / 350)) -- 1 = pleine gorge
		local nz = noise(s / 150 + 0.3, 4.1, SEED)
		local sw = 20 + 4 * g + 41 * Lisse((s - 1100) / 1100) -- largeur de l'eau
		local hwG = 22 + 16 * (nz + 0.5) -- demi-largeur du fond de gorge (22..38)
		local hw = (sw / 2 + 3) + g * (hwG - (sw / 2 + 3))
		local cum = 0
		for _, c in ipairs(C.Cascades) do cum += c[2] * Lisse((s - c[1]) / 10 + 0.5) end
		-- niveau du lit HORS cascades : descente imposee (pas de dependance au relief => jamais de vallee enfoncee)
		local base = C.Lit[#C.Lit][2] - 0.0044 * (s - C.Lit[#C.Lit][1]) -- au-dela du dernier point : pente mini
		for k = 1, #C.Lit - 1 do
			local a, b = C.Lit[k], C.Lit[k + 1]
			if s <= b[1] then base = a[2] + (b[2] - a[2]) * (s - a[1]) / (b[1] - a[1]) break end
		end
		local bedC = base - cum -- strictement decroissant : base decroit, cum croit
		local Dg = C.ProfGorge * (1 - Lisse((s - 750) / 500)) -- profondeur de gorge, decroit vers l'aval
		local rim = math.clamp(moy[i], bedC + 5 + g * Dg, bedC + 12 + g * Dg)
		local prof = rim - bedC
		local ww = (1 - g) * clamp(prof * 1.3, 10, 60) + g * 3 -- paroi : 3 studs en gorge, talus doux ensuite
		ch.F[i] = { s = s, g = g, sw = sw, hw = hw, ww = ww, bedC = bedC, rim = rim }
	end
	return ch
end
D.Ruisseau = construireRuisseau()

-- ===== Pont (16) : deux plates-formes de rive arasees a la meme hauteur (multiple de 4), hors de la gorge =====
do
	local R = D.Ruisseau
	local _, i, f = proche(R, 3163, 2018)
	local a, b = R.P[i], R.P[i + 1]
	local cx, cz = a[1] + (b[1] - a[1]) * f, a[2] + (b[2] - a[2]) * f
	local tx, tz = b[1] - a[1], b[2] - a[2]
	local l = math.sqrt(tx * tx + tz * tz)
	tx, tz = tx / l, tz / l
	local nx, nz = -tz, tx
	local Fa, Fb = R.F[i], R.F[i + 1]
	local wl = (Fa.hw + Fa.ww) + (Fb.hw + Fb.ww - Fa.hw - Fa.ww) * f
	local rim = Fa.rim + (Fb.rim - Fa.rim) * f
	local dr = wl + 14
	D.Pont = { Centre = { cx, cz }, N = { nx, nz }, Dr = dr, Y = math.floor(rim / 4 + 0.5) * 4, RPlein = 8, RFondu = 26,
		Pads = { { cx + nx * dr, cz + nz * dr }, { cx - nx * dr, cz - nz * dr } } }
end
local function pont(h, X, Z)
	local Pt = D.Pont
	for k = 1, 2 do
		local c = Pt.Pads[k]
		local d = math.sqrt((X - c[1]) ^ 2 + (Z - c[2]) ^ 2)
		if d < Pt.RFondu then h += (Pt.Y - h) * (1 - Lisse((d - Pt.RPlein) / (Pt.RFondu - Pt.RPlein))) end
	end
	return h
end

-- ===== Niveau du lit du lahar : fonction GLOBALE de Z (origine Z=-1500, nord de la carte du lahar), monotone decroissante =====
-- S3 (au nord) utilisera la meme fonction : pas de raccord a faire.
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

-- ===== Surface avant routes : relief + lahar + ruisseau/gorge =====
function D.Surface0(X, Z)
	local h = H.H(X, Z)
	local genre, eau, gor, hum, sable = nil, nil, 0, 0, false
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
	local R = D.Ruisseau
	local d, i, f = proche(R, X, Z)
	if d < 420 then
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
						gr -= D.Cfg.Cuvette * (1 - q * q)
					elseif dd < hw then
						gr += 1.0 * noise(X / 9 + 0.5, Z / 9 + 0.5, SEED)
					end
					h = gr
					local wt = bedC - 0.5
					if gr < wt - 0.3 then eau = wt end
					if g <= 0.35 and dd < sw / 2 + 7 + 7 * noise(X / 10 + 0.3, Z / 10 + 0.6, SEED) then genre = "berge" end
				end
			end
			if d > hw + ww + 5 and math.abs(X - D.Pont.Centre[1]) < 120 and math.abs(Z - D.Pont.Centre[2]) < 120 then h = pont(h, X, Z) end
		end
	end
	return h, genre, eau, gor, hum, sable
end

-- ===== Route 83, sentier, parking : profils lisses (arasement progressif) =====
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
D.Route = creerChemin(C.PtsRoute, 16)
D.Sentier = creerChemin(C.PtsSentier, 12)
profil(D.Route)
profil(D.Sentier)
do -- aire du parking : hauteur UNIQUE (multiple de 4 => voxels plats), route et sentier se raccordent a elle en douceur
	local P = C.Parking
	D.ParkingY = math.floor(D.Route.Y[select(2, proche(D.Route, 2800, 3250))] / 4 + 0.5) * 4
	for _, ch in ipairs({ D.Route, D.Sentier }) do
		for i = 1, #ch.P do
			local dx = math.max(P.X0 - ch.P[i][1], ch.P[i][1] - P.X1, 0)
			local dz = math.max(P.Z0 - ch.P[i][2], ch.P[i][2] - P.Z1, 0)
			local w = 1 - Lisse(math.sqrt(dx * dx + dz * dz) / (P.Fondu + 40))
			ch.Y[i] += (D.ParkingY - ch.Y[i]) * w
		end
	end
end

local function appliquer(ch, demi, fondu, X, Z, h, genre, nom)
	local d, i, f = proche(ch, X, Z)
	if d > demi + fondu then return h, genre end
	local y = ch.Y[i] + (ch.Y[i + 1] - ch.Y[i]) * f
	h += (y - h) * (1 - Lisse((d - demi) / fondu))
	local dn = d + (0.25 * demi + 0.5) * noise(X / 7 + 0.9, Z / 7 + 0.4, SEED) * 2 -- bord irregulier (le relief ne change pas)
	local coeur = (nom == "route") and (demi + 2) or (demi + 1.2) -- >= demi voxel (4 studs) pour garantir la continuite -- coeur sans bruit : axe 100 % continu
	if d <= coeur or dn <= demi - 0.8 then genre = nom elseif dn <= demi + 3 and genre ~= nom then genre = nom .. "_bord" end
	return h, genre
end

function D.Colonne(X, Z)
	local h, genre, eau, gor, hum, sable = D.Surface0(X, Z)
	if X > 2500 and Z > 2200 then
		h, genre = appliquer(D.Route, C.Route.Demi, C.Route.Fondu, X, Z, h, genre, "route")
		local P = C.Parking
		local dx, dz = math.max(P.X0 - X, X - P.X1, 0), math.max(P.Z0 - Z, Z - P.Z1, 0)
		local dp = math.sqrt(dx * dx + dz * dz)
		if dp < P.Fondu then
			h += (D.ParkingY - h) * (1 - Lisse(dp / P.Fondu))
			if dp <= 2 then genre = "route" end
		end
	end
	if X < 2900 and Z < 3300 then
		local g0 = genre -- la route / l'aire du parking gardent la priorite sur le sentier
		h, genre = appliquer(D.Sentier, C.Sentier.Demi, C.Sentier.Fondu, X, Z, h, genre, "sentier")
		if g0 == "route" then genre = g0 end
	end
	if X > 1300 and X < 1760 then h, genre = S4.AppliquerSentierEst(h, genre, X, Z) end -- sentier de S4 prolonge jusqu'au lahar
	-- bords nord/ouest en pente douce
	local tp = 1 - math.min(Lisse((X - C.XMin) / C.Marge), Lisse((Z - C.ZMin) / C.Marge))
	h -= C.ChuteMarge * tp * tp
	return h, genre, eau, gor, hum, sable
end

D.Couvert = function(X, Z) -- couvert forestier suppose (0..1) : clairiere autour du parking
	local dp = math.sqrt((X - 2800) ^ 2 + (Z - 3230) ^ 2)
	return 0.72 - 0.4 * (1 - Lisse(dp / 160))
end

return D
