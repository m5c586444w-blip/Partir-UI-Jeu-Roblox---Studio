-- tools/studio/ResetPaths (hors projets Rojo) — LECTURE SEULE
-- Remise à zéro (HANDOFF, étape 0b) : imprime le chemin de chaque instance des services du jeu, une par
-- ligne (« Service/Parent/Nom »). Recopier la sortie dans un fichier texte, puis :
--   python3 tools/studio/reset_diff.py <fichier> Lobby   (ou Partie)
-- qui liste tout ce qui n'est pas dans la place assemblée par Rojo (résidus à supprimer).
local SERVICES = {
	"Workspace",
	"Lighting",
	"MaterialService",
	"ReplicatedFirst",
	"ReplicatedStorage",
	"ServerScriptService",
	"ServerStorage",
	"StarterGui",
	"StarterPack",
	"StarterPlayer",
	"SoundService",
	"Teams",
	"TextChatService",
	"Chat",
}

local lines = {}
local function visit(instance, path)
	table.insert(lines, path)
	for _, child in instance:GetChildren() do
		visit(child, path .. "/" .. child.Name)
	end
end

for _, serviceName in SERVICES do
	local ok, service = pcall(function()
		return game:GetService(serviceName)
	end)
	if ok and service then
		visit(service, serviceName)
	end
end
-- impression par paquets de 100 lignes : une seule sortie trop longue serait coupée sans prévenir
local CHUNK = 100 -- constante (outil)
for first = 1, #lines, CHUNK do
	print(table.concat(lines, "\n", first, math.min(first + CHUNK - 1, #lines)))
end
