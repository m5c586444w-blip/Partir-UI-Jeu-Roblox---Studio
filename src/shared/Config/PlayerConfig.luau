-- ReplicatedStorage/Config/PlayerConfig
-- Valeurs de la bible, sections 2.5 et 7. Ne rien ajouter ici sans la bible.
-- Jalon J1 : seulement la liste des rôles (nécessaire aux données de 16.4).
-- Le reste de la section 7 (vitesses, santé, endurance, peur...) est rempli au jalon J6 (phase A3).
local PlayerConfig = {}

-- 2.5 : les 10 rôles jouables, dans l'ordre de la bible.
-- id = identifiant de code (2.5) : RoleCard_<ROLE>, Characters/<ROLE>, VO_<ROLE>_*,
-- et clé des données skins / equipped (16.4).
PlayerConfig.Roles = {
	{ id = "Leader", title = "Meneur" },
	{ id = "Medic", title = "Médecin" },
	{ id = "Tracker", title = "Pisteur" },
	{ id = "Cameraman", title = "Caméraman" },
	{ id = "Mechanic", title = "Mécanicienne" },
	{ id = "Descendant", title = "Descendante" },
	{ id = "Geologist", title = "Géologue" },
	{ id = "Athlete", title = "Sportif" },
	{ id = "RadioOperator", title = "Opératrice radio" },
	{ id = "Pyrotechnician", title = "Pyrotechnicien" },
}

return PlayerConfig
