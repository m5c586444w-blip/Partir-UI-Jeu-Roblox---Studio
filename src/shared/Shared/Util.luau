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
function Util.findUI(root, path)
	local node = root
	for part in string.gmatch(path, "[^/]+") do
		node = if node ~= nil then node:FindFirstChild(part) else nil
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
