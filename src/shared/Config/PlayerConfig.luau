-- ReplicatedStorage/Config/PlayerConfig
-- Valeurs de la bible, sections 2.5 et 7. Ne rien ajouter ici sans la bible.
-- Jalon J1 : seulement la liste des rôles (nécessaire aux données de 16.4).
-- Le reste de la section 7 (vitesses, santé, endurance, peur...) est rempli au jalon J6 (phase A3).
local PlayerConfig = {}

-- 2.5 : les 10 rôles jouables, dans l'ordre de la bible.
-- id = identifiant anglais utilisé dans les noms (RoleCard_<ROLE>, Characters/<ROLE>, VO_<ROLE>_*)
-- et comme clé dans les données (skins, equipped, section 16.4).
-- Seul « Leader » est donné par la bible (16.4, VO_Leader_Order).
-- Un rôle sans id est ignoré par les scripts tant que la bible ne le donne pas.
PlayerConfig.Roles = {
	{ id = "Leader", title = "Meneur" },
	{ id = nil, title = "Médecin" }, -- TODO(BIBLE): identifiant anglais du rôle Médecin
	{ id = nil, title = "Pisteur" }, -- TODO(BIBLE): identifiant anglais du rôle Pisteur
	{ id = nil, title = "Caméraman" }, -- TODO(BIBLE): identifiant anglais du rôle Caméraman
	{ id = nil, title = "Mécanicienne" }, -- TODO(BIBLE): identifiant anglais du rôle Mécanicienne
	{ id = nil, title = "Descendante" }, -- TODO(BIBLE): identifiant anglais du rôle Descendante
	{ id = nil, title = "Géologue" }, -- TODO(BIBLE): identifiant anglais du rôle Géologue
	{ id = nil, title = "Sportif" }, -- TODO(BIBLE): identifiant anglais du rôle Sportif
	{ id = nil, title = "Opératrice radio" }, -- TODO(BIBLE): identifiant anglais du rôle Opératrice radio
	{ id = nil, title = "Pyrotechnicien" }, -- TODO(BIBLE): identifiant anglais du rôle Pyrotechnicien
}

return PlayerConfig
