-- ReplicatedStorage/Config/GoreConfig
-- Valeurs de la bible, section 11. Ne rien ajouter ici sans la bible.
-- Jalon J6 : seulement le ragdoll de la mort (7.3, 11.5). Les deux profils sont ajoutés au jalon J13.
local GoreConfig = {}

-- 11.5 : ragdoll : BallSocketConstraint sur les articulations à la mort ;
-- le corps passe ancré après 10 s immobile, pour économiser la physique
GoreConfig.Ragdoll = { AnchorAfterStill = 10 }

return GoreConfig
