-- ReplicatedStorage/Config/MapConfig
-- Toutes les positions viennent de la section 3 de la bible. Ne rien ajouter ici sans la bible.
-- Jalon J1 : seulement les départs S1 à S3 (tirés au lancement, section 4.4).
-- Les lieux Pxx, extractions, points tirés et tracés sont remplis au jalon J2 (phase A7).
local MapConfig = {}

-- 3.3 : départs (X, Y, Z)
MapConfig.Spawns = {
	S1 = Vector3.new(2780, 120, 3220), -- autour du van ; 10 points espacés de 6 studs
	S2 = Vector3.new(-1380, 70, 3290), -- autour du bulldozer
	S3 = Vector3.new(-820, 230, 640), -- dans le camp, corps visibles
}

return MapConfig
