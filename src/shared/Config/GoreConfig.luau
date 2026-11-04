-- ReplicatedStorage/Config/GoreConfig
-- Valeurs de la bible, section 11 (et 17.1, 17.3 pour les plafonds de flaques). Ne rien ajouter ici sans la bible.
local GoreConfig = {}

-- 11.2 : "Restricted" ou "Moderate". Le même jeu peut être publié en deux expériences, une par label.
-- TODO(BIBLE): 19.4 « Bloquant — Restricted 18+ » : profil à publier. PROVISOIRE : "Moderate" (le plus prudent).
-- Le questionnaire de maturité est rempli par Gabriel, jamais par Claude Code (11.1).
GoreConfig.Profile = "Moderate"

-- 11.2 : deux profils
GoreConfig.Profiles = {
	Restricted = {
		dismember = true, -- un coup de plus de 50 sur un membre à moins de 10 % de PV
		execution = true, -- ATK_Execution, avec noir à l'instant de la mort
		bloodPools = { lifetime = 600, maxOnMap = 40 },
		wounds = "Decal_Wound", -- decals de plaies (13.5 : Decal_Wound_A–D)
		geologistBodies = "Restricted", -- membres manquants, sang séché
		bloodTrails = "Normal",
	},
	Moderate = {
		dismember = false,
		execution = false, -- l'Alpha traîne le joueur hors de vue
		bloodPools = { lifetime = 120, small = true }, -- petites taches au sol
		wounds = "DarkStains", -- taches sombres sur les vêtements
		geologistBodies = "Moderate", -- corps couverts (bâche, pierres)
		bloodTrails = "Discreet",
	},
}

-- 11.2 : démembrement
GoreConfig.Dismember = {
	MinHit = 50,
	MaxLimbFraction = 0.1,
	Limbs = { "ArmL", "ArmR", "LegL", "LegR" }, -- bras, jambes
	StumpPrefix = "Gore_Stump_", -- 11.5 : capuchon qui masque la coupe, sans détail anatomique
}

-- 11.4 : option « Gore réduit », réglage local, désactivé par défaut ; applique l'affichage Moderate
GoreConfig.ReducedGoreDefault = false

-- 11.5 : implémentation
GoreConfig.Blood = {
	BurstDuration = 0.3, -- ParticleEmitter court
	PoolDecals = { Restricted = "Decal_Blood_Pool", Moderate = "Decal_Blood_Pool" }, -- versions sombres pour Moderate (13.5)
	-- 17.3 : plafond de flaques selon le préréglage (mobile : 15, 17.1)
	PoolsByPreset = { Low = 15, Medium = 25, High = 40, Ultra = 40 },
}
GoreConfig.Ragdoll = { AnchorAfterStill = 10 } -- le corps passe ancré après 10 s immobile

-- TODO(BIBLE): taille d'une flaque et d'une petite tache (13.5 : decals à créer). PROVISOIRE : 4 et 1,5 studs.
GoreConfig.PoolSize = { Restricted = 4, Moderate = 1.5 }

return GoreConfig
