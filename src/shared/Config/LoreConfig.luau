-- ReplicatedStorage/Config/LoreConfig
-- Textes de la bible : documents DOC_xx (2.7), panneaux M1-M8 (4.3), dialogues (4.2),
-- messages système (4.6). Claude Code recopie ces textes, il n'en rédige pas d'autre (section 2).
-- Les documents sont recopiés au jalon J7, le musée et les dialogues au jalon J14.
local LoreConfig = {}

-- 4.6 : messages système, affichés par NotificationGui.
-- Le serveur envoie la clé avec RE_Notify ; {player} et {n} sont remplacés par le code.
LoreConfig.Messages = {
	MSG_PartyFull = "Ce groupe est complet (10 joueurs).",
	MSG_CodeInvalid = "Aucun groupe ne correspond à ce code.",
	MSG_QuickJoinNone = "Aucun groupe public disponible. Crée le tien.",
	MSG_PartyLeft = "Tu as quitté le groupe.",
	MSG_HostLeft = "Le créateur du groupe est parti. {player} prend sa place.",
	MSG_RoleTaken = "Ce rôle est déjà pris par {player}.",
	MSG_RoleRequired = "Choisis un rôle avant d'être prêt.",
	MSG_WeaponTaken = "Cette arme est déjà attribuée à {player}.",
	MSG_WeaponNotAllowed = "L'opératrice radio ne peut pas porter d'arme à feu.",
	MSG_WeaponVote = "Deux joueurs veulent la même arme. Votez : 15 secondes.",
	MSG_NightmareLocked = "Cauchemar se débloque après une première survie.",
	MSG_WaitingReady = "En attente : {n} joueur(s) pas encore prêt(s).",
	MSG_Countdown = "Départ dans {n} s.",
	MSG_CountdownCancelled = "Départ annulé : un joueur n'est plus prêt.",
	MSG_Teleporting = "En route vers la forêt…",
	MSG_TeleportRetry = "Le départ a échoué. Nouvel essai…",
	MSG_TeleportAbort = "Impossible de partir pour l'instant. Réessayez dans un moment.",
	MSG_WaitingPlayers = "En attente des autres membres du groupe…",
	MSG_PlayerMissing = "{player} n'a pas rejoint la forêt.",
	MSG_VersionMismatch = "Une mise à jour est en cours. Retour en ville.",
	MSG_ReturnToLobby = "Retour en ville…",
	MSG_DataLoadFailed = "Ta progression n'a pas pu être chargée. Elle ne sera pas sauvegardée pendant cette session.",
	MSG_LaunchConfigMissing = "La partie n'a pas pu être préparée. Retour en ville.",
}

-- 15.6 : textes d'interface remplis par les scripts ({player} remplacé par le code)
LoreConfig.UI = {
	TakenBy = "Pris par {player}",
	Watching = "Tu regardes {player}",
	Lock = "Verrouillé",
}

-- 2.7 : documents trouvables (texte définitif). title = colonne « Type » ; body = texte affiché.
-- kind : "Paper" (papier), "Tape" (cassette / audio), "Image" (image + légende), "Video", "Map".
-- image / audio : assets à créer (13.5, 13.7), vides en attendant.
LoreConfig.Documents = {
	DOC_01 = {
		title = "Avis de recherche",
		kind = "Paper",
		body = "DISPARUS depuis le 7 octobre : Dr A. Whitcombe, S. Ito, B. Castillo, L. Brandt. Recherches suspendues. Toute information : Skamania County Sheriff.",
	},
	DOC_02 = {
		title = "Permis de recherche",
		kind = "Paper",
		body = "Pacific Cascades University — relevé géophysique des tubes de lave, secteur sud. Autorisation 30 jours. Interdiction d'entrer dans la zone fermée.",
	},
	DOC_03 = {
		title = "Cassette 1 (Ito)",
		kind = "Tape",
		body = "Jour 9. Encore des cailloux sur la bâche cette nuit. Alan dit que c'est le vent. Le vent ne vise pas.",
	},
	DOC_04 = {
		title = "Carnet de terrain (Castillo)",
		kind = "Paper",
		body = "Trois coups sur un tronc, au nord. Puis trois coups au sud. Ils se répondent.",
	},
	DOC_05 = {
		title = "Cassette 2 (Whitcombe)",
		kind = "Tape",
		body = "Il était petit. Il s'est approché du camp. J'ai tiré. Personne ne doit savoir. On part dans deux jours.",
	},
	DOC_06 = {
		title = "Photo d'empreinte",
		kind = "Image",
		body = "41 cm. Deux tailles différentes sur la même piste.",
		image = "Img_DOC06",
	},
	DOC_07 = { title = "Carte des tunnels", kind = "Map", body = "", image = "Img_TabletMap_Tunnels", unlocks = "E4" },
	DOC_08 = { title = "Vidéo de la tablette", kind = "Video", body = "", cinematic = "CS_05" },
	DOC_09 = {
		title = "Message radio (Ito)",
		kind = "Tape",
		body = "Ici Ito, tour de guet. Alan est descendu. Il dit qu'il va leur rendre. Si quelqu'un entend… ne dormez pas près de l'eau.",
	},
	DOC_10 = {
		title = "Dernier carnet (Ito)",
		kind = "Paper",
		body = "Ils ne mangent pas les morts tout de suite. Ils les rangent. Comme des réserves. Ou comme des avertissements.",
	},
	-- DOC_11 : résumé de l'enquête au musée (texte du panneau M2, 4.3) — rempli au jalon J14
	DOC_12 = {
		title = "Carnet de la famille Halvorsen",
		kind = "Paper",
		pages = {
			"Il n'a jamais voulu en parler. Il disait seulement : ne tire pas le premier.",
			"Ils frappaient les arbres avant les pierres.", -- débloquée au siège
			"On leur avait pris quelqu'un, à eux aussi.", -- fin « La vérité »
		},
	},
	DOC_13 = {
		title = "Note du ranger Hollis",
		kind = "Paper",
		body = "Zone fermée. Officiellement le sol. Officieusement, on retrouve des wapitis sans tête. Ne restez pas après la nuit tombée.",
	},
	DOC_14 = { title = "Enregistrement météo", kind = "Tape", body = "", audio = "SFX_Call_Long_01" }, -- 40 s de vent, puis un cri long
	DOC_15 = {
		title = "Panneau « Sasquatch Refuge »",
		kind = "Sign",
		body = "SKAMANIA COUNTY — SASQUATCH REFUGE — Ord. 69-01",
	},
	DOC_16 = { title = "Photo de groupe des géologues", kind = "Image", body = "", image = "Img_DOC16" },
}

-- 8.3 : tablette, appli Réseau
LoreConfig.Tablet = {
	NoNetwork = "Aucun réseau",
	NoGps = "Pas de signal GPS",
	HollisReply = "Restez groupés. Personne ne monte avant l'aube.",
}

-- Textes des invites ProximityPrompt (InteractGui > ActionText).
-- 15.6 : libellés courts absents du tableau → proposition de Claude Code, marquée DÉFAUT.
LoreConfig.Prompts = {
	Pickup = "Ramasser", -- DÉFAUT
	Revive = "Relever", -- DÉFAUT (7.3 : « Relever »)
	Barricade = "Barricader", -- DÉFAUT (5.2 : « Barricader 3 ouvertures »)
	Repair = "Réparer", -- DÉFAUT (5.2 : « réparer »)
	ChangeWheel = "Changer la roue", -- DÉFAUT (5.2 : « changer la roue lacérée »)
	Call = "Appeler", -- DÉFAUT (5.2 : « appel »)
	Drive = "Conduire", -- DÉFAUT (5.2 : « conduire »)
	ClearPlug = "Dégager le bouchon", -- DÉFAUT (5.2)
	Read = "Lire", -- 15.6 (Play : Lire)
	Open = "Ouvrir", -- DÉFAUT (sac d'un mort)
	SkinShop = "Tenues", -- DÉFAUT (magasin, L04)
	Records = "Records", -- DÉFAUT (diner, L05 ; 4.5 « records »)
	EvidenceBoard = "Preuves", -- DÉFAUT (musée, L03 ; 15.6 « Preuves »)
}

-- 5.3 : fins (titres de la colonne « Fin » ; texte : colonne « Récompense » quand elle est rédigée)
-- TODO(BIBLE): textes de fin affichés dans ResultsGui > EndingText (seul « Silence » en a un)
LoreConfig.Endings = {
	Survie = { title = "Survie", text = "" },
	Preuve = { title = "Preuve", text = "" },
	Verite = { title = "La vérité", text = "" },
	Ordonnance = { title = "Ordonnance 69-01", text = "" },
	Silence = { title = "Silence", text = "Le podcast est publié… incomplet" },
}

-- 15.6 : libellés courts absents du tableau → DÉFAUT (statuts de ResultsGui > Survivors)
LoreConfig.Status = {
	Extracted = "Extrait", -- DÉFAUT
	Dead = "Mort", -- DÉFAUT
	Missing = "Disparu", -- 5.1 : « disparus »
}

-- 4.2 : dialogue du ranger Dale Hollis (bulles, 3 choix)
LoreConfig.Dialogue = {
	Speaker = "Ranger Dale Hollis", -- 2.6
	Prompt = "Parle au ranger", -- 4.2 : indicateur discret
	Opening = "Vous êtes les gamins du podcast ? Je vais vous dire ce que j'ai dit aux autres : n'y allez pas.",
	Choices = {
		{
			text = "Qu'est-ce qui s'est passé en 1924 ?",
			answer = "Allez voir le musée d'en face. Et lisez le rapport des rangers, pas seulement l'histoire des mineurs.",
		},
		{
			text = "On a le droit de tirer ?",
			answer = "Sur un ours, si vous n'avez pas le choix. Sur l'autre chose… Ordonnance 69-01. Ici, c'est un refuge.",
		},
		{
			text = "Où sont les géologues ?",
			answer = "Si je le savais, je ne serais pas assis ici. La route 83 est fermée. Officiellement, vous ne passez pas.",
		},
	},
}

-- 4.3 : le récit réel au musée (8 panneaux). source : ligne « Source » avec l'adresse du site.
-- TODO(BIBLE): adresse source de chaque panneau (4.3 l'exige, sans la donner panneau par panneau).
LoreConfig.Museum = {
	M1 = {
		title = "Juillet 1924",
		body = "Des prospecteurs travaillent près d'une gorge au sud-est du volcan. Ils disent avoir vu des créatures d'environ deux mètres. L'un d'eux tire. La nuit suivante, leur cabane est bombardée de pierres jusqu'à l'aube.",
		source = "",
		image = "Img_Museum_M1",
		voice = "VO_Museum_01",
	},
	M2 = {
		title = "L'enquête",
		body = "Deux rangers descendent dans la gorge. Ils ne trouvent rien et montrent que les empreintes peuvent être truquées. La presse, elle, baptise l'endroit Ape Canyon.",
		source = "",
		image = "Img_Museum_M2",
		voice = "VO_Museum_02",
	},
	M3 = {
		title = "Le témoin",
		body = "Fred Beck racontera l'histoire toute sa vie. En 1967, son livre y ajoute une dimension spirituelle absente des récits de 1924.",
		source = "",
		image = "Img_Museum_M3",
		voice = "VO_Museum_03",
	},
	M4 = {
		title = "Ape Cave",
		body = "Un tube de lave de près de 4 km, formé il y a 2 000 ans, découvert en 1947 par un bûcheron. Son nom vient d'un groupe local, les St. Helens Apes.",
		source = "",
		image = "Img_Museum_M4",
		voice = "VO_Museum_04",
	},
	M5 = {
		title = "L'ordonnance 69-01",
		body = "Le 1er avril 1969, le comté de Skamania fait du meurtre d'un Sasquatch un crime. Ce n'est pas une blague. En 1984, le comté devient un refuge.",
		source = "",
		image = "Img_Museum_M5",
		voice = "VO_Museum_05",
	},
	M6 = {
		title = "18 mai 1980",
		body = "À 8 h 32, le flanc nord s'effondre. 57 personnes meurent. Au nord, la forêt est couchée sur 600 km² et le lac Spirit se couvre de troncs.",
		source = "",
		image = "Img_Museum_M6",
		voice = "VO_Museum_06",
	},
	M7 = {
		title = "Lawetlat'la",
		body = "Pour les Cowlitz, le volcan est Lawetlat'la, « celui qui fume » ; pour les Klickitat, Loowit. Plusieurs peuples du Nord-Ouest racontent aussi des êtres de la forêt dont on évite de dire le nom. Ces récits appartiennent à des cultures vivantes.",
		source = "",
		image = "Img_Museum_M7",
		voice = "VO_Museum_07",
	},
	-- M8 porte la mention « Fiction » en petit (dans le titre de la bible)
	M8 = {
		title = "Disparus (fiction)",
		body = "Il y a 21 jours, quatre géologues ont cessé de répondre. Les recherches sont suspendues. Leur dernier message parlait de pierres lancées sur leur camp.",
		source = "",
		image = "Img_Museum_M8",
		voice = "VO_Museum_08",
		fiction = true,
	},
}

-- 15.6 : astuces de LoadingGui > Tip, tirées au hasard
LoreConfig.LoadingTips = {
	"Une lampe allumée se voit de très loin.",
	"Le bruit de l'eau couvre tes pas.",
	"Seul, tu es discret. Seul, tu es une proie.",
}

return LoreConfig
