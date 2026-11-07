-- tools/studio/ApplyTerrainMaterials (hors projets Rojo) — recrée les MaterialVariant du terrain (13.4) et les teintes
-- À lancer dans la Partie (barre de commande ou outil MCP, contexte Édition). Une texture PBR Poly Haven (CC0, 1 024 px :
-- couleur, normale, rugosité) par matériau de terrain ; sources et licences : ReplicatedStorage/Credits, fichiers dans
-- assets/terrain/. Les identifiants sont ceux renvoyés par l'envoi du 2026-11-07 (compte qui a téléversé les images).
-- Un MaterialVariant doit avoir le même matériau de base que le matériau qu'il remplace : une variante par matériau.

local MaterialService = game:GetService("MaterialService")
local MapConfig = require(game:GetService("ReplicatedStorage").Config.MapConfig)

local TILE = 30 -- constante (studs par tuile de texture, DÉFAUT du 2026-11-07)
local TILE_GROUND = 48 -- constante (sols d'herbe et de forêt : tuiles plus grandes, le quadrillage se voit de loin)

-- nom de la variante = { matériau de base, couleur, normale, rugosité }
local VARIANTS = {
	PF_LeafyGrass = { Enum.Material.LeafyGrass, 124168886532888, 96914400027905, 114963976285212 }, -- Forest Ground 03 (aiguilles, feuilles)
	PF_Grass = { Enum.Material.Grass, 113465666955005, 76264927084395, 127390191584644 }, -- Leafy Grass (prairie)
	PF_Ground = { Enum.Material.Ground, 121479777950608, 109721597947101, 106483111108966 }, -- Brown Mud Dry (terre)
	PF_Mud = { Enum.Material.Mud, 114832597009649, 94221255311704, 123616034213106 }, -- Mud Forest
	PF_MuddyTracks = { Enum.Material.Mud, 83719219601931, 110820452256959, 105533623514053 }, -- Muddy Tracks (disponible)
	PF_Rock = { Enum.Material.Rock, 138983756842743, 134786768170619, 114950488225100 }, -- Rock Pitted Mossy
	PF_Basalt = { Enum.Material.Basalt, 116309104997137, 105660698607364, 72483149639042 }, -- Dark Rock (basalte sombre)
	-- Burned Ground 01 : couleur passée en gris neutre (assets/terrain/ash_gray) pour que AshColor (#7A7670) donne la cendre de 3.6
	PF_Sand = { Enum.Material.Sand, 92965341258568, 128216929274994, 122275822330630 },
}

-- matériau de terrain → variante (PF_MuddyTracks ne remplace rien)
local OVERRIDES = {
	Grass = "PF_Grass",
	Ground = "PF_Ground",
	LeafyGrass = "PF_LeafyGrass",
	Mud = "PF_Mud",
	Rock = "PF_Rock",
	Basalt = "PF_Basalt",
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
	variant.MaterialPattern = Enum.MaterialPattern.Organic -- DÉFAUT : réduit le quadrillage visible de loin
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
-- teintes sombres et désaturées (MapConfig.Terrain.Tints) ; Sand : AshColor
for material, hex in MapConfig.Terrain.Tints do
	workspace.Terrain:SetMaterialColor(Enum.Material[material], Color3.fromHex(hex))
end
workspace.Terrain:SetMaterialColor(Enum.Material.Sand, MapConfig.Terrain.Materials.AshColor)
print("ApplyTerrainMaterials : variantes, remplacements et teintes appliqués")
