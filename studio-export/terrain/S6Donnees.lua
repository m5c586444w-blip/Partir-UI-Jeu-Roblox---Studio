--[[ S6Donnees : geometrie du secteur S6 Sud-ouest (chantier 10, depart S2, piste forestiere, sentiers, ruisseau, clairieres).
 Copie locale de ServerStorage/TerrainBuilder/S6Donnees. Coordonnees MONDE (X = x-4000, Z = y-4000).
 Boite : X -4000..1400, Z 2500..4000 (bords de carte : ouest X=-4000, sud Z=4000). Nord Z=2500 = S5 / S4 ; est X=1400 = S7 (meme H).
 Raccord nord : S4 et S5 ont abaisse leur bord sud (Z 2400..2500) de 30 studs (facteur F(X)) ; S6 REMONTE ce rabais sur 200 studs.
 Ruisseau : continuation du ruisseau de S5 (queue de S5Donnees.Ruisseau copiee telle quelle, puis prolongement vers le sud). ]]
local H = require(script.Parent.HauteurGlobale)
local D5 = require(script.Parent.S5Donnees)
local noise, Lisse, clamp = math.noise, H.Lisse, math.clamp
local sqrt, floor, max, min, abs, exp = math.sqrt, math.floor, math.max, math.min, math.abs, math.exp
local SEED = H.Config.Graine
local D = {}

D.Cfg = {
	XMin = -4000, XMax = 1400, ZMin = 2500, ZMax = 4000,
	RabaisNord = 0, RampeNord = 200, -- RabaisNord 0 : S4/S5 n'ont plus de rabais (SudChute=0) ; -- remonte le rabais de S4/S5 (30 studs) sur 200 studs
	Coupe = { X = -1400, Z = 3300, RX = 150, RZ = 125, Fondu = 0.5, Adoucit = 0.8 }, -- lieu 10 : coupe rase ~300x250 (Fondu en rayons normalises)
	Pad = { X = -1390, Z = 3300, DemiX = 60, DemiZ = 45, Fondu = 45 }, -- aire d'engins arasee (depart S2, bulldozer, cabane)
	Cuvette = 4, PenteRuisseau = 0.004, FondMin = 10, LargeurSortie = 48,
	Piste = { Demi = 5, Fondu = 14 }, Sentier = { Demi = 2.2, Fondu = 12 },
	-- waypoints du ruisseau apres le raccord avec S5 (Z>=2500) ; sort par le bord sud
	ExtRuisseau = { { -1605, 2570 }, { -1640, 2700 }, { -1720, 2880 }, { -1810, 3080 }, { -1860, 3300 }, { -1840, 3520 },
		{ -1880, 3720 }, { -1930, 3880 }, { -1960, 4040 } },
	-- piste forestiere fictive : bord sud de la carte -> aire d'engins du chantier
	PtsPiste = { { -1000, 4040 }, { -1020, 3900 }, { -1090, 3780 }, { -1190, 3670 }, { -1290, 3560 }, { -1380, 3470 }, { -1410, 3400 }, { -1420, 3340 } },
	-- sentier chantier -> Ape Cave : trace complet jusqu'a l'aire d'entree de S5 (-2440,2345) ; S6 n'ecrit que Z>=2500
	-- (la suite Z<2500 est dans la boite de S5 : fonction exportee D.AppliquerSentierCave)
	PtsSentierCave = { { -1440, 3265 }, { -1480, 3170 }, { -1540, 3070 }, { -1600, 2960 }, { -1660, 2880 }, { -1740, 2810 }, { -1850, 2740 },
		{ -2000, 2660 }, { -2150, 2600 }, { -2300, 2550 }, { -2400, 2520 }, { -2440, 2500 }, { -2440, 2420 }, { -2440, 2345 } },
	-- sentier chantier -> poste des rangers (17) de S4 : sort au bord nord Z=2500 vers X=230 ; suite dans S4 : PtsSentierEstSuite
	PtsSentierEst = { { -1350, 3250 }, { -1200, 3200 }, { -1000, 3120 }, { -800, 3020 }, { -600, 2920 }, { -350, 2800 }, { -100, 2680 }, { 100, 2570 }, { 230, 2500 } },
	-- suite proposee dans S4 (NON construite) : bord sud de S4 -> piste du poste (215,1488)
	PtsSentierEstSuite = { { 230, 2500 }, { 225, 2300 }, { 215, 2100 }, { 205, 1900 }, { 205, 1700 }, { 210, 1590 }, { 212, 1510 } },
	-- clairieres cles (centre X,Z ; rayon d'influence sur le couvert) ; le chantier a sa propre coupe
	Clairieres = { { "Ouest", -2500, 3350, 110 }, { "Est", -300, 3250, 110 }, { "Sud", -950, 3720, 90 }, { "Gue", -1700, 2800, 80 } },
}
local C = D.Cfg

-- ===== utilitaires de chemins (Catmull-Rom, meme methode que S4/S5) =====
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
local function boite(ch, marge)
	local x0, x1, z0, z1 = 1e9, -1e9, 1e9, -1e9
	for _, p in ipairs(ch.P) do x0, x1, z0, z1 = min(x0, p[1]), max(x1, p[1]), min(z0, p[2]), max(z1, p[2]) end
	ch.bx0, ch.bx1, ch.bz0, ch.bz1 = x0 - marge, x1 + marge, z0 - marge, z1 + marge
end
local function proche(ch, X, Z)
	if X < ch.bx0 or X > ch.bx1 or Z < ch.bz0 or Z > ch.bz1 then return 1e9, 1, 0 end
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
	return sqrt(best), bi, bf
end
D.Proche = proche

-- ===== Coupe rase (lieu 10) : relief adouci, bord irregulier ; pad = aire d'engins arasee =====
local function rayonCoupe(X, Z)
	local K = C.Coupe
	local dx, dz = (X - K.X) / K.RX, (Z - K.Z) / K.RZ
	local r = sqrt(dx * dx + dz * dz)
	return r * (1 + 0.16 * noise(X / 95 + 3.1, Z / 95 + 7.7, SEED)) -- bord irregulier
end
local function hCoupe(X, Z, h)
	local K = C.Coupe
	local r = rayonCoupe(X, Z)
	local w = 1 - Lisse((r - 1) / K.Fondu)
	if w <= 0 then return h, r end
	local hb = H.Basse(X, Z)
	local h2 = hb + (h - hb) * (1 - K.Adoucit)
	return h + (h2 - h) * w, r
end
do
	local P = C.Pad
	D.PadY = floor(hCoupe(P.X, P.Z, H.H(P.X, P.Z)) / 4 + 0.5) * 4
end
local function distRect(p, X, Z)
	local dx, dz = max(abs(X - p.X) - p.DemiX, 0), max(abs(Z - p.Z) - p.DemiZ, 0)
	return sqrt(dx * dx + dz * dz)
end

-- ===== Chemins : profil = H (avec coupe) lissee le long de l'axe =====
local function profil(ch, bloqueurs)
	local n, y = #ch.P, {}
	for i = 1, n do
		local X, Z = ch.P[i][1], ch.P[i][2]
		y[i] = hCoupe(X, Z, H.H(X, Z))
	end
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
local function chemin(pts, cfg, bloqueurs)
	local ch = creerChemin(pts, 12)
	ch.Demi, ch.Fondu = cfg.Demi, cfg.Fondu
	profil(ch, bloqueurs)
	boite(ch, cfg.Demi + cfg.Fondu + 8)
	return ch
end
local function appliquer(ch, X, Z, h, genre)
	local demi, fondu = ch.Demi, ch.Fondu
	local d, i, f = proche(ch, X, Z)
	if d > demi + fondu then return h, genre end
	local y = ch.Y[i] + (ch.Y[i + 1] - ch.Y[i]) * f
	h += (y - h) * (1 - Lisse((d - demi) / fondu))
	local dn = d + (0.25 * demi + 0.5) * noise(X / 7 + 0.9, Z / 7 + 0.4, SEED) * 2
	if d <= demi + 2.2 or dn <= demi - 0.8 then genre = "sentier" elseif dn <= demi + 3 and genre ~= "sentier" then genre = "sentier_bord" end
	return h, genre
end
local pad = { C.Pad.X, C.Pad.Z, D.PadY, 100 }
-- extremites epinglees : bord nord (H pur) et aire d'entree d'Ape Cave (S5)
local finCave = { -2440, 2500, H.H(-2440, 2500), 90 }
local aire7 = { -2440, 2345, D5.Aire7Y, 110 }
local finEst = { 230, 2500, H.H(230, 2500), 90 }
D.Piste = chemin(C.PtsPiste, C.Piste, { pad })
D.SentierCave = chemin(C.PtsSentierCave, C.Sentier, { pad, finCave, aire7 })
D.SentierEst = chemin(C.PtsSentierEst, C.Sentier, { pad, finEst })
-- suite du sentier du poste dans S4 (axe seul) : ecrit par S6Terrain.EcrireSentierPoste
local D4 = require(script.Parent.S4Donnees)
D.SentierPoste = chemin(C.PtsSentierEstSuite, C.Sentier, { { 230, 2500, H.H(230, 2500), 90 }, { 212, 1510, D4.PosteY, 110 } })
function D.AppliquerSentierPoste(h, genre, X, Z) return appliquer(D.SentierPoste, X, Z, h, genre) end
-- export pour S5 : applique le sentier d'Ape Cave sur ses colonnes Z<2500 (comme S4Donnees.AppliquerSentierEst pour S7)
function D.AppliquerSentierCave(h, genre, X, Z) return appliquer(D.SentierCave, X, Z, h, genre) end
D.Chemins = { D.Piste, D.SentierCave, D.SentierEst }

-- ===== Ruisseau : queue de S5 (copiee) + prolongement vers le sud =====
local function construireRuisseau()
	local R5 = D5.Ruisseau
	local n5 = #R5.P
	local iJ = 1
	for i = 1, n5 do if R5.P[i][2] < C.ZMin then iJ = i end end -- dernier point strictement au nord du bord
	local iD = iJ
	while iD > 1 and R5.P[iD][2] > C.ZMin - 150 do iD -= 1 end
	local P, F = {}, {}
	for i = iD, iJ do P[#P + 1] = { R5.P[i][1], R5.P[i][2] }; F[#F + 1] = R5.F[i] end
	local nT = #P
	local fJ = F[nT]
	local ctrl = { { R5.P[iJ - 1][1], R5.P[iJ - 1][2] }, { R5.P[iJ][1], R5.P[iJ][2] } }
	for _, p in ipairs(C.ExtRuisseau) do ctrl[#ctrl + 1] = p end
	local ext = creerChemin(ctrl, 20, 2).P
	local cop = {}
	for i = 1, #ext do cop[i] = { ext[i][1], ext[i][2] } end
	local sAcc, L = {}, 0
	local prev = P[nT]
	for i = 1, #ext do
		L += sqrt((ext[i][1] - prev[1]) ^ 2 + (ext[i][2] - prev[2]) ^ 2)
		sAcc[i] = L
		prev = ext[i]
	end
	for i = 1, #ext - 1 do -- meandres (nuls a la jonction)
		local a = (i == 1) and P[nT] or cop[i - 1]
		local b = cop[i + 1]
		local tx, tz = b[1] - a[1], b[2] - a[2]
		local l = sqrt(tx * tx + tz * tz)
		local amp = 18 * noise(sAcc[i] / 200 + 5.8, 3.3, SEED) * Lisse(sAcc[i] / 140)
		ext[i] = { cop[i][1] - tz / l * amp, cop[i][2] + tx / l * amp }
	end
	for i = 1, #ext do P[#P + 1] = ext[i] end
	local ch = { P = P }
	cumul(ch)
	local moy = {}
	for i = 1, #P do
		local a, c = 0, 0
		for j = max(1, i - 8), min(#P, i + 8) do a += H.Basse(P[j][1], P[j][2]); c += 1 end
		moy[i] = a / c
	end
	local bed = fJ.bedC
	local sJ = ch.S[nT]
	local cuvJ = fJ.cuv or C.Cuvette
	ch.F = {}
	for i = 1, nT do ch.F[i] = F[i] end
	for i = nT + 1, #P do
		local sr = ch.S[i] - sJ
		local raw = moy[i] - 6
		bed = max(min(bed - C.PenteRuisseau * (ch.S[i] - ch.S[i - 1]), raw), C.FondMin)
		local sw = fJ.sw + (C.LargeurSortie - fJ.sw) * Lisse(sr / 1400)
		local rim = clamp(moy[i], bed + 4, bed + 14)
		local ww = clamp((rim - bed) * 1.6, 12, 40)
		local cuv = cuvJ + (C.Cuvette - cuvJ) * Lisse(sr / 200)
		ch.F[i] = { s = ch.S[i], sw = sw, hw = sw / 2 + 3, ww = ww, bedC = bed, rim = rim, cuv = cuv }
	end
	boite(ch, 250)
	return ch
end
D.Ruisseau = construireRuisseau()

-- gue : point du sentier de la grotte le plus proche de l'axe du ruisseau
do
	local best, gx, gz = 1e9, 0, 0
	for _, p in ipairs(D.SentierCave.P) do
		local d = proche(D.Ruisseau, p[1], p[2])
		if d < best then best, gx, gz = d, p[1], p[2] end
	end
	C.Gues = { { gx, gz } }
end
local function facteurGue(X, Z)
	local f = 0
	for _, g in ipairs(C.Gues) do
		f = max(f, 1 - Lisse((sqrt((X - g[1]) ^ 2 + (Z - g[2]) ^ 2) - 14) / 40))
	end
	return f
end

-- ===== Affleurements rocheux : petites bosses raides (deviennent Rock par la pente) =====
D.Rochers = {}
do
	local pas = 260
	for gx = C.XMin, C.XMax - pas, pas do
		for gz = C.ZMin, C.ZMax - pas, pas do
			local nn = noise(gx / 97 + 1.3, gz / 97 + 8.1, SEED)
			if nn > -0.05 then
				local X = gx + pas * (0.15 + 0.7 * (noise(gx / 53 + 4.4, gz / 53 + 0.3, SEED) + 0.7) / 1.4)
				local Z = gz + pas * (0.15 + 0.7 * (noise(gx / 61 + 2.2, gz / 61 + 6.6, SEED) + 0.7) / 1.4)
				local ok = true
				for _, ch in ipairs({ D.Piste, D.SentierCave, D.SentierEst }) do if proche(ch, X, Z) < 40 then ok = false end end
				if proche(D.Ruisseau, X, Z) < 150 then ok = false end
				if rayonCoupe(X, Z) < 1.5 then ok = false end
				if ok then D.Rochers[#D.Rochers + 1] = { X, Z, 11 + 6 * (nn + 0.7), 8 + 3 * (nn + 0.7) } end
			end
		end
	end
end
local function rochers(X, Z, h)
	for _, r in ipairs(D.Rochers) do
		local dx, dz = X - r[1], Z - r[2]
		if abs(dx) < 3 * r[4] and abs(dz) < 3 * r[4] then h += r[3] * exp(-(dx * dx + dz * dz) / (r[4] * r[4])) end
	end
	return h
end

-- ===== Surface =====
function D.Surface(X, Z)
	local h = H.H(X, Z)
	local genre, eau, hum, sable = nil, nil, 0, false
	h = rochers(X, Z, h)
	local r
	h, r = hCoupe(X, Z, h)
	if r < 1 then genre = "aire" end
	local dp = distRect(C.Pad, X, Z)
	if dp < C.Pad.Fondu then
		h += (D.PadY - h) * (1 - Lisse(dp / C.Pad.Fondu))
		if dp == 0 then genre = "aire" end
	end
	for _, ch in ipairs(D.Chemins) do h, genre = appliquer(ch, X, Z, h, genre) end
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
			sable = true
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
			end
		end
	end
	return h, genre, eau, hum, sable
end

-- facteur du rabais pose par S4/S5 sur leur bord sud : rabais = 30 * (Lisse((Z-2400)/100) * F(X))^2 ; F mesure sur le terrain existant
function D.FacteurRabais(X)
	local f = Lisse((X + 1300) / 300) * (1 - Lisse((X - 1200) / 150))
	return f, Lisse((X + 790) / 200) -- 2e valeur : part du rabais retiree par la reecriture de la bande de S4 (X>-790, Z 2400..2500)
end

function D.Colonne(X, Z)
	local h, genre, eau, hum, sable = D.Surface(X, Z)
	local u = (Z - C.ZMin) / C.RampeNord
	if u < 1 then
		local F, w = D.FacteurRabais(X)
		local k = (1 - Lisse(u)) * F -- S4/S5 : rabais = 30 * ts^2, ts = Lisse(..) * facteur(X)
		h -= C.RabaisNord * k * k * (1 - w)
	end
	return h, genre, eau, 0, hum, sable
end

-- couvert forestier suppose (0..1) : dense, clairieres
function D.Couvert(X, Z)
	local c = 0.85
	if X > 500 then c = 0.92 end
	local K = C.Coupe
	local dc = sqrt((X - K.X) ^ 2 + (Z - K.Z) ^ 2)
	c -= 0.8 * (1 - Lisse((dc - 140) / 90))
	for _, cl in ipairs(C.Clairieres) do
		local dd = sqrt((X - cl[2]) ^ 2 + (Z - cl[3]) ^ 2)
		c -= 0.65 * (1 - Lisse(dd / cl[4]))
	end
	return clamp(c, 0.08, 1)
end

return D
