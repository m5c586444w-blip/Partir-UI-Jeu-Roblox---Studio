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

return Util
