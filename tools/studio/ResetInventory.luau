-- tools/studio/ResetInventory (hors projets Rojo) — LECTURE SEULE
-- Remise à zéro (HANDOFF, étape 0) : inventaire de tout ce que contient une place ouverte dans Studio.
-- À coller dans la barre de commande de Studio (ou à lancer par l'outil MCP de Studio), une fois dans
-- la place Lobby et une fois dans la place Partie. Le script n'écrit, ne déplace et ne supprime rien :
-- il imprime un inventaire en Markdown à recopier dans RESET_INVENTAIRE.md.
-- Avec Team Create, toute modification est enregistrée aussitôt : ne rien changer d'autre à la main.

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

-- propriétés qui portent un identifiant d'asset
local ASSET_PROPERTIES = {
	"SoundId",
	"Image",
	"Texture",
	"TextureID",
	"TextureId",
	"MeshId",
	"AnimationId",
	"ColorMap",
	"NormalMap",
	"RoughnessMap",
	"MetalnessMap",
	"SkyboxBk",
	"SkyboxDn",
	"SkyboxFt",
	"SkyboxLf",
	"SkyboxRt",
	"SkyboxUp",
	"LinkedSource",
	"PackageId",
}

-- appels qui nomment un stockage (DataStore, MemoryStore, MessagingService)
local STORE_PATTERNS = {
	'GetDataStore%(%s*"([^"]+)"',
	'GetOrderedDataStore%(%s*"([^"]+)"',
	"GetGlobalDataStore%(%s*%)",
	'GetSortedMap%(%s*"([^"]+)"',
	'GetHashMap%(%s*"([^"]+)"',
	'GetQueue%(%s*"([^"]+)"',
	'SubscribeAsync%(%s*"([^"]+)"',
	'PublishAsync%(%s*"([^"]+)"',
}

local lines = {}
local function out(text)
	table.insert(lines, text)
end

local function read(instance, property)
	local ok, value = pcall(function()
		return instance[property]
	end)
	if ok and type(value) == "string" and value ~= "" then
		return value
	end
	if ok and typeof(value) == "number" and value ~= 0 and property == "PackageId" then
		return tostring(value)
	end
	return nil
end

out(
	("# Inventaire de la place %s (PlaceId %d, GameId %d, version %d)"):format(
		game.Name,
		game.PlaceId,
		game.GameId,
		game.PlaceVersion
	)
)
out("")

local scripts, packages, assets, stores = {}, {}, {}, {}
for _, serviceName in SERVICES do
	local ok, service = pcall(function()
		return game:GetService(serviceName)
	end)
	if ok and service then
		local counts = {}
		local total = 0
		for _, instance in service:GetDescendants() do
			total += 1
			counts[instance.ClassName] = (counts[instance.ClassName] or 0) + 1
			if instance:IsA("LuaSourceContainer") then
				local okSource, source = pcall(function()
					return instance.Source
				end)
				source = if okSource then source else ""
				table.insert(
					scripts,
					("- `%s` (%s, %d caractères)"):format(instance:GetFullName(), instance.ClassName, #source)
				)
				for _, pattern in STORE_PATTERNS do
					for name in string.gmatch(source, pattern) do
						stores[name] = (stores[name] or "") .. " " .. instance:GetFullName()
					end
				end
			end
			if instance:IsA("PackageLink") then
				table.insert(
					packages,
					("- `%s` : %s"):format(instance:GetFullName(), tostring(read(instance, "PackageId")))
				)
			end
			for _, property in ASSET_PROPERTIES do
				local value = read(instance, property)
				if value and string.find(value, "%d") then
					table.insert(assets, ("- `%s`.%s = %s"):format(instance:GetFullName(), property, value))
				end
			end
		end
		out(("## %s : %d instances"):format(serviceName, total))
		local classes = {}
		for className, n in counts do
			table.insert(classes, ("%s ×%d"):format(className, n))
		end
		table.sort(classes)
		out(if #classes > 0 then table.concat(classes, ", ") else "(vide)")
		out("")
		for _, child in service:GetChildren() do
			out(("- `%s` (%s, %d descendants)"):format(child.Name, child.ClassName, #child:GetDescendants()))
		end
		out("")
	end
end

-- terrain : nombre de cellules non vides
local terrain = workspace.Terrain
local okCells, cells = pcall(function()
	return terrain:CountCells()
end)
out(("## Terrain : %s cellules"):format(if okCells then tostring(cells) else "inconnu"))
out("")
out(("## Scripts (%d)"):format(#scripts))
for _, line in scripts do
	out(line)
end
out("")
out(("## Packages (%d)"):format(#packages))
for _, line in packages do
	out(line)
end
out("")
out(("## Identifiants d'assets (%d)"):format(#assets))
for _, line in assets do
	out(line)
end
out("")
out("## Noms de stockage trouvés dans les scripts (DataStore, MemoryStore, MessagingService)")
for name, where in stores do
	out(("- `%s` :%s"):format(name, where))
end
out("")

-- impression par paquets de 100 lignes : une seule sortie trop longue serait coupée sans prévenir
local CHUNK = 100 -- constante (outil)
for first = 1, #lines, CHUNK do
	print(table.concat(lines, "\n", first, math.min(first + CHUNK - 1, #lines)))
end
