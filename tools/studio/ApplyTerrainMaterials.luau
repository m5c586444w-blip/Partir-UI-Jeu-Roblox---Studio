-- tools/studio/ApplyTerrainMaterials (hors projets Rojo) — recrée les MaterialVariant du terrain (13.4)
-- À lancer dans la Partie (barre de commande ou outil MCP, contexte Édition) : crée ou met à jour les variantes de
-- MaterialService et les associe aux matériaux de terrain. Textures Poly Haven CC0 (1 024 px, couleur / normale /
-- rugosité) téléversées le 2026-11-07 depuis assets/terrain/ ; sources et licences : ReplicatedStorage/Credits.
-- Les identifiants sont ceux renvoyés par l'envoi ; ils appartiennent au compte qui a téléversé les images.

local MaterialService = game:GetService("MaterialService")

local TILE = 30 -- constante (studs par tuile de texture, DÉFAUT du 2026-11-07)
local TILE_GROUND = 48 -- constante (herbe et sols de forêt : tuiles plus grandes, le quadrillage se voit de loin)

-- nom de la variante = { matériau de base, couleur, normale, rugosité }
local VARIANTS = {
	PF_Ground = { Enum.Material.Ground, 109245734977514, 86039605845052, 72840541166694 }, -- Forest Ground 01
	PF_LeafyGrass = { Enum.Material.LeafyGrass, 89404280888803, 127598096126730, 76382098325593 }, -- Forest Floor
	PF_Grass = { Enum.Material.Grass, 89404280888803, 127598096126730, 76382098325593 }, -- DÉFAUT : Forest Floor
	PF_Mud = { Enum.Material.Mud, 114832597009649, 94221255311704, 123616034213106 }, -- Mud Forest
	PF_MuddyTracks = { Enum.Material.Mud, 83719219601931, 110820452256959, 105533623514053 }, -- Muddy Tracks
	PF_Rock = { Enum.Material.Rock, 138983756842743, 134786768170619, 114950488225100 }, -- Rock Pitted Mossy
	PF_Sand = { Enum.Material.Sand, 121732491769634, 93330635692484, 86038684208427 }, -- Brown Mud 03 : couleur passée en gris neutre (assets/terrain/ash_gray, moyenne 0,87) pour que AshColor (#7A7670) donne la cendre de 3.6
}

-- matériau de terrain → variante (PF_MuddyTracks reste disponible, sans remplacer Mud)
local OVERRIDES = {
	Grass = "PF_Grass",
	Ground = "PF_Ground",
	LeafyGrass = "PF_LeafyGrass",
	Mud = "PF_Mud",
	Rock = "PF_Rock",
	Basalt = "PF_Rock",
	Sand = "PF_Sand",
}

local function asset(id)
	return "rbxassetid://" .. id
end

for name, spec in VARIANTS do
	local variant = MaterialService:FindFirstChild(name) or Instance.new("MaterialVariant")
	variant.Name = name
	variant.BaseMaterial = spec[1]
	variant.ColorMap = asset(spec[2])
	variant.NormalMap = asset(spec[3])
	variant.RoughnessMap = asset(spec[4])
	variant.StudsPerTile = if name == "PF_Grass"
			or name == "PF_LeafyGrass"
			or name == "PF_Ground"
		then TILE_GROUND
		else TILE
	variant.Parent = MaterialService
end
for material, name in OVERRIDES do
	MaterialService:SetBaseMaterialOverride(Enum.Material[material], name)
end
print("ApplyTerrainMaterials : variantes et remplacements appliqués")
