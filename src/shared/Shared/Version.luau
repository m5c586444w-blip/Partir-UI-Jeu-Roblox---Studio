-- ReplicatedStorage/Shared/Version
-- Numéro de version commun aux deux places (section 16.1) : le Lobby l'écrit dans la
-- configuration de partie, la Partie le compare au sien.
-- À augmenter de 1 à chaque publication qui change Config, Shared ou les remotes,
-- et publier alors les deux places ensemble.
local Version = {}

Version.Number = 1

return Version
