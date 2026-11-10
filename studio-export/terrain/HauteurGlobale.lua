--[[
 HauteurGlobale — fonction de hauteur DETERMINISTE de toute la carte (X, Z de -4000 a 4000).
 Copie locale : terrain/HauteurGlobale.lua

 H(X,Z) = tendance (monte vers le nord) + grandes vallees + collines + detail. Graine fixe (Config.Graine) :
 tous les secteurs obtiennent la meme valeur au meme point. Rivieres, gorges, lahar, routes ne modifient
 PAS H : elles s'appliquent par-dessus (CreuserGorge, Arase) dans chaque secteur.
 Parametres : HSud/HNord (altitude de la tendance a ZSud=4000 / ZNord=-3500), AmpVallees/LongVallees,
 AmpCollines/LongCollines, AmpDetail/LongDetail, ReliefSud/ReliefNord (multiplicateur d'amplitude),
 Plancher (altitude minimale douce).
]]
local M = {}

M.Config = {
	Graine = 7.31,
	HSud = 20, HNord = 400, ZSud = 4000, ZNord = -3500,
	AmpVallees = 110, LongVallees = 1250,
	AmpCollines = 100, LongCollines = 350,
	AmpDetail = 8, LongDetail = 60,
	ReliefSud = 0.6, ReliefNord = 1.4,
	Plancher = 16, PlancherK = 8, -- altitude minimale douce : H ne descend jamais sous Plancher - PlancherK (=8)
}

local noise, clamp = math.noise, math.clamp

function M.Lisse(t)
	t = clamp(t, 0, 1)
	return t * t * (3 - 2 * t)
end

local function plancher(h)
	local p = M.Config.Plancher
	if h < p then
		local k = M.Config.PlancherK
		return p - k * (1 - math.exp((h - p) / k)) -- asymptote p-k, continue et derivable en p
	end
	return h
end

local function fraction(Z)
	local c = M.Config
	return clamp((c.ZSud - Z) / (c.ZSud - c.ZNord), 0, 1.2)
end

function M.Tendance(Z)
	local c = M.Config
	return c.HSud + (c.HNord - c.HSud) * fraction(Z)
end

-- Relief a grande echelle seul (tendance + grandes vallees) : reference pour les lits de rivieres
function M.Basse(X, Z)
	local c = M.Config
	local k = c.ReliefSud + (c.ReliefNord - c.ReliefSud) * math.min(fraction(Z), 1)
	local v = c.AmpVallees * noise(X / c.LongVallees + 0.31, Z / c.LongVallees + 0.77, c.Graine)
		+ 0.35 * c.AmpVallees * noise(X / 600 + 4.13, Z / 600 + 9.51, c.Graine)
	return plancher(M.Tendance(Z) + k * v)
end

function M.H(X, Z)
	local c = M.Config
	local k = c.ReliefSud + (c.ReliefNord - c.ReliefSud) * math.min(fraction(Z), 1)
	local h = M.Tendance(Z)
	h += k * c.AmpVallees * noise(X / c.LongVallees + 0.31, Z / c.LongVallees + 0.77, c.Graine)
	h += k * 0.35 * c.AmpVallees * noise(X / 600 + 4.13, Z / 600 + 9.51, c.Graine)
	h += k * c.AmpCollines * noise(X / c.LongCollines + 2.7, Z / c.LongCollines + 6.2, c.Graine)
	h += k * 0.4 * c.AmpCollines * noise(X / 150 + 8.8, Z / 150 + 1.9, c.Graine)
	h += c.AmpDetail * noise(X / c.LongDetail + 5.5, Z / c.LongDetail + 3.3, c.Graine)
	return plancher(h)
end

-- Arase : tire h vers cible. d = distance a l'axe ; plein jusqu'a rayonPlein, fondu sur rayonFondu.
function M.Arase(h, cible, d, rayonPlein, rayonFondu)
	local t = 1 - M.Lisse((d - rayonPlein) / rayonFondu)
	return h + (cible - h) * t
end

-- CreuserGorge : profil en travers. d = distance a l'axe, fond/rebord = altitudes, demiLargeur du fond,
-- paroi = largeur horizontale de la paroi (petite = quasi verticale).
function M.CreuserGorge(d, fond, rebord, demiLargeur, paroi)
	local u = clamp((d - demiLargeur) / paroi, 0, 1)
	return fond + (rebord - fond) * M.Lisse(u)
end

return M
