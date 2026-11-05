-- ReplicatedStorage/Config/PlayerConfig
-- Valeurs de la bible, sections 2.5, 6.3 et 7. Ne rien ajouter ici sans la bible.
local PlayerConfig = {}

-- 2.5 : les 10 rôles jouables. id = identifiant de code (RoleCard_<ROLE>, Characters/<ROLE>, VO_<ROLE>_*)
PlayerConfig.Roles = {
	{ id = "Leader", title = "Meneur", character = "Caleb Marsh" },
	{ id = "Medic", title = "Médecin", character = "Priya Natarajan" },
	{ id = "Tracker", title = "Pisteur", character = "Wyatt Dunn" },
	{ id = "Cameraman", title = "Caméraman", character = "Theo Lindqvist" },
	{ id = "Mechanic", title = "Mécanicienne", character = "Rosa Delgado" },
	{ id = "Descendant", title = "Descendante", character = "Nora Halvorsen" },
	{ id = "Geologist", title = "Géologue", character = "Malik Okafor" },
	{ id = "Athlete", title = "Sportif", character = "Jake Kowalski" },
	{ id = "RadioOperator", title = "Opératrice radio", character = "Mei Tanaka" },
	{ id = "Pyrotechnician", title = "Pyrotechnicien", character = "Dylan Croft" },
}

-- 7.1 : modèle du rôle dans ReplicatedStorage/Characters/<ROLE>/Skin_<n>
PlayerConfig.CharactersFolder = "Characters"
PlayerConfig.SkinPrefix = "Skin_"

-- 7.2 : déplacement (studs/s) et bruit (rayon entendu, studs)
PlayerConfig.Movement = {
	Walk = { speed = 12, noise = 25 },
	Run = { speed = 20, noise = 60 },
	Crouch = { speed = 6, noise = 6 },
	Prone = { speed = 2.5, noise = 0 },
	Carry = { speed = 8, noise = 40 }, -- porter un blessé
	JumpLandNoise = 30, -- saut (réception)
	LimpThreshold = 0.3, -- boiter : jambe < 30 %
	LimpSpeedFactor = 0.6,
	LimpNoiseBonus = 10,
	-- eau aux genoux / cendre / neige
	TerrainSpeedFactor = { Water = 0.7, Ash = 0.9, Snow = 0.85 },
	WaterNoiseFactor = 2,
	-- exceptions des rôles (7.2, 7.7)
	RoleRunSpeed = { Medic = 18 },
	RoleCarrySpeed = { Athlete = 12 }, -- le Sportif peut courir en portant
	RoleCanRunCarrying = { Athlete = true },
	RoleRunNoise = { Athlete = 75 }, -- respiration : bruit de course 75
}

-- 7.2 : caméra
PlayerConfig.Camera = {
	FieldOfView = 70,
	RunFieldOfView = 76,
	FirstPersonLocked = true,
	CrosshairOnlyWhenAiming = true,
}

-- 7.3 : points de vie par membre
PlayerConfig.Limbs = { "Head", "Torso", "ArmL", "ArmR", "LegL", "LegR" }
PlayerConfig.LimbHealth = { Head = 30, Torso = 100, ArmL = 50, ArmR = 50, LegL = 60, LegR = 60 }
PlayerConfig.RoleLimbHealth = { Pyrotechnician = { Torso = 80 } } -- 7.7 : torse 80 PV
PlayerConfig.LowLimbThreshold = 0.3 -- effets sous 30 %
PlayerConfig.LowArmReloadFactor = 1.5 -- bras sous 30 % : recharge ×1,5 plus lente
PlayerConfig.LowTorsoStaminaFactor = 0.5 -- torse sous 30 % : endurance max ÷ 2

-- 7.3 : sang
PlayerConfig.Blood = {
	Max = 100,
	LightBleedPerSecond = 0.5,
	HeavyBleedPerSecond = 2,
	DesaturateBelow = 40,
	DownedBelow = 20,
}

-- 7.3 : à terre (durée selon la difficulté : ActConfig.Difficulties)
PlayerConfig.Downed = {
	CrawlSpeed = 1.5,
	ReviveTime = 6,
	RoleReviveTime = { Medic = 3 },
	ReviveLimbFraction = 0.2, -- le joueur revient avec 20 % sur le membre touché
}

-- 19.5 (C6) : porter un coéquipier à terre (vitesse, bruit et endurance : Movement.Carry, Stamina)
PlayerConfig.Carry = {
	PickUpTime = 2, -- maintenir Utiliser 2 s pour le charger sur l'épaule
	PutDownTime = 1, -- Utiliser 1 s pour le poser
	DownedTimeFactor = 0.5, -- le compte à rebours du joueur porté avance deux fois moins vite
}

-- 6.3 : caméra de mort (sans coupe), puis spectateur
PlayerConfig.DeathCamera = { Duration = 4, TiltDegrees = 10, Height = 3 } -- Height : DÉFAUT (studs au-dessus du corps)

-- 7.4 : endurance
PlayerConfig.Stamina = {
	Max = 100,
	RoleMax = { Geologist = 80 },
	RunCostPerSecond = 12,
	JumpCost = 10,
	CarryCostPerSecond = 6,
	RegenWalkingPerSecond = 15,
	RegenIdlePerSecond = 25,
	RegenDelay = 1.5,
	ExhaustedDuration = 4,
	ExhaustedPantNoise = 35, -- halètement audible à 35 studs
}

-- 7.5 : peur (0 à 100), jamais affichée en chiffre
PlayerConfig.Fear = {
	Max = 100,
	NoLightRadius = 10, -- aucune lumière à 10 studs : +1/s
	NoLightPerSecond = 1,
	AloneRadius = 40, -- aucun coéquipier à 40 studs : +1,5/s
	AlonePerSecond = 1.5,
	SeeBody = 15, -- une fois par corps
	SeeCreatureMin = 20, -- +20 à +35, plus si proche
	SeeCreatureMax = 35,
	ScreamRadius = 100, -- cri à moins de 100 studs : +10
	Scream = 10,
	WoodKnock = 4, -- coup sur tronc entendu
	TeammateRadius = 15, -- coéquipier à 15 studs : −2/s
	TeammatePerSecond = -2,
	InLightPerSecond = -1,
	NearFirePerSecond = -3, -- près d'un feu ou d'une fusée
	LeaderOrder = -20, -- recharge 90 s (7.7)
	RoleFactor = { Descendant = 1.25 },
	-- seuils et effets
	HeartbeatAt = 40,
	ShakyAimAt = 60,
	ShakyAimFactor = 1.5,
	BreathingAt = 60,
	BreathingNoise = 20,
	MisplacedSoundsAt = 80,
	MisplacedSoundsDuration = 2,
	StaminaRegenFactorAt80 = 0.7,
	InvoluntaryScreamAt = 100,
	InvoluntaryScreamNoise = 200,
	InvoluntaryScreamCooldown = 60,
	-- TODO(BIBLE): distance à laquelle un joueur « voit » un corps (+15) et la créature (+20 à +35).
	-- Tant qu'elles valent nil, ces hausses ne sont pas appliquées.
	SeeBodyRange = nil,
	SeeCreatureRange = nil,
}

-- 7.6 : visibilité pour la créature (coefficient multiplié à sa portée de vue)
PlayerConfig.Visibility = {
	StandingOpen = 1.0,
	StandingForest = 0.6,
	CrouchFactor = 0.6,
	ProneInFernsFactor = 0.1,
	ProneInFernsMaxDistance = 10, -- invisible au-delà de 10 studs
	LightOnFactor = 3,
	LightOnMaxDistance = 600,
	RainOrFogFactor = 0.6,
	TabletOpenFactor = 1.5, -- 8.3
}

-- 7.7 : capacités des rôles
PlayerConfig.Abilities = {
	Leader = { OutlineRange = 30, OrderFear = -20, OrderRange = 15, OrderCooldown = 90 },
	Medic = { HealFactor = 2, ReviveTime = 3 },
	Tracker = {
		FootprintMaxAge = 120,
		DirectionErrorDegrees = 45,
		DirectionCooldown = 60,
		GrudgeShotFactor = 2,
	},
	Cameraman = { BatteryMinutes = 6 },
	Mechanic = { RepairFactor = 2, QuickSlots = 3 },
	Descendant = { HiddenClueRange = 8, FearFactor = 1.25 },
	Geologist = { StaminaMax = 80 },
	Athlete = { CarrySpeed = 12, PlankTime = 4, RunNoise = 75 },
	RadioOperator = { MimicHearRange = 150, NoFirearm = true },
	Pyrotechnician = {
		FlareRecipe = { ITM_Battery = 2, ITM_DuctTape = 1 },
		NoiseTrapRecipe = { ITM_TinCan = 1, ITM_Rope = 1 },
		TorsoHealth = 80,
	},
}

-- 7.8 : communication
PlayerConfig.Communication = {
	VoiceNoiseMax = 80,
	WalkieRange = 1500,
	WalkieBeepNoise = 20,
	PingDuration = 10,
	PingRayLength = 1000, -- DÉFAUT : portée du rayon qui pose un repère (studs)
}

-- 7.2 : posture → réglage de mouvement (RE_SetStance)
PlayerConfig.Stances = { Stand = "Walk", Crouch = "Crouch", Prone = "Prone", Run = "Run" }

-- Interface : 15.2 (HUD) et réglages d'affichage DÉFAUT (ni texte, ni gameplay)
PlayerConfig.Interface = {
	HudFadeAfter = 4, -- 15.2 : le HUD s'efface après 4 s sans changement
	FearVignetteMinTransparency = 0.4, -- DÉFAUT : « léger vignettage » (7.5) à peur 100
	NotificationDuration = 5, -- DÉFAUT : s d'affichage d'un message système
	NotificationMax = 4, -- DÉFAUT : messages affichés en même temps
	LeanOffset = 1.5, -- DÉFAUT : décalage de caméra en se penchant (studs)
	BobAmplitude = 0.08, -- DÉFAUT : balancement de marche (studs)
	BobFrequency = 8, -- DÉFAUT : fréquence du balancement à la vitesse de marche (rad/s)
	AimSway = 0.2, -- DÉFAUT : balancement de visée de base (degrés), ×1,5 par la peur ≥ 60 (7.5)
	LowBloodSaturation = -1, -- DÉFAUT : saturation à sang 0 (désaturation progressive sous 40)
	LowHeadBlur = 8, -- DÉFAUT : flou (BlurEffect.Size) tête sous 30 %
	LampFlickerChance = 0.15, -- DÉFAUT : chance par image qu'une lampe faible s'éteigne
	PortraitDistance = 6, -- DÉFAUT : distance de la caméra du portrait (RoleSelectGui, studs)
}

-- DÉFAUT : touches (clavier, positions physiques : Q = A sur un clavier AZERTY, 7.2 « A/E »)
PlayerConfig.Keys = {
	Sprint = Enum.KeyCode.LeftShift,
	Crouch = Enum.KeyCode.C,
	Prone = Enum.KeyCode.X,
	LeanL = Enum.KeyCode.Q,
	LeanR = Enum.KeyCode.E,
	Light = Enum.KeyCode.T,
	Reload = Enum.KeyCode.R,
	Tablet = Enum.KeyCode.Tab,
	Ping = Enum.KeyCode.G,
	Bag = Enum.KeyCode.B,
	Ability = Enum.KeyCode.V,
	Settings = Enum.KeyCode.P, -- DÉFAUT : ouvre SettingsGui (Échap est le menu Roblox)
	Slots = { Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four },
	GamepadSprint = Enum.KeyCode.ButtonL3,
	GamepadCrouch = Enum.KeyCode.ButtonB,
	GamepadFire = Enum.KeyCode.ButtonR2,
	GamepadAim = Enum.KeyCode.ButtonL2,
	GamepadReload = Enum.KeyCode.ButtonY,
}

-- DÉFAUT (valeurs techniques, ni texte ni gameplay) : cadences de calcul côté serveur
PlayerConfig.Technical = {
	Tick = 0.5, -- s entre deux mises à jour de santé, d'endurance et de peur
	FootstepNoiseInterval = 0.5, -- s entre deux bruits de pas en mouvement
	StanceSpeedTolerance = 1.25, -- vitesse réelle tolérée au-dessus de la vitesse de la posture (16.3)
	SpawnLift = 3, -- hauteur de pose d'un personnage au-dessus du point de départ (studs)
	InteractKey = Enum.KeyCode.F, -- touche d'interaction (A et E servent à se pencher, 7.2)
	InteractGamepadKey = Enum.KeyCode.ButtonX,
	HoldTolerance = 0.3, -- marge (s) sur le temps de maintien vérifié par le serveur
	VideoCheckInterval = 0.25, -- s entre deux contrôles de la vidéo de classe A
	DownedDamageKills = true, -- TODO(BIBLE): un coup reçu à terre tue-t-il ? PROVISOIRE : oui
	-- DÉFAUT (19.5, C6) : Porter et Poser ont leur propre touche, pour ne pas se confondre avec Relever
	CarryKey = Enum.KeyCode.G,
	CarryGamepadKey = Enum.KeyCode.ButtonY,
	CarryOffset = Vector3.new(0, 1.5, 0.5), -- position du joueur porté sur l'épaule (studs)
	TapCycleTime = 0.3, -- écran tactile : un appui plus court change d'invite au lieu d'agir
}

-- 19.5 (C2) : un coup de 20 à 34 → hémorragie légère ; 35 ou plus → grave ; moins de 20 → aucune.
-- Saisie tenue plus de 2 s → légère. Les pierres ne causent jamais d'hémorragie grave.
PlayerConfig.BleedOnDamage = { LightAt = 20, HeavyAt = 35, GrabLightAfter = 2, StoneMax = "Light" }

-- TODO(BIBLE): sur quel membre agissent le bandage (+10 PV) et la trousse (+40 PV) ?
-- PROVISOIRE : le membre le plus abîmé (en proportion).
PlayerConfig.HealTarget = "MostDamaged"

-- TODO(BIBLE): sang rendu au joueur relevé après être tombé faute de sang. PROVISOIRE : le seuil (20).
PlayerConfig.ReviveBlood = 20

return PlayerConfig
