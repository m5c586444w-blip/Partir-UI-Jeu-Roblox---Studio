-- StarterPlayer/StarterPlayerScripts/ClientBootstrap (les deux places)
-- DÉFAUT : charge tous les contrôleurs de StarterPlayerScripts/Controllers (16.1, 16.2) :
-- Init() de chacun, puis Start(). Un contrôleur en erreur n'arrête pas les autres.
local controllersFolder = script.Parent:WaitForChild("Controllers")

local controllers = {}
local names = {}
for _, module in controllersFolder:GetChildren() do
	if module:IsA("ModuleScript") then
		local ok, result = pcall(require, module)
		if ok then
			controllers[module.Name] = result
			table.insert(names, module.Name)
		else
			warn("ClientBootstrap : échec du chargement de " .. module.Name .. " : " .. tostring(result))
		end
	end
end
table.sort(names)

for _, name in names do
	local controller = controllers[name]
	if controller.Init then
		local ok, err = pcall(controller.Init, controller, controllers)
		if not ok then
			warn("ClientBootstrap : échec de " .. name .. ".Init : " .. tostring(err))
		end
	end
end

for _, name in names do
	local controller = controllers[name]
	if controller.Start then
		task.spawn(function()
			local ok, err = pcall(controller.Start, controller)
			if not ok then
				warn("ClientBootstrap : échec de " .. name .. ".Start : " .. tostring(err))
			end
		end)
	end
end
