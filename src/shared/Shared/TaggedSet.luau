-- ReplicatedStorage/Shared/TaggedSet
-- DÉFAUT (technique, 17 : budget mobile) : listes d'instances taguées tenues à jour par les signaux de
-- CollectionService (GetInstanceAddedSignal / GetInstanceRemovedSignal) au lieu d'un GetTagged à chaque
-- appel, et RaycastParams construits une seule fois puis mis à jour seulement quand une instance d'un
-- des tags suivis est ajoutée ou retirée.
local CollectionService = game:GetService("CollectionService")

local TaggedSet = {}

local sets = {} -- [tag] = { list = {Instance}, version = number }

local function get(tag)
	local set = sets[tag]
	if set then
		return set
	end
	set = { list = CollectionService:GetTagged(tag), version = 0 }
	sets[tag] = set
	CollectionService:GetInstanceAddedSignal(tag):Connect(function(instance)
		if not table.find(set.list, instance) then
			table.insert(set.list, instance)
		end
		set.version += 1
	end)
	CollectionService:GetInstanceRemovedSignal(tag):Connect(function(instance)
		local index = table.find(set.list, instance)
		if index then
			-- l'ordre n'a pas d'importance : le dernier prend la place du retiré
			set.list[index] = set.list[#set.list]
			set.list[#set.list] = nil
		end
		set.version += 1
	end)
	return set
end

-- liste tenue à jour des instances portant `tag` (à lire seulement, ne pas modifier)
function TaggedSet.list(tag)
	return get(tag).list
end

-- numéro qui change à chaque ajout ou retrait d'une instance portant `tag`
function TaggedSet.version(tag)
	return get(tag).version
end

-- RaycastParams « Exclude » : les instances fixes de `base`, plus toutes les instances des `tags`.
-- cache:Get() rend toujours le même objet ; son filtre n'est refait que si un des tags a changé.
function TaggedSet.excludeParams(base, tags)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local versions = {}
	local function rebuild()
		local filter = table.clone(base)
		for _, tag in tags do
			local set = get(tag)
			versions[tag] = set.version
			table.move(set.list, 1, #set.list, #filter + 1, filter)
		end
		params.FilterDescendantsInstances = filter
	end
	rebuild()
	local cache = {}
	function cache:Get()
		for _, tag in tags do
			if get(tag).version ~= versions[tag] then
				rebuild()
				break
			end
		end
		return params
	end
	return cache
end

return TaggedSet
