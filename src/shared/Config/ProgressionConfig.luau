-- ReplicatedStorage/Config/ProgressionConfig
-- Valeurs de la bible, section 16.4 (données, XP) et 16.2 (DataService).
-- Ne rien ajouter ici sans la bible.
-- Les règles de déblocage des skins (7.1) et de Cauchemar (5.4) sont ajoutées au jalon J14.
local ProgressionConfig = {}

-- 16.4 : DataStore PisteFroide_v1, clé player_<UserId>
ProgressionConfig.DataStoreName = "PisteFroide_v1"
ProgressionConfig.KeyPrefix = "player_"

-- 16.4 : champ « version » des données
ProgressionConfig.DataVersion = 1

-- 16.2 : sauvegarde toutes les 120 s et à la fermeture
ProgressionConfig.AutosaveInterval = 120

-- 16.4 : liste des preuves, 200 au plus
ProgressionConfig.MaxEvidence = 200

-- 16.4 : clés des fins (5.3)
ProgressionConfig.EndingIds = { "Survie", "Preuve", "Verite", "Ordonnance", "Silence" }

-- 16.4 et 4.3 : panneaux du musée M1 à M8
ProgressionConfig.MuseumPanelIds = { "M1", "M2", "M3", "M4", "M5", "M6", "M7", "M8" }

-- 16.4 : pages du carnet Halvorsen (DOC_12) ; la page 1 est débloquée au départ
ProgressionConfig.DefaultNotebookPages = { true, false, false }

-- 7.1 : 3 skins par personnage, A dès le début
ProgressionConfig.SkinIds = { "A", "B", "C" }
ProgressionConfig.DefaultSkin = "A"

-- 16.4 : niveau = partie entière de la racine de (XP ÷ 100)
ProgressionConfig.XPPerLevelDivisor = 100

-- 16.4 : gains d'XP ; preuves selon 8.4
ProgressionConfig.XPGains = {
	MuseumPanel = 5, -- panneau de musée lu (première fois, 4.2)
	GamePlayed = 50, -- partie jouée
	Survival = 200, -- survie
	EvidenceA = 500, -- 8.4 : vidéo du Caméraman
	EvidenceB = 150, -- 8.4 : moulage, cri, poils, photo
	EvidenceC = 50, -- 8.4 : document, photo du charnier
}

-- 16.2 : verrouillage de session (valeurs techniques acceptées le 4 novembre 2026, 16.4)
ProgressionConfig.SessionLock = {
	-- un verrou non rafraîchi depuis 360 s (3 sauvegardes manquées) est considéré abandonné
	StaleAfter = 360,
	-- nombre d'essais de chargement si une autre place tient encore le verrou (téléportation)
	LoadAttempts = 6,
	-- secondes entre deux essais de chargement
	LoadRetryDelay = 5,
}

return ProgressionConfig
