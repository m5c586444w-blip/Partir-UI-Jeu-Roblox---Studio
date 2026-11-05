-- ReplicatedStorage/Shared/Util
-- Fonctions utilitaires partagées par les deux places.
local Util = {}

-- copie profonde d'une table (sans métatables)
function Util.deepCopy(value)
	if type(value) ~= "table" then
		return value
	end
	local copy = {}
	for key, child in value do
		copy[key] = Util.deepCopy(child)
	end
	return copy
end

-- ajoute à `target` les clés de `template` qui lui manquent (récursif).
-- Les valeurs déjà présentes ne sont jamais écrasées.
function Util.reconcile(target, template)
	for key, templateValue in template do
		local current = target[key]
		if current == nil then
			target[key] = Util.deepCopy(templateValue)
		elseif type(current) == "table" and type(templateValue) == "table" then
			Util.reconcile(current, templateValue)
		end
	end
	return target
end

-- clés d'une table, triées
function Util.sortedKeys(dictionary)
	local keys = {}
	for key in dictionary do
		table.insert(keys, key)
	end
	table.sort(keys)
	return keys
end

-- appelle `fn` jusqu'à `attempts` fois, avec `delay` secondes entre deux échecs.
-- Renvoie ok, puis le résultat (ou le dernier message d'erreur).
function Util.retry(attempts, delay, fn, ...)
	local ok, result
	for attempt = 1, attempts do
		ok, result = pcall(fn, ...)
		if ok then
			return true, result
		end
		if attempt < attempts then
			task.wait(delay)
		end
	end
	return false, result
end

-- cherche une remote dans ReplicatedStorage/Remotes ; avertissement clair si elle manque
function Util.getRemote(name)
	local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
	local remote = remotes and remotes:FindFirstChild(name)
	if remote == nil then
		warn("Remote manquante : Remotes/" .. name)
	end
	return remote
end

-- côté serveur : envoie un message système de LoreConfig.Messages (4.6) à un joueur.
-- `params` remplace {player} et {n} côté client (ex. { player = "Nora", n = 3 }).
function Util.notify(player, messageKey, params)
	local remote = Util.getRemote("RE_Notify")
	if remote ~= nil and player.Parent ~= nil then
		remote:FireClient(player, messageKey, params)
	end
end

-- côté client : texte final d'un message système, {player} et {n} remplacés
function Util.formatMessage(template, params)
	params = params or {}
	return (
		template:gsub("{(%w+)}", function(name)
			local value = params[name]
			return if value ~= nil then tostring(value) else "{" .. name .. "}"
		end)
	)
end

-- DÉFAUT : état partagé de la partie (journal, preuves du groupe, horloge…), en attributs d'un
-- dossier ReplicatedStorage/MatchState créé par le serveur (répliqué automatiquement).
function Util.getMatchState()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local RunService = game:GetService("RunService")
	local folder = ReplicatedStorage:FindFirstChild("MatchState")
	if folder == nil then
		if RunService:IsServer() then
			folder = Instance.new("Folder")
			folder.Name = "MatchState"
			folder.Parent = ReplicatedStorage
		else
			folder = ReplicatedStorage:WaitForChild("MatchState")
		end
	end
	return folder
end

-- tableau ↔ chaîne JSON (attributs : pas de tables)
function Util.encode(value)
	return game:GetService("HttpService"):JSONEncode(value)
end

function Util.decode(text, fallback)
	if type(text) ~= "string" or text == "" then
		return fallback
	end
	local ok, value = pcall(function()
		return game:GetService("HttpService"):JSONDecode(text)
	end)
	return if ok then value else fallback
end

-- HumanoidRootPart du personnage d'un joueur, ou nil
function Util.characterRoot(player)
	local character = player and player.Character
	return character and character:FindFirstChild("HumanoidRootPart") or nil
end

-- côté client : élément d'UI par son chemin depuis PlayerGui (ex. "HUDGui/BodyStatus/Head").
-- 15.1 : un élément introuvable produit un seul avertissement clair, et le jeu continue (renvoie nil).
local warnedUI = {}
-- 15.7 (1) : un écran peut avoir deux dispositions, Layout_Desktop et Layout_Touch, avec les mêmes noms
-- d'éléments. Seule `Visible` de ces deux cadres est changée (selon UserInputService.TouchEnabled).
local LAYOUTS = { "Layout_Desktop", "Layout_Touch" }

function Util.isTouch()
	return game:GetService("UserInputService").TouchEnabled
end

-- disposition active d'un ScreenGui (nil si l'écran n'en a pas)
function Util.activeLayout(gui)
	local desktop, touch = gui:FindFirstChild(LAYOUTS[1]), gui:FindFirstChild(LAYOUTS[2])
	if desktop == nil and touch == nil then
		return nil
	end
	if Util.isTouch() then
		return touch or desktop
	end
	return desktop or touch
end

-- 15.7 : voile à 60 % montré tant qu'une des fenêtres listées dans son attribut veilFor est visible
local function bindVeil(container)
	local veil = container:FindFirstChild("Veil")
	local list = veil and veil:GetAttribute("veilFor")
	if veil == nil or type(list) ~= "string" then
		return
	end
	local windows = {}
	for name in string.gmatch(list, "[^,]+") do
		local w = container:FindFirstChild(name)
		if w and w:IsA("GuiObject") then
			table.insert(windows, w)
		end
	end
	local function update()
		local shown = false
		for _, w in windows do
			shown = shown or w.Visible
		end
		veil.Visible = shown
	end
	for _, w in windows do
		w:GetPropertyChangedSignal("Visible"):Connect(update)
	end
	update()
end

-- prépare un ScreenGui une seule fois : disposition (15.7) et voiles
function Util.prepareGui(gui)
	if gui == nil or not gui:IsA("ScreenGui") or gui:GetAttribute("prepared") then
		return
	end
	gui:SetAttribute("prepared", true)
	local touch = Util.isTouch()
	local desktop, touchLayout = gui:FindFirstChild(LAYOUTS[1]), gui:FindFirstChild(LAYOUTS[2])
	if desktop then
		desktop.Visible = not touch or touchLayout == nil
	end
	if touchLayout then
		touchLayout.Visible = touch
	end
	for _, container in { gui, desktop, touchLayout } do
		if container then
			bindVeil(container)
		end
	end
end

function Util.findUI(root, path)
	local node = root
	for part in string.gmatch(path, "[^/]+") do
		if node == nil then
			break
		end
		local child = node:FindFirstChild(part)
		if child == nil and node:IsA("ScreenGui") then
			-- 15.7 : l'élément est dans la disposition active
			local layout = Util.activeLayout(node)
			child = layout and layout:FindFirstChild(part)
		end
		node = child
	end
	if node == nil and not warnedUI[path] then
		warnedUI[path] = true
		warn("UI manquante : " .. path)
	end
	return node
end

Util.SECONDS_PER_MINUTE = 60 -- constante (unité)
Util.GUI_WAIT_TIMEOUT = 30 -- constante (attente d'une ScreenGui dans PlayerGui, s)

-- côté client : ScreenGui du joueur (attend sa copie dans PlayerGui)
function Util.waitGui(name)
	local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	local gui = playerGui:WaitForChild(name, Util.GUI_WAIT_TIMEOUT)
	if gui == nil then
		warn("UI manquante : " .. name)
	else
		Util.prepareGui(gui)
	end
	return gui
end

-- 15.1 : clone d'un enfant « Template » (seule création d'UI permise aux scripts)
function Util.cloneTemplate(template, order)
	local clone = template:Clone()
	clone.Name = template.Name .. "Clone"
	clone.Visible = true
	if order then
		clone.LayoutOrder = order
	end
	clone.Parent = template.Parent
	return clone
end

-- retire les clones d'un modèle (laisse le Template et les objets de disposition)
function Util.clearClones(template)
	for _, child in template.Parent:GetChildren() do
		if child.Name == template.Name .. "Clone" then
			child:Destroy()
		end
	end
end

return Util
