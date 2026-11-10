--[[ S3Donnees : geometrie du secteur S3 Nord-est (X 1400..4000, Z -2500..1700 ; la bande Z 1400..1700 reecrit le bord nord de S7).
 Coordonnees MONDE (X = x-4000, Z = y-4000). D.Colonne(X,Z) -> h, genre, niveauEau, gorge, hum, sable (meme contrat que S7/S4).
 Raccords : S7 (sud) = chaine du ruisseau PROLONGEE vers l'amont (meme bedC/largeur a la jonction) + fondu vers S7.Colonne (Z 1580..1700) ;
 S4 (ouest) = fondu de la contribution de S4 (ruisseau, marge nord) sur 300 studs depuis X=1400. ]]
local H = require(script.Parent.HauteurEST) -- A1 : H et Basse + Alignement_EST.Delta
local HG = require(script.Parent.HauteurGlobale) -- relief brut (contribution de S4)
local AE = require(script.Parent.Alignement_EST)
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
	LaharNord = { Debut = -1500, Fin = -1800 }, -- le lahar s'efface vers la gorge
	-- ruisseau : de la source (pied de falaise, gorge d'Ape Canyon) a la jonction avec S7 (2550,1500)
	-- A1 : ruisseau d'Ape Canyon (affluent de R2) : fonte S8 -> gorge (P05s, P05) -> (2550,1500) -> rejoint R2 (S7) a (3380,1330)
	PtsRuisseau = { {2690,-1950},{2690,-1700},{2700,-1650},{2670,-1450},{2680,-1150},{2700,-800},{2720,-450},{2730,-100},{2720,300},{2700,700},{2640,1000},{2560,1250},{2530,1380},{2550,1500},{2850,1520},{3150,1450},{3380,1330} },
	-- lit absolu de la gorge (Z, niveau du lit) : P05s (2700,-1650) sol 330 (+7 de cuvette) ; P05 sol 250 (+7) ; rapides entre les deux
	CleLit = { {-2000,350},{-1700,342},{-1640,331},{-1420,252},{-1000,245},{-300,225},{500,200},{1000,185},{1500,165} }, -- DEFAUT : suite du lit jusqu'a (2550,1500)
	Cascades = { {200, 8}, {350, 10}, {2350, 5} }, -- {abscisse curviligne depuis la source, chute}
	Gorge = { S0 = 60, S1 = 1250, Fondu = 500, Prof = 170 }, -- gorge pleine de S0 a S1 puis s'ouvre ; Prof = profondeur maxi (bible : 150 a P05)
	LargeurSource = 12, PenteMin = 0.0045, PenteMax = 0.30, -- DEFAUT : rapides jusqu'a 30 % (P05s -> P05)
	Ruine = { X = 2550, Z = -1300, Y = 300, Demi = 25, Fondu = 35 }, -- P05c : corniche Y=300
	Mine = { X = 3333, Z = -667, Y = 390, Fx = 0, Fz = 1, Demi = 20, --[[ site choisi par recherche de pente (nominal ~3200,0) : entree vers le nord, mur au sud ]] Fondu = 30, Mur = 40, Raide = 10, Dos = 80 },
	Tour = { X = 3800, Z = 667, Y = 300, Demi = 15, Fondu = 35 }, -- P24 (bible : cabine +60)
	Gues = { {2725,-300} }, -- gue de l'affluent d'Ape sur T4 ; le gue de R2 est dans S7.Gues -- passages a gue des sentiers (cuvette reduite a 1.4 : eau peu profonde, franchissable)
	SentierApe = { Demi = 3, Fondu = 14 }, SentierPetit = { Demi = 2, Fondu = 12 }, -- bible : T1 6 de large, T4 4
	-- A1 phase B : T1 selon la bible 3.5 (P01 -> (2400,1867) -> (2200,267) -> P05 -> P06). Jonction (2330,1590) = fin de S7.PtsSentier ; sortie X=1500 en (1500,-2240) (suite vers P06 = ticket CENTRE).
	-- DEFAUT PROPOSE : trace le long du lit du lahar (bord est), passe a ~160 studs de P05 (dans son rayon 300), descend le coin NO du lahar par lacets (X 1650..1950) ; PtsP05 = branche vers P05.
	PtsApe = { {2330,1590},{2290,1300},{2270,1000},{2240,650},{2200,267},{2210,-100},{2260,-300},{2320,-480},{2330,-800},{2350,-1100},{2400,-1300},{2450,-1370},{2290,-1420},{2090,-1540},{2010,-1620},{1940,-1730},{1910,-1820},{1790,-1860},{1770,-1960},{1700,-2040},{1650,-2080},{1560,-2160},{1500,-2240} },
	PtsP05 = { {2450,-1370},{2465,-1450},{2490,-1540},{2530,-1620},{2580,-1680},{2620,-1640},{2630,-1570},{2622,-1500},{2610,-1450},{2600,-1400} }, -- A1 phase B : branche de T1 jusqu'a P05 (bord 400), 6 de large ; croise le sentier de crete de S8 (-> ruine) vers (2563,-1668) ; derniere montee sur le flanc ouest du bord (X 2610..2630, a >= 35 studs du sentier S8)
	PtsRuine = { {2552,-1325},{2565,-1420},{2585,-1520} }, -- A1 phase B : debut du sentier de crete de S8 (ruine -> crete) : S8 ne construit que Z < -1380, le premier troncon (mur de la corniche) est pose ici
	SentierRuine = { Demi = 2.2, Fondu = 14 }, -- meme gabarit que S8.Cfg.Sentier
	PtsMine = { {2320,-480},{2420,-460},{2510,-430},{2600,-380},{2725,-300},{2850,-300},{3000,-380},{3130,-460},{3225,-520},{3290,-600},{3333,-667} }, -- T4 : ruine (T1) -> gue d'Ape -> gue de R2 -> mine P15
	PtsTourApe = { {3800,667},{3650,680},{3470,700} }, -- P24 -> T4
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
	local G = C.Gorge
	local RJ = S7.R2 -- jonction : sommet de R2 le plus proche de (3380,1330)
	local jb, ji = 1e18, 1
	for k = 1, #RJ.P do local dd = (RJ.P[k][1] - 3380) ^ 2 + (RJ.P[k][2] - 1330) ^ 2; if dd < jb then jb, ji = dd, k end end
	local FJ = RJ.F[ji]
	D.JonctionR2 = { RJ.P[ji][1], RJ.P[ji][2] }
	local function cumCasc(s)
		local c = 0
		for _, k in ipairs(C.Cascades) do c += k[2] * Lisse((s - k[1]) / 10 + 0.5) end
		return c
	end
	local moy, moyB, g, cum = {}, {}, {}, {}
	for i = 1, n do
		local a, c = 0, 0
		for j = math.max(1, i - 3), math.min(n, i + 3) do a += H.H(P[j][1], P[j][2]); c += 1 end
		moy[i] = a / c
		local ab, cb = 0, 0
		for j = math.max(1, i - 12), math.min(n, i + 12) do ab += H.Basse(P[j][1], P[j][2]); cb += 1 end
		moyB[i] = ab / cb
		local s = ch.S[i]
		g[i] = Lisse((s - G.S0) / 120) * (1 - Lisse((s - G.S1) / G.Fondu))
		cum[i] = cumCasc(s)
	end
	-- lit : on part de la jonction (bedC fixe de S7) et on remonte (monotone par construction)
	local bedNo = {}
	bedNo[n] = FJ.bedC + 0.3 + cum[n]
	local function cleLit(Z)
		local K = C.CleLit
		if Z <= K[1][1] then return K[1][2] end
		for q = 1, #K - 1 do if Z <= K[q + 1][1] then return K[q][2] + (K[q + 1][2] - K[q][2]) * (Z - K[q][1]) / (K[q + 1][1] - K[q][1]) end end
		return nil
	end
	local iLeg, lb = 1, 1e18 -- (2550,1500) : debut du bras est qui rejoint R2
	for k = 1, n do local dd = (P[k][1] - 2550) ^ 2 + (P[k][2] - 1500) ^ 2; if dd < lb then lb, iLeg = dd, k end end
	local BLeg = 165
	for i = n - 1, iLeg, -1 do -- bras est : descente lineaire vers la jonction avec R2
		bedNo[i] = bedNo[n] + (BLeg - bedNo[n]) * (ch.S[n] - ch.S[i]) / (ch.S[n] - ch.S[iLeg])
	end
	for i = iLeg - 1, 1, -1 do
		local ds = ch.S[i + 1] - ch.S[i]
		local want = moyB[i] - 6 - g[i] * G.Prof + cum[i]
		local kz = cleLit(P[i][2])
		if kz then want = kz + cum[i] end -- lit absolu de la gorge d'Ape Canyon
		bedNo[i] = clamp(want, bedNo[i + 1] + C.PenteMin * ds, bedNo[i + 1] + C.PenteMax * ds)
	end
	ch.F = {}
	for i = 1, n do
		local s = ch.S[i]
		local nz = noise(s / 150 + 0.3, 4.1, SEED)
		local sw = C.LargeurSource + (FJ.sw - C.LargeurSource) * Lisse(s / SJ)
		local e5 = math.exp(-((P[i][2] + 1650) / 80) ^ 2) -- P05s : gorge de 9 de large
		sw = sw * (1 - 0.5 * e5)
		local hwG = (12 + 10 * (nz + 0.5)) * (1 - e5) + 4.5 * e5
		local hw = (sw / 2 + 3) + g[i] * (hwG - (sw / 2 + 3))
		local bedC = bedNo[i] - cum[i]
		local wj = 1 - Lisse((SJ - s) / 300)
		local rimC = clamp(math.max(moy[i], 400 * g[i]), bedC + 5, bedC + 12 + g[i] * G.Prof) -- bord 400 dans la gorge d'Ape Canyon (bible P05)
		local rim = FJ.rim * wj + rimC * (1 - wj)
		local prof = rim - bedC
		local ww = (1 - g[i]) * clamp(prof * 1.3, 10, 60) + g[i] * 3
		ch.F[i] = { s = s, g = g[i], sw = sw, hw = hw, ww = ww, bedC = bedC, rim = rim }
	end
	ch.F[n] = FJ
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
	local t = 1 - Lisse((d - (hw + ww)) / (10 + 240 * (1 - g) + 110 * g)) -- DEFAUT : raccord de gorge ramene a 120 studs (rim 400 localise)
	local sEnd = R.S[#R.S]
	t *= Lisse((sEnd - (R.S[i] + (R.S[i + 1] - R.S[i]) * f)) / 250) -- pres de la jonction avec R2 : pas de remplissage du lit de R2
	if t > 0 or d < hw + ww + 14 then
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
-- T4a : P15 -> P16 (rive est du pont) le long de la rive est de R2
C.PtsMineTour = { {3333,-667},{3380,-450},{3420,-100},{3450,300},{3470,700},{3490,1100},{3510,1400},{S7.Pont.Pads[1][1], S7.Pont.Pads[1][2]} }
do
	local Rn = C.Ruine
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
local function base(X, Z) -- A1 phase B : sol avant sentiers = lahar + ruisseau d'Ape (+ R2 au nord-est) ; sert aux profils de T1, de sa branche P05 et de T4
	local h, genre = lahar(X, Z)
	if X > 2950 and Z < 1800 then h, genre = S7.AppliquerR2(h, genre, X, Z, false) end
	return (ruisseau(h, genre, X, Z))
end
local function profil(ch, avecRuisseau)
	local n, y = #ch.P, {}
	for i = 1, n do
		if avecRuisseau then y[i] = base(ch.P[i][1], ch.P[i][2]) else y[i] = (lahar(ch.P[i][1], ch.P[i][2])) end
	end
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
D.P05 = creerChemin(C.PtsP05, 12, 6) -- A1 phase B
D.Ruine = creerChemin(C.PtsRuine, 12, 6) -- A1 phase B
for _, ch in ipairs({ D.Ape, D.P05, D.Ruine }) do profil(ch, true) end
for _, ch in ipairs({ D.SMine, D.SMineTour, D.STourApe }) do profil(ch) end -- T4 : profil inchange (sans ruisseau), seule la tete change
relier(D.Ape, C.PtsApe[1][1], C.PtsApe[1][2], S7.Sentier.Y[#S7.Sentier.Y], 100) -- raccord au sentier de S7
-- A1 phase B : T1 ne finit plus a la ruine (l'acces a la ruine = sentier de crete de S8, depuis la branche P05)

relier(D.SMine, C.Mine.X, C.Mine.Z, C.Mine.Y, 110)
relier(D.SMineTour, C.Mine.X, C.Mine.Z, C.Mine.Y, 110)
relier(D.SMineTour, S7.Pont.Pads[1][1], S7.Pont.Pads[1][2], S7.Pont.Y, 110)
relier(D.STourApe, C.Tour.X, C.Tour.Z, C.Tour.Y, 110)
-- les points d'attache sur le sentier d'Ape Canyon prennent la hauteur de ce sentier
do
	local d, i, f = proche(D.Ape, 2320, -480, nil)
	local y = D.Ape.Y[i] + (D.Ape.Y[i + 1] - D.Ape.Y[i]) * f
	relier(D.SMine, 2320, -480, y, 90)
	d, i, f = proche(D.SMineTour, 3470, 700, nil)
	y = D.SMineTour.Y[i] + (D.SMineTour.Y[i + 1] - D.SMineTour.Y[i]) * f
	relier(D.STourApe, 3470, 700, y, 90)
end
-- A1 : pente des sentiers <= 15 % (deblai/remblai), bouts imposes
S7.Graduer(D.Ape, S7.PenteT1, D.Ape.Y[1], D.Ape.Y[#D.Ape.Y])
do -- A1 phase B : branche P05 : depart a la hauteur de T1 (apres gradation), arrivee a 399.6 (cible bible P05)
	local p = C.PtsP05[1]
	local d, i, f = proche(D.Ape, p[1], p[2], nil)
	relier(D.P05, p[1], p[2], D.Ape.Y[i] + (D.Ape.Y[i + 1] - D.Ape.Y[i]) * f, 90)
	relier(D.P05, 2600, -1400, 399.6, 60)
	S7.Graduer(D.P05, S7.PenteT1, D.P05.Y[1], D.P05.Y[#D.P05.Y])
end
do -- A1 phase B : acces a la ruine : part de la corniche (300), pente <= 33 % comme le sentier de crete de S8
	relier(D.Ruine, C.Ruine.X, C.Ruine.Z, C.Ruine.Y, 110)
	S7.Graduer(D.Ruine, 0.33, C.Ruine.Y, nil)
end
do -- T4b part de T1 apres gradation de T1
	local d, i, f = proche(D.Ape, 2320, -480, nil)
	relier(D.SMine, 2320, -480, D.Ape.Y[i] + (D.Ape.Y[i + 1] - D.Ape.Y[i]) * f, 90)
end
for _, ch in ipairs({ D.SMine, D.SMineTour }) do S7.Graduer(ch, S7.PenteSentier, ch.Y[1], ch.Y[#ch.Y]) end
do
	local d, i, f = proche(D.SMineTour, 3470, 700, nil)
	local y = D.SMineTour.Y[i] + (D.SMineTour.Y[i + 1] - D.SMineTour.Y[i]) * f
	relier(D.STourApe, 3470, 700, y, 40)
	S7.Graduer(D.STourApe, S7.PenteSentier, D.STourApe.Y[1], y)
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
	if X > 2250 then
		h, genre = appliquer(D.SMine, Sp.Demi, Sp.Fondu, X, Z, h, genre)
		h, genre = appliquer(D.SMineTour, Sp.Demi, Sp.Fondu, X, Z, h, genre)
		h, genre = appliquer(D.STourApe, Sp.Demi, Sp.Fondu, X, Z, h, genre)
	end
	if Z > 1450 then
		if X > 1300 and X < 1760 then local dl = AE.Delta(X, Z); local h2, g2 = S4.AppliquerSentierEst(h - dl, genre, X, Z); h, genre = h2 + dl, g2 end
		if X < 2900 then h, genre = appliquer(D.S7Sentier, S7.Cfg.Sentier.Demi, S7.Cfg.Sentier.Fondu, X, Z, h, genre) end
	end
	local eau, gor, hum, sable
	if X > 2950 and Z < 1800 then -- R2 (S7) : partie nord dans la boite de S3, puis l'affluent d'Ape par-dessus
		h, genre, eau, gor, hum, sable = S7.AppliquerR2(h, genre, X, Z, false)
		local h2, g2, e2, o2, hu2, sa2 = ruisseau(h, genre, X, Z)
		h, genre = h2, g2
		if e2 then eau = e2 end
		gor, hum, sable = math.max(gor, o2), math.max(hum, hu2), sable or sa2
	else
		h, genre, eau, gor, hum, sable = ruisseau(h, genre, X, Z)
	end
	if not eau and genre ~= "gorge" and genre ~= "berge" then -- A1 phase B : T1 et sa branche P05 reappliques APRES le ruisseau (son fondu ne doit pas deformer l'axe) ; jamais dans le lit
		h, genre = appliquer(D.Ape, Sa.Demi, Sa.Fondu, X, Z, h, genre)
		h, genre = appliquer(D.P05, Sa.Demi, Sa.Fondu, X, Z, h, genre)
		if Z > 1450 and X < 2900 then h, genre = appliquer(D.S7Sentier, S7.Cfg.Sentier.Demi, S7.Cfg.Sentier.Fondu, X, Z, h, genre) end -- bande de raccord S7 : meme axe que S7.Colonne
	end
	if math.abs(X - C.Ruine.X) < C.Ruine.Demi + C.Ruine.Fondu and math.abs(Z - C.Ruine.Z) < C.Ruine.Demi + C.Ruine.Fondu then
		h, genre = pate(C.Ruine, C.Ruine.Y, X, Z, h, genre)
	end
	if Z > -1396 and X > 2480 and X < 2640 then h, genre = appliquer(D.Ruine, C.SentierRuine.Demi, C.SentierRuine.Fondu, X, Z, h, genre) end -- A1 phase B : acces a la ruine, pose APRES la corniche (depart au bord de la corniche)
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
		if Z < 800 then h += (S4.Surface(X, Z) - HG.H(X, Z)) * w4 end
		local tp = 1 - Lisse((Z - S4.Cfg.ZMin) / S4.Cfg.Marge)
		local fn = 1 - Lisse((S4.Cfg.ZMin - Z) / 300)
		h -= S4.Cfg.ChuteMarge * tp * tp * fn * w4
	end
	-- A1 : reprise de S2.Corr3 (le ticket A1 reecrit S3 : S2 avait corrige ces deux bandes apres coup ; la correction est integree ici)
	if Z > -1000 and Z < -500 and X < 1700 then -- marge nord de S4 annulee (continuite avec S4/S2)
		local S4c = S4.Cfg
		local tp = 1 - Lisse((Z - S4c.ZMin) / S4c.Marge)
		local fn = 1 - Lisse((S4c.ZMin - Z) / 300)
		h += S4c.ChuteMarge * tp * tp * fn * w4
	end
	if Z < -2400 and X < 1500 then -- marge nord de S3 annulee pour X < 1500 (la carte de S2 continue)
		local tn2 = 1 - Lisse((Z - C.ZMin) / C.Marge)
		h += C.ChuteMarge * tn2 * tn2
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
