-- ReplicatedStorage/Shared/NoiseTypes
-- Types d'événements de bruit {position, rayon, type} reçus par NoiseService (sections 7, 8 et 9.4).
-- Les rayons sont dans PlayerConfig, ItemConfig et WeaponConfig.
local NoiseTypes = {
	Footstep = "Footstep", -- 7.2 : marche, course, accroupi, porter, boiter
	Jump = "Jump", -- 7.2 : réception d'un saut
	Pant = "Pant", -- 7.4 : halètement
	Breath = "Breath", -- 7.5 : respiration audible (peur ≥ 60)
	Scream = "Scream", -- 7.5 : cri involontaire (peur 100)
	Voice = "Voice", -- 7.8 : voix
	WalkieBeep = "WalkieBeep", -- 7.8
	Item = "Item", -- 8.1 : clic de lampe, bandage, outils…
	Impact = "Impact", -- 8.1 : pierre ou branche qui retombe
	Gunshot = "Gunshot", -- 8.2
	Melee = "Melee", -- 8.2
	Repair = "Repair", -- 5.2 : réparations, clouage
	Vehicle = "Vehicle", -- 5.2 : démarrage du van, bulldozer
	Other = "Other",
}

return NoiseTypes
