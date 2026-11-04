-- ReplicatedStorage/Config/WeaponConfig
-- Valeurs de la bible, section 8.2 (et 16.3 pour la validation). Ne rien ajouter ici sans la bible.
local WeaponConfig = {}

-- « Toute la carte » : la diagonale de la carte de 8 000 × 8 000 studs (section 0)
local WHOLE_MAP = math.ceil(8000 * math.sqrt(2))

-- 8.2 : armes. fireInterval = 1 tir toutes les n s ; reload = s par munition
WeaponConfig.Weapons = {
	WPN_Rifle = {
		name = "Fusil à verrou",
		ammo = 5,
		fireInterval = 1.4,
		reloadPerRound = 1.2,
		damageBody = 180,
		damageHead = 400,
		friendlyTorso = 120,
		noise = WHOLE_MAP,
	},
	WPN_Revolver = {
		name = "Revolver",
		ammo = 6,
		fireInterval = 0.6,
		reloadPerRound = 0.8,
		damageBody = 70,
		damageHead = 160,
		friendlyTorso = 60,
		noise = 2500,
	},
	WPN_Shotgun = {
		name = "Fusil à pompe",
		ammo = 4,
		fireInterval = 1.0,
		reloadPerRound = 0.9,
		pellets = 8,
		damagePerPellet = 18, -- jusqu'à 15 studs, puis −70 % à 40 studs
		fullDamageRange = 15,
		reducedRange = 40,
		reducedFactor = 0.3,
		-- TODO(BIBLE): forme de la baisse entre 15 et 40 studs (linéaire en attendant) et portée au-delà de 40
		friendlyPerPellet = 15,
		noise = WHOLE_MAP,
		-- TODO(BIBLE): écart des plombs (degrés). PROVISOIRE : 0 = tous dans l'axe
		spreadDegrees = 0,
	},
	WPN_FlareGun = {
		name = "Pistolet lance-fusées",
		owner = "Pyrotechnician",
		ammo = 3,
		reloadTime = 2,
		damage = 20,
		blindDuration = 3,
		creatureFleeDuration = 8,
		friendlyDamage = 30, -- + brûlure
		noise = 1200,
		-- TODO(BIBLE): cadence du pistolet lance-fusées (« — » dans 8.2) et effet de la brûlure sur un coéquipier
	},
	MEL_Axe = {
		name = "Hache",
		owner = "Athlete",
		melee = true,
		fireInterval = 1.1,
		damage = 25,
		grabReleaseHits = 1, -- un coup sur le bras qui saisit = lâcher
		friendlyDamage = 30,
		noise = 40,
	},
	MEL_Machete = {
		name = "Machette",
		melee = true,
		fireInterval = 0.8,
		damage = 18,
		grabReleaseHits = 2, -- deux coups = lâcher
		friendlyDamage = 20,
		noise = 30,
		-- TODO(BIBLE): qui porte la machette au départ, ou où se trouve-t-elle ?
	},
}

-- TODO(BIBLE): portée des armes de mêlée (studs). PROVISOIRE : 7, la portée du coup de la créature (9.10)
WeaponConfig.MeleeRange = 7

-- 8.2 : armes à feu selon la taille du groupe (1–3, 4–6, 7–10)
WeaponConfig.FirearmsByGroupSize = {
	{ maxPlayers = 3, weapons = { "WPN_Rifle" } },
	{ maxPlayers = 6, weapons = { "WPN_Rifle", "WPN_Revolver" } },
	{ maxPlayers = 10, weapons = { "WPN_Rifle", "WPN_Revolver", "WPN_Shotgun" } },
}
WeaponConfig.RifleToRole = "Tracker" -- le fusil revient d'office au Pisteur s'il est présent
WeaponConfig.NoFirearmRole = "RadioOperator" -- l'Opératrice ne peut pas en porter

-- 8.2 : boîte de munitions de secours (A1–A5, une seule ; absente en Cauchemar)
WeaponConfig.AmmoBox = { WPN_Rifle = 5, WPN_Revolver = 6, WPN_Shotgun = 4 }

-- 16.3 : RE_FireWeapon — origine à moins de 5 studs de la tête
WeaponConfig.MaxOriginOffset = 5

-- 4.4 : conflit au tableau des armes : vote à la majorité en 15 s, sinon tirage
WeaponConfig.ConflictVoteDuration = 15

-- 13.5 : icônes Icon_<ID> ; identifiants rbxassetid à renseigner après import (DÉFAUT : vide)
WeaponConfig.Icons = {}

return WeaponConfig
