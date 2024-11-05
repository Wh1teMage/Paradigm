local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local DataTransfer = require(script.DataTransfer)
local PackageComponent = require(script.PackageComponent)

local Events = ReplicatedStorage.Events

local CustomEvents = {}

local Event = {}

local Signal = {}

function Signal:Disconnect()
	local connection = CustomEvents[self.EventName]['_connections'][self.Id]
	setmetatable(connection, nil)
	CustomEvents[self.EventName]['_connections'][self.Id] = nil
end

function Event:Wait(scope: string)
	local uuid = tostring(os.clock())..tostring(math.random(-1000, 1000))
	if (not self['_waitConnections'][scope]) then
		self['_waitConnections'][scope] = {}
	end
	
	local waitConnection = { isFinished = false }
	
	local callback = function()
		while (not waitConnection.isFinished) do
			task.wait()
		end
	end

	self['_waitConnections'][scope][uuid] = waitConnection
	
	callback()
	
	self['_waitConnections'][scope][uuid] = nil
end

function Event:Connect(callback: (scope: string, ...any) -> ())
	local uuid = tostring(os.clock())..tostring(math.random(-1000, 1000))
	
	local event = setmetatable(
		{
			Callback = callback,
			Id = uuid,
			EventName = self.Name,
		},
		{
			__call = function(...)
				callback(...)
			end,
			__index = function(t, i)
				return Signal[i]
			end,
		}
	)
	
	self['_connections'][uuid] = callback
	
	return event
end

function Event:Fire(scope: string, ...)
	
	local args = {...}

	if (not self.IsBindable) then
		
		if (RunService:IsClient()) then
			local data, len = DataTransfer:Encode({...})
			PackageComponent:AddToPackage(scope, {data, len})
			--self.Instance:FireServer(scope, DataTransfer:Encode({...}))
		else
			local data, len = DataTransfer:Encode({table.unpack(args, 2)})
			PackageComponent:AddToPackage(scope, {data, len}, args[1] :: Player)
			--self.Instance:FireClient(args[1] :: Player, scope, data, len)
		end
		
	else
		
		for _, connection in pairs(self['_connections']) do
			connection(scope, ...)
		end

		for _, info in pairs(self['_waitConnections'][scope] or {}) do
			info.isFinished = true
		end
		
	end
	
end

function Event:FireAllClients(scope: string, ...)
	if (RunService:IsClient()) then return end

	for _, player in pairs(Players:GetPlayers()) do
		self:Fire(scope, player, ...)
	end
end

local function eventConnection(name: string)
	
	local event: RemoteEvent = Events:FindFirstChild(name)
	local customEvent = CustomEvents[name]
	
	if ((not event) or (not customEvent)) then warn(name..' event doesnt exist') return end
	
	local connection;

	if (RunService:IsClient()) then

		PackageComponent.Finish = function(self, package)
			local redactedPackage = {}

			for scope, vals in pairs(package) do
				local elementSize = (buffer.len(vals[1][1]) + 2)
				local buff = buffer.create(#vals * elementSize)

				local offset = 0

				for i, val in pairs(vals) do
					buffer.copy(buff, offset, val[1])
					offset += elementSize-2
					buffer.writeu8(buff, offset, val[2])
					offset += 2
				end

				redactedPackage[scope] = { buff, elementSize }
			end

			event:FireServer(redactedPackage)
		end

		connection = event.OnClientEvent:Connect(function(data) --scope, buff: buffer, strLen
			--print(data)

			for scope, vals in pairs(data) do

				local buff = vals[1]
				local elementSize = vals[2]

				local strLen = buffer.readu8(buff, elementSize-2)

				for i = 0, buffer.len(buff)-1, elementSize do
					local newBuff = buffer.create(elementSize)
					buffer.copy(newBuff, 0, buff, i, elementSize)

					local value = DataTransfer:Decode(newBuff, strLen)

					--print(value, i, buffer.len(buff))
			
					for _, connection in pairs(customEvent['_connections']) do
						connection(scope, table.unpack(value))
					end
		
					for _, info in pairs(customEvent['_waitConnections'][scope] or {}) do
						info.isFinished = true
					end
				end

			end

			--print(scope, buffer.len(buff), strLen)

		end)
	else

		PackageComponent.Finish = function(self, package)
			--print(package, 'package')

			for player, data in pairs(package) do

				local redactedPackage = {}

				for scope, vals in pairs(data) do
					local elementSize = (buffer.len(vals[1][1]) + 2)
					local buff = buffer.create(#vals * elementSize)
	
					local offset = 0
	
					for i, val in pairs(vals) do
						buffer.copy(buff, offset, val[1])
						offset += elementSize-2
						buffer.writeu8(buff, offset, val[2])
						offset += 2
					end
	
					redactedPackage[scope] = { buff, elementSize }
				end

				event:FireClient(player, redactedPackage)
			end
		end

		connection = event.OnServerEvent:Connect(function(player, data) --scope, buff, strLen

			for scope, vals in pairs(data) do

				local buff = vals[1]
				local elementSize = vals[2]

				local strLen = buffer.readu8(buff, elementSize-2)

				for i = 0, buffer.len(buff)-1, elementSize do
					local newBuff = buffer.create(elementSize)
					buffer.copy(newBuff, 0, buff, i, elementSize)

					local value = DataTransfer:Decode(newBuff, strLen)

					--print(value, i, buffer.len(buff))
			
					for _, connection in pairs(customEvent['_connections']) do
						connection(scope, player, table.unpack(value))
					end
		
					for _, info in pairs(customEvent['_waitConnections'][scope] or {}) do
						info.isFinished = true
					end
				end

			end

			--print(player, scope, buff, strLen)


		end)
	end
	
	customEvent['RBXConnection'] = connection
end

local function constructor(name: string, isBindable: boolean?)
	local foundInstance = Events:FindFirstChild(name)
	if (RunService:IsClient() and (not foundInstance) and (not isBindable)) then 
		warn(name..' No event'); return 
	end
	
	local self = setmetatable(
		{
			Name = name,
			IsBindable = isBindable or false,
			Instance = foundInstance,
			_connections = {},
			_waitConnections = {},
			RBXConnection = nil,
		},
		{__index = function(t, i)
			return Event[i]
		end}
	)
	
	if (RunService:IsServer() and (not foundInstance) and (not isBindable)) then
		foundInstance = Instance.new('RemoteEvent')
		foundInstance.Name = name
		foundInstance.Parent = Events
		
		self.Instance = foundInstance
	end
	
	CustomEvents[name] = self
	
	if (not isBindable) then eventConnection(name) end
	
	return self
end

local SignalComponentFabric = {}

function SignalComponentFabric:GetSignal(name: string, isBindable: boolean?): typeof(Event)
	if (not CustomEvents[name]) then return constructor(name, isBindable) end
	return CustomEvents[name]
end

return SignalComponentFabric
