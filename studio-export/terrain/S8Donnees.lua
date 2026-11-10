--[[ S8Donnees : coin NORD-EST (S8) X 1500..4000 / Z -4000..-2440 + couloir de raccord dans S3 (X 2440..2900, Z -2440..-1380).
 Flanc du volcan : H + montee vers le nord, falaises en gradins (non gravissables), ravins, eboulis de cendre ; sentier de randonnee
 (ruine d'Ape Canyon -> crete (2800,-3000) -> boucle) ; ruisseau de fonte relie a la source de S3 (2690,-1950).
 D.Colonne(X,Z) -> h, genre, eau, gor, hum, sable. Coordonnees MONDE. ]]
local H = require(script.Parent.HauteurGlobale)
local S3 = require(script.Parent.S3Donnees)
local S7 = require(script.Parent.S7Donnees)
local noise, Lisse, clamp, sqrt = math.noise, H.Lisse, math.clamp, math.sqrt
local SEED = H.Config.Graine
local D = {}
D.Cfg = {
	XMin = 1500, XMax = 4000, ZMin = -4000, ZMax = -2440,
	Ov = { X0 = 2440, X1 = 2900, Z0 = -2440, Z1 = -1380 }, -- couloir reecrit dans S3 (sentier + ruisseau)
	Raccord = { Z0 = -2440, Z1 = -2560 }, -- fondu S3 -> montagne
	Monte = 160, MonteLong = 1500, -- surelevation supplementaire vers le volcan (Z -2500 -> -4000)
	FondOuest = 250, -- marge douce vers S2 : tout retombe sur H pur a X=1500
	Falaise = { Haut = 45, Larg = 0.014, Seuils = { -0.16, 0.04, 0.2 }, Echelle = 420, Libre = 70, LibreFondu = 80 },
	Ravin = { Prof = 40, Echelle = 280, Largeur = 0.018 },
	PtsRuisseau = { {2690,-1950},{2690,-2150},{2670,-2350},{2640,-2500},{2625,-2660},{2630,-2850},{2690,-3050},{2760,-3250},{2800,-3420} },
	Gue = { 2625, -2660 }, GueDemi = 60,
	Cascades = { {170,12},{330,12},{480,12},{900,10},{1080,10},{1260,10} }, -- {s depuis la jonction, chute}
	Prof = 70, PenteMin = 0.0045, PenteMax = 0.12, Largeur = { Jonc = 12, Max = 18 },
	Sentier = { Demi = 2.2, Fondu = 14, PenteMax = 0.33 }, -- axe 3,3..4,8 avec bords irreguliers
	PtsSentier = { {2615,-1400},{2585,-1520},{2565,-1650},{2550,-1780},{2540,-1900},{2530,-2000},{2500,-2080},{2545,-2160},{2505,-2240},{2545,-2320},{2565,-2420},{2575,-2520},{2600,-2610},{2625,-2660},{2670,-2700},{2710,-2760},{2740,-2830},{2770,-2920},{2800,-3000} },
	PtsBoucle = { {2740,-2830},{2790,-2790},{2870,-2800},{2920,-2880},{2905,-2980},{2845,-3050},{2800,-3000} },
	Crete = { 2800, -3000 },
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

-- ===== montagne brute (sans sentier ni ruisseau) ; falaises/ravins masques pres du sentier et du ruisseau =====
local masque = function() return 1 end -- redefini plus bas (depend des chaines)
local function cendre(X, Z, h)
	local e = 2 * (noise(X / 160 + 9.1, Z / 160 + 2.2, SEED) * 0.6 + noise(X / 60 + 1.0, Z / 60 + 5.0, SEED) * 0.4)
	local sc = 0.55 * e + 0.5 * Lisse((h - 380) / 200) + 0.25 * Lisse((-Z - 2800) / 800) - 0.1
	if sc > 0.5 then return "lahar" elseif sc > 0.22 then return "laharbord" end
	return nil
end
local function montagne(X, Z)
	local wf = Lisse((X - C.XMin) / C.FondOuest)
	local h = H.H(X, Z)
	h += wf * C.Monte * Lisse((-2500 - Z) / C.MonteLong)
	local m = Lisse((-2560 - Z) / 150) * wf
	local F = C.Falaise
	local fz = 0
	if m > 0 then
		local mk = masque(X, Z)
		m *= mk
		if m > 0 then
			local f1 = noise(X / F.Echelle + 1.3, Z / F.Echelle + 7.1, SEED) + 0.06 * noise(X / 90 + 4.4, Z / 90 + 1.1, SEED)
			for _, t in ipairs(F.Seuils) do h += m * F.Haut * Lisse((f1 - t) / F.Larg + 0.5) end
			local R = C.Ravin
			local r = noise(X / R.Echelle + 3.1, Z / (R.Echelle * 1.2) + 0.9, SEED) + 0.03 * noise(X / 40 + 2.0, Z / 40 + 8.0, SEED)
			h -= m * R.Prof * (1 - Lisse(math.abs(r) / R.Largeur))
		end
	end
	return h, cendre(X, Z, h)
end
D.Montagne = montagne

-- hauteur de reference (sert aux profils de sentier/ruisseau)
local function ref(X, Z)
	if Z >= C.Raccord.Z0 then return (S3.Colonne(X, Z)) end
	local h = H.H(X, Z) + C.Monte * Lisse((-2500 - Z) / C.MonteLong) * Lisse((X - C.XMin) / C.FondOuest)
	if Z > C.Raccord.Z1 then
		local w = Lisse((C.Raccord.Z0 - Z) / (C.Raccord.Z0 - C.Raccord.Z1))
		h = (S3.Colonne(X, Z)) * (1 - w) + h * w
	end
	return h
end

-- ===== ruisseau de fonte : de la jonction (2690,-1950) vers la source ; lit MONOTONE montant vers l'amont =====
local function construireRuisseau()
	local ch = creerChemin(C.PtsRuisseau, 20, 8)
	local P, n = ch.P, #ch.P
	local copie = {}
	for i = 1, n do copie[i] = { P[i][1], P[i][2] } end
	cumul(ch)
	local SJ0 = ch.S[n]
	for i = 2, n - 1 do
		local tx, tz = copie[i + 1][1] - copie[i - 1][1], copie[i + 1][2] - copie[i - 1][2]
		local l = sqrt(tx * tx + tz * tz)
		local off = 16 * noise(ch.S[i] / 190 + 0.5, 7.7, SEED) * Lisse(ch.S[i] / 200) * Lisse((SJ0 - ch.S[i]) / 200)
		P[i] = { copie[i][1] - tz / l * off, copie[i][2] + tx / l * off }
	end
	cumul(ch)
	local SJ = ch.S[n]
	-- abscisse du gue
	local sg, bd = 0, 1e18
	for i = 1, n do
		local d = (P[i][1] - C.Gue[1]) ^ 2 + (P[i][2] - C.Gue[2]) ^ 2
		if d < bd then bd, sg = d, ch.S[i] end
	end
	D.SGue = sg
	local F3 = S3.Ruisseau.F[1]
	local moy, g, cum = {}, {}, {}
	for i = 1, n do
		local a, c = 0, 0
		for j = math.max(1, i - 8), math.min(n, i + 8) do a += ref(P[j][1], P[j][2]); c += 1 end
		moy[i] = a / c
		local s = ch.S[i]
		local gg = Lisse(s / 160) * (1 - Lisse((s - (SJ - 260)) / 200))
		gg *= 1 - (1 - Lisse((math.abs(s - sg) - 40) / 90)) -- gue : plus de ravin
		g[i] = gg
		local cc = 0
		for _, k in ipairs(C.Cascades) do cc += k[2] * Lisse((s - k[1]) / 10 + 0.5) end
		cum[i] = cc
	end
	local bedNo = { F3.bedC }
	for i = 2, n do
		local ds = ch.S[i] - ch.S[i - 1]
		local want = moy[i] - 6 - g[i] * C.Prof
		bedNo[i] = clamp(want, bedNo[i - 1] + C.PenteMin * ds, bedNo[i - 1] + C.PenteMax * ds)
	end
	ch.F = {}
	for i = 1, n do
		local s = ch.S[i]
		local nz = noise(s / 150 + 0.3, 4.1, SEED)
		local sw = C.Largeur.Jonc + (C.Largeur.Max - C.Largeur.Jonc) * Lisse(s / 400) * (1 - Lisse((s - (SJ - 350)) / 250))
		local hwG = 12 + 10 * (nz + 0.5)
		local hw = (sw / 2 + 3) + g[i] * (hwG - (sw / 2 + 3))
		local bedC = bedNo[i] + cum[i]
		local rim = clamp(moy[i], bedC + 6 + g[i] * C.Prof, bedC + 300)
		local prof = rim - bedC
		local ww = (1 - g[i]) * clamp(prof * 1.3, 10, 60) + g[i] * 3
		ch.F[i] = { s = s, g = g[i], sw = sw, hw = hw, ww = ww, bedC = bedC, rim = rim }
	end
	ch.F[1] = { s = 0, g = 0, sw = F3.sw, hw = F3.sw / 2 + 3, ww = F3.ww, bedC = F3.bedC, rim = F3.rim }
	return indexer(ch, 8)
end
D.Ruisseau = construireRuisseau()

local function ruisseau(h, genre, X, Z)
	local eau, gor, hum, sable = nil, 0, 0, false
	local R = D.Ruisseau
	local d, i, f = proche(R, X, Z, 300)
	if not d then return h, genre, eau, gor, hum, sable end
	local a, b = R.F[i], R.F[i + 1]
	local function lp(k) return a[k] + (b[k] - a[k]) * f end
	local g, hw, ww, sw, rim, bedC = lp("g"), lp("hw"), lp("ww"), lp("sw"), lp("rim"), lp("bedC")
	local t = 1 - Lisse((d - (hw + ww)) / (50 + 70 * g))
	if t > 0 then
		h += (rim - h) * t
		gor = g
		hum = 1 - Lisse((d - sw / 2 - 2) / 45)
		sable = sw > 14
		genre = (g > 0.35 and d < hw + ww + 14) and "gorge" or genre
		if d < hw + ww + 14 then
			local dd = d + 4 * g * noise(X / 16 + 0.1, Z / 16 + 0.9, SEED)
			if d < hw + ww then
				local gr = H.CreuserGorge(dd, bedC, rim, hw, ww)
				if dd < sw / 2 then
					local q = 2 * dd / sw
					local cuv = S7.Cfg.Cuvette
					local dg = sqrt((X - C.Gue[1]) ^ 2 + (Z - C.Gue[2]) ^ 2)
					if dg < 45 then cuv *= 1 - 0.8 * (1 - Lisse((dg - 12) / 33)) end
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

-- ===== sentiers =====
local function profil(ch, depart)
	local n, y = #ch.P, {}
	for i = 1, n do y[i] = ref(ch.P[i][1], ch.P[i][2]) end
	for _ = 1, 6 do
		local z = {}
		for i = 1, n do
			local a, c = 0, 0
			for j = math.max(1, i - 5), math.min(n, i + 5) do a += y[j]; c += 1 end
			z[i] = a / c
		end
		y = z
	end
	if depart then
		for i = 1, n do
			local w = 1 - Lisse(sqrt((ch.P[i][1] - depart[1]) ^ 2 + (ch.P[i][2] - depart[2]) ^ 2) / 110)
			y[i] += (depart[3] - y[i]) * w
		end
	end
	ch.Y = y
end
D.Sentier = creerChemin(C.PtsSentier, 12, 6)
D.Boucle = creerChemin(C.PtsBoucle, 12, 6)
profil(D.Sentier, { 2615, -1400, S3.Cfg.Ruine.Y })
-- pente limitee (aller puis retour)
do
	local Y, mx = D.Sentier.Y, C.Sentier.PenteMax
	for i = 2, #Y do
		local ds = D.Sentier.S[i] - D.Sentier.S[i - 1]
		Y[i] = clamp(Y[i], Y[i - 1] - mx * ds, Y[i - 1] + mx * ds)
	end
end
profil(D.Boucle)
do -- la boucle prend la hauteur du sentier a ses deux extremites
	local function hs(X, Z)
		local d, i, f = proche(D.Sentier, X, Z, nil)
		return D.Sentier.Y[i] + (D.Sentier.Y[i + 1] - D.Sentier.Y[i]) * f
	end
	local p, q = C.PtsBoucle[1], C.PtsBoucle[#C.PtsBoucle]
	local y1, y2 = hs(p[1], p[2]), hs(q[1], q[2])
	local n, Y = #D.Boucle.P, D.Boucle.Y
	for i = 1, n do
		local dp = sqrt((D.Boucle.P[i][1] - p[1]) ^ 2 + (D.Boucle.P[i][2] - p[2]) ^ 2)
		local dq = sqrt((D.Boucle.P[i][1] - q[1]) ^ 2 + (D.Boucle.P[i][2] - q[2]) ^ 2)
		Y[i] += (y1 - Y[i]) * (1 - Lisse(dp / 120))
		Y[i] += (y2 - Y[i]) * (1 - Lisse(dq / 120))
	end
	local mx = C.Sentier.PenteMax
	for i = 2, n do
		local ds = D.Boucle.S[i] - D.Boucle.S[i - 1]
		Y[i] = clamp(Y[i], Y[i - 1] - mx * ds, Y[i - 1] + mx * ds)
	end
	Y[n] = y2
end

masque = function(X, Z) -- 0 pres du sentier/du ruisseau (pas de falaise), 1 loin
	local F = C.Falaise
	local m = 1
	for _, ch in ipairs({ D.Sentier, D.Boucle }) do
		local d = proche(ch, X, Z, F.Libre + F.LibreFondu)
		if d then m = math.min(m, Lisse((d - F.Libre) / F.LibreFondu)) end
	end
	if m > 0 then
		local d = proche(D.Ruisseau, X, Z, 130)
		if d then m = math.min(m, Lisse((d - 40) / 90)) end
	end
	return m
end

local function appliquer(ch, X, Z, h, genre)
	local S = C.Sentier
	local d, i, f = proche(ch, X, Z, S.Demi + S.Fondu)
	if not d or d > S.Demi + S.Fondu then return h, genre end
	local y = ch.Y[i] + (ch.Y[i + 1] - ch.Y[i]) * f
	h += (y - h) * (1 - Lisse((d - S.Demi) / S.Fondu))
	local dn = d + (0.25 * S.Demi + 0.5) * noise(X / 7 + 0.9, Z / 7 + 0.4, SEED) * 2
	if d <= S.Demi + 1.2 or dn <= S.Demi - 0.8 then genre = "sentier" elseif dn <= S.Demi + 3 and genre ~= "sentier" then genre = "sentier_bord" end
	return h, genre
end

function D.Colonne(X, Z)
	local h, genre, eau, gor, hum, sable
	local R = C.Raccord
	if Z >= R.Z0 then
		h, genre, eau, gor, hum, sable = S3.Colonne(X, Z)
	elseif Z > R.Z1 then
		local w = Lisse((R.Z0 - Z) / (R.Z0 - R.Z1))
		local h3, g3, e3, o3, hu3, sa3 = S3.Colonne(X, Z)
		local hm, gm = montagne(X, Z)
		h = h3 * (1 - w) + hm * w
		if w > 0.5 then genre = gm else genre, eau, gor, hum, sable = g3, e3, o3, hu3, sa3 end
	else
		h, genre = montagne(X, Z)
	end
	if Z < -1380 then
		h, genre = appliquer(D.Sentier, X, Z, h, genre)
		if Z < -2700 then h, genre = appliquer(D.Boucle, X, Z, h, genre) end
		if Z < -1952 then
			local h2, g2, e2, o2, hu2, sa2 = ruisseau(h, genre, X, Z)
			local wm = Lisse((-1952 - Z) / 10)
			h = h + (h2 - h) * wm
			if wm > 0.5 then genre, eau, gor, hum, sable = g2, e2, o2, hu2, sa2 end
			if eau and h >= eau - 0.3 then eau = nil end
		end
	end
	return h, genre, eau, gor, hum, sable
end

function D.Couvert(X, Z) -- peu de couvert : roche, cendre
	if Z >= C.Raccord.Z0 then return S3.Couvert(X, Z) end
	return clamp(0.4 - 0.25 * Lisse((-2500 - Z) / 1200), 0.12, 0.45)
end
function D.AltRoche(Z)
	if Z >= C.Raccord.Z0 then return S3.AltRoche(Z) end
	return 330 - 40 * Lisse((-2500 - Z) / 1000)
end

return D
