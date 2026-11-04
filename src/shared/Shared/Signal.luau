-- ReplicatedStorage/Shared/Signal
-- Signal minimal en Luau pur : Connect, Once, Fire, Wait, DisconnectAll.
-- Les fonctions connectées tournent chacune dans leur propre fil (task.spawn).
local Signal = {}
Signal.__index = Signal

local Connection = {}
Connection.__index = Connection

function Connection:Disconnect()
	if not self.Connected then
		return
	end
	self.Connected = false
	local connections = self._signal._connections
	local index = table.find(connections, self)
	if index then
		table.remove(connections, index)
	end
end

function Signal.new()
	return setmetatable({ _connections = {} }, Signal)
end

function Signal:Connect(handler)
	local connection = setmetatable({
		Connected = true,
		_signal = self,
		_handler = handler,
	}, Connection)
	table.insert(self._connections, connection)
	return connection
end

function Signal:Once(handler)
	local connection
	connection = self:Connect(function(...)
		connection:Disconnect()
		handler(...)
	end)
	return connection
end

function Signal:Fire(...)
	-- copie : un handler peut se déconnecter pendant l'appel
	for _, connection in table.clone(self._connections) do
		if connection.Connected then
			task.spawn(connection._handler, ...)
		end
	end
end

function Signal:Wait()
	local thread = coroutine.running()
	self:Once(function(...)
		task.spawn(thread, ...)
	end)
	return coroutine.yield()
end

function Signal:DisconnectAll()
	for _, connection in table.clone(self._connections) do
		connection:Disconnect()
	end
end

return Signal
