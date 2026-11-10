--[[ HauteurEST : proxy de HauteurGlobale pour la region EST (S7/S3/S8) : H et Basse + Alignement_EST.Delta ; tout le reste est delegue.
 (Tendance reste brute.) HauteurGlobale n'est pas modifie. ]]
local HG = require(script.Parent.HauteurGlobale)
local AE = require(script.Parent.Alignement_EST)
local P = setmetatable({}, { __index = HG })
function P.H(X, Z) return HG.H(X, Z) + AE.Delta(X, Z) end
function P.Basse(X, Z) return HG.Basse(X, Z) + AE.Delta(X, Z) end
P.Brut = HG
return P
