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

-- 7.1 : déblocage des skins : A dès le début, B après 5 parties jouées, C après 1 survie
ProgressionConfig.SkinUnlocks = {
	A = { stat = nil, need = 0 },
	B = { stat = "plays", need = 5 },
	C = { stat = "survivals", need = 1 },
}

-- 19.5 (C38) : accessoires cosmétiques, choisis dans SkinShopGui (Accessories). stat : champ des données
-- (16.4 ; evidenceBOut = preuves de classe B sorties, DÉFAUT : compteur ajouté aux données).
-- Les identifiants sont des DÉFAUT (noms des boutons de SkinShopGui > Accessories).
ProgressionConfig.AccessoryIds = { "Beanie", "AmberHeadlamp", "ColdTrailBag" }
ProgressionConfig.AccessoryUnlocks = {
	-- TODO(BIBLE): les 3 couleurs du bonnet (C43 ; asset à créer, 13.3)
	Beanie = { stat = "plays", need = 3, colors = 3 }, -- bonnet (3 couleurs) après 3 parties
	AmberHeadlamp = { stat = "plays", need = 10 }, -- frontale ambre après 10 parties
	ColdTrailBag = { stat = "evidenceBOut", need = 1 }, -- sac « Cold Trail » : 1re preuve de classe B sortie
}

-- 17.2 : menu Réglages. Valeurs possibles et défaut PC / mobile ; enregistrés dans settings (16.4).
-- Les identifiants (Preset, FieldOfView…) sont ceux des lignes de SettingsGui (DÉFAUT, UI_MAP.md).
ProgressionConfig.Settings = {
	Preset = { options = { "Low", "Medium", "High", "Ultra" }, pc = "High", mobile = "Low" },
	Brightness = { min = -0.5, max = 0.5, pc = 0, mobile = 0 }, -- ajouté à ExposureCompensation
	ViewDistance = { options = { 25, 50, 75, 100 }, pc = 100, mobile = 50 },
	VegetationDensity = { options = { 25, 50, 75, 100 }, pc = 100, mobile = 50 },
	TreeWind = { options = { true, false }, pc = true, mobile = false },
	LampShadows = { options = { true, false }, pc = true, mobile = false },
	DepthOfField = { options = { true, false }, pc = true, mobile = false },
	Particles = { options = { "Low", "Normal" }, pc = "Normal", mobile = "Low" },
	FieldOfView = { min = 60, max = 90, pc = 70, mobile = 70 },
	-- DÉFAUT (C37) : plage de la sensibilité (17.2 : « — ») — préférence du joueur, pas une valeur de jeu
	Sensitivity = { min = 0.1, max = 3, pc = 1.0, mobile = 1.0 },
	InvertY = { options = { true, false }, pc = false, mobile = false },
	TouchButtonSize = { min = 80, max = 130, pc = 100, mobile = 100 },
	Master = { min = 0, max = 100, pc = 80, mobile = 80 },
	Ambience = { min = 0, max = 100, pc = 80, mobile = 80 },
	Voice = { min = 0, max = 100, pc = 80, mobile = 80 },
	Music = { min = 0, max = 100, pc = 80, mobile = 80 },
	Effects = { min = 0, max = 100, pc = 80, mobile = 80 },
	Subtitles = { options = { true, false }, pc = true, mobile = true },
	SubtitleSize = { options = { "Small", "Medium", "Large" }, pc = "Medium", mobile = "Medium" },
	ReduceMotion = { options = { true, false }, pc = false, mobile = false },
	ReducedGore = { options = { true, false }, pc = false, mobile = false }, -- 11.4
	Language = { options = { "French", "English", "Account" }, pc = "Account", mobile = "Account" }, -- défaut : langue du compte
}

-- 17.3 : ce que change chaque préréglage
ProgressionConfig.Presets = {
	Low = {
		clutter = 0.4,
		lampShadows = "PlayerOnly",
		animatedTrees = 0,
		dof = false,
		bloom = false,
		particles = "Low",
		bloodPools = 15,
	},
	Medium = {
		clutter = 0.7,
		lampShadows = 2,
		animatedTrees = 0,
		dof = false,
		bloom = true,
		particles = "Normal",
		bloodPools = 25,
	},
	High = {
		clutter = 1.0,
		lampShadows = 6,
		animatedTrees = 120,
		dof = true,
		bloom = true,
		particles = "Normal",
		bloodPools = 40,
	},
	Ultra = {
		clutter = 1.0,
		lampShadows = 6,
		animatedTrees = 200,
		dof = true,
		bloom = true,
		particles = "Normal",
		bloodPools = 40,
	},
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
