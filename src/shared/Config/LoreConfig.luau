-- ReplicatedStorage/Config/LoreConfig
-- Textes de la bible : documents DOC_xx (2.7), panneaux M1-M8 (4.3), dialogues (4.2).
-- Claude Code recopie ces textes, il n'en rédige pas d'autre (section 2).
-- Squelette créé au jalon J1 : les textes sont recopiés aux jalons J7 (documents) et J14 (musée, dialogues).
local LoreConfig = {}

-- Clés de texte envoyées par le serveur avec RE_Notify (16.3 : « clé de texte »).
-- TODO(BIBLE): aucun de ces textes n'est écrit dans la bible. Chaîne vide = rien d'affiché.
LoreConfig.Notifications = {
	PartyFull = "", -- TODO(BIBLE): texte « groupe complet »
	PartyNotFound = "", -- TODO(BIBLE): texte « aucun groupe avec ce code »
	NoPublicParty = "", -- TODO(BIBLE): texte « aucun groupe public à rejoindre »
	AlreadyInParty = "", -- TODO(BIBLE): texte « tu es déjà dans un groupe »
	LaunchFailed = "", -- TODO(BIBLE): texte « le départ a échoué »
	VersionMismatch = "", -- TODO(BIBLE): texte « versions Lobby / Partie différentes »
	LaunchDataMissing = "", -- TODO(BIBLE): texte « configuration de partie introuvable »
}

return LoreConfig
