--[[ Alignement_EST : champ de correction de hauteur de la region EST (S7, S3, S8) pour caler les lieux sur la bible 3.2.
 Delta(X,Z) = couche regionale lisse (moyenne ponderee normalisee de noyaux gaussiens, sigma Cfg.Sigma, centres sur les ancres) + plateaux par lieu
 (valeur exacte sur le rayon plein, fondu ensuite). Vaut 0 pour X <= Cfg.Xb (frontieres avec le CENTRE : X=1400 et X=1500) par un fondu multiplicatif.
 Applique par le module HauteurEST (H.H / H.Basse + Delta) : lits, lahar, plateformes, routes et sentiers se recalculent donc
 sur le relief aligne. HauteurGlobale n'est PAS modifie (il reste partage avec les autres regions).
 Toutes les valeurs numeriques de Cfg marquees DEFAUT sont des propositions (pas d'appui chiffre dans la bible). ]]
local H0 = require(script.Parent.HauteurGlobale)
local exp, sqrt, floor = math.exp, math.sqrt, math.floor
local M = {}

M.Cfg = {
	Sigma = 450,   -- DEFAUT : largeur des noyaux gaussiens de la couche regionale (moyenne ponderee normalisee)
	FondAmbiant = 0.15, -- DEFAUT : poids du 'zero' lointain dans la moyenne ponderee
	Xb = 1500, Wb = 450, -- DEFAUT : correction nulle pour X <= Xb (frontieres CENTRE), pleine a Xb+Wb
	Pas = 16,      -- DEFAUT : pas du cache bilineaire (studs)
	RMin = 20,     -- DEFAUT : rayon plein minimal d'une ancre (valeur exacte au centre)
	FonduMin = 90, -- DEFAUT : fondu minimal des plateaux
}

-- Ancres : { nom, X, Z, Y cible du RELIEF (sol) , rayon plein, base ("H" ou "Basse") }
-- Y = cible bible 3.2 ; pour la coulee (lahar) Y = niveau du lit + creux 6 (le lit suit H.Basse + Delta)
M.Ancres = {
	{ "P01", 2800, 3200, 120, 80 },
	{ "P02s", 2100, 3500, 120, 20, "Basse" },   -- lit 114 + creux 6 (+4 : NiveauLahar mesure 105.9 pour 110 vise)
	{ "P02n", 2100, -1500, 386, 20, "Basse" },  -- lit 380 + creux 6
	{ "P03", 3200, 2200, 110, 20 },             -- bord de gorge 110
	{ "P16", 3467, 1600, 150, 20 },             -- tablier 150
	{ "P05", 2600, -1400, 400, 20 },            -- bord 400
	{ "P05c", 2550, -1300, 300, 30 },           -- corniche de la ruine
	{ "P15", 3333, -667, 394, 50 },             -- mine (pad 390 + mur au sud)
	{ "P23", 2400, -3467, 560, 40, 604 }, -- 604 = sol S8 mesure avant (montagne + falaises)
	{ "P24", 3800, 667, 300, 50 },
	{ "CreteEst", 3200, -800, 400, 20 },
}
-- axe de la coulee : Delta lineaire en Z entre le sud (+102) et le nord (+136) => lit monotone (NiveauLahar = Basse + Delta - creux)
for _, z in ipairs({ 3000, 2500, 2000, 1500, 1000, 500, 0, -500, -1000 }) do
	M.Ancres[#M.Ancres + 1] = { "Lahar_" .. z, 2100, z, nil, 20, nil, 102 + 34 * (3500 - z) / 5000 }
end

local A = {}
local function base(a)
	if type(a[6]) == "number" then return a[6] end
	local f = a[6] == "Basse" and H0.Basse or H0.H
	return f(a[2], a[3])
end
for i, a in ipairs(M.Ancres) do
	A[i] = { x = a[2], z = a[3], d = a[7] or (a[4] and (a[4] - base(a)) or 0), r = math.max(a[5], M.Cfg.RMin), nom = a[1] }
end
local n = #A
local sg2 = 2 * M.Cfg.Sigma ^ 2

local function Lisse(t) t = math.clamp(t, 0, 1); return t * t * (3 - 2 * t) end
local function regional(X, Z)
	local num, den = 0, M.Cfg.FondAmbiant
	for i = 1, n do
		local a = A[i]
		local k = exp(-((X - a.x) ^ 2 + (Z - a.z) ^ 2) / sg2)
		num += k * a.d
		den += k
	end
	return (num / den) * Lisse((X - M.Cfg.Xb) / M.Cfg.Wb)
end
M.Regional = regional

local function brut(X, Z)
	local d = regional(X, Z)
	local tb = Lisse((X - M.Cfg.Xb) / M.Cfg.Wb)
	for i = 1, n do
		local a = A[i]
		do
			local dist = sqrt((X - a.x) ^ 2 + (Z - a.z) ^ 2)
			local fo = math.max(1.5 * a.r, M.Cfg.FonduMin)
			local w = 1 - Lisse((dist - a.r) / fo)
			if w > 0 then d += w * (a.d * tb - d) end
		end
	end
	return d
end

-- cache bilineaire
local cache, PAS = {}, M.Cfg.Pas
local function noeud(ix, iz)
	local k = ix * 4096 + iz
	local v = cache[k]
	if v == nil then v = brut(ix * PAS, iz * PAS); cache[k] = v end
	return v
end
function M.Delta(X, Z)
	local fx, fz = X / PAS, Z / PAS
	local ix, iz = floor(fx), floor(fz)
	local tx, tz = fx - ix, fz - iz
	local a = noeud(ix, iz) * (1 - tx) + noeud(ix + 1, iz) * tx
	local b = noeud(ix, iz + 1) * (1 - tx) + noeud(ix + 1, iz + 1) * tx
	return a * (1 - tz) + b * tz
end
M.DeltaExact = brut
M.Noeuds = A

return M
