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

-- 15.6 : astuces de LoadingGui > Tip, tirées au hasard
LoreConfig.LoadingTips = {
	"Une lampe allumée se voit de très loin.",
	"Le bruit de l'eau couvre tes pas.",
	"Seul, tu es discret. Seul, tu es une proie.",
}

return LoreConfig
