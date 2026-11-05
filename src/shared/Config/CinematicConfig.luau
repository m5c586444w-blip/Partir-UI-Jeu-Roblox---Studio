-- ReplicatedStorage/Config/CinematicConfig
-- Valeurs et textes de la bible, section 6. Ne rien ajouter ici sans la bible.
-- Plans : Part invisibles Workspace/Cinematics/CS_xx_Shot_n (posées à la main, 6.1), caméra
-- Scriptable, transitions TweenService. Chaque plan dure duration / nombre de plans (DÉFAUT).
-- scope : "Lobby", "Place" (joueurs dans le rayon du lieu), "All" (tous), "Local" (un seul joueur).
local CinematicConfig = {}

-- 6.1 : règles communes
CinematicConfig.MaxInGameDuration = 12 -- en partie, 12 s au plus
CinematicConfig.SafetyAfter = 3 -- invulnérable et retiré des cibles pendant la cinématique, plus 3 s
CinematicConfig.LobbySkipAfter = 10 -- en lobby, bouton « Passer » après 10 s
CinematicConfig.BarAspect = 2.35 -- bandes noires 2.35:1

-- 6.2 : liste
CinematicConfig.Cinematics = {
	CS_00 = {
		trigger = "1re connexion au lobby",
		duration = 70,
		scope = "Local",
		shots = 7,
		fov = 50, -- plan 1 : travelling lent (FOV 50)
		subtitle = "1924. Cinq hommes, une cabane, une nuit de pierres. Les rangers n'ont rien trouvé. En 1969, le comté a quand même voté une loi pour le protéger. En 1980, la montagne a explosé. Et il y a trois semaines, quatre géologues ont cessé de répondre. Cette nuit, on y va.",
		voice = "VO_CS00",
	},
	CS_01 = {
		trigger = "Compte à rebours fini",
		duration = 8,
		scope = "Lobby",
		shots = 2,
		subtitle = "Route forestière 83 — fermée",
	},
	CS_02a = {
		trigger = "Début de partie (S1)",
		duration = 10,
		scope = "All",
		shots = 1,
		subtitle = "OK. On trouve le camp, on filme, on rentre.",
	},
	CS_02b = {
		trigger = "Début de partie (S2)",
		duration = 10,
		scope = "All",
		shots = 1,
		subtitle = "OK. On trouve le camp, on filme, on rentre.",
	},
	CS_02c = {
		trigger = "Début de partie (S3)",
		duration = 10,
		scope = "All",
		shots = 1,
		subtitle = "OK. On trouve le camp, on filme, on rentre.",
	},
	-- CS_03 : pas de coupe, la caméra du joueur est attirée vers une silhouette à 90–120 studs (directeur, A5)
	CS_03 = {
		trigger = "1er aperçu de la créature",
		duration = 4,
		scope = "Local",
		noCut = true,
		silhouetteMin = 90,
		silhouetteMax = 120,
		faunaSilenceBefore = 3,
	},
	CS_04 = {
		trigger = "1re entrée dans P09",
		duration = 9,
		scope = "Place",
		place = "P09",
		shots = 2,
		subtitle = "… Oh non.",
		subtitleNearestPlayer = true,
	},
	-- 19.5 (C23) : CS_05 joue dans la tablette (TabletGui), sans prise de caméra ; le joueur reste dans
	-- le monde et peut fermer à tout moment. La limite de 12 s et l'invulnérabilité ne s'appliquent pas.
	CS_05 = {
		inTablet = true,
		trigger = "Vidéo de la tablette (DOC_08)",
		duration = 25,
		scope = "Local",
		shots = 6,
		subtitle = "Éteins ça. Éteins ça !",
		screenText = "Point de repli de l'équipe : cabane des mineurs",
		timestamp = "J-17 02:14",
		noMusic = true,
		subtitleShot = 3, -- 6.2 : « 3. Whitcombe : Éteins ça. Éteins ça ! »
		screenTextShot = 6, -- 6.2 : « 6. Écran : Point de repli… »
	},
	CS_06 = { trigger = "Début du siège", duration = 6, scope = "Place", place = "P05c", shots = 2 },
	CS_07 = { trigger = "Fin du siège", duration = 10, scope = "Place", place = "P05c", shots = 2, routeText = true },
	CS_08 = { trigger = "Début de l'acte 3", duration = 5, scope = "All", shots = 1, sound = "SFX_Call_Long_02" },
	CS_09 = { trigger = "05 h 00", duration = 6, scope = "All", shots = 1 },
	CS_10 = { trigger = "Extraction E1", duration = 12, scope = "All", shots = 3, music = "MUS_Dawn" },
	CS_11 = { trigger = "Extraction E2", duration = 12, scope = "All", shots = 2, music = "MUS_Dawn" },
	CS_12 = { trigger = "Extraction E3", duration = 12, scope = "All", shots = 2, music = "MUS_Dawn" },
	CS_13 = {
		trigger = "Extraction E4",
		duration = 12,
		scope = "All",
		shots = 2,
		music = "MUS_Dawn",
		subtitle = "On leur avait pris quelqu'un, à eux aussi.",
	},
	CS_14 = {
		trigger = "Alpha tué",
		duration = 12,
		scope = "All",
		shots = 3,
		screenText = "Étudiants inculpés : première application de l'ordonnance 69-01",
	},
	CS_15 = { trigger = "Preuve de classe A sortie", duration = 6, scope = "All", shots = 1 },
	CS_16 = {
		trigger = "Aucun survivant",
		duration = 10,
		scope = "All",
		shots = 2,
		screenText = "Épisode 12 — Cold Trail — durée 00:47",
	},
}

-- 3.3 et 5.2 : cinématique d'arrivée selon le départ tiré
CinematicConfig.StartCinematic = { S1 = "CS_02a", S2 = "CS_02b", S3 = "CS_02c" }

-- 19.5 (C24) : message radio entendu hors du rayon d'une cinématique de lieu, dit par le personnage
-- du joueur le plus proche du lieu. Autres cinématiques : aucun message.
CinematicConfig.OutOfRangeRadioText = {
	CS_04 = "{player} : On a trouvé le camp. Il y a… quelqu'un. Venez.",
	CS_06 = "{player} : Ça tombe sur la cabane ! Rejoignez-nous !",
	CS_07 = "{player} : Ça s'est arrêté. Je crois.",
}

return CinematicConfig
