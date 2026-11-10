--[[ S3Donnees : geometrie du secteur S3 Nord-est (X 1400..4000, Z -2500..1700 ; la bande Z 1400..1700 reecrit le bord nord de S7).
 Coordonnees MONDE (X = x-4000, Z = y-4000). D.Colonne(X,Z) -> h, genre, niveauEau, gorge, hum, sable (meme contrat que S7/S4).
 Raccords : S7 (sud) = chaine du ruisseau PROLONGEE vers l'amont (meme bedC/largeur a la jonction) + fondu vers S7.Colonne (Z 1580..1700) ;
 S4 (ouest) = fondu de la contribution de S4 (ruisseau, marge nord) sur 300 studs depuis X=1400. ]]
local H = require(script.Parent.HauteurGlobale)
local S4 = require(script.Parent.S4Donnees)
local S7 = require(script.Parent.S7Donnees)
local noise, Lisse, clamp, sqrt = math.noise, H.Lisse, math.clamp, math.sqrt
local SEED = H.Config.Graine
local D = {}

D.Cfg = {
	XMin = 1400, XMax = 4000, ZMin = -2500, ZMax = 1700, -- terrain construit
	Marge = 100, ChuteMarge = 45, -- bord nord (Z=-2500) : le sol descend de 45 sur 100
	Larg4 = 300, -- largeur du fondu vers S4 (X 1400..1700)
	Raccord7 = { Z0 = 1580, Z1 = 1700 }, -- fondu vers S7.Colonne
	LaharNord = { Debut = -1200, Fin = -1500 }, -- le lahar s'efface vers la gorge
	-- ruisseau : de la source (pied de falaise, gorge d'Ape Canyon) a la jonction avec S7 (2550,1500)
	PtsRuisseau = { {2690,-1950},{2690,-1700},{2685,-1450},{2680,-1150},{2700,-800},{2720,-450},{2730,-100},{2720,300},{2700,700},{2640,1000},{2560,1250},{2530,1380},{2550,1500} },
	Cascades = { {500, 10}, {2350, 5} }, -- {abscisse curviligne depuis la source, chute}
	Gorge = { S0 = 60, S1 = 1250, Fondu = 500, Prof = 55 }, -- gorge pleine de S0 a S1 puis s'ouvre
	LargeurSource = 12, PenteMin = 0.0045, PenteMax = 0.07,
	Ruine = { X = 2615, Z = -1400, Demi = 25, Fondu = 35 },
	Mine = { X = 3300, Z = -75, Fx = 0, Fz = -1, Demi = 20, --[[ site choisi par recherche de pente (nominal ~3200,0) : entree vers le nord, mur au sud ]] Fondu = 30, Mur = 40, Raide = 10, Dos = 80 },
	Tour = { X = 3300, Z = 1000, Demi = 15, Fondu = 35, Rayon = 150 }, -- recentree sur la crete locale
	Gues = { {2720,70}, {2576,1200} }, -- passages a gue des sentiers (cuvette reduite a 1.4 : eau peu profonde, franchissable)
	SentierApe = { Demi = 2.4, Fondu = 14 }, SentierPetit = { Demi = 1.9, Fondu = 12 },
	PtsApe = { {2300,1600},{2345,1490},{2420,1330},{2450,1100},{2465,800},{2470,500},{2470,200},{2470,-100},{2490,-450},{2510,-800},{2540,-1100},{2590,-1330},{2615,-1400} },
	PtsMine = { {2470,0},{2600,40},{2720,70},{2850,30},{2980,-40},{3100,-130},{3220,-175},{3300,-150},{3300,-100},{3300,-75} },
	PtsTourApe = { {3300,1000},{3100,1050},{2900,1110},{2760,1140},{2640,1170},{2560,1210},{2480,1270},{2420,1330} },
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
-- index grossier (1 sommet sur k) : evite de tester tous les segments pour chaque colonne
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
-- plus proche point du chemin : renvoie d, i, f (nil si plus loin que rmax)
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

-- ===== Lahar (2) : meme fonction que S7 (NiveauLahar globale de Z), s'efface vers le nord (Z -1200..-1500) =====
local function lahar(X, Z)
	local h = H.H(X, Z)
	local genre
	local L = S7.Cfg.Lahar
	local xmin = L.XMin + 40 * noise(Z / 200 + 0.3, 2.2, SEED)
	local xmax = L.XMax + 40 * noise(Z / 230 + 5.1, 3.3, SEED)
	local out = math.max(xmin - X, X - xmax, 0)
	if out >= L.Fondu then return h, genre end
	local N = C.LaharNord
	local tl = (1 - Lisse(out / L.Fondu)) * (1 - Lisse((Z - L.ZFin) / L.ZFondu)) * (1 - Lisse((N.Debut - Z) / (N.Debut - N.Fin)))
	if tl > 0 then
		local lv = S7.NiveauLahar(Z) + 1.5 * noise(X / 25 + 0.2, Z / 25 + 0.7, SEED)
		h += (lv - h) * tl
		if tl > 0.6 then genre = "lahar" elseif tl > 0.1 then genre = "laharbord" end
	end
	return h, genre
end

-- ===== Ruisseau : chaine S3 (source -> jonction) + chaine de S7 ; niveau du lit strictement decroissant =====
local function construireRuisseau()
	local ch = creerChemin(C.PtsRuisseau, 20, 8)
	local P, n = ch.P, #ch.P
	local SJ = ch.S[n]
	local copie = {}
	for i = 1, n do copie[i] = { P[i][1], P[i][2] } end
	for i = 2, n - 1 do -- meandres, nuls a la source et pres de la jonction
		local tx, tz = copie[i + 1][1] - copie[i - 1][1], copie[i + 1][2] - copie[i - 1][2]
		local l = sqrt(tx * tx + tz * tz)
		local off = 18 * noise(ch.S[i] / 200 + 0.5, 7.7, SEED) * Lisse(ch.S[i] / 150) * Lisse((SJ - ch.S[i]) / 350)
		P[i] = { copie[i][1] - tz / l * off, copie[i][2] + tx / l * off }
	end
	cumul(ch)
	SJ = ch.S[n]
	local G, F7 = C.Gorge, S7.Ruisseau.F
	local function cumCasc(s)
		local c = 0
		for _, k in ipairs(C.Cascades) do c += k[2] * Lisse((s - k[1]) / 10 + 0.5) end
		return c
	end
	local moy, g, cum = {}, {}, {}
	for i = 1, n do
		local a, c = 0, 0
		for j = math.max(1, i - 12), math.min(n, i + 12) do a += H.Basse(P[j][1], P[j][2]); c += 1 end
		moy[i] = a / c
		local s = ch.S[i]
		g[i] = Lisse((s - G.S0) / 120) * (1 - Lisse((s - G.S1) / G.Fondu))
		cum[i] = cumCasc(s)
	end
	-- lit : on part de la jonction (bedC fixe de S7) et on remonte (monotone par construction)
	local bedNo = {}
	bedNo[n] = F7[1].bedC + cum[n]
	for i = n - 1, 1, -1 do
		local ds = ch.S[i + 1] - ch.S[i]
		local want = moy[i] - 6 - g[i] * G.Prof + cum[i]
		bedNo[i] = clamp(want, bedNo[i + 1] + C.PenteMin * ds, bedNo[i + 1] + C.PenteMax * ds)
	end
	ch.F = {}
	for i = 1, n do
		local s = ch.S[i]
		local nz = noise(s / 150 + 0.3, 4.1, SEED)
		local sw = C.LargeurSource + (F7[1].sw - C.LargeurSource) * Lisse(s / SJ) -- 12 -> 20 (S7 : 20 a s=0)
		local hwG = 12 + 10 * (nz + 0.5)
		local hw = (sw / 2 + 3) + g[i] * (hwG - (sw / 2 + 3))
		local bedC = bedNo[i] - cum[i]
		local wj = 1 - Lisse((SJ - s) / 300)
		local rimC = clamp(moy[i], bedC + 5 + g[i] * G.Prof, bedC + 12 + g[i] * G.Prof)
		local rim = F7[1].rim * wj + rimC * (1 - wj)
		local prof = rim - bedC
		local ww = (1 - g[i]) * clamp(prof * 1.3, 10, 60) + g[i] * 3
		ch.F[i] = { s = s, g = g[i], sw = sw, hw = hw, ww = ww, bedC = bedC, rim = rim }
	end
	ch.F[n] = F7[1]
	-- on colle la chaine de S7 (sans son premier point = jonction)
	local P7 = S7.Ruisseau.P
	for j = 2, #P7 do
		P[#P + 1] = P7[j]
		ch.F[#ch.F + 1] = F7[j]
	end
	D.NbS3 = n
	return indexer(ch, 8)
end
D.Ruisseau = construireRuisseau()

local function ruisseau(h, genre, X, Z)
	local eau, gor, hum, sable = nil, 0, 0, false
	local R = D.Ruisseau
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
					local cuv = S7.Cfg.Cuvette
					for _, gu in ipairs(C.Gues) do
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
	end
	return h, genre, eau, gor, hum, sable
end

-- ===== Pates plates (ruine, tour) et mine =====
local function distRect(p, X, Z)
	local dx, dz = math.max(math.abs(X - p.X) - p.Demi, 0), math.max(math.abs(Z - p.Z) - p.Demi, 0)
	return sqrt(dx * dx + dz * dz)
end
local function pate(p, y, X, Z, h, genre)
	local d = distRect(p, X, Z)
	if d >= p.Fondu then return h, genre end
	h += (y - h) * (1 - Lisse(d / p.Fondu))
	if d == 0 then genre = "aire" end
	return h, genre
end
do -- tour : recentrer sur le point haut local (crete)
	local T, best = C.Tour, -1e9
	local bx, bz = T.X, T.Z
	for dx = -T.Rayon, T.Rayon, 10 do
		for dz = -T.Rayon, T.Rayon, 10 do
			if dx * dx + dz * dz <= T.Rayon ^ 2 then
				local v = H.H(T.X + dx, T.Z + dz) - 0.02 * sqrt(dx * dx + dz * dz)
				if v > best then best, bx, bz = v, T.X + dx, T.Z + dz end
			end
		end
	end
	T.X, T.Z = bx, bz
	T.Y = math.floor(H.H(bx, bz) / 4) * 4
end
C.PtsMineTour = { {3300,-75},{3300,-150},{3390,-120},{3440,0},{3420,300},{3380,600},{3370,900},{C.Tour.X, C.Tour.Z} }
C.PtsTourApe[1] = { C.Tour.X, C.Tour.Z }
do
	local Rn = C.Ruine
	local h0 = ruisseau(lahar(Rn.X, Rn.Z), nil, Rn.X, Rn.Z)
	Rn.Y = round4(h0)
	local M = C.Mine
	M.Y = round4(H.H(M.X, M.Z) - 4)
end
local function mine(h, genre, X, Z)
	local P = C.Mine
	local dx, dz = X - P.X, Z - P.Z -- l'entree s'ouvre vers F=(Fx,Fz) ; u > 0 = derriere (le mur)
	local u = -(dx * P.Fx + dz * P.Fz)
	local av = math.abs(-dx * P.Fz + dz * P.Fx)
	if av >= P.Demi + P.Fondu then return h, genre end
	if u < P.Demi then
		local du, dv = math.max(-u - P.Demi, 0), math.max(av - P.Demi, 0)
		local d = sqrt(du * du + dv * dv)
		if d >= P.Fondu then return h, genre end
		h += (P.Y - h) * (1 - Lisse(d / P.Fondu))
		if d == 0 then genre = "aire" end
		return h, genre
	end
	local mv = 1 - Lisse((av - P.Demi) / P.Fondu)
	local uu = u - P.Demi
	local mur = P.Y + P.Mur * Lisse(uu / P.Raide)
	local tgt = mur + (h - mur) * Lisse((uu - P.Raide - 10) / P.Dos)
	h += (tgt - h) * mv
	if mv > 0.5 and uu < P.Raide + 25 then genre = "gorge" end
	return h, genre
end

-- ===== Sentiers : profil = surface (H + lahar) lissee le long du chemin, extremites ramenees aux pates =====
local function profil(ch)
	local n, y = #ch.P, {}
	for i = 1, n do y[i] = (lahar(ch.P[i][1], ch.P[i][2])) end
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
D.Ape = creerChemin(C.PtsApe, 12, 6)
D.SMine = creerChemin(C.PtsMine, 12, 6)
D.SMineTour = creerChemin(C.PtsMineTour, 12, 6)
D.STourApe = creerChemin(C.PtsTourApe, 12, 6)
for _, ch in ipairs({ D.Ape, D.SMine, D.SMineTour, D.STourApe }) do profil(ch) end
relier(D.Ape, C.PtsApe[1][1], C.PtsApe[1][2], S7.Sentier.Y[#S7.Sentier.Y], 100) -- raccord au sentier de S7
relier(D.Ape, C.Ruine.X, C.Ruine.Z, C.Ruine.Y, 110)
relier(D.SMine, C.Mine.X, C.Mine.Z, C.Mine.Y, 110)
relier(D.SMineTour, C.Mine.X, C.Mine.Z, C.Mine.Y, 110)
relier(D.SMineTour, C.Tour.X, C.Tour.Z, C.Tour.Y, 110)
relier(D.STourApe, C.Tour.X, C.Tour.Z, C.Tour.Y, 110)
-- les points d'attache sur le sentier d'Ape Canyon prennent la hauteur de ce sentier
do
	local d, i, f = proche(D.Ape, 2470, 0, nil)
	local y = D.Ape.Y[i] + (D.Ape.Y[i + 1] - D.Ape.Y[i]) * f
	for _, ch in ipairs({ D.SMine }) do relier(ch, 2470, 0, y, 90) end
	d, i, f = proche(D.Ape, 2420, 1330, nil)
	y = D.Ape.Y[i] + (D.Ape.Y[i + 1] - D.Ape.Y[i]) * f
	relier(D.STourApe, 2420, 1330, y, 90)
end
D.S7Sentier = indexer({ P = S7.Sentier.P, Y = S7.Sentier.Y }, 6)

local function appliquer(ch, demi, fondu, X, Z, h, genre)
	local d, i, f = proche(ch, X, Z, demi + fondu)
	if not d or d > demi + fondu then return h, genre end
	local y = ch.Y[i] + (ch.Y[i + 1] - ch.Y[i]) * f
	h += (y - h) * (1 - Lisse((d - demi) / fondu))
	local dn = d + (0.25 * demi + 0.5) * noise(X / 7 + 0.9, Z / 7 + 0.4, SEED) * 2
	if d <= demi + 1.2 or dn <= demi - 0.8 then genre = "sentier" elseif dn <= demi + 3 and genre ~= "sentier" then genre = "sentier_bord" end
	return h, genre
end

-- ===== Surface complete de S3 (sans marges ni raccords) =====
local function surface3(X, Z)
	local h, genre = lahar(X, Z)
	local Sa, Sp = C.SentierApe, C.SentierPetit
	h, genre = appliquer(D.Ape, Sa.Demi, Sa.Fondu, X, Z, h, genre)
	if X > 2400 then
		h, genre = appliquer(D.SMine, Sp.Demi, Sp.Fondu, X, Z, h, genre)
		h, genre = appliquer(D.SMineTour, Sp.Demi, Sp.Fondu, X, Z, h, genre)
		h, genre = appliquer(D.STourApe, Sp.Demi, Sp.Fondu, X, Z, h, genre)
	end
	if Z > 1450 then
		if X > 1300 and X < 1760 then h, genre = S4.AppliquerSentierEst(h, genre, X, Z) end
		if X < 2900 then h, genre = appliquer(D.S7Sentier, S7.Cfg.Sentier.Demi, S7.Cfg.Sentier.Fondu, X, Z, h, genre) end
	end
	local eau, gor, hum, sable
	h, genre, eau, gor, hum, sable = ruisseau(h, genre, X, Z)
	if math.abs(X - C.Ruine.X) < C.Ruine.Demi + C.Ruine.Fondu and math.abs(Z - C.Ruine.Z) < C.Ruine.Demi + C.Ruine.Fondu then
		h, genre = pate(C.Ruine, C.Ruine.Y, X, Z, h, genre)
	end
	if math.abs(X - C.Tour.X) < C.Tour.Demi + C.Tour.Fondu and math.abs(Z - C.Tour.Z) < C.Tour.Demi + C.Tour.Fondu then
		h, genre = pate(C.Tour, C.Tour.Y, X, Z, h, genre)
	end
	if math.abs(X - C.Mine.X) < 150 and math.abs(Z - C.Mine.Z) < 150 then h, genre = mine(h, genre, X, Z) end
	return h, genre, eau, gor, hum, sable
end
D.Surface3 = surface3

function D.Colonne(X, Z)
	local h, genre, eau, gor, hum, sable = surface3(X, Z)
	-- raccord ouest avec S4 : contribution de S4 (ruisseau) et marge nord de S4, fondues sur Larg4
	local w4 = 1 - Lisse((X - C.XMin) / C.Larg4)
	if w4 > 0 then
		if Z < 800 then h += (S4.Surface(X, Z) - H.H(X, Z)) * w4 end
		local tp = 1 - Lisse((Z - S4.Cfg.ZMin) / S4.Cfg.Marge)
		local fn = 1 - Lisse((S4.Cfg.ZMin - Z) / 300)
		h -= S4.Cfg.ChuteMarge * tp * tp * fn * w4
	end
	-- raccord sud avec S7 (la bande Z 1400..1700 est reecrite)
	local R7 = C.Raccord7
	if Z > R7.Z0 then
		local w = Lisse((Z - R7.Z0) / (R7.Z1 - R7.Z0))
		local h7, g7, e7, o7, hu7, sa7 = S7.Colonne(X, Z)
		h = h + (h7 - h) * w
		if w > 0.5 then genre, eau, gor, hum, sable = g7, e7, o7, hu7, sa7 end
		if eau and h >= eau - 0.3 then eau = nil end
	end
	-- bord nord en pente douce
	local tn = 1 - Lisse((Z - C.ZMin) / C.Marge)
	h -= C.ChuteMarge * tn * tn
	return h, genre, eau, gor, hum, sable
end

-- couvert forestier suppose (0..1) : decroit vers le volcan, clairieres autour des lieux
function D.Couvert(X, Z)
	local c = 0.85 - 0.4 * Lisse(-Z / 2400)
	local function cl(p, r) return 0.5 * (1 - Lisse(sqrt((X - p.X) ^ 2 + (Z - p.Z) ^ 2) / r)) end
	c -= cl(C.Ruine, 90) + cl(C.Mine, 90) + cl(C.Tour, 90)
	return clamp(c, 0.1, 1)
end
-- altitude a partir de laquelle la roche apparait (le nord est haut : on monte le seuil)
function D.AltRoche(Z)
	return 330 + 90 * Lisse(-Z / 2500)
end

return D
