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

return Util
