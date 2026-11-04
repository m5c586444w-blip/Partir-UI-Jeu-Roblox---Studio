-- ReplicatedStorage/Config/AudioConfig
-- Valeurs de la bible, sections 12.5, 12.6 et 13.7. Ne rien ajouter ici sans la bible.
-- Les sons sont à fournir (13.1 : Freesound CC0 / CC-BY, enregistrements de Gabriel) ;
-- chaque identifiant rbxassetid est vide tant que le son n'est pas importé dans Studio.
-- Un son vide n'est pas joué (avertissement dans la console, jamais d'erreur).
local AudioConfig = {}

-- 12.5 : sons d'ambiance
AudioConfig.Ambience = {
	AMB_Birds = { where = "Forêt", acts = { 0, 4 }, silencedByCreature = true, id = "" },
	AMB_Insects_Owls = { where = "Forêt", acts = { 1, 2, 3 }, silencedByCreature = true, id = "" },
	AMB_Wind_Pines = { where = "Dehors", volumeFromWind = true, id = "" },
	AMB_River = { where = "R1, R2, R3", emitterSpacing = 60, masksNoise = true, id = "" },
	AMB_Waterfall = { where = "P13", masksNoise = true, id = "" },
	AMB_CanyonWind = { where = "P03, P05", id = "" },
	AMB_AshEmpty = { where = "P08", id = "" },
	AMB_TunnelDrips = { where = "P07", id = "" },
}
AudioConfig.FaunaSilenceRadius = 60 -- EVT_01 / 9.6 : la faune se tait sur 60 studs

-- 12.6 : musique
AudioConfig.Music = {
	MUS_Lobby = { when = "Lobby", id = "" },
	MUS_Siege = { when = "Acte 2, pendant le bombardement", id = "" },
	MUS_Chase = { when = "La créature attaque ou charge le joueur local à moins de 60 studs", range = 60, id = "" },
	MUS_Dawn = { when = "Cinématiques d'extraction", id = "" },
}

-- 12.5 : pas des joueurs, 4 variantes par matériau
AudioConfig.FootstepMaterials =
	{ "Grass", "LeafyGrass", "Ground", "Mud", "Pebble", "Rock", "Basalt", "Sand", "Snow", "Water", "Wood", "Metal" }
AudioConfig.FootstepVariants = 4
AudioConfig.Footsteps = {} -- [matériau] = { id1, id2, id3, id4 }

-- 13.7 : sons de la créature, des impacts, des joueurs, des voix, des objets et des lieux.
-- [ID] = rbxassetid ; vide en attendant l'import.
AudioConfig.Sounds = {}

-- 2.7 : enregistrements des documents (cassettes, DOC_14)
AudioConfig.Documents = {}

return AudioConfig
