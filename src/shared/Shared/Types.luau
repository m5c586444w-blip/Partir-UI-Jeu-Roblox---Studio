-- ReplicatedStorage/Shared/Types
-- Types Luau partagés (documentation du format des données ; aucun code).

-- 16.4 : données d'un joueur (DataStore PisteFroide_v1, clé player_<UserId>)
export type EvidenceEntry = {
	class: string, -- "A", "B" ou "C" (8.4)
	kind: string, -- ex. "Video"
	date: number,
}

export type PlayerData = {
	version: number,
	xp: number,
	plays: number,
	survivals: number,
	endings: { [string]: boolean },
	evidence: { EvidenceEntry }, -- 200 au plus
	skins: { [string]: { [string]: boolean } }, -- skins[role][skin]
	equipped: { [string]: string }, -- equipped[role] = skin
	notebookPages: { boolean },
	museumRead: { [string]: boolean },
	nightmareUnlocked: boolean,
	settings: { [string]: any },
}

-- 4.4 et 16.4 : configuration de partie écrite par LaunchService, lue par PartyLoaderService
export type LaunchPlayer = {
	userId: number,
	role: string?, -- rempli par RoleService (J9)
	weapon: string?, -- rempli par WeaponBoardService (J9)
}

export type LaunchData = {
	version: number, -- Shared/Version du Lobby
	players: { LaunchPlayer },
	difficulty: string?, -- rempli par VoteService (J9)
	weather: string?, -- rempli par VoteService (J9)
	start: string, -- "S1", "S2" ou "S3"
	seed: number, -- os.time() au lancement (3.4)
}

return {}
